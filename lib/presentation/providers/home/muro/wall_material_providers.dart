
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';

import '../../../../data/repositories/home/muro/wall_material_repository_impl.dart';
import '../../../../domain/repositories/home/muro/wall_material_repository.dart';
import '../../../../domain/usecases/home/muro/get_wall_materials_usecase.dart';

final wallMaterialRepositoryProvider = Provider<WallMaterialRepository>((ref) {
  return WallMaterialRepositoryImpl();
});

final getWallMaterialsUseCaseProvider = Provider<GetWallMaterialsUseCase>((ref) {
  final repository = ref.read(wallMaterialRepositoryProvider);
  return GetWallMaterialsUseCase(repository);
});

final wallMaterialsProvider = FutureProvider<List<WallMaterial>>((ref) async {
  final useCase = ref.read(getWallMaterialsUseCaseProvider);
  return await useCase();
});

final selectedMaterialProvider = StateProvider<WallMaterial?>((ref) => null);
