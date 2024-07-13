

import '../../entities/entities.dart';

abstract interface class ProjectsRemoteDataSource {

  String getCurrentUserId();

  Future<List<Project>> loadProjects(String userId);

  Future<void> saveProject(Project project);

  Future<void> deleteProject(Project project);

  Future<void> editProject(Project project);
}