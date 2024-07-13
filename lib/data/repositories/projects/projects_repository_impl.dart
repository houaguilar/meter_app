import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/domain/datasources/projects/projects_local_data_source.dart';
import 'package:meter_app/domain/datasources/projects/projects_remote_data_source.dart';
import 'package:meter_app/domain/entities/projects/project.dart';
import 'package:uuid/uuid.dart';
import '../../../config/network/connection_checker.dart';
import '../../../domain/repositories/projects/projects_repository.dart';


class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsLocalDataSource projectsLocalDataSource;
  final ProjectsRemoteDataSource projectsRemoteDataSource;
  final ConnectionChecker connectionChecker;

  ProjectsRepositoryImpl(
      this.projectsLocalDataSource,
      this.projectsRemoteDataSource,
      this.connectionChecker,
      );

  Future<void> _syncLocalToRemote() async {
    if (await connectionChecker.isConnected) {
      try {
        final userId = projectsRemoteDataSource.getCurrentUserId();
        final localProjects = await projectsLocalDataSource.loadProjects();
        final remoteProjects = await projectsRemoteDataSource.loadProjects(userId);

        // Sync local projects to remote
        for (var localProject in localProjects) {
          if (!remoteProjects.contains(localProject)) {
            await projectsRemoteDataSource.saveProject(localProject);
          }
        }

        // Delete remote projects that were deleted locally
        for (var remoteProject in remoteProjects) {
          if (!localProjects.contains(remoteProject)) {
            await projectsRemoteDataSource.deleteProject(remoteProject);
          }
        }
      } catch (e) {
        print('Error syncing projects: $e');
      }
    }
  }

  @override
  Future<Either<Failure, void>> saveProject(String name) async {
    try {
      // Save project locally
      final newProject = Project(name: name, userId: const Uuid().v4().toString());
      await projectsLocalDataSource.saveProject(newProject.name);
    //  await projectsLocalDataSource.saveProject(name);
  //    await _syncLocalToRemote();
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString(), type: FailureType.unknown));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      // Load projects from local source
      final localProjects = await projectsLocalDataSource.loadProjects();

      // Attempt to sync with remote source
   //   await _syncLocalToRemote();

      return Right(localProjects);
    } catch (e) {
      return Left(Failure(message: e.toString(), type: FailureType.unknown));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(Project project) async {
    try {
      // Delete project locally
      await projectsLocalDataSource.deleteProject(project);
  //    await _syncLocalToRemote();
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString(), type: FailureType.unknown));
    }
  }

  @override
  Future<Either<Failure, void>> editProject(Project project) async {
    try {
      // Edit project locally
      await projectsLocalDataSource.editProject(project);
   //   await _syncLocalToRemote();
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString(), type: FailureType.unknown));
    }
  }

  /*@override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      final localProjectsResult = await projectsLocalDataSource.loadProjects();
      final localProjects = localProjectsResult;
      if (!await connectionChecker.isConnected) {
        return right(localProjects);
      }
      final userId = projectsRemoteDataSource.getCurrentUserId();
      final remoteProjectsResult = await projectsRemoteDataSource.loadProjects(userId);
      final remoteProjects = remoteProjectsResult;

//      await _syncProjects(remoteProjects);
      final updatedLocalProjects = await projectsLocalDataSource.loadProjects();
      return right(remoteProjects);
    } on ServerException catch (e) {
      print('repo get first');
      return left(Failure(message: e.message));
    } catch (e) {
      print('repo get second');
      return left(Failure(message: 'Error get project: ${e.toString()}'));
    }

    *//*if (await connectionChecker.isConnected) {
      try {
        final userId = projectsRemoteDataSource.getCurrentUserId();
        final remoteProjects = await projectsRemoteDataSource.loadProjects(userId);
    //    await _syncProjects(remoteProjects);
        return right(remoteProjects);
      } catch (e) {
        return left(Failure(message: 'Error loading projects from remote: $e'));
      }
    } else {
      try {
        final localProjects = await projectsLocalDataSource.loadProjects();
        return right(localProjects);
      } catch (e) {
        return left(Failure(message: 'Error loading projects from local: $e'));
      }
    }*//*
  }

  Future<void> _syncProjects(List<Project> remoteProjects) async {
    *//*final localProjects = await projectsLocalDataSource.loadProjects();
    for (final remoteProject in remoteProjects) {
      final existingProject = localProjects.firstWhereOrNull(
            (project) => project.uuid == remoteProject.uuid,
      );

      if (existingProject == null) {
        await projectsLocalDataSource.saveProject(remoteProject.name);
      } else {
        await projectsLocalDataSource.editProject(remoteProject);
      }*//*


    for (final remoteProject in remoteProjects) {
      final localProjects = await projectsLocalDataSource.loadProjects();
      final existingProject = localProjects.firstWhere(
            (project) => project.uuid == remoteProject.uuid,
        orElse: () => Project(name: '', userId: '', uuid: ''),
      );

      if (existingProject.name.isEmpty) {
        await projectsLocalDataSource.saveProject(remoteProject.name);
      } else {
        await projectsLocalDataSource.editProject(remoteProject);
      }
    }
  }


  @override
  Future<Either<Failure, void>> saveProject(String name) async {
    *//*try {
      final newProject = Project(name: name, uuid: const Uuid().v4().toString());
      await projectsLocalDataSource.saveProject(newProject.name);

      if (!await connectionChecker.isConnected) {
        return right(null);
      }

      final userId = projectsRemoteDataSource.getCurrentUserId();
      final remoteProject = newProject.copyWith(userId: userId);
      await projectsRemoteDataSource.saveProject(remoteProject);
      return right(null);
    } on ServerException catch (e) {
      print('repo save first');
      return left(Failure(message: e.message));
    } catch (e) {
      print('repo save second');
      return left(Failure(message: 'Error saving project: ${e.toString()}'));
    }*//*

    if (await connectionChecker.isConnected) {
      try {
        final userId = projectsRemoteDataSource.getCurrentUserId();
        final newProject = Project(name: name, userId: userId);
        await projectsRemoteDataSource.saveProject(newProject);
  //      await projectsLocalDataSource.saveProject(name);
        return right(null);
      } catch (e) {
        return left(Failure(message: 'Error saving project: $e'));
      }
    } else {
      try {
        await projectsLocalDataSource.saveProject(name);
        return right(null);
      } catch (e) {
        return left(Failure(message: 'Error saving project locally: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(Project project) async {
    *//*try {
      await projectsLocalDataSource.deleteProject(project);
      if (await connectionChecker.isConnected) {
        await projectsRemoteDataSource.deleteProject(project);
      }
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error deleting project: ${e.toString()}'));
    }*//*

    if (await connectionChecker.isConnected) {
      try {
        await projectsRemoteDataSource.deleteProject(project);
 //       await projectsLocalDataSource.deleteProject(project);
        return right(null);
      } catch (e) {
        return left(Failure(message: 'Error deleting project: $e'));
      }
    } else {
      try {
        await projectsLocalDataSource.deleteProject(project);
        return right(null);
      } catch (e) {
        return left(Failure(message: 'Error deleting project locally: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> editProject(Project project) async {
    *//*try {
      await projectsLocalDataSource.editProject(project);
      if (await connectionChecker.isConnected) {
        await projectsRemoteDataSource.editProject(project);
      }
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error deleting project: ${e.toString()}'));
    }*//*

    if (await connectionChecker.isConnected) {
      try {
        await projectsRemoteDataSource.editProject(project);
 //       await projectsLocalDataSource.editProject(project);
        return right(null);
      } catch (e) {
        return left(Failure(message: 'Error editing project: $e'));
      }
    } else {
      try {
        await projectsLocalDataSource.editProject(project);
        return right(null);
      } catch (e) {
        return left(Failure(message: 'Error editing project locally: $e'));
      }
    }
  }*/
}
