
import 'package:meter_app/domain/entities/projects/project.dart';

abstract interface class ProjectsLocalDataSource {

  Future<void> saveProject(String name);

  Future<List<Project>> loadProjects();

  Future<void> deleteProject(Project project);

  Future<void> editProject(Project project);

  Future<void> saveProjects(List<Project> projects);
}
