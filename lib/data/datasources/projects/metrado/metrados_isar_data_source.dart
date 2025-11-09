import 'package:isar/isar.dart';
import 'package:meter_app/domain/datasources/projects/metrados/metrados_local_data_source.dart';
import 'package:meter_app/domain/entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import 'package:meter_app/domain/entities/home/estructuras/columna/columna.dart';
import 'package:meter_app/domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import 'package:meter_app/domain/entities/home/estructuras/solado/solado.dart';
import 'package:meter_app/domain/entities/home/estructuras/viga/viga.dart';

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

      // CORREGIDO: Solo verificar duplicados dentro del proyecto actual
      // Los nombres de metrados pueden repetirse entre diferentes proyectos
      final existingMetrado = await isar.metrados
          .filter()
          .nameEqualTo(name.trim())
          .and()
          .projectIdEqualTo(projectId) // Solo en este proyecto específico
          .findFirst();

      if (existingMetrado != null) {
        // MEJORADO: Lanzar ServerException en lugar de Failure para consistencia
        throw const ServerException('Ya existe un metrado con este nombre en el proyecto actual');
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
    } on ServerException {
      // Re-lanzar ServerExceptions tal como están
      rethrow;
    } on Failure {
      // Convertir Failure a ServerException para consistencia
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

      // CORREGIDO: Verificar duplicados solo en el mismo proyecto, excluyendo el metrado actual
      final existingMetrados = await isar.metrados
          .filter()
          .nameEqualTo(metrado.name.trim())
          .and()
          .projectIdEqualTo(metrado.projectId)
          .findAll();

      // Verificar si existe algún metrado con el mismo nombre que NO sea el actual
      final duplicateExists = existingMetrados
          .any((m) => m.id != metrado.id);

      if (duplicateExists) {
        throw const ServerException('Ya existe un metrado con este nombre en el proyecto actual');
      }

      // Actualizar en la base de datos
      await isar.writeTxn(() async {
        await isar.metrados.put(metrado);
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al actualizar metrado: ${e.toString()}');
    }
  }

  // Método auxiliar para eliminar todos los resultados de un metrado
  Future<void> _deleteAllMetradoResults(int metradoId) async {
    final isar = isarService;

    // Eliminar todos los tipos de resultados asociados al metrado
    await isar.ladrillos.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.pisos.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.tarrajeos.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.losas.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.columnas.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.vigas.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.sobrecimientos.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.cimientoCorridos.filter().metradoIdEqualTo(metradoId).deleteAll();
    await isar.solados.filter().metradoIdEqualTo(metradoId).deleteAll();
  }
}