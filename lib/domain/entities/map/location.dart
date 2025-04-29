class LocationMap {
  final String? id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String? userId;
  final String? imageUrl;

  LocationMap({
    this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.userId,
    this.imageUrl,
  });
}
