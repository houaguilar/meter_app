import 'package:isar/isar.dart';
import 'package:meter_app/domain/datasources/projects/projects_local_data_source.dart';
import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/domain/entities/home/estructuras/columna/columna.dart';
import 'package:meter_app/domain/entities/home/estructuras/viga/viga.dart';
import 'package:meter_app/domain/entities/home/losas/losas.dart';
import 'package:uuid/uuid.dart';

import '../../../config/constants/error/exceptions.dart';
import '../../../config/constants/error/failures.dart';

class ProjectsIsarDataSource implements ProjectsLocalDataSource {
  final Isar isarService;

  ProjectsIsarDataSource(this.isarService);

  @override
  Future<List<Project>> loadProjects() async {
    try {
      final isar = isarService;

      // Cargar TODOS los proyectos sin filtrar por usuario
      // Esto es lo que estaba causando el problema - se debe filtrar en el repository
      final projects = await isar.projects
          .where()
          .sortByUserIdDesc()
          .findAll();

      return projects;
    } catch (e) {
      throw ServerException('Error al cargar proyectos: ${e.toString()}');
    }
  }

  @override
  Future<void> saveProject(String name) async {
    try {
      final isar = isarService;

      // Validar entrada
      if (name.trim().isEmpty) {
        throw const ServerException('El nombre del proyecto es requerido');
      }

      if (name.length > 100) {
        throw const ServerException('El nombre del proyecto es demasiado largo');
      }

      // Sanitizar el nombre
      final sanitizedName = _sanitizeProjectName(name.trim());

      // Verificar duplicados - sin filtrar por usuario aquí
      final existingProject = await isar.projects
          .filter()
          .nameEqualTo(sanitizedName)
          .findFirst();

      if (existingProject != null) {
        throw Failure(
          message: 'Ya existe un proyecto con el nombre "$sanitizedName"',
          type: FailureType.duplicateName,
        );
      }

      // Crear proyecto sin userId (se asignará en el repository)
      final project = Project(
        name: sanitizedName,
        userId: null, // Será asignado en el repository layer
      );

      await isar.writeTxn(() async {
        await isar.projects.put(project);
      });
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerException('Error al guardar proyecto: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProject(Project project) async {
    try {
      final isar = isarService;

      await isar.writeTxn(() async {
        // Eliminar todos los metrados y sus resultados asociados
        await _deleteAllProjectData(project.id);

        // Eliminar el proyecto
        await isar.projects.delete(project.id);
      });
    } catch (e) {
      throw ServerException('Error al eliminar proyecto: ${e.toString()}');
    }
  }

  @override
  Future<void> editProject(Project project) async {
    try {
      final isar = isarService;

      // Validar entrada
      if (project.name.trim().isEmpty) {
        throw const ServerException('El nombre del proyecto es requerido');
      }

      if (project.name.length > 100) {
        throw const ServerException('El nombre del proyecto es demasiado largo');
      }

      // Sanitizar el nombre
      final sanitizedName = _sanitizeProjectName(project.name.trim());

      // Verificar duplicados (excluyendo el proyecto actual)
      final existingProject = await isar.projects
          .filter()
          .nameEqualTo(sanitizedName)
          .and()
          .not()
          .idEqualTo(project.id)
          .findFirst();

      if (existingProject != null) {
        throw Failure(
          message: 'Ya existe un proyecto con el nombre "$sanitizedName"',
          type: FailureType.duplicateName,
        );
      }

      // Actualizar el proyecto manteniendo el userId actual
      final updatedProject = project.copyWith(name: sanitizedName);

      await isar.writeTxn(() async {
        await isar.projects.put(updatedProject);
      });
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar proyecto: ${e.toString()}');
    }
  }

  @override
  Future<void> saveProjects(List<Project> projects) async {
    try {
      final isar = isarService;

      await isar.writeTxn(() async {
        for (var project in projects) {
          // Validar cada proyecto antes de guardarlo
          if (project.name.trim().isEmpty) continue;

          final sanitizedProject = project.copyWith(
            name: _sanitizeProjectName(project.name.trim()),
          );

          await isar.projects.put(sanitizedProject);
        }
      });
    } catch (e) {
      throw ServerException('Error al guardar proyectos: ${e.toString()}');
    }
  }

  /// Métodos específicos para filtrado por usuario (usados por el repository)

  /// Carga proyectos filtrados por usuario
  Future<List<Project>> loadProjectsByUser(String userId) async {
    try {
      final isar = isarService;

      final projects = await isar.projects
          .filter()
          .userIdEqualTo(userId)
          .sortByUserIdDesc()
          .findAll();

      return projects;
    } catch (e) {
      throw ServerException('Error al cargar proyectos del usuario: ${e.toString()}');
    }
  }

  /// Verifica duplicados en el scope del usuario
  Future<bool> hasProjectWithNameForUser(String name, String userId, {int? excludeProjectId}) async {
    try {
      final isar = isarService;
      final sanitizedName = _sanitizeProjectName(name.trim());

      var query = isar.projects
          .filter()
          .nameEqualTo(sanitizedName)
          .and()
          .userIdEqualTo(userId);

      if (excludeProjectId != null) {
        query = query.and().not().idEqualTo(excludeProjectId);
      }

      final existing = await query.findFirst();
      return existing != null;
    } catch (e) {
      return false;
    }
  }

  /// Asigna un usuario a un proyecto
  Future<void> assignUserToProject(int projectId, String userId) async {
    try {
      final isar = isarService;

      final project = await isar.projects.get(projectId);
      if (project == null) {
        throw const ServerException('Proyecto no encontrado');
      }

      final updatedProject = project.copyWith(userId: userId);

      await isar.writeTxn(() async {
        await isar.projects.put(updatedProject);
      });
    } catch (e) {
      throw ServerException('Error al asignar usuario al proyecto: ${e.toString()}');
    }
  }

  /// Elimina todos los datos asociados a un proyecto
  Future<void> _deleteAllProjectData(int projectId) async {
    final isar = isarService;

    // Obtener todos los metrados del proyecto
    final metrados = await isar.metrados
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();

    // Eliminar todos los resultados de cada metrado
    for (var metrado in metrados) {
      await _deleteAllMetradoResults(metrado.id);
    }

    // Eliminar los metrados
    for (var metrado in metrados) {
      await isar.metrados.delete(metrado.id);
    }
  }

  /// Elimina todos los resultados de un metrado
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

  /// Sanitiza el nombre del proyecto
  String _sanitizeProjectName(String name) {
    if (name.isEmpty) return name;

    // Remover caracteres peligrosos
    String cleaned = name
        .replaceAll(RegExp('[<>"\'{}`]'), '') // Remover caracteres HTML/JS
        .replaceAll(RegExp(r'[^\w\s\-_.\(\)]', unicode: true), '') // Solo caracteres seguros
        .trim();

    // Limitar longitud
    if (cleaned.length > 100) {
      cleaned = cleaned.substring(0, 100).trim();
    }

    return cleaned.isEmpty ? 'Proyecto sin nombre' : cleaned;
  }

  /// Obtiene estadísticas del proyecto
  Future<Map<String, dynamic>> getProjectStatistics(int projectId) async {
    try {
      final isar = isarService;

      final metradosCount = await isar.metrados
          .filter()
          .projectIdEqualTo(projectId)
          .count();

      final metrados = await isar.metrados
          .filter()
          .projectIdEqualTo(projectId)
          .findAll();

      int totalResults = 0;
      for (var metrado in metrados) {
        final ladrillosCount = await isar.ladrillos
            .filter()
            .metradoIdEqualTo(metrado.id)
            .count();
        final pisosCount = await isar.pisos
            .filter()
            .metradoIdEqualTo(metrado.id)
            .count();
        final tarrajeosCount = await isar.tarrajeos
            .filter()
            .metradoIdEqualTo(metrado.id)
            .count();
        final losasCount = await isar.losaAligeradas
            .filter()
            .metradoIdEqualTo(metrado.id)
            .count();
        final columnasCount = await isar.columnas
            .filter()
            .metradoIdEqualTo(metrado.id)
            .count();
        final vigasCount = await isar.vigas
            .filter()
            .metradoIdEqualTo(metrado.id)
            .count();

        totalResults += ladrillosCount + pisosCount + tarrajeosCount +
            losasCount + columnasCount + vigasCount;
      }

      return {
        'metrados': metradosCount,
        'totalResults': totalResults,
        'hasData': metradosCount > 0,
      };
    } catch (e) {
      return {
        'metrados': 0,
        'totalResults': 0,
        'hasData': false,
      };
    }
  }

  /// Busca proyectos por nombre
  Future<List<Project>> searchProjects(String query, String? userId) async {
    try {
      final isar = isarService;

      if (query.trim().isEmpty) {
        return userId != null
            ? await loadProjectsByUser(userId)
            : await loadProjects();
      }

      var queryBuilder = isar.projects
          .filter()
          .nameContains(query.trim(), caseSensitive: false);

      if (userId != null) {
        queryBuilder = queryBuilder.and().userIdEqualTo(userId);
      }

      final projects = await queryBuilder
          .sortByUserIdDesc()
          .findAll();

      return projects;
    } catch (e) {
      throw ServerException('Error al buscar proyectos: ${e.toString()}');
    }
  }
}