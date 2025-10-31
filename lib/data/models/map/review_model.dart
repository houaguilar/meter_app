import '../../../domain/entities/map/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    super.id,
    super.supabaseId,
    super.locationId,
    super.userId,
    super.userName,
    required super.rating,
    super.comment,
    super.ownerResponse,
    super.createdAt,
    super.ownerRespondedAt,
    super.updatedAt,
  });

  /// Constructor desde Supabase
  factory ReviewModel.fromSupabase(Map<String, dynamic> map) {
    return ReviewModel(
      supabaseId: map['id']?.toString(),
      locationId: map['location_id']?.toString(),
      userId: map['user_id']?.toString(),
      userName: map['user_name']?.toString(),
      rating: (map['rating'] as num?)?.toInt() ?? 3,
      comment: map['comment']?.toString(),
      ownerResponse: map['provider_response']?.toString(), // Cambiado de owner_response a provider_response
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      ownerRespondedAt: map['responded_at'] != null // Cambiado de owner_responded_at a responded_at
          ? DateTime.tryParse(map['responded_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  /// Constructor desde entity (para conversión)
  factory ReviewModel.fromEntity(Review entity) {
    return ReviewModel(
      id: entity.id,
      supabaseId: entity.supabaseId,
      locationId: entity.locationId,
      userId: entity.userId,
      userName: entity.userName,
      rating: entity.rating,
      comment: entity.comment,
      ownerResponse: entity.ownerResponse,
      createdAt: entity.createdAt,
      ownerRespondedAt: entity.ownerRespondedAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte a Map para Supabase
  Map<String, dynamic> toSupabase() {
    final map = <String, dynamic>{
      'location_id': locationId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating.clamp(1, 5), // Asegurar 1-5
      'comment': comment,
      'provider_response': ownerResponse, // Cambiado de owner_response a provider_response
      'responded_at': ownerRespondedAt?.toIso8601String(), // Cambiado de owner_responded_at a responded_at
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Solo incluir ID si no es null (para updates)
    if (supabaseId != null) {
      map['id'] = supabaseId;
    }

    // Solo incluir created_at si no es null
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }

  @override
  ReviewModel copyWith({
    int? id,
    String? supabaseId,
    String? locationId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    String? ownerResponse,
    DateTime? createdAt,
    DateTime? ownerRespondedAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      ownerResponse: ownerResponse ?? this.ownerResponse,
      createdAt: createdAt ?? this.createdAt,
      ownerRespondedAt: ownerRespondedAt ?? this.ownerRespondedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
