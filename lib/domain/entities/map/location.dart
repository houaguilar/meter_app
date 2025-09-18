
class LocationMap {
  final String? id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String? userId;
  final String? imageUrl;
  final DateTime? createdAt;

  LocationMap({
    this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.userId,
    this.imageUrl,
    this.createdAt,
  });

  LocationMap copyWith({
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
    return LocationMap(
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

  @override
  String toString() {
    return 'LocationMap(id: $id, title: $title, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationMap &&
        other.id == id &&
        other.title == title &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, latitude, longitude);
  }
}