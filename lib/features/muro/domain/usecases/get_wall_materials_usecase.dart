
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';
import 'package:meter_app/features/muro/domain/repositories/wall_material_repository.dart';

class GetWallMaterialsUseCase {
  final WallMaterialRepository repository;

  GetWallMaterialsUseCase(this.repository);

  Future<List<WallMaterial>> call() async {
    return await repository.getWallMaterials();
  }
}
