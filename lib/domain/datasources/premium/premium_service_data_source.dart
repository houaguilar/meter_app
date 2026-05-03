import 'package:meter_app/data/models/premium/premium_status_model.dart';
import 'package:meter_app/domain/entities/premium/purchase_result.dart';

abstract interface class PremiumServiceDataSource {
  Future<PurchaseResult> purchaseMonthlySubscription();
  Future<PurchaseResult> restorePurchases();
  Future<PremiumStatusModel> getCurrentPremiumStatus();
  Future<void> syncWithBackend();

  // Mock específico
  Future<PurchaseResult> grantTrialPremium();
  Future<void> forceExpiration();
  Future<void> clearAllSubscriptions();
}