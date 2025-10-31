import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_config.dart';
import '../../../config/constants/error/exceptions.dart';
import '../../../config/utils/app_logger.dart';
import '../../../domain/datasources/premium/premium_service_data_source.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../../domain/entities/premium/purchase_result.dart' as domain;
import '../../models/premium/premium_status_model.dart';

/// Implementación de PremiumServiceDataSource usando RevenueCat
///
/// Esta clase maneja todas las interacciones con RevenueCat SDK
/// incluyendo compras, restauración y sincronización con Supabase
class RevenueCatServiceImpl implements PremiumServiceDataSource {
  final SupabaseClient supabaseClient;
  String? _currentUserId;
  bool _isInitialized = false;

  RevenueCatServiceImpl(this.supabaseClient) {
    _initializeRevenueCat();
  }

  Future<void> _initializeRevenueCat() async {
    try {
      _currentUserId = supabaseClient.auth.currentUser?.id;

      if (_currentUserId == null) {
        AppLogger.premium.w('⚠️ RevenueCat: Usuario no autenticado, inicialización pospuesta');
        return;
      }

      AppLogger.premium.i('🚀 Inicializando RevenueCat...');
      AppLogger.premium.d('Entorno: ${AppConfig.currentEnvironment}');
      AppLogger.premium.d('Usuario: $_currentUserId');

      // Configurar debug logs
      await Purchases.setLogLevel(
        AppConfig.enableRevenueCatDebugLogs ? LogLevel.debug : LogLevel.info,
      );

      // Obtener API key según plataforma y entorno
      final apiKey = AppConfig.getRevenueCatApiKey();

      // Configurar RevenueCat con la nueva API
      final configuration = PurchasesConfiguration(apiKey);

      if (_currentUserId != null) {
        await Purchases.configure(configuration);
        await Purchases.logIn(_currentUserId!);
      } else {
        await Purchases.configure(configuration);
      }

      // Configurar atributos del usuario para analytics
      await Purchases.setAttributes({
        'user_id': _currentUserId!,
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'environment': AppConfig.currentEnvironment.name,
      });

      // Listener para cambios en el estado de compra
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);

      _isInitialized = true;
      AppLogger.premium.i('✅ RevenueCat inicializado correctamente');

    } catch (e, stackTrace) {
      AppLogger.premium.errorWithDetails(
        '❌ Error inicializando RevenueCat',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Error inicializando RevenueCat: $e');
    }
  }

  /// Callback que se ejecuta cuando hay cambios en CustomerInfo
  void _onCustomerInfoUpdate(CustomerInfo customerInfo) {
    AppLogger.premium.d('🔄 CustomerInfo actualizado desde RevenueCat');
    _syncCustomerInfoToSupabase(customerInfo);
  }

  @override
  Future<domain.PurchaseResult> purchaseMonthlySubscription() async {
    try {
      _ensureInitialized();

      AppLogger.premium.i('💳 Iniciando compra de suscripción mensual...');

      // Obtener offerings disponibles
      final offerings = await Purchases.getOfferings();
      AppLogger.premium.d('Offerings disponibles: ${offerings.all.keys}');

      final offering = offerings.current;
      if (offering == null) {
        AppLogger.premium.w('⚠️ No hay offering activo');
        return domain.PurchaseResult.error('No hay ofertas disponibles en este momento');
      }

      // Buscar el paquete mensual
      final monthlyPackage = offering.monthly;
      if (monthlyPackage == null) {
        AppLogger.premium.w('⚠️ No hay paquete mensual disponible');

        // Intentar buscar paquete por ID
        final alternativePackage = offering.availablePackages.firstWhere(
          (p) => p.storeProduct.identifier == AppConfig.premiumProductId,
          orElse: () => throw const ServerException('Suscripción mensual no disponible'),
        );

        AppLogger.premium.d('Usando paquete alternativo: ${alternativePackage.identifier}');
        return await _processPurchase(alternativePackage);
      }

      AppLogger.premium.d('Paquete mensual encontrado: ${monthlyPackage.identifier}');
      AppLogger.premium.d('Precio: ${monthlyPackage.storeProduct.priceString}');

      return await _processPurchase(monthlyPackage);

    } on PlatformException catch (e) {
      return _handlePurchaseError(e);
    } catch (e, stackTrace) {
      AppLogger.premium.errorWithDetails(
        '❌ Error en compra',
        error: e,
        stackTrace: stackTrace,
      );
      return domain.PurchaseResult.error('Error inesperado: $e');
    }
  }

  Future<domain.PurchaseResult> _processPurchase(Package package) async {
    try {
      AppLogger.premium.d('📦 Procesando compra del paquete: ${package.identifier}');

      // Usar la nueva API de purchases
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;

      AppLogger.premium.d('CustomerInfo recibido');
      AppLogger.premium.d('Entitlements activos: ${customerInfo.entitlements.active.keys}');

      // Verificar si el entitlement premium está activo
      final entitlement = customerInfo.entitlements.all[AppConfig.premiumEntitlement];

      if (entitlement?.isActive == true) {
        final premiumStatus = _buildPremiumStatus(entitlement!);

        AppLogger.premium.i('✅ Compra exitosa - Premium activado');
        AppLogger.premium.d('Expira: ${premiumStatus.premiumUntil}');

        // Sincronizar con Supabase
        await _syncStatusToSupabase(premiumStatus);

        // Parsear latestPurchaseDate (es un String ISO8601)
        final purchaseDate = entitlement.latestPurchaseDate != null
            ? DateTime.tryParse(entitlement.latestPurchaseDate!)
            : null;

        return domain.PurchaseResult.success(
          premiumStatus,
          transactionId: entitlement.latestPurchaseDate,
          purchaseDate: purchaseDate,
        );
      }

      AppLogger.premium.w('⚠️ Compra procesada pero entitlement no activo');
      return domain.PurchaseResult.error('La compra se procesó pero el premium no se activó');

    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<domain.PurchaseResult> restorePurchases() async {
    try {
      _ensureInitialized();

      AppLogger.premium.i('🔄 Restaurando compras...');

      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo.entitlements.all[AppConfig.premiumEntitlement];

      if (entitlement?.isActive == true) {
        final premiumStatus = _buildPremiumStatus(entitlement!);

        AppLogger.premium.i('✅ Compras restauradas - Premium activo');

        // Sincronizar con Supabase
        await _syncStatusToSupabase(premiumStatus);

        return domain.PurchaseResult.success(premiumStatus);
      }

      AppLogger.premium.i('ℹ️ No se encontraron compras activas');
      return domain.PurchaseResult.error('No se encontraron compras previas');

    } on PlatformException catch (e) {
      AppLogger.premium.w('⚠️ Error restaurando compras: ${e.message}');
      return domain.PurchaseResult.error('Error al restaurar compras: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.premium.errorWithDetails(
        '❌ Error restaurando compras',
        error: e,
        stackTrace: stackTrace,
      );
      return domain.PurchaseResult.error('Error inesperado: $e');
    }
  }

  @override
  Future<PremiumStatusModel> getCurrentPremiumStatus() async {
    try {
      _ensureInitialized();

      AppLogger.premium.d('📊 Obteniendo status actual de RevenueCat...');

      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[AppConfig.premiumEntitlement];

      // Parsear expirationDate si existe
      DateTime? expirationDate;
      if (entitlement?.expirationDate != null) {
        expirationDate = DateTime.tryParse(entitlement!.expirationDate!);
      }

      final premiumStatus = PremiumStatus(
        isPremium: entitlement?.isActive == true,
        premiumUntil: expirationDate,
        source: PremiumSource.revenueCat,
        entitlementId: entitlement?.identifier,
        revenueCatUserId: _currentUserId,
        lastVerifiedAt: DateTime.now(),
      );

      AppLogger.premium.d('Status: ${premiumStatus.isActive ? "Premium" : "Free"}');

      if (_currentUserId == null) {
        throw const ServerException('Usuario no autenticado');
      }

      return PremiumStatusModel.fromDomain(_currentUserId!, premiumStatus);

    } catch (e, stackTrace) {
      AppLogger.premium.errorWithDetails(
        '❌ Error obteniendo status',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Error obteniendo status: $e');
    }
  }

  @override
  Future<void> syncWithBackend() async {
    try {
      _ensureInitialized();

      AppLogger.premium.d('☁️ Sincronizando con RevenueCat...');

      // Forzar sincronización de compras con las stores
      final customerInfo = await Purchases.getCustomerInfo();

      // Sincronizar con Supabase (no retorna nada)
      _syncCustomerInfoToSupabase(customerInfo);

      AppLogger.premium.i('✅ Sincronización completada');

    } catch (e, stackTrace) {
      AppLogger.premium.errorWithDetails(
        '❌ Error sincronizando',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Error sincronizando: $e');
    }
  }

  // ==================== MÉTODOS PRIVADOS ====================

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const ServerException('RevenueCat no está inicializado');
    }
  }

  PremiumStatus _buildPremiumStatus(EntitlementInfo entitlement) {
    // expirationDate es un String ISO8601, necesita parsearse
    DateTime? expirationDate;
    if (entitlement.expirationDate != null) {
      expirationDate = DateTime.tryParse(entitlement.expirationDate!);
    }

    return PremiumStatus(
      isPremium: true,
      premiumUntil: expirationDate,
      source: PremiumSource.revenueCat,
      entitlementId: AppConfig.premiumEntitlement,
      revenueCatUserId: _currentUserId,
      lastVerifiedAt: DateTime.now(),
    );
  }

  Future<void> _syncStatusToSupabase(PremiumStatus status) async {
    try {
      if (_currentUserId == null) return;

      AppLogger.premium.d('☁️ Sincronizando status con Supabase...');

      await supabaseClient.from('profiles').update({
        'is_premium': status.isPremium,
        'premium_until': status.premiumUntil?.toIso8601String(),
        'premium_source': 'revenuecat',
        'entitlement_id': status.entitlementId,
        'revenuecat_user_id': status.revenueCatUserId,
        'last_verified_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentUserId!);

      AppLogger.premium.d('✅ Status sincronizado con Supabase');

    } catch (e) {
      AppLogger.premium.w('⚠️ Error sincronizando con Supabase: $e');
      // No lanzar error, es mejor que la compra funcione aunque falle el sync
    }
  }

  void _syncCustomerInfoToSupabase(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[AppConfig.premiumEntitlement];

    // Parsear expirationDate si existe
    DateTime? expirationDate;
    if (entitlement?.expirationDate != null) {
      expirationDate = DateTime.tryParse(entitlement!.expirationDate!);
    }

    final status = PremiumStatus(
      isPremium: entitlement?.isActive == true,
      premiumUntil: expirationDate,
      source: PremiumSource.revenueCat,
      entitlementId: entitlement?.identifier,
      revenueCatUserId: _currentUserId,
      lastVerifiedAt: DateTime.now(),
    );

    _syncStatusToSupabase(status);
  }

  domain.PurchaseResult _handlePurchaseError(PlatformException e) {
    final errorCode = e.code;
    final message = e.message ?? 'Error desconocido';

    AppLogger.premium.w('⚠️ Error de compra: $errorCode - $message');

    // Códigos de error comunes de RevenueCat
    switch (errorCode) {
      case 'USER_CANCELLED':
      case 'PURCHASE_CANCELLED':
        return domain.PurchaseResult.userCancelled();

      case 'PRODUCT_ALREADY_PURCHASED':
      case 'PURCHASE_INVALID':
        return domain.PurchaseResult.error('Ya tienes una suscripción activa');

      case 'NETWORK_ERROR':
        return domain.PurchaseResult.error('Error de conexión. Verifica tu internet.');

      case 'INVALID_PURCHASE':
        return domain.PurchaseResult.error('Compra inválida. Contacta a soporte.');

      default:
        return domain.PurchaseResult.error('Error en la compra: $message');
    }
  }

  // ==================== MÉTODOS NO APLICABLES ====================

  @override
  Future<domain.PurchaseResult> grantTrialPremium() async {
    throw const ServerException(
      'Trial manual no disponible con RevenueCat. '
      'Configura trials en RevenueCat dashboard.',
    );
  }

  @override
  Future<void> forceExpiration() async {
    throw const ServerException('Force expiration no disponible con RevenueCat');
  }

  @override
  Future<void> clearAllSubscriptions() async {
    throw const ServerException('Clear subscriptions no disponible con RevenueCat');
  }
}