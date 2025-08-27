
import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rxdart/rxdart.dart';
import '../../../config/constants/error/failures.dart';
import '../../../domain/datasources/premium/premium_local_data_source.dart';
import '../../../domain/datasources/premium/premium_remote_data_source.dart';
import '../../../domain/datasources/premium/premium_service_data_source.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../../domain/entities/premium/purchase_result.dart';
import '../../../domain/repositories/premium/premium_repository.dart';
import '../../models/premium/premium_status_model.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumServiceDataSource serviceDataSource;
  final PremiumRemoteDataSource remoteDataSource;
  final PremiumLocalDataSource localDataSource;
  final InternetConnection connectionChecker;

  final BehaviorSubject<PremiumStatus> _statusController = BehaviorSubject<PremiumStatus>();
  String? _currentUserId;
  Timer? _syncTimer;

  PremiumRepositoryImpl({
    required this.serviceDataSource,
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  }) {
    _initializeSync();
  }

  void _initializeSync() {
    // Sincronización periódica cada 5 minutos
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _syncInBackground();
    });
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  @override
  Future<Either<Failure, PremiumStatus>> getPremiumStatus() async {
    if (_currentUserId == null) {
      return left(Failure(message: 'Usuario no autenticado'));
    }

    try {
      // 1. Intentar cache local primero
      final cached = await localDataSource.getCachedPremiumStatus(_currentUserId!);

      // 2. Si hay cache y es reciente (< 1 hora), usarlo
      if (cached != null && _isCacheValid(cached)) {
        final status = cached.toDomain();
        _statusController.add(status);

        // Sincronizar en background
        _syncInBackground();

        return right(status);
      }

      // 3. Si hay internet, sincronizar desde remoto
      if (await connectionChecker.hasInternetAccess) {
        return await _syncFromRemoteAndCache();
      }

      // 4. Si no hay internet, usar cache aunque sea viejo
      if (cached != null) {
        final status = cached.toDomain();
        _statusController.add(status);
        return right(status);
      }

      // 5. Si no hay nada, devolver estado gratuito
      final freeStatus = PremiumStatus.free();
      _statusController.add(freeStatus);
      return right(freeStatus);

    } catch (e) {
      return left(Failure(message: 'Error obteniendo premium status: $e'));
    }
  }

  @override
  Stream<PremiumStatus> watchPremiumStatus() {
    if (_currentUserId == null) {
      return Stream.value(PremiumStatus.free());
    }

    // Combinar streams usando rxdart
    return CombineLatestStream.list([
      _statusController.stream,
      localDataSource.watchCachedPremiumStatus(_currentUserId!)
          .map((model) => model?.toDomain() ?? PremiumStatus.free()),
      remoteDataSource.watchPremiumStatus(_currentUserId!)
          .map((model) => model.toDomain())
          .onErrorReturn(PremiumStatus.free()), // Manejar errores del stream remoto
    ]).map((statusList) {
      // Priorizar status premium activo, luego el más reciente
      final activeStatus = statusList.firstWhere(
            (status) => status.isActive,
        orElse: () => statusList.first,
      );
      return activeStatus;
    }).distinct();
  }

  @override
  Future<Either<Failure, PurchaseResult>> purchaseMonthlySubscription() async {
    try {
      final result = await serviceDataSource.purchaseMonthlySubscription();

      if (result.isSuccess && result.premiumStatus != null) {
        await _updateCacheAndRemote(result.premiumStatus!);
      }

      return right(result);
    } catch (e) {
      return left(Failure(message: 'Error en compra: $e'));
    }
  }

  @override
  Future<Either<Failure, PurchaseResult>> restorePurchases() async {
    try {
      final result = await serviceDataSource.restorePurchases();

      if (result.isSuccess && result.premiumStatus != null) {
        await _updateCacheAndRemote(result.premiumStatus!);
      }

      return right(result);
    } catch (e) {
      return left(Failure(message: 'Error restaurando compras: $e'));
    }
  }

  @override
  Future<Either<Failure, PurchaseResult>> grantTrialPremium() async {
    try {
      final result = await serviceDataSource.grantTrialPremium();

      if (result.isSuccess && result.premiumStatus != null) {
        await _updateCacheAndRemote(result.premiumStatus!);
      }

      return right(result);
    } catch (e) {
      return left(Failure(message: 'Error otorgando trial: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forceExpiration() async {
    try {
      await serviceDataSource.forceExpiration();
      await syncFromSupabase();
      return right(null);
    } catch (e) {
      return left(Failure(message: 'Error forzando expiración: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllSubscriptions() async {
    try {
      await serviceDataSource.clearAllSubscriptions();
      if (_currentUserId != null) {
        await localDataSource.clearPremiumCache(_currentUserId!);
      }
      _statusController.add(PremiumStatus.free());
      return right(null);
    } catch (e) {
      return left(Failure(message: 'Error limpiando suscripciones: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncWithSupabase() async {
    try {
      await serviceDataSource.syncWithBackend();
      return right(null);
    } catch (e) {
      return left(Failure(message: 'Error sincronizando: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncFromSupabase() async {
    return await _syncFromRemoteAndCache().then(
          (result) => result.fold(
            (failure) => left(failure),
            (status) => right(null),
      ),
    );
  }

  // Métodos privados
  Future<Either<Failure, PremiumStatus>> _syncFromRemoteAndCache() async {
    if (_currentUserId == null) {
      return left(Failure(message: 'Usuario no autenticado'));
    }

    try {
      final remoteStatus = await remoteDataSource.getPremiumStatus(_currentUserId!);
      await localDataSource.cachePremiumStatus(_currentUserId!, remoteStatus);

      final status = remoteStatus.toDomain();
      _statusController.add(status);

      return right(status);
    } catch (e) {
      return left(Failure(message: 'Error sincronizando desde remoto: $e'));
    }
  }

  Future<void> _updateCacheAndRemote(PremiumStatus status) async {
    if (_currentUserId == null) return;

    try {
      final model = PremiumStatusModel.fromDomain(_currentUserId!, status);

      // Actualizar cache local
      await localDataSource.cachePremiumStatus(_currentUserId!, model);

      // Actualizar remoto si hay internet
      if (await connectionChecker.hasInternetAccess) {
        await remoteDataSource.updatePremiumStatus(_currentUserId!, model);
      }

      _statusController.add(status);
    } catch (e) {
      print('Error actualizando cache y remoto: $e');
    }
  }

  bool _isCacheValid(PremiumStatusModel cached) {
    if (cached.lastVerifiedAt == null) return false;

    final cacheAge = DateTime.now().difference(cached.lastVerifiedAt!);
    return cacheAge.inHours < 1; // Cache válido por 1 hora
  }

  void _syncInBackground() {
    if (_currentUserId != null) {
      _syncFromRemoteAndCache().catchError((error) {
        print('Error en sincronización background: $error');
      });
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _statusController.close();
  }
}