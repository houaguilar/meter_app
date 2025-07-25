
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';
import 'package:meter_app/domain/repositories/home/muro/wall_material_repository.dart';

class GetWallMaterialsUseCase {
  final WallMaterialRepository repository;

  GetWallMaterialsUseCase(this.repository);

  Future<List<WallMaterial>> call() async {
    return await repository.getWallMaterials();
  }
}
