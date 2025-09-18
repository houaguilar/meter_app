import 'location.dart';

class LocationWithDistance extends LocationMap {
  final double? distanceKm;

  LocationWithDistance({
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

  // Factory method desde LocationMap base
  factory LocationWithDistance.fromLocation(
      LocationMap location, {
        double? distanceKm,
      }) {
    return LocationWithDistance(
      id: location.id,
      title: location.title,
      description: location.description,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      userId: location.userId,
      imageUrl: location.imageUrl,
      createdAt: location.createdAt,
      distanceKm: distanceKm,
    );
  }

  @override
  LocationWithDistance copyWith({
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
    return LocationWithDistance(
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

  @override
  String toString() {
    return 'LocationWithDistance(id: $id, title: $title, distanceKm: $distanceKm)';
  }
}