import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_config.dart';
import '../../../config/constants/error/exceptions.dart';
import '../../../config/utils/app_logger.dart';
import '../../../domain/datasources/premium/premium_service_data_source.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../../domain/entities/premium/purchase_result.dart';
import '../../models/premium/premium_status_model.dart';

class MockPremiumServiceImpl implements PremiumServiceDataSource {
  final SupabaseClient supabaseClient;
  final StreamController<PremiumStatus> _statusController = StreamController.broadcast();

  PremiumStatus _currentStatus = PremiumStatus.free();
  String? _currentUserId;

  MockPremiumServiceImpl(this.supabaseClient) {
    _initializeCurrentUser();
  }

  void _initializeCurrentUser() {
    _currentUserId = supabaseClient.auth.currentUser?.id;
    AppLogger.premium.i('🎭 Mock Service: Inicializando con userId: $_currentUserId');

    if (_currentUserId != null) {
      _loadCurrentStatus();
    } else {
      AppLogger.premium.w('🎭 Mock Service: No hay usuario autenticado');
    }
  }

  Future<void> _loadCurrentStatus() async {
    if (_currentUserId == null) return;

    try {
      AppLogger.premium.d('🎭 Mock Service: Cargando status para usuario: $_currentUserId');

      final response = await supabaseClient
          .from('profiles')
          .select('is_premium, premium_until, premium_source, entitlement_id')
          .eq('id', _currentUserId!)
          .maybeSingle();

      if (response == null) {
        AppLogger.premium.w('🎭 Mock Service: No se encontró perfil, usando estado gratuito');
        _currentStatus = PremiumStatus.free();
      } else {
        AppLogger.premium.d('🎭 Mock Service: Datos de Supabase: $response');

        _currentStatus = PremiumStatus(
          isPremium: response['is_premium'] ?? false,
          premiumUntil: response['premium_until'] != null
              ? DateTime.parse(response['premium_until'])
              : null,
          source: _sourceFromString(response['premium_source'] ?? 'none'),
          entitlementId: response['entitlement_id'],
          lastVerifiedAt: DateTime.now(),
        );

        AppLogger.premium.d('🎭 Mock Service: Status cargado: ${_currentStatus.toString()}');
      }

      _statusController.add(_currentStatus);
    } catch (e) {
      AppLogger.premium.e('Error cargando status mock: $e');
      _currentStatus = PremiumStatus.free();
      _statusController.add(_currentStatus);
    }
  }

  @override
  Future<PurchaseResult> purchaseMonthlySubscription() async {
    AppLogger.premium.i('🎭 Mock Service: Iniciando compra mensual...');

    // Verificar usuario actual
    _currentUserId = supabaseClient.auth.currentUser?.id;
    AppLogger.premium.d('🎭 Mock Service: Usuario actual: $_currentUserId');

    if (_currentUserId == null) {
      AppLogger.premium.e('🎭 Mock Service: ERROR - No hay usuario autenticado');
      return PurchaseResult.error('Usuario no autenticado');
    }

    await _simulateDelay(AppConfig.mockPurchaseDelay);

    // Simular posible error (10% de probabilidad)
    if (_shouldSimulateError()) {
      AppLogger.premium.w('🎭 Mock Service: Simulando error de pago');
      return PurchaseResult.error('Error simulado de pago mock');
    }

    // Simular cancelación de usuario (5% de probabilidad)
    if (_shouldSimulateCancellation()) {
      AppLogger.premium.i('🎭 Mock Service: Simulando cancelación de usuario');
      return PurchaseResult.userCancelled();
    }

    // Simular compra exitosa
    AppLogger.premium.i('🎭 Mock Service: Procesando compra exitosa...');
    final newStatus = PremiumStatus.mockPurchase(days: 30);
    AppLogger.premium.d('🎭 Mock Service: Nuevo status creado: ${newStatus.toString()}');

    try {
      await _updateStatus(newStatus);
      AppLogger.premium.i('🎭 Mock Service: Status actualizado exitosamente');

      final result = PurchaseResult.success(
        newStatus,
        transactionId: 'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
        purchaseDate: DateTime.now(),
      );

      AppLogger.premium.d('🎭 Mock Service: Resultado de compra: ${result.toString()}');
      return result;

    } catch (e) {
      AppLogger.premium.e('🎭 Mock Service: ERROR actualizando status: $e');
      return PurchaseResult.error('Error actualizando premium status: $e');
    }
  }
  @override
  Future<PurchaseResult> restorePurchases() async {
    await _simulateDelay(const Duration(seconds: 1));

    // Simular restauración basada en el estado actual
    if (_currentStatus.source.isMock && _currentStatus.isActive) {
      return PurchaseResult.success(_currentStatus);
    }

    // Si no hay compras previas, simular 50% de probabilidad de encontrar una
    if (Random().nextBool()) {
      final restoredStatus = PremiumStatus.mockPurchase(days: 15);
      await _updateStatus(restoredStatus);
      return PurchaseResult.success(restoredStatus);
    }

    return PurchaseResult.error('No se encontraron compras previas');
  }

  @override
  Future<PurchaseResult> grantTrialPremium() async {
    AppLogger.premium.i('🎭 Mock Service: Otorgando trial premium...');

    _currentUserId = supabaseClient.auth.currentUser?.id;
    AppLogger.premium.d('🎭 Mock Service: Usuario para trial: $_currentUserId');

    if (_currentUserId == null) {
      return PurchaseResult.error('Usuario no autenticado');
    }

    await _simulateDelay(const Duration(milliseconds: 500));

    // Verificar si ya tuvo trial
    if (_currentStatus.source == PremiumSource.mockTrial) {
      AppLogger.premium.w('🎭 Mock Service: Usuario ya tuvo trial');
      return PurchaseResult.error('Ya utilizaste tu período de prueba');
    }

    final trialStatus = PremiumStatus.mockTrial(days: AppConfig.mockTrialDays);
    AppLogger.premium.d('🎭 Mock Service: Status de trial creado: ${trialStatus.toString()}');

    try {
      await _updateStatus(trialStatus);
      AppLogger.premium.i('🎭 Mock Service: Trial otorgado exitosamente');

      return PurchaseResult.success(trialStatus);
    } catch (e) {
      AppLogger.premium.e('🎭 Mock Service: ERROR otorgando trial: $e');
      return PurchaseResult.error('Error otorgando trial: $e');
    }
  }

  @override
  Future<void> forceExpiration() async {
    final expiredStatus = _currentStatus.copyWith(
      isPremium: false,
      premiumUntil: DateTime.now().subtract(const Duration(days: 1)),
    );

    await _updateStatus(expiredStatus);
  }

  @override
  Future<void> clearAllSubscriptions() async {
    await _updateStatus(PremiumStatus.free());
  }

  @override
  Future<PremiumStatusModel> getCurrentPremiumStatus() async {
    await _loadCurrentStatus(); // Refresh desde Supabase

    if (_currentUserId == null) {
      throw const ServerException('Usuario no autenticado');
    }

    return PremiumStatusModel.fromDomain(_currentUserId!, _currentStatus);
  }

  @override
  Future<void> syncWithBackend() async {
    // En mock, simplemente actualizar desde Supabase
    await _loadCurrentStatus();
  }

  // Métodos privados de utilidad
  Future<void> _updateStatus(PremiumStatus newStatus) async {
    // Always get fresh userId
    _currentUserId = supabaseClient.auth.currentUser?.id;

    if (_currentUserId == null) {
      throw const ServerException('Usuario no autenticado');
    }

    try {
      AppLogger.premium.d('🎭 Mock Service: Actualizando status para usuario: $_currentUserId');
      AppLogger.premium.d('🎭 Mock Service: Nuevo status: ${newStatus.toString()}');

      // Actualizar en Supabase usando UPDATE directo
      final updateData = {
        'is_premium': newStatus.isPremium,
        'premium_until': newStatus.premiumUntil?.toIso8601String(),
        'premium_source': _sourceToString(newStatus.source),
        'entitlement_id': newStatus.entitlementId,
        'revenuecat_user_id': newStatus.revenueCatUserId,
        'last_verified_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await supabaseClient
          .from('profiles')
          .update(updateData)
          .eq('id', _currentUserId!)
          .select();

      AppLogger.premium.d('🎭 Mock Service: Resultado de actualización: $result');

      _currentStatus = newStatus.copyWith(lastVerifiedAt: DateTime.now());
      _statusController.add(_currentStatus);

      AppLogger.premium.i('🎭 MOCK: Premium status actualizado exitosamente');

    } catch (e) {
      AppLogger.premium.e('🎭 Mock Service Error actualizando: $e');
      throw ServerException('Error actualizando status mock: $e');
    }
  }

  Future<void> _simulateDelay(Duration delay) async {
    await Future.delayed(delay);
  }

  bool _shouldSimulateError() => Random().nextInt(100) < 10; // 10%
  bool _shouldSimulateCancellation() => Random().nextInt(100) < 5; // 5%

  PremiumSource _sourceFromString(String source) {
    switch (source) {
      case 'mock_trial': return PremiumSource.mockTrial;
      case 'mock_purchase': return PremiumSource.mockPurchase;
      case 'revenuecat': return PremiumSource.revenueCat;
      default: return PremiumSource.none;
    }
  }

  String _sourceToString(PremiumSource source) {
    switch (source) {
      case PremiumSource.mockTrial: return 'mock_trial';
      case PremiumSource.mockPurchase: return 'mock_purchase';
      case PremiumSource.revenueCat: return 'revenuecat';
      case PremiumSource.none: return 'none';
    }
  }

  Stream<PremiumStatus> get statusStream => _statusController.stream;

  void dispose() {
    _statusController.close();
  }
}