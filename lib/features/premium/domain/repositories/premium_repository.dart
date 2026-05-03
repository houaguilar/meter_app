import 'package:fpdart/fpdart.dart';
import 'package:meter_app/domain/entities/premium/premium_status.dart';
import 'package:meter_app/domain/entities/premium/purchase_result.dart';
import 'package:meter_app/core/constants/error/failures.dart';

abstract interface class PremiumRepository {
  // Estado premium
  Future<Either<Failure, PremiumStatus>> getPremiumStatus();
  Stream<PremiumStatus> watchPremiumStatus();

  // Compras
  Future<Either<Failure, PurchaseResult>> purchaseMonthlySubscription();
  Future<Either<Failure, PurchaseResult>> restorePurchases();

  // Mock específico
  Future<Either<Failure, PurchaseResult>> grantTrialPremium();
  Future<Either<Failure, void>> forceExpiration();
  Future<Either<Failure, void>> clearAllSubscriptions();

  // Sincronización
  Future<Either<Failure, void>> syncWithSupabase();
  Future<Either<Failure, void>> syncFromSupabase();
}