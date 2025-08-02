import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/domain/datasources/projects/projects_local_data_source.dart';
import 'package:meter_app/domain/datasources/projects/projects_remote_data_source.dart';
import 'package:meter_app/domain/entities/projects/project.dart';

import '../../../config/network/connection_checker.dart';
import '../../../domain/repositories/projects/projects_repository.dart';
import '../../datasources/projects/projects_isar_data_source.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsLocalDataSource projectsLocalDataSource;
  final ProjectsRemoteDataSource projectsRemoteDataSource;
  final ConnectionChecker connectionChecker;

  ProjectsRepositoryImpl(
      this.projectsLocalDataSource,
      this.projectsRemoteDataSource,
      this.connectionChecker,
      );

  @override
  Future<Either<Failure, void>> saveProject(String name) async {
    try {
      // Obtener el usuario actual
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return left(Failure(
          message: 'Usuario no autenticado',
          type: FailureType.general,
        ));
      }

      // Verificar duplicados en el scope del usuario
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        final hasDuplicate = await isarDataSource.hasProjectWithNameForUser(name, currentUserId);

        if (hasDuplicate) {
          return left(Failure(
            message: 'Ya tienes un proyecto con el nombre "$name"',
            type: FailureType.duplicateName,
          ));
        }
      }

      // Crear proyecto local con el usuario asignado
      await projectsLocalDataSource.saveProject(name);

      // Obtener el proyecto recién creado para asignarle el usuario
      final projects = await projectsLocalDataSource.loadProjects();
      final newProject = projects.firstWhere((p) => p.name == name);

      // Asignar usuario al proyecto
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        await isarDataSource.assignUserToProject(newProject.id, currentUserId);
      }

      // Intentar sincronizar con remoto si hay conexión
      await _trySyncToRemote();

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(
        message: 'Error al guardar proyecto: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      // Obtener el usuario actual
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return left(Failure(
          message: 'Usuario no autenticado',
          type: FailureType.general,
        ));
      }

      // Cargar proyectos filtrados por usuario
      List<Project> localProjects;
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        localProjects = await isarDataSource.loadProjectsByUser(currentUserId);
      } else {
        // Fallback para otras implementaciones
        final allProjects = await projectsLocalDataSource.loadProjects();
        localProjects = allProjects.where((p) => p.userId == currentUserId).toList();
      }

      // Intentar sincronizar con remoto si hay conexión
      await _trySyncFromRemote(currentUserId);

      // Recargar después de la sincronización
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        localProjects = await isarDataSource.loadProjectsByUser(currentUserId);
      }

      return Right(localProjects);
    } catch (e) {
      return Left(Failure(
        message: 'Error al cargar proyectos: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(Project project) async {
    try {
      // Verificar que el proyecto pertenezca al usuario actual
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return left(Failure(
          message: 'Usuario no autenticado',
          type: FailureType.general,
        ));
      }

      if (project.userId != currentUserId) {
        return left(Failure(
          message: 'No tienes permisos para eliminar este proyecto',
          type: FailureType.general,
        ));
      }

      // Eliminar localmente
      await projectsLocalDataSource.deleteProject(project);

      // Intentar sincronizar con remoto si hay conexión
      await _trySyncToRemote();

      return const Right(null);
    } catch (e) {
      return Left(Failure(
        message: 'Error al eliminar proyecto: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> editProject(Project project) async {
    try {
      // Verificar que el proyecto pertenezca al usuario actual
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return left(Failure(
          message: 'Usuario no autenticado',
          type: FailureType.general,
        ));
      }

      if (project.userId != currentUserId) {
        return left(Failure(
          message: 'No tienes permisos para editar este proyecto',
          type: FailureType.general,
        ));
      }

      // Verificar duplicados en el scope del usuario
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        final hasDuplicate = await isarDataSource.hasProjectWithNameForUser(
          project.name,
          currentUserId,
          excludeProjectId: project.id,
        );

        if (hasDuplicate) {
          return left(Failure(
            message: 'Ya tienes un proyecto con el nombre "${project.name}"',
            type: FailureType.duplicateName,
          ));
        }
      }

      // Editar localmente
      await projectsLocalDataSource.editProject(project);

      // Intentar sincronizar con remoto si hay conexión
      await _trySyncToRemote();

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(
        message: 'Error al editar proyecto: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }

  /// Busca proyectos del usuario actual
  Future<Either<Failure, List<Project>>> searchProjects(String query) async {
    try {
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return left(Failure(
          message: 'Usuario no autenticado',
          type: FailureType.general,
        ));
      }

      List<Project> projects;
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        projects = await isarDataSource.searchProjects(query, currentUserId);
      } else {
        // Fallback
        final allProjects = await projectsLocalDataSource.loadProjects();
        projects = allProjects
            .where((p) => p.userId == currentUserId)
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      return Right(projects);
    } catch (e) {
      return Left(Failure(
        message: 'Error al buscar proyectos: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }

  /// Obtiene estadísticas de un proyecto
  Future<Either<Failure, Map<String, dynamic>>> getProjectStatistics(int projectId) async {
    try {
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        final stats = await isarDataSource.getProjectStatistics(projectId);
        return Right(stats);
      }

      return Right({
        'metrados': 0,
        'totalResults': 0,
        'hasData': false,
      });
    } catch (e) {
      return Left(Failure(
        message: 'Error al obtener estadísticas: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }

  // Métodos privados de sincronización

  /// Obtiene el ID del usuario actual
  Future<String?> _getCurrentUserId() async {
    try {
      return projectsRemoteDataSource.getCurrentUserId();
    } catch (e) {
      // Si no puede obtener el usuario, retorna null
      return null;
    }
  }

  /// Intenta sincronizar hacia el servidor remoto
  Future<void> _trySyncToRemote() async {
    try {
      if (!await connectionChecker.isConnected) {
        return; // Sin conexión, no sincronizar
      }

      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return; // Sin usuario, no sincronizar
      }

      // Obtener proyectos locales del usuario
      List<Project> localProjects;
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        localProjects = await isarDataSource.loadProjectsByUser(currentUserId);
      } else {
        final allProjects = await projectsLocalDataSource.loadProjects();
        localProjects = allProjects.where((p) => p.userId == currentUserId).toList();
      }

      // Obtener proyectos remotos del usuario
      final remoteProjects = await projectsRemoteDataSource.loadProjects(currentUserId);

      // Sincronizar proyectos locales hacia remoto
      for (var localProject in localProjects) {
        final existsRemotely = remoteProjects.any((remote) =>
        remote.uuid == localProject.uuid || remote.name == localProject.name);

        if (!existsRemotely) {
          await projectsRemoteDataSource.saveProject(localProject);
        }
      }

      // Eliminar remotos que no existen localmente
      for (var remoteProject in remoteProjects) {
        final existsLocally = localProjects.any((local) =>
        local.uuid == remoteProject.uuid || local.name == remoteProject.name);

        if (!existsLocally) {
          await projectsRemoteDataSource.deleteProject(remoteProject);
        }
      }
    } catch (e) {
      // Ignorar errores de sincronización - no deben afectar la operación principal
      print('Error en sincronización hacia remoto: $e');
    }
  }

  /// Intenta sincronizar desde el servidor remoto
  Future<void> _trySyncFromRemote(String userId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return; // Sin conexión, no sincronizar
      }

      // Obtener proyectos remotos
      final remoteProjects = await projectsRemoteDataSource.loadProjects(userId);

      // Obtener proyectos locales del usuario
      List<Project> localProjects;
      if (projectsLocalDataSource is ProjectsIsarDataSource) {
        final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
        localProjects = await isarDataSource.loadProjectsByUser(userId);
      } else {
        final allProjects = await projectsLocalDataSource.loadProjects();
        localProjects = allProjects.where((p) => p.userId == userId).toList();
      }

      // Sincronizar proyectos remotos hacia local
      for (var remoteProject in remoteProjects) {
        final existsLocally = localProjects.any((local) =>
        local.uuid == remoteProject.uuid || local.name == remoteProject.name);

        if (!existsLocally) {
          // Crear proyecto local y asignar usuario
          await projectsLocalDataSource.saveProject(remoteProject.name);

          // Asignar usuario si es posible
          if (projectsLocalDataSource is ProjectsIsarDataSource) {
            final isarDataSource = projectsLocalDataSource as ProjectsIsarDataSource;
            final projects = await projectsLocalDataSource.loadProjects();
            final newProject = projects.firstWhere((p) => p.name == remoteProject.name);
            await isarDataSource.assignUserToProject(newProject.id, userId);
          }
        }
      }
    } catch (e) {
      // Ignorar errores de sincronización
      print('Error en sincronización desde remoto: $e');
    }
  }
}