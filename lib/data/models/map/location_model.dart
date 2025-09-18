// lib/data/models/map/location_model.dart
import '../../../domain/entities/map/location.dart';

class LocationModel extends LocationMap {
  LocationModel({
    super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.address,
    super.userId,
    super.imageUrl,
    super.createdAt,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      imageUrl: map['image_url']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'user_id': userId,
      'image_url': imageUrl,
    };

    // Solo incluir ID si no es null (para nuevos registros Supabase lo genera)
    if (id != null) {
      map['id'] = id;
    }

    // Solo incluir created_at si no es null
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }

  @override
  LocationModel copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? userId,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}