
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
// NOTA: Descomenta estas líneas cuando agregues RevenueCat a pubspec.yaml
// import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../config/app_config.dart';
import '../../../config/constants/error/exceptions.dart';
import '../../../domain/datasources/premium/premium_service_data_source.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../../domain/entities/premium/purchase_result.dart';
import '../../models/premium/premium_status_model.dart';

class RevenueCatServiceImpl implements PremiumServiceDataSource {
  final SupabaseClient supabaseClient;
  String? _currentUserId;

  RevenueCatServiceImpl(this.supabaseClient) {
    _initializeRevenueCat();
  }

  Future<void> _initializeRevenueCat() async {
    _currentUserId = supabaseClient.auth.currentUser?.id;

    if (_currentUserId == null) {
      throw const ServerException('Usuario no autenticado');
    }

    try {
      // TODO: Descomenta cuando agregues RevenueCat
      /*
      await Purchases.setDebugLogsEnabled(true);
      await Purchases.configure(
        PurchasesConfiguration(AppConfig.revenueCatApiKey)
          ..appUserID = _currentUserId
      );

      // Configurar atributos del usuario
      await Purchases.setAttributes({
        'user_id': _currentUserId!,
        'platform': 'flutter',
      });
      */

      print('RevenueCat inicializado para usuario: $_currentUserId');
    } catch (e) {
      throw ServerException('Error inicializando RevenueCat: $e');
    }
  }

  @override
  Future<PurchaseResult> purchaseMonthlySubscription() async {
    try {
      // TODO: Implementar con RevenueCat real
      /*
      final offerings = await Purchases.getOfferings();
      final defaultOffering = offerings.getOffering(AppConfig.defaultOffering);

      if (defaultOffering == null) {
        return PurchaseResult.error('No se encontró la oferta de suscripción');
      }

      final monthlyPackage = defaultOffering.monthly;
      if (monthlyPackage == null) {
        return PurchaseResult.error('Suscripción mensual no disponible');
      }

      final purchaserInfo = await Purchases.purchasePackage(monthlyPackage);

      if (purchaserInfo.entitlements.all[AppConfig.premiumEntitlement]?.isActive == true) {
        final entitlement = purchaserInfo.entitlements.all[AppConfig.premiumEntitlement]!;

        final premiumStatus = PremiumStatus(
          isPremium: true,
          premiumUntil: entitlement.expirationDate,
          source: PremiumSource.revenueCat,
          entitlementId: AppConfig.premiumEntitlement,
          revenueCatUserId: _currentUserId,
          lastVerifiedAt: DateTime.now(),
        );

        return PurchaseResult.success(
          premiumStatus,
          transactionId: entitlement.latestPurchaseDate?.millisecondsSinceEpoch.toString(),
          purchaseDate: entitlement.latestPurchaseDate,
        );
      }
      */

      // Placeholder para desarrollo sin RevenueCat
      throw const ServerException('RevenueCat no configurado - usar modo mock');

    } catch (e) {
      if (e.toString().contains('user_cancelled')) {
        return PurchaseResult.userCancelled();
      }
      return PurchaseResult.error('Error en la compra: $e');
    }
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    try {
      // TODO: Implementar con RevenueCat real
      /*
      final purchaserInfo = await Purchases.restorePurchases();

      if (purchaserInfo.entitlements.all[AppConfig.premiumEntitlement]?.isActive == true) {
        final entitlement = purchaserInfo.entitlements.all[AppConfig.premiumEntitlement]!;

        final premiumStatus = PremiumStatus(
          isPremium: true,
          premiumUntil: entitlement.expirationDate,
          source: PremiumSource.revenueCat,
          entitlementId: AppConfig.premiumEntitlement,
          revenueCatUserId: _currentUserId,
          lastVerifiedAt: DateTime.now(),
        );

        return PurchaseResult.success(premiumStatus);
      }

      return PurchaseResult.error('No se encontraron compras previas');
      */

      throw const ServerException('RevenueCat no configurado - usar modo mock');

    } catch (e) {
      return PurchaseResult.error('Error restaurando compras: $e');
    }
  }

  @override
  Future<PremiumStatusModel> getCurrentPremiumStatus() async {
    try {
      // TODO: Implementar con RevenueCat real
      /*
      final purchaserInfo = await Purchases.getPurchaserInfo();
      final entitlement = purchaserInfo.entitlements.all[AppConfig.premiumEntitlement];

      final premiumStatus = PremiumStatus(
        isPremium: entitlement?.isActive == true,
        premiumUntil: entitlement?.expirationDate,
        source: PremiumSource.revenueCat,
        entitlementId: entitlement?.identifier,
        revenueCatUserId: _currentUserId,
        lastVerifiedAt: DateTime.now(),
      );

      return PremiumStatusModel.fromDomain(_currentUserId!, premiumStatus);
      */

      throw const ServerException('RevenueCat no configurado - usar modo mock');

    } catch (e) {
      throw ServerException('Error obteniendo status de RevenueCat: $e');
    }
  }

  @override
  Future<void> syncWithBackend() async {
    try {
      // TODO: Implementar sincronización con RevenueCat
      /*
      await Purchases.syncPurchases();
      */
      print('Sincronización con RevenueCat completada');
    } catch (e) {
      throw ServerException('Error sincronizando con RevenueCat: $e');
    }
  }

  // Métodos no aplicables para RevenueCat
  @override
  Future<PurchaseResult> grantTrialPremium() async {
    throw const ServerException('Trial no disponible en modo RevenueCat');
  }

  @override
  Future<void> forceExpiration() async {
    throw const ServerException('Force expiration no disponible en modo RevenueCat');
  }

  @override
  Future<void> clearAllSubscriptions() async {
    throw const ServerException('Clear subscriptions no disponible en modo RevenueCat');
  }
}