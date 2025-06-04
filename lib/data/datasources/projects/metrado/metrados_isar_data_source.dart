import 'package:isar/isar.dart';
import 'package:meter_app/domain/datasources/projects/metrados/metrados_local_data_source.dart';
import 'package:meter_app/domain/entities/home/estructuras/columna/columna.dart';
import 'package:meter_app/domain/entities/home/estructuras/viga/viga.dart';
import 'package:meter_app/domain/entities/home/losas/losas.dart';

import '../../../../config/constants/error/exceptions.dart';
import '../../../../config/constants/error/failures.dart';
import '../../../../domain/entities/entities.dart';

class MetradosIsarDataSource implements MetradosLocalDataSource {
  final Isar isarService;

  MetradosIsarDataSource(this.isarService);

  @override
  Future<int> saveMetrado(String name, int projectId) async {
    try {
      final isar = isarService;

      // Validar entrada
      if (name.trim().isEmpty) {
        throw const ServerException('El nombre del metrado es requerido');
      }

      if (name.length > 100) {
        throw const ServerException('El nombre del metrado es demasiado largo');
      }

      // Verificar que el proyecto existe
      final project = await isar.projects.get(projectId);
      if (project == null) {
        throw const ServerException('El proyecto especificado no existe');
      }

      // Verificar duplicados en el mismo proyecto
      final existingMetrado = await isar.metrados
          .filter()
          .nameEqualTo(name.trim())
          .and()
          .projectIdEqualTo(projectId)
          .findFirst();

      if (existingMetrado != null) {
        throw Failure(
          message: 'Ya existe un metrado con el nombre "$name" en este proyecto',
          type: FailureType.duplicateName,
        );
      }

      // Crear el nuevo metrado
      final metrado = Metrado(
        name: name.trim(),
        projectId: projectId,
      );

      // Establecer la relación con el proyecto
      metrado.project.value = project;

      // Guardar en la base de datos
      await isar.writeTxn(() async {
        await isar.metrados.put(metrado);
        await metrado.project.save();
      });

      return metrado.id;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerException('Error al crear metrado: ${e.toString()}');
    }
  }

  @override
  Future<List<Metrado>> loadMetrados(int projectId) async {
    try {
      final isar = isarService;

      // Verificar que el proyecto existe
      final project = await isar.projects.get(projectId);
      if (project == null) {
        throw const ServerException('El proyecto especificado no existe');
      }

      // Cargar metrados del proyecto y ordenar por nombre
      await project.metrados.load();
      final metrados = project.metrados.toList();

      // Ordenar por fecha de creación (ID) descendente para mostrar los más recientes primero
      metrados.sort((a, b) => b.id.compareTo(a.id));

      return metrados;
    } catch (e) {
      throw ServerException('Error al cargar metrados: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMetrado(Metrado metrado) async {
    try {
      final isar = isarService;

      await isar.writeTxn(() async {
        // Eliminar todos los resultados asociados al metrado
        await _deleteAllMetradoResults(metrado.id);

        // Eliminar el metrado
        await isar.metrados.delete(metrado.id);
      });
    } catch (e) {
      throw ServerException('Error al eliminar metrado: ${e.toString()}');
    }
  }

  @override
  Future<void> updateMetrado(Metrado metrado) async {
    try {
      final isar = isarService;

      // Validar entrada
      if (metrado.name.trim().isEmpty) {
        throw const ServerException('El nombre del metrado es requerido');
      }

      if (metrado.name.length > 100) {
        throw const ServerException('El nombre del metrado es demasiado largo');
      }

      // Verificar duplicados (excluyendo el metrado actual)
      final existingMetrado = await isar.metrados
          .filter()
          .nameEqualTo(metrado.name.trim())
          .and()
          .projectIdEqualTo(metrado.projectId)
          .and()
          .not()
          .idEqualTo(metrado.id)
          .findFirst();

      if (existingMetrado != null) {
        throw Failure(
          message: 'Ya existe un metrado con el nombre "${metrado.name}" en este proyecto',
          type: FailureType.duplicateName,
        );
      }

      // Actualizar el metrado
      final updatedMetrado = metrado.copyWith(name: metrado.name.trim());

      await isar.writeTxn(() async {
        await isar.metrados.put(updatedMetrado);
      });
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar metrado: ${e.toString()}');
    }
  }

  /// Elimina todos los resultados asociados a un metrado
  Future<void> _deleteAllMetradoResults(int metradoId) async {
    final isar = isarService;

    // Eliminar ladrillos
    final ladrillosToDelete = await isar.ladrillos
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in ladrillosToDelete) {
      await isar.ladrillos.delete(item.id);
    }

    // Eliminar pisos
    final pisosToDelete = await isar.pisos
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in pisosToDelete) {
      await isar.pisos.delete(item.id);
    }

    // Eliminar tarrajeos
    final tarrajeosToDelete = await isar.tarrajeos
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in tarrajeosToDelete) {
      await isar.tarrajeos.delete(item.id);
    }

    // Eliminar losas aligeradas
    final losasToDelete = await isar.losaAligeradas
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in losasToDelete) {
      await isar.losaAligeradas.delete(item.id);
    }

    // Eliminar columnas
    final columnasToDelete = await isar.columnas
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in columnasToDelete) {
      await isar.columnas.delete(item.id);
    }

    // Eliminar vigas
    final vigasToDelete = await isar.vigas
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in vigasToDelete) {
      await isar.vigas.delete(item.id);
    }
  }

  /// Obtiene el conteo total de resultados para un metrado
  Future<int> getTotalResultsCount(int metradoId) async {
    try {
      final isar = isarService;

      final ladrillosCount = await isar.ladrillos
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      final pisosCount = await isar.pisos
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      final tarrajeosCount = await isar.tarrajeos
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      final losasCount = await isar.losaAligeradas
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      final columnasCount = await isar.columnas
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      final vigasCount = await isar.vigas
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      return ladrillosCount + pisosCount + tarrajeosCount +
          losasCount + columnasCount + vigasCount;
    } catch (e) {
      return 0;
    }
  }

  /// Verifica si un metrado tiene resultados
  Future<bool> hasResults(int metradoId) async {
    final count = await getTotalResultsCount(metradoId);
    return count > 0;
  }

  /// Obtiene estadísticas detalladas de un metrado
  Future<Map<String, int>> getMetradoStatistics(int metradoId) async {
    try {
      final isar = isarService;
      final stats = <String, int>{};

      stats['ladrillos'] = await isar.ladrillos
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      stats['pisos'] = await isar.pisos
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      stats['tarrajeos'] = await isar.tarrajeos
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      stats['losas'] = await isar.losaAligeradas
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      stats['columnas'] = await isar.columnas
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      stats['vigas'] = await isar.vigas
          .filter()
          .metradoIdEqualTo(metradoId)
          .count();

      return stats;
    } catch (e) {
      return {};
    }
  }

  /// Busca metrados por nombre en un proyecto
  Future<List<Metrado>> searchMetrados(int projectId, String query) async {
    try {
      final isar = isarService;

      if (query.trim().isEmpty) {
        return await loadMetrados(projectId);
      }

      final metrados = await isar.metrados
          .filter()
          .projectIdEqualTo(projectId)
          .and()
          .nameContains(query.trim(), caseSensitive: false)
          .sortByProjectIdDesc()
          .findAll();

      return metrados;
    } catch (e) {
      throw ServerException('Error al buscar metrados: ${e.toString()}');
    }
  }
}