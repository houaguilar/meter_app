// lib/domain/entities/home/acero/losa/mesh_enums.dart
import 'package:isar/isar.dart';

@Name("MeshType")
enum MeshType {
  @Name("inferior")
  inferior,
  @Name("superior")
  superior;

  String get displayName {
    switch (this) {
      case MeshType.inferior:
        return 'Malla Inferior';
      case MeshType.superior:
        return 'Malla Superior';
    }
  }
}

@Name("MeshDirection")
enum MeshDirection {
  @Name("horizontal")
  horizontal,
  @Name("vertical")
  vertical;

  String get displayName {
    switch (this) {
      case MeshDirection.horizontal:
        return 'Horizontal';
      case MeshDirection.vertical:
        return 'Vertical';
    }
  }
}
