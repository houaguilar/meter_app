
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/domain/datasources/projects/projects_local_data_source.dart';
import 'package:meter_app/domain/entities/projects/project.dart';
import '../../../domain/repositories/projects/projects_local_repository.dart';

class ProjectsLocalRepositoryImpl implements ProjectsLocalRepository {
  final ProjectsLocalDataSource projectsLocalDataSource;
  const ProjectsLocalRepositoryImpl(this.projectsLocalDataSource);

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      print('Attempting to load projects from data source');
      final projects = await projectsLocalDataSource.loadProjects();
      print('Loaded projects: $projects');
      return right(projects);
    } catch (e) {
      print('Error loading projects: $e');
      return left(e is Failure ? e : Failure(message: 'Error desconocido'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProject(String name) async {
    try {
      print('Attempting to save project: $name');
      await projectsLocalDataSource.saveProject(name);
      print('Project saved successfully');
      return right(null);
    } catch (e) {
      print('Error saving project: $e');
      return left(e is Failure ? e : Failure(message: 'Error desconocido'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(Project project) async {
    try {
      await projectsLocalDataSource.deleteProject(project);
      return right(null);
    } catch (e) {
      return left(e is Failure ? e : Failure(message: 'Error desconocido'));
    }
  }

  @override
  Future<Either<Failure, void>> editProject(Project project) async {
    try {
      await projectsLocalDataSource.editProject(project);
      return right(null);
    } catch (e) {
      return left(e is Failure ? e : Failure(message: 'Error desconocido'));
    }
  }
}