// lib/domain/entities/home/muro/wall_material.dart
class WallMaterial {
  final String id;
  final String name;
  final String image;
  final String size;
  final double? lengthBrick;
  final double? widthBrick;
  final double? heightBrick;
  final String details;
  // REMOVIDO: final bool isAvailable;
  // REMOVIDO: final String? unavailableReason;
  // REMOVIDO: Cualquier propiedad relacionada con disponibilidad

  const WallMaterial({
    required this.id,
    required this.name,
    required this.image,
    required this.size,
    this.lengthBrick,
    this.widthBrick,
    this.heightBrick,
    required this.details,
    // REMOVIDO: this.isAvailable = true,
    // REMOVIDO: this.unavailableReason,
  });

  WallMaterial copyWith({
    String? id,
    String? name,
    String? image,
    String? size,
    double? lengthBrick,
    double? widthBrick,
    double? heightBrick,
    String? details,
    // REMOVIDO: bool? isAvailable,
    // REMOVIDO: String? unavailableReason,
  }) {
    return WallMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      size: size ?? this.size,
      lengthBrick: lengthBrick ?? this.lengthBrick,
      widthBrick: widthBrick ?? this.widthBrick,
      heightBrick: heightBrick ?? this.heightBrick,
      details: details ?? this.details,
      // REMOVIDO: isAvailable: isAvailable ?? this.isAvailable,
      // REMOVIDO: unavailableReason: unavailableReason ?? this.unavailableReason,
    );
  }

  @override
  String toString() {
    return 'WallMaterial(id: $id, name: $name, size: $size, lengthBrick: $lengthBrick, widthBrick: $widthBrick, heightBrick: $heightBrick)';
    // REMOVIDO: isAvailable del toString
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WallMaterial &&
        other.id == id &&
        other.name == name &&
        other.image == image &&
        other.size == size &&
        other.lengthBrick == lengthBrick &&
        other.widthBrick == widthBrick &&
        other.heightBrick == heightBrick &&
        other.details == details;
    // REMOVIDO: other.isAvailable == isAvailable &&
    // REMOVIDO: other.unavailableReason == unavailableReason;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      image,
      size,
      lengthBrick,
      widthBrick,
      heightBrick,
      details,
      // REMOVIDO: isAvailable,
      // REMOVIDO: unavailableReason,
    );
  }
}