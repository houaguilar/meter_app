import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/premium/premium_status.dart';

part 'premium_status_model.g.dart';

@JsonSerializable()
@Collection()
class PremiumStatusModel {
  Id id = Isar.autoIncrement;

  @Index()
  String userId;

  bool isPremium;

  DateTime? premiumUntil;

  String premiumSource;

  String? entitlementId;

  String? revenueCatUserId;

  DateTime? lastVerifiedAt;

  DateTime? createdAt;

  DateTime? updatedAt;

  PremiumStatusModel({
    required this.userId,
    required this.isPremium,
    this.premiumUntil,
    this.premiumSource = 'none',
    this.entitlementId,
    this.revenueCatUserId,
    this.lastVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // From JSON con manejo seguro de nulls
  factory PremiumStatusModel.fromJson(Map<String, dynamic> json) {
    return PremiumStatusModel(
      userId: json['user_id']?.toString() ?? '',
      isPremium: json['is_premium'] == true, // Conversión segura
      premiumUntil: json['premium_until'] != null
          ? DateTime.tryParse(json['premium_until'].toString())
          : null,
      premiumSource: json['premium_source']?.toString() ?? 'none',
      entitlementId: json['entitlement_id']?.toString(),
      revenueCatUserId: json['revenuecat_user_id']?.toString(),
      lastVerifiedAt: json['last_verified_at'] != null
          ? DateTime.tryParse(json['last_verified_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'is_premium': isPremium,
      'premium_until': premiumUntil?.toIso8601String(),
      'premium_source': premiumSource,
      'entitlement_id': entitlementId,
      'revenuecat_user_id': revenueCatUserId,
      'last_verified_at': lastVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // From/To Domain
  PremiumStatus toDomain() {
    return PremiumStatus(
      isPremium: isPremium,
      premiumUntil: premiumUntil,
      source: _sourceFromString(premiumSource),
      entitlementId: entitlementId,
      revenueCatUserId: revenueCatUserId,
      lastVerifiedAt: lastVerifiedAt,
    );
  }

  factory PremiumStatusModel.fromDomain(String userId, PremiumStatus status) {
    return PremiumStatusModel(
      userId: userId,
      isPremium: status.isPremium,
      premiumUntil: status.premiumUntil,
      premiumSource: _sourceToString(status.source),
      entitlementId: status.entitlementId,
      revenueCatUserId: status.revenueCatUserId,
      lastVerifiedAt: status.lastVerifiedAt,
    );
  }

  // Copiar con actualizaciones
  PremiumStatusModel copyWith({
    bool? isPremium,
    DateTime? premiumUntil,
    String? premiumSource,
    String? entitlementId,
    String? revenueCatUserId,
    DateTime? lastVerifiedAt,
  }) {
    return PremiumStatusModel(
      userId: userId,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      premiumSource: premiumSource ?? this.premiumSource,
      entitlementId: entitlementId ?? this.entitlementId,
      revenueCatUserId: revenueCatUserId ?? this.revenueCatUserId,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    )..id = id;
  }

  // Helpers privados
  static PremiumSource _sourceFromString(String source) {
    switch (source) {
      case 'mock_trial':
        return PremiumSource.mockTrial;
      case 'mock_purchase':
        return PremiumSource.mockPurchase;
      case 'revenuecat':
        return PremiumSource.revenueCat;
      default:
        return PremiumSource.none;
    }
  }

  static String _sourceToString(PremiumSource source) {
    switch (source) {
      case PremiumSource.mockTrial:
        return 'mock_trial';
      case PremiumSource.mockPurchase:
        return 'mock_purchase';
      case PremiumSource.revenueCat:
        return 'revenuecat';
      case PremiumSource.none:
        return 'none';
    }
  }
}