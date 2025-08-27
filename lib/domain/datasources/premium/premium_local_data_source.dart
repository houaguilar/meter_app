import '../../../data/models/premium/premium_status_model.dart';

abstract interface class PremiumLocalDataSource {
  Future<PremiumStatusModel?> getCachedPremiumStatus(String userId);
  Future<void> cachePremiumStatus(String userId, PremiumStatusModel status);
  Future<void> clearPremiumCache(String userId);
  Stream<PremiumStatusModel?> watchCachedPremiumStatus(String userId);
}