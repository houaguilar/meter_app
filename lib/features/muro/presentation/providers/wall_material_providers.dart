// lib/presentation/providers/home/muro/wall_material_providers_improved.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meter_app/domain/entities/home/muro/wall_material.dart';
import 'package:meter_app/features/muro/domain/repositories/wall_material_repository.dart';
import 'package:meter_app/features/muro/domain/usecases/get_wall_materials_usecase.dart';
import 'package:meter_app/init_dependencies.dart';

/// Provider para el repositorio de materiales de muro
final wallMaterialRepositoryProvider = Provider<WallMaterialRepository>((ref) {
  return serviceLocator<WallMaterialRepository>();
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
final selectedMaterialProvider = NotifierProvider<SelectedMaterialNotifier, WallMaterial?>(() => SelectedMaterialNotifier());

class SelectedMaterialNotifier extends Notifier<WallMaterial?> {
  @override
  WallMaterial? build() => null;

  void select(WallMaterial? material) => state = material;
}
