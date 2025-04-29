
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';

abstract interface class WallMaterialRepository {
  Future<List<WallMaterial>> fetchWallMaterials();
}