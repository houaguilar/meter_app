part of 'premium_bloc.dart';

abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object?> get props => [];
}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumLoaded extends PremiumState {
  final PremiumStatus status;
  final bool isPerformingAction;

  const PremiumLoaded({
    required this.status,
    this.isPerformingAction = false,
  });

  @override
  List<Object> get props => [status, isPerformingAction];

  PremiumLoaded copyWith({
    PremiumStatus? status,
    bool? isPerformingAction,
  }) {
    return PremiumLoaded(
      status: status ?? this.status,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }
}

class PremiumError extends PremiumState {
  final String message;
  final PremiumStatus? lastKnownStatus;

  const PremiumError({
    required this.message,
    this.lastKnownStatus,
  });

  @override
  List<Object?> get props => [message, lastKnownStatus];
}

class PurchaseInProgress extends PremiumState {
  final PremiumStatus currentStatus;

  const PurchaseInProgress(this.currentStatus);

  @override
  List<Object> get props => [currentStatus];
}

class PurchaseSuccess extends PremiumState {
  final PurchaseResult result;
  final PremiumStatus newStatus;

  const PurchaseSuccess({
    required this.result,
    required this.newStatus,
  });

  @override
  List<Object> get props => [result, newStatus];
}

class PurchaseFailure extends PremiumState {
  final String message;
  final PremiumStatus currentStatus;

  const PurchaseFailure({
    required this.message,
    required this.currentStatus,
  });

  @override
  List<Object> get props => [message, currentStatus];
}