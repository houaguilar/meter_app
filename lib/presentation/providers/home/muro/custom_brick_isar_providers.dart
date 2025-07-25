// lib/presentation/providers/home/muro/custom_brick_isar_providers.dart
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/presentation/providers/home/muro/wall_material_providers_improved.dart';
import '../../../../config/usecase/usecase.dart';
import '../../../../domain/entities/home/muro/custom_brick.dart';
import '../../../../domain/entities/home/muro/wall_material.dart';

import '../../../../domain/usecases/home/muro/custom_brick/check_custom_brick_name.dart';
import '../../../../domain/usecases/home/muro/custom_brick/delete_custom_brick.dart';
import '../../../../domain/usecases/home/muro/custom_brick/get_all_custom_bricks.dart';
import '../../../../domain/usecases/home/muro/custom_brick/save_custom_brick.dart';
import '../../../../domain/usecases/home/muro/custom_brick/update_custom_brick.dart';
import '../../../../init_dependencies.dart';
import '../../../assets/images.dart';

/// Provider para obtener todos los ladrillos personalizados
final customBricksProvider = FutureProvider<List<CustomBrick>>((ref) async {
  final useCase = serviceLocator<GetAllCustomBricks>();
  final result = await useCase(NoParams());

  return result.fold(
        (failure) => throw Exception(failure.message),
        (bricks) => bricks,
  );
});

/// Provider para el estado de guardado de ladrillos
final customBrickSaveStateProvider = StateNotifierProvider<CustomBrickSaveNotifier, AsyncValue<CustomBrick?>>((ref) {
  return CustomBrickSaveNotifier(ref);
});

/// Notifier para manejar el guardado de ladrillos personalizados
class CustomBrickSaveNotifier extends StateNotifier<AsyncValue<CustomBrick?>> {
  final Ref _ref;

  CustomBrickSaveNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Guardar un nuevo ladrillo personalizado
  Future<void> saveCustomBrick(CustomBrick brick) async {
    state = const AsyncValue.loading();

    try {
      final useCase = serviceLocator<SaveCustomBrick>();
      final result = await useCase(SaveCustomBrickParams(brick: brick));

      result.fold(
            (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
            (savedBrick) {
          state = AsyncValue.data(savedBrick);
          // Invalidar providers para refrescar la lista
          _invalidateProviders();
        },
      );
    } catch (e) {
      state = AsyncValue.error('Error inesperado: $e', StackTrace.current);
    }
  }

  /// Actualizar un ladrillo existente
  Future<void> updateCustomBrick(CustomBrick brick) async {
    state = const AsyncValue.loading();

    try {
      final useCase = serviceLocator<UpdateCustomBrick>();
      final result = await useCase(UpdateCustomBrickParams(brick: brick));

      result.fold(
            (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
            (updatedBrick) {
          state = AsyncValue.data(updatedBrick);
          // Invalidar providers para refrescar la lista
          _invalidateProviders();
        },
      );
    } catch (e) {
      state = AsyncValue.error('Error inesperado: $e', StackTrace.current);
    }
  }

  /// Eliminar un ladrillo personalizado
  Future<void> deleteCustomBrick(String customId) async {
    state = const AsyncValue.loading();

    try {
      final useCase = serviceLocator<DeleteCustomBrick>();
      final result = await useCase(DeleteCustomBrickParams(customId: customId));

      result.fold(
            (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
            (_) {
          state = const AsyncValue.data(null);
          // Invalidar providers para refrescar la lista
          _invalidateProviders();
        },
      );
    } catch (e) {
      state = AsyncValue.error('Error inesperado: $e', StackTrace.current);
    }
  }

  /// Verificar si existe un nombre
  Future<bool> checkNameExists(String name, {String? excludeId}) async {
    try {
      final useCase = serviceLocator<CheckCustomBrickName>();
      final result = await useCase(CheckCustomBrickNameParams(
        name: name,
        excludeId: excludeId,
      ));

      return result.fold(
            (failure) => false, // En caso de error, asumimos que no existe
            (exists) => exists,
      );
    } catch (e) {
      return false;
    }
  }

  /// Limpiar el estado
  void clearState() {
    state = const AsyncValue.data(null);
  }

  /// Invalidar providers relacionados para refrescar
  void _invalidateProviders() {
    _ref.invalidate(customBricksProvider);
    _ref.invalidate(wallMaterialsWithCustomProvider);
  }
}

/// Provider que combina materiales predefinidos con ladrillos personalizados guardados
final wallMaterialsWithCustomProvider = FutureProvider<List<WallMaterial>>((ref) async {
  try {
    // Obtener materiales predefinidos
    final predefinedMaterials = await ref.watch(wallMaterialsProvider.future);

    // Obtener ladrillos personalizados guardados
    final customBricksResult = await ref.watch(customBricksProvider.future);

    // Convertir ladrillos personalizados a formato WallMaterial
    final customMaterials = customBricksResult.map((brick) {
      return WallMaterial(
        id: 'saved_${brick.customId}', // Prefijo 'saved_' para identificar guardados
        name: '⭐ ${brick.name}', // Estrella para distinguir visualmente
        image: AppImages.tabiconImg,
        size: brick.displaySize,
        lengthBrick: brick.length,
        widthBrick: brick.width,
        heightBrick: brick.height,
        details: '${brick.description ?? 'Ladrillo personalizado guardado'}\n• Dimensiones: ${brick.displaySize}\n• Volumen: ${brick.volume.toStringAsFixed(3)} litros\n• Creado: ${brick.createdAt.day}/${brick.createdAt.month}/${brick.createdAt.year}',
      );
    }).toList();

    // Combinar: primero los guardados, luego los predefinidos
    return [...customMaterials, ...predefinedMaterials];

  } catch (e) {
    // Si hay error cargando custom bricks, solo devolver predefinidos
    print('⚠️ Error cargando ladrillos personalizados: $e');
    return await ref.watch(wallMaterialsProvider.future);
  }
});

/// Provider para manejar la selección de ladrillo personalizado actual
final selectedCustomBrickProvider = StateProvider<CustomBrick?>((ref) => null);

/// Provider de utilidad para refrescar manualmente los datos
final refreshCustomBricksProvider = Provider<VoidCallback>((ref) {
  return () {
    ref.invalidate(customBricksProvider);
    ref.invalidate(wallMaterialsWithCustomProvider);
  };
});

/// Provider para estadísticas de ladrillos personalizados
final customBricksStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final customBricksAsync = ref.watch(customBricksProvider);

  return customBricksAsync.when(
    data: (bricks) {
      if (bricks.isEmpty) {
        return {
          'total': 0,
          'hasData': false,
          'averageVolume': 0.0,
          'mostRecentDate': null,
        };
      }

      // Calcular estadísticas
      final totalVolume = bricks.fold<double>(
        0.0,
            (sum, brick) => sum + brick.volume,
      );

      final averageVolume = totalVolume / bricks.length;

      // Encontrar el más reciente
      final mostRecent = bricks.reduce((a, b) =>
      a.createdAt.isAfter(b.createdAt) ? a : b
      );

      return {
        'total': bricks.length,
        'hasData': true,
        'averageVolume': averageVolume,
        'mostRecentDate': mostRecent.createdAt,
        'mostRecentName': mostRecent.name,
      };
    },
    loading: () => {
      'total': 0,
      'hasData': false,
      'isLoading': true,
    },
    error: (_, __) => {
      'total': 0,
      'hasData': false,
      'hasError': true,
    },
  );
});

/// Provider para buscar ladrillos por nombre (útil para futuras funcionalidades)
final searchCustomBricksProvider = Provider.family<List<CustomBrick>, String>((ref, query) {
  final customBricks = ref.watch(customBricksProvider);

  return customBricks.when(
    data: (bricks) {
      if (query.isEmpty) return bricks;

      final lowercaseQuery = query.toLowerCase();
      return bricks.where((brick) =>
      brick.name.toLowerCase().contains(lowercaseQuery) ||
          brick.description?.toLowerCase().contains(lowercaseQuery) == true
      ).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider para validar un nombre de ladrillo en tiempo real
final validateBrickNameProvider = Provider.family<Future<bool>, String>((ref, name) async {
  if (name.trim().isEmpty) return false;

  try {
    final useCase = serviceLocator<CheckCustomBrickName>();
    final result = await useCase(CheckCustomBrickNameParams(name: name.trim()));

    return result.fold(
          (failure) => false,
          (exists) => !exists, // Retorna true si el nombre NO existe (es válido)
    );
  } catch (e) {
    return false;
  }
});

/// Provider para obtener un ladrillo específico por ID
final customBrickByIdProvider = Provider.family<CustomBrick?, String>((ref, customId) {
  final customBricks = ref.watch(customBricksProvider);

  return customBricks.when(
    data: (bricks) {
      try {
        return bricks.firstWhere((brick) => brick.customId == customId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Extension para facilitar el uso de los providers
extension CustomBrickProvidersExtension on WidgetRef {
  /// Invalida todos los providers relacionados con ladrillos personalizados
  void invalidateCustomBrickProviders() {
    invalidate(customBricksProvider);
    invalidate(wallMaterialsWithCustomProvider);
    invalidate(customBricksStatsProvider);
  }

  /// Refresca los datos de ladrillos personalizados
  void refreshCustomBricks() {
    read(refreshCustomBricksProvider)();
  }

  /// Obtiene las estadísticas de ladrillos personalizados
  Map<String, dynamic> getCustomBricksStats() {
    return read(customBricksStatsProvider);
  }
}