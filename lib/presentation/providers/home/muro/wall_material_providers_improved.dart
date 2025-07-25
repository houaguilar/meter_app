// lib/presentation/providers/home/muro/wall_material_providers_improved.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/home/muro/wall_material_repository_impl.dart';
import '../../../../domain/entities/home/muro/wall_material.dart';
import '../../../../domain/repositories/home/muro/wall_material_repository.dart';
import '../../../../domain/usecases/home/muro/get_wall_materials_usecase.dart';

/// Provider para el repositorio de materiales de muro
final wallMaterialRepositoryProvider = Provider<WallMaterialRepository>((ref) {
  return WallMaterialRepositoryImpl();
});

/// Provider para el caso de uso de obtener materiales
final getWallMaterialsUseCaseProvider = Provider<GetWallMaterialsUseCase>((ref) {
  final repository = ref.read(wallMaterialRepositoryProvider);
  return GetWallMaterialsUseCase(repository);
});

/// Provider principal que expone la lista de materiales
final wallMaterialsProvider = FutureProvider<List<WallMaterial>>((ref) async {
  final useCase = ref.read(getWallMaterialsUseCaseProvider);
  return await useCase();
});

/// Provider para el material seleccionado actualmente
final selectedMaterialProvider = StateProvider<WallMaterial?>((ref) => null);
