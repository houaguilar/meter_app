
import 'package:equatable/equatable.dart';
import 'premium_status.dart';

enum PurchaseResultType {
  success,
  userCancelled,
  error,
  alreadyOwned,
  pending,
}

class PurchaseResult extends Equatable {
  final PurchaseResultType type;
  final String? message;
  final PremiumStatus? premiumStatus;
  final String? transactionId;
  final DateTime? purchaseDate;

  const PurchaseResult({
    required this.type,
    this.message,
    this.premiumStatus,
    this.transactionId,
    this.purchaseDate,
  });

  factory PurchaseResult.success(PremiumStatus premiumStatus, {
    String? transactionId,
    DateTime? purchaseDate,
  }) {
    return PurchaseResult(
      type: PurchaseResultType.success,
      premiumStatus: premiumStatus,
      transactionId: transactionId,
      purchaseDate: purchaseDate ?? DateTime.now(),
      message: 'Compra realizada exitosamente',
    );
  }

  factory PurchaseResult.userCancelled() {
    return const PurchaseResult(
      type: PurchaseResultType.userCancelled,
      message: 'Compra cancelada por el usuario',
    );
  }

  factory PurchaseResult.error(String message) {
    return PurchaseResult(
      type: PurchaseResultType.error,
      message: message,
    );
  }

  factory PurchaseResult.alreadyOwned(PremiumStatus premiumStatus) {
    return PurchaseResult(
      type: PurchaseResultType.alreadyOwned,
      premiumStatus: premiumStatus,
      message: 'Ya tienes una suscripción activa',
    );
  }

  bool get isSuccess => type == PurchaseResultType.success;
  bool get isError => type == PurchaseResultType.error;
  bool get isCancelled => type == PurchaseResultType.userCancelled;

  @override
  List<Object?> get props => [
    type,
    message,
    premiumStatus,
    transactionId,
    purchaseDate,
  ];
}