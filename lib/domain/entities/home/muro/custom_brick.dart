import 'package:isar/isar.dart';
import 'package:meter_app/config/assets/app_images.dart';

part 'custom_brick.g.dart';

@collection
class CustomBrick {
  Id id = Isar.autoIncrement;

  @Index()
  late String customId;

  @Index()
  late String name;

  late double length;
  late double width;
  late double height;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  late String? description;

  /// Campo calculado para mostrar las dimensiones
  @ignore
  String get displaySize => '${length.toStringAsFixed(1)}×${width.toStringAsFixed(1)}×${height.toStringAsFixed(1)} cm';

  /// Campo calculado para obtener el volumen
  @ignore
  double get volume => (length * width * height) / 1000; // en litros

  /// Constructor por defecto
  CustomBrick();

  /// Constructor con parámetros
  CustomBrick.create({
    required this.customId,
    required this.name,
    required this.length,
    required this.width,
    required this.height,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  /// Método para crear desde CustomBrickConfig existente
  factory CustomBrick.fromConfig(String customId, String name, double length, double width, double height, {String? description}) {
    return CustomBrick.create(
      customId: customId,
      name: name,
      length: length,
      width: width,
      height: height,
      description: description,
    );
  }

  /// Convertir a WallMaterial para mostrar en la lista
  /// Este método permitirá que los ladrillos personalizados aparezcan junto con los predefinidos
  Map<String, dynamic> toWallMaterialData() {
    return {
      'id': 'custom_$customId',
      'name': name,
      'image': AppImages.personalizadoImg,
      'size': displaySize,
      'lengthBrick': length,
      'widthBrick': width,
      'heightBrick': height,
      'details': description ?? 'Ladrillo personalizado creado por el usuario.\n• Dimensiones: $displaySize\n• Volumen: ${volume.toStringAsFixed(3)} litros\n• Creado: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
    };
  }

  /// Método copyWith para actualizaciones inmutables
  CustomBrick copyWith({
    String? customId,
    String? name,
    double? length,
    double? width,
    double? height,
    String? description,
    DateTime? updatedAt,
  }) {
    final brick = CustomBrick.create(
      customId: customId ?? this.customId,
      name: name ?? this.name,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
    brick.id = id;
    return brick;
  }

  @override
  String toString() {
    return 'CustomBrick(id: $id, customId: $customId, name: $name, dimensions: $displaySize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomBrick &&
        other.customId == customId &&
        other.name == name &&
        other.length == length &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    return Object.hash(customId, name, length, width, height);
  }
}