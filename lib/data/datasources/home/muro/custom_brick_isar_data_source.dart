// lib/data/datasources/home/muro/custom_brick_isar_data_source.dart
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/datasources/home/muro/custom_brick_local_data_source.dart';
import '../../../../domain/entities/home/muro/custom_brick.dart';
import '../../../../config/constants/error/exceptions.dart';

/// Implementación del datasource usando Isar
class CustomBrickIsarDataSource implements CustomBrickLocalDataSource {
  final Isar _isar;
  final _uuid = const Uuid();

  CustomBrickIsarDataSource(this._isar);

  @override
  Future<List<CustomBrick>> getAllCustomBricks() async {
    try {
      final bricks = await _isar.customBricks
          .where()
          .sortByCreatedAtDesc() // Más recientes primero
          .findAll();

      return bricks;
    } catch (e) {
      throw ServerException('Error al cargar ladrillos personalizados: ${e.toString()}');
    }
  }

  @override
  Future<CustomBrick?> getCustomBrickById(String customId) async {
    try {
      final brick = await _isar.customBricks
          .filter()
          .customIdEqualTo(customId)
          .findFirst();

      return brick;
    } catch (e) {
      throw ServerException('Error al buscar ladrillo personalizado: ${e.toString()}');
    }
  }

  @override
  Future<CustomBrick> saveCustomBrick(CustomBrick brick) async {
    try {
      // Validaciones
      if (brick.name.trim().isEmpty) {
        throw const ServerException('El nombre del ladrillo es requerido');
      }

      if (brick.length <= 0 || brick.width <= 0 || brick.height <= 0) {
        throw const ServerException('Las dimensiones deben ser mayores a 0');
      }

      // Verificar si ya existe un ladrillo con el mismo nombre
      final exists = await existsByName(brick.name.trim());
      if (exists) {
        throw const ServerException('Ya existe un ladrillo con ese nombre');
      }

      // Generar ID único si no lo tiene
      final brickToSave = brick.customId.isEmpty
          ? brick.copyWith(customId: _uuid.v4())
          : brick;

      // Guardar en Isar
      await _isar.writeTxn(() async {
        await _isar.customBricks.put(brickToSave);
      });

      // Retornar el ladrillo guardado
      final savedBrick = await getCustomBrickById(brickToSave.customId);
      return savedBrick ?? brickToSave;

    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al guardar ladrillo personalizado: ${e.toString()}');
    }
  }

  @override
  Future<CustomBrick> updateCustomBrick(CustomBrick brick) async {
    try {
      // Validaciones
      if (brick.customId.isEmpty) {
        throw const ServerException('ID del ladrillo es requerido para actualizar');
      }

      if (brick.name.trim().isEmpty) {
        throw const ServerException('El nombre del ladrillo es requerido');
      }

      // Verificar que existe
      final existing = await getCustomBrickById(brick.customId);
      if (existing == null) {
        throw const ServerException('Ladrillo personalizado no encontrado');
      }

      // Verificar nombre duplicado (excluyendo el actual)
      final nameExists = await existsByName(brick.name.trim(), excludeId: brick.customId);
      if (nameExists) {
        throw const ServerException('Ya existe un ladrillo con ese nombre');
      }

      // Crear ladrillo actualizado
      final updatedBrick = existing.copyWith(
        name: brick.name.trim(),
        length: brick.length,
        width: brick.width,
        height: brick.height,
        description: brick.description,
        updatedAt: DateTime.now(),
      );

      // Guardar en Isar
      await _isar.writeTxn(() async {
        await _isar.customBricks.put(updatedBrick);
      });

      return updatedBrick;

    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al actualizar ladrillo personalizado: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCustomBrick(String customId) async {
    try {
      if (customId.isEmpty) {
        throw const ServerException('ID del ladrillo es requerido');
      }

      final brick = await getCustomBrickById(customId);
      if (brick == null) {
        throw const ServerException('Ladrillo personalizado no encontrado');
      }

      await _isar.writeTxn(() async {
        await _isar.customBricks.delete(brick.id);
      });

    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al eliminar ladrillo personalizado: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllCustomBricks() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.customBricks.clear();
      });
    } catch (e) {
      throw ServerException('Error al eliminar todos los ladrillos personalizados: ${e.toString()}');
    }
  }

  @override
  Future<bool> existsByName(String name, {String? excludeId}) async {
    try {
      final query = _isar.customBricks
          .filter()
          .nameEqualTo(name.trim());

      if (excludeId != null) {
        final existing = await query.findAll();
        return existing.any((brick) => brick.customId != excludeId);
      }

      final count = await query.count();
      return count > 0;

    } catch (e) {
      throw ServerException('Error al verificar nombre duplicado: ${e.toString()}');
    }
  }
}