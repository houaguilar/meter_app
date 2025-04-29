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
      id: map['id'],
      title: map['title'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      userId: map['user_id'],
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'user_id': userId,
      'image_url': imageUrl,
    };
  }
}
