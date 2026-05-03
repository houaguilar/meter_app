part of 'premium_bloc.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object?> get props => [];
}

class LoadPremiumStatus extends PremiumEvent {}

class PurchaseMonthlySubscription extends PremiumEvent {}

class RestorePurchases extends PremiumEvent {}

class GrantTrialPremium extends PremiumEvent {}

class ForceExpiration extends PremiumEvent {}

class ClearAllSubscriptions extends PremiumEvent {}

class SyncWithSupabase extends PremiumEvent {}

class RefreshPremiumStatus extends PremiumEvent {}

class PremiumStatusUpdated extends PremiumEvent {
  final PremiumStatus status;

  const PremiumStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}