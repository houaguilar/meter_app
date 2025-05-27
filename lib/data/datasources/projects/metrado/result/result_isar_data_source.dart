

import 'package:isar/isar.dart';

import '../../../../../domain/datasources/projects/metrados/result/result_local_data_source.dart';
import '../../../../../domain/entities/entities.dart';

class ResultIsarDataSource implements ResultLocalDataSource {
  final Isar isarService;

  ResultIsarDataSource(this.isarService);

  @override
  Future<void> saveResults(List<dynamic> results, String metradoId) async {
    final isar = isarService;
    final metrado = await isar.metrados.get(int.parse(metradoId));

    if (metrado != null) {
      await isar.writeTxn(() async {
        for (var result in results) {
          if (result is Ladrillo) {
            result.metrado.value = metrado;
            result.metradoId = int.parse(metradoId);
            await isar.ladrillos.put(result);
            await result.metrado.save();
          } else if (result is Piso) {
            result.metradoId = int.parse(metradoId);
            await isar.pisos.put(result);
            await result.metrado.save();
          }
        }
      });
    }
  }

  @override
  Future<List<dynamic>> loadResults(String metradoId) async {
    final ladrillos = await isarService.ladrillos.filter().metradoIdEqualTo(int.parse(metradoId)).findAll();
    final pisos = await isarService.pisos.filter().metradoIdEqualTo(int.parse(metradoId)).findAll();
    return [...ladrillos, ...pisos];
  }
}