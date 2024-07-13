import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/domain/entities/projects/project.dart';
import 'package:meter_app/domain/repositories/projects/projects_repository.dart';
import 'package:meter_app/config/network/connection_checker.dart';

class SyncService {
  final ProjectsRepository projectsRepository;
  final ConnectionChecker connectionChecker;

  SyncService({
    required this.projectsRepository,
    required this.connectionChecker,
  });

  Future<Either<Failure, void>> syncProjects() async {
    try {
      if (!await connectionChecker.isConnected) {
        return right(null); // No sync needed if offline
      }

      final localProjectsResult = await projectsRepository.getAllProjects();
      final localProjects = localProjectsResult.getOrElse((failure) => []);

      for (final project in localProjects) {
        final syncResult = await _syncProject(project);
        if (syncResult.isLeft()) {
          return left(syncResult.getLeft().getOrElse(() => Failure(message: 'Error syncing projects')));
        }
      }

      return right(null);
    } catch (e) {
      return left(Failure(message: 'Error syncing projects: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> _syncProject(Project project) async {
    try {
      final remoteProjectsResult = await projectsRepository.getAllProjects();
      final remoteProjects = remoteProjectsResult.getOrElse((failure) => []);

      final existingRemoteProject = remoteProjects.firstWhere(
            (remoteProject) => remoteProject.uuid == project.uuid,
        orElse: () => Project(name: '', userId: '', uuid: ''), // Provide a default project to avoid null
      );

      if (existingRemoteProject.name.isEmpty) { // Check if it's the default project
        final saveResult = await projectsRepository.saveProject(project.name);
        if (saveResult.isLeft()) {
          return left(saveResult.getLeft().getOrElse(() => Failure(message: 'Error saving remote project')));
        }
      } else {
        final editResult = await projectsRepository.editProject(project);
        if (editResult.isLeft()) {
          return left(editResult.getLeft().getOrElse(() => Failure(message: 'Error editing remote project')));
        }
      }
      return right(null);
    } catch (e) {
      return left(Failure(message: 'Error syncing project: ${e.toString()}'));
    }
  }

}
