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
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id']?.toString(), // Convertir a String si es necesario
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      imageUrl: map['image_url']?.toString(),
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

    return map;
  }

  // Método para crear una copia con valores actualizados
  LocationModel copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? userId,
    String? imageUrl,
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
    );
  }

  @override
  String toString() {
    return 'LocationModel(id: $id, title: $title, latitude: $latitude, longitude: $longitude, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        other.userId == userId &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    description.hashCode ^
    latitude.hashCode ^
    longitude.hashCode ^
    address.hashCode ^
    userId.hashCode ^
    imageUrl.hashCode;
  }
}