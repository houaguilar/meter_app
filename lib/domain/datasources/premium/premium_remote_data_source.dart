
import '../../../data/models/premium/premium_status_model.dart';

abstract interface class PremiumRemoteDataSource {
  Future<PremiumStatusModel> getPremiumStatus(String userId);
  Future<void> updatePremiumStatus(String userId, PremiumStatusModel status);
  Stream<PremiumStatusModel> watchPremiumStatus(String userId);
}