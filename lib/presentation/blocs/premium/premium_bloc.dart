import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../config/app_config.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../../domain/entities/premium/purchase_result.dart';
import '../../../domain/repositories/premium/premium_repository.dart';

part 'premium_event.dart';
part 'premium_state.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final PremiumRepository premiumRepository;
  StreamSubscription<PremiumStatus>? _statusSubscription;

  PremiumBloc({
    required this.premiumRepository,
  }) : super(PremiumInitial()) {
    on<LoadPremiumStatus>(_onLoadPremiumStatus);
    on<PurchaseMonthlySubscription>(_onPurchaseMonthlySubscription);
    on<RestorePurchases>(_onRestorePurchases);
    on<GrantTrialPremium>(_onGrantTrialPremium);
    on<ForceExpiration>(_onForceExpiration);
    on<ClearAllSubscriptions>(_onClearAllSubscriptions);
    on<SyncWithSupabase>(_onSyncWithSupabase);
    on<PremiumStatusUpdated>(_onPremiumStatusUpdated);
    on<RefreshPremiumStatus>(_onRefreshPremiumStatus);

    // Inicializar escucha de cambios
    _listenToStatusChanges();
  }

  void _listenToStatusChanges() {
    _statusSubscription = premiumRepository.watchPremiumStatus().listen(
          (status) => add(PremiumStatusUpdated(status)),
      onError: (error) {
        if (state is PremiumLoaded) {
          final currentState = state as PremiumLoaded;
          emit(PremiumError(
            message: 'Error observando premium status: $error',
            lastKnownStatus: currentState.status,
          ));
        }
      },
    );
  }

  Future<void> _onLoadPremiumStatus(
      LoadPremiumStatus event,
      Emitter<PremiumState> emit,
      ) async {
    emit(PremiumLoading());

    final result = await premiumRepository.getPremiumStatus();

    result.fold(
          (failure) => emit(PremiumError(message: failure.message)),
          (status) => emit(PremiumLoaded(status: status)),
    );
  }

  Future<void> _onPurchaseMonthlySubscription(
      PurchaseMonthlySubscription event,
      Emitter<PremiumState> emit,
      ) async {
    final currentStatus = _getCurrentStatus();
    if (currentStatus == null) return;

    emit(PurchaseInProgress(currentStatus));

    final result = await premiumRepository.purchaseMonthlySubscription();

    result.fold(
          (failure) => emit(PurchaseFailure(
        message: failure.message,
        currentStatus: currentStatus,
      )),
          (purchaseResult) async {
        if (purchaseResult.isSuccess && purchaseResult.premiumStatus != null) {
          emit(PurchaseSuccess(
            result: purchaseResult,
            newStatus: purchaseResult.premiumStatus!,
          ));

          // AGREGAR: Refrescar después de compra exitosa
          await Future.delayed(const Duration(seconds: 1));
          add(RefreshPremiumStatus());

        } else if (purchaseResult.isCancelled) {
          emit(PremiumLoaded(status: currentStatus));
        } else {
          emit(PurchaseFailure(
            message: purchaseResult.message ?? 'Error desconocido',
            currentStatus: currentStatus,
          ));
        }
      },
    );
  }

  Future<void> _onRestorePurchases(
      RestorePurchases event,
      Emitter<PremiumState> emit,
      ) async {
    final currentStatus = _getCurrentStatus();
    if (currentStatus == null) return;

    emit(PremiumLoaded(status: currentStatus, isPerformingAction: true));

    final result = await premiumRepository.restorePurchases();

    result.fold(
          (failure) => emit(PurchaseFailure(
        message: failure.message,
        currentStatus: currentStatus,
      )),
          (purchaseResult) {
        if (purchaseResult.isSuccess && purchaseResult.premiumStatus != null) {
          emit(PremiumLoaded(status: purchaseResult.premiumStatus!));
        } else {
          emit(PurchaseFailure(
            message: purchaseResult.message ?? 'No se encontraron compras previas',
            currentStatus: currentStatus,
          ));
        }
      },
    );
  }

  Future<void> _onGrantTrialPremium(
      GrantTrialPremium event,
      Emitter<PremiumState> emit,
      ) async {
    if (!AppConfig.isDevelopment) {
      emit(const PremiumError(message: 'Trial solo disponible en modo desarrollo'));
      return;
    }

    final currentStatus = _getCurrentStatus();
    if (currentStatus == null) return;

    emit(PremiumLoaded(status: currentStatus, isPerformingAction: true));

    final result = await premiumRepository.grantTrialPremium();

    result.fold(
          (failure) => emit(PurchaseFailure(
        message: failure.message,
        currentStatus: currentStatus,
      )),
          (purchaseResult) {
        if (purchaseResult.isSuccess && purchaseResult.premiumStatus != null) {
          emit(PremiumLoaded(status: purchaseResult.premiumStatus!));
        } else {
          emit(PurchaseFailure(
            message: purchaseResult.message ?? 'Error otorgando trial',
            currentStatus: currentStatus,
          ));
        }
      },
    );
  }

  Future<void> _onForceExpiration(
      ForceExpiration event,
      Emitter<PremiumState> emit,
      ) async {
    if (!AppConfig.isDevelopment) {
      emit(const PremiumError(message: 'Force expiration solo disponible en modo desarrollo'));
      return;
    }

    final currentStatus = _getCurrentStatus();
    if (currentStatus == null) return;

    emit(PremiumLoaded(status: currentStatus, isPerformingAction: true));

    final result = await premiumRepository.forceExpiration();

    result.fold(
          (failure) => emit(PremiumError(
        message: failure.message,
        lastKnownStatus: currentStatus,
      )),
          (_) => {}, // El estado se actualizará automáticamente via stream
    );
  }

  Future<void> _onClearAllSubscriptions(
      ClearAllSubscriptions event,
      Emitter<PremiumState> emit,
      ) async {
    if (!AppConfig.isDevelopment) {
      emit(const PremiumError(message: 'Clear subscriptions solo disponible en modo desarrollo'));
      return;
    }

    final currentStatus = _getCurrentStatus();
    if (currentStatus == null) return;

    emit(PremiumLoaded(status: currentStatus, isPerformingAction: true));

    final result = await premiumRepository.clearAllSubscriptions();

    result.fold(
          (failure) => emit(PremiumError(
        message: failure.message,
        lastKnownStatus: currentStatus,
      )),
          (_) => {}, // El estado se actualizará automáticamente via stream
    );
  }

  Future<void> _onSyncWithSupabase(
      SyncWithSupabase event,
      Emitter<PremiumState> emit,
      ) async {
    final currentStatus = _getCurrentStatus();
    if (currentStatus == null) return;

    emit(PremiumLoaded(status: currentStatus, isPerformingAction: true));

    final result = await premiumRepository.syncFromSupabase();

    result.fold(
          (failure) => emit(PremiumError(
        message: failure.message,
        lastKnownStatus: currentStatus,
      )),
          (_) => {}, // El estado se actualizará automáticamente via stream
    );
  }

  void _onPremiumStatusUpdated(
      PremiumStatusUpdated event,
      Emitter<PremiumState> emit,
      ) {
    emit(PremiumLoaded(status: event.status));
  }

  PremiumStatus? _getCurrentStatus() {
    if (state is PremiumLoaded) {
      return (state as PremiumLoaded).status;
    } else if (state is PurchaseInProgress) {
      return (state as PurchaseInProgress).currentStatus;
    } else if (state is PurchaseFailure) {
      return (state as PurchaseFailure).currentStatus;
    } else if (state is PremiumError) {
      return (state as PremiumError).lastKnownStatus;
    }
    return null;
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRefreshPremiumStatus(
      RefreshPremiumStatus event,
      Emitter<PremiumState> emit,
      ) async {
    // Forzar una nueva carga desde Supabase
    final result = await premiumRepository.syncFromSupabase();
    result.fold(
          (failure) => print('Error refrescando premium status: ${failure.message}'),
          (_) => print('Premium status refrescado exitosamente'),
    );
  }

  void forceRefresh() {
    add(LoadPremiumStatus());
  }
}