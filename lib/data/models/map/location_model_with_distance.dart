// Modelo extendido que incluye distancia para PostGIS
import '../../../domain/entities/map/location_with_distance.dart';
import 'location_model.dart';

class LocationModelWithDistance extends LocationModel {
  final double? distanceKm;

  LocationModelWithDistance({
    required super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.address,
    super.userId,
    super.imageUrl,
    super.createdAt,
    this.distanceKm,
  });

  factory LocationModelWithDistance.fromMap(Map<String, dynamic> map) {
    final baseLocation = LocationModel.fromMap(map);
    return LocationModelWithDistance(
      id: baseLocation.id,
      title: baseLocation.title,
      description: baseLocation.description,
      latitude: baseLocation.latitude,
      longitude: baseLocation.longitude,
      address: baseLocation.address,
      userId: baseLocation.userId,
      imageUrl: baseLocation.imageUrl,
      createdAt: baseLocation.createdAt,
      distanceKm: map['distance_km']?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    if (distanceKm != null) {
      map['distance_km'] = distanceKm;
    }
    return map;
  }

  // Convertir a LocationWithDistance (entidad)
  LocationWithDistance toLocationWithDistance() {
    return LocationWithDistance(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      userId: userId,
      imageUrl: imageUrl,
      createdAt: createdAt,
      distanceKm: distanceKm,
    );
  }

  @override
  LocationModelWithDistance copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? userId,
    String? imageUrl,
    DateTime? createdAt,
    double? distanceKm,
  }) {
    return LocationModelWithDistance(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}