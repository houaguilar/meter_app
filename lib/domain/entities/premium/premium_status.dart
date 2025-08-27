
import 'package:equatable/equatable.dart';

enum PremiumSource {
  none,
  mockTrial,
  mockPurchase,
  revenueCat;

  String get displayName {
    switch (this) {
      case PremiumSource.none:
        return 'Ninguno';
      case PremiumSource.mockTrial:
        return 'Trial Mock';
      case PremiumSource.mockPurchase:
        return 'Compra Mock';
      case PremiumSource.revenueCat:
        return 'RevenueCat';
    }
  }

  bool get isMock => this == mockTrial || this == mockPurchase;
}

class PremiumStatus extends Equatable {
  final bool isPremium;
  final DateTime? premiumUntil;
  final PremiumSource source;
  final String? entitlementId;
  final String? revenueCatUserId;
  final DateTime? lastVerifiedAt;

  const PremiumStatus({
    required this.isPremium,
    this.premiumUntil,
    this.source = PremiumSource.none,
    this.entitlementId,
    this.revenueCatUserId,
    this.lastVerifiedAt,
  });

  // Factory para estado gratuito
  factory PremiumStatus.free() {
    return const PremiumStatus(
      isPremium: false,
      source: PremiumSource.none,
    );
  }

  // Factory para trial mock
  factory PremiumStatus.mockTrial({int days = 7}) {
    final expirationDate = DateTime.now().add(Duration(days: days));
    return PremiumStatus(
      isPremium: true,
      premiumUntil: expirationDate,
      source: PremiumSource.mockTrial,
      entitlementId: 'mock_trial',
      lastVerifiedAt: DateTime.now(),
    );
  }

  // Factory para compra mock
  factory PremiumStatus.mockPurchase({int days = 30}) {
    final expirationDate = DateTime.now().add(Duration(days: days));
    return PremiumStatus(
      isPremium: true,
      premiumUntil: expirationDate,
      source: PremiumSource.mockPurchase,
      entitlementId: 'mock_premium',
      lastVerifiedAt: DateTime.now(),
    );
  }

  // Verificar si el premium está expirado
  bool get isExpired {
    if (!isPremium) return true;
    if (premiumUntil == null) return false;
    return DateTime.now().isAfter(premiumUntil!);
  }

  // Verificar si está activo
  bool get isActive => isPremium && !isExpired;

  // Días restantes
  int? get daysRemaining {
    if (!isPremium || premiumUntil == null) return null;
    final remaining = premiumUntil!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // Tiempo restante formateado
  String get timeRemainingFormatted {
    if (!isPremium || premiumUntil == null) return 'No disponible';

    final now = DateTime.now();
    if (now.isAfter(premiumUntil!)) return 'Expirado';

    final difference = premiumUntil!.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      return '$days días restantes';
    } else if (hours > 0) {
      return '$hours horas restantes';
    } else {
      return 'Menos de 1 hora';
    }
  }

  // CopyWith para actualizaciones
  PremiumStatus copyWith({
    bool? isPremium,
    DateTime? premiumUntil,
    PremiumSource? source,
    String? entitlementId,
    String? revenueCatUserId,
    DateTime? lastVerifiedAt,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      source: source ?? this.source,
      entitlementId: entitlementId ?? this.entitlementId,
      revenueCatUserId: revenueCatUserId ?? this.revenueCatUserId,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }

  @override
  List<Object?> get props => [
    isPremium,
    premiumUntil,
    source,
    entitlementId,
    revenueCatUserId,
    lastVerifiedAt,
  ];

  @override
  String toString() {
    return 'PremiumStatus(isPremium: $isPremium, source: $source, '
        'until: $premiumUntil, active: $isActive)';
  }
}