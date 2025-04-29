
class WallMaterial {
  final String id;
  final String name;
  final String image;
  final String size;
  final double? lengthBrick;
  final double? widthBrick;
  final double? heightBrick;
  final String details;

  WallMaterial({
    required this.id,
    required this.name,
    required this.image,
    required this.size,
    this.lengthBrick,
    this.widthBrick,
    this.heightBrick,
    required this.details,
  });
}
