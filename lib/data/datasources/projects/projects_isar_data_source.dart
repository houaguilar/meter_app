
import 'package:isar/isar.dart';
import 'package:meter_app/domain/datasources/projects/projects_local_data_source.dart';
import 'package:meter_app/domain/entities/entities.dart';

import '../../../config/constants/error/failures.dart';

class ProjectsIsarDataSource implements ProjectsLocalDataSource {
  final Isar isarService;
  ProjectsIsarDataSource(this.isarService);

  @override
  Future<List<Project>> loadProjects() async {
    final isar = isarService;
    return await isar.projects.where().findAll();
  }

  @override
  Future<void> saveProject(String name) async {
    final isar = isarService;

    final existingProject = await isar.projects.filter().nameEqualTo(name).findFirst();
    if (existingProject != null) {
      throw Failure(message: 'Project with name $name already exists', type: FailureType.duplicateName);
    }

    final project = Project(name: name);

    await isar.writeTxn(() async {
      await isar.projects.put(project);
    });
  }

  @override
  Future<void> deleteProject(Project project) async {
    final isar = isarService;

    await isar.writeTxn(() async {
      // Eliminar los metrados relacionados
      final metradosToDelete = await isar.metrados.filter().projectIdEqualTo(project.id).findAll();
      for (var metrado in metradosToDelete) {
        await isar.metrados.delete(metrado.id);
      }
      // Eliminar el proyecto
      await isar.projects.delete(project.id);
    });
  }

  @override
  Future<void> editProject(Project project) async {
    final isar = isarService;

    final existingProject = await isar.projects.filter().nameEqualTo(project.name).findFirst();
    if (existingProject != null && existingProject.id != project.id) {
      throw Failure(message: 'Project with name ${project.name} already exists', type: FailureType.duplicateName);
    }

    await isar.writeTxn(() async {
      await isar.projects.put(project);
    });
  }
}
