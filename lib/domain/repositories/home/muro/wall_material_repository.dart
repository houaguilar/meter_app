// lib/domain/repositories/home/muro/wall_material_repository.dart
import '../../../entities/home/muro/wall_material.dart';

abstract class WallMaterialRepository {
  /// Obtiene todos los materiales de muro disponibles
  Future<List<WallMaterial>> getWallMaterials();

  /// Obtiene un material específico por su ID
  Future<WallMaterial?> getWallMaterialById(String id);
}