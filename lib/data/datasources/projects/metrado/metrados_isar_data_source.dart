import 'package:isar/isar.dart';
import 'package:meter_app/domain/datasources/projects/metrados/metrados_local_data_source.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../../domain/entities/entities.dart';

class MetradosIsarDataSource implements MetradosLocalDataSource {
  final Isar isarService;
  MetradosIsarDataSource(this.isarService);

  @override
  Future<int> saveMetrado(String name, int projectId) async {
    final isar = isarService;

    final existingMetrado = await isar.metrados.filter().nameEqualTo(name).findFirst();
    if (existingMetrado != null) {
      throw Failure(message: 'Metrado with name $name already exists', type: FailureType.duplicateName);
    }

    final metrado = Metrado(name: name, projectId: projectId);
    final project = await isar.projects.get(projectId);

    if (project != null) {
      metrado.project.value = project;
      await isar.writeTxn(() async {
        await isar.metrados.put(metrado);
        await metrado.project.save();
      });
      return metrado.id; // Retorna el metradoId
    }
    throw IsarError('Project not found');
  }

  @override
  Future<List<Metrado>> loadMetrados(int projectId) async {
    final isar = isarService;

    final project = await isar.projects.get(projectId);
    if (project != null) {
      await project.metrados.load();
      return project.metrados.toList();
    }
    return [];
  }

  @override
  Future<void> deleteMetrado(Metrado metrado) async {
    final isar = isarService;

    await isar.writeTxn(() async {

      final ladrillosToDelete = await isarService.ladrillos.filter().metradoIdEqualTo(metrado.id).findAll();
      final bloquetasToDelete = await isarService.bloquetas.filter().metradoIdEqualTo(metrado.id).findAll();
      final pisosToDelete = await isarService.pisos.filter().metradoIdEqualTo(metrado.id).findAll();

      for (var result in ladrillosToDelete) {
        await isar.ladrillos.delete(result.id);
      }

      for (var result in bloquetasToDelete) {
        await isar.bloquetas.delete(result.id);
      }

      for (var result in pisosToDelete) {
        await isar.pisos.delete(result.id);
      }

      await isar.metrados.delete(metrado.id);
    });
  }

  @override
  Future<void> updateMetrado(Metrado metrado) async {
    final isar = isarService;

    await isar.writeTxn(() async {
      await isar.metrados.put(metrado);
    });
  }


}