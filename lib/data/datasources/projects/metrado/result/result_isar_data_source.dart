import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/home/estructuras/columna/columna.dart';
import 'package:meter_app/domain/entities/home/estructuras/viga/viga.dart';
import 'package:meter_app/domain/entities/home/losas/losas.dart';

import '../../../../../config/constants/error/exceptions.dart';
import '../../../../../domain/datasources/projects/metrados/result/result_local_data_source.dart';
import '../../../../../domain/entities/entities.dart';

class ResultIsarDataSource implements ResultLocalDataSource {
  final Isar isarService;

  ResultIsarDataSource(this.isarService);

  @override
  Future<void> saveResults(List<dynamic> results, String metradoId) async {
    if (results.isEmpty) {
      throw const ServerException('No hay resultados para guardar');
    }

    final isar = isarService;
    final metradoIdInt = int.tryParse(metradoId);

    if (metradoIdInt == null) {
      throw const ServerException('ID de metrado inválido');
    }

    final metrado = await isar.metrados.get(metradoIdInt);

    if (metrado == null) {
      throw const ServerException('Metrado no encontrado');
    }

    try {
      await isar.writeTxn(() async {
        // Limpiar resultados existentes para este metrado
        await _clearExistingResults(metradoIdInt);

        // Guardar nuevos resultados según su tipo
        for (var result in results) {
          await _saveResultByType(result, metradoIdInt, metrado);
        }
      });
    } catch (e) {
      throw ServerException('Error al guardar resultados: ${e.toString()}');
    }
  }

  @override
  Future<List<dynamic>> loadResults(String metradoId) async {
    final metradoIdInt = int.tryParse(metradoId);

    if (metradoIdInt == null) {
      throw const ServerException('ID de metrado inválido');
    }

    try {
      final allResults = <dynamic>[];

      // Cargar todos los tipos de resultados
      final ladrillos = await isarService.ladrillos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final pisos = await isarService.pisos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final tarrajeos = await isarService.tarrajeos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final losas = await isarService.losaAligeradas
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final columnas = await isarService.columnas
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final vigas = await isarService.vigas
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      // Agregar todos los resultados a la lista
      allResults.addAll(ladrillos);
      allResults.addAll(pisos);
      allResults.addAll(tarrajeos);
      allResults.addAll(losas);
      allResults.addAll(columnas);
      allResults.addAll(vigas);

      return allResults;
    } catch (e) {
      throw ServerException('Error al cargar resultados: ${e.toString()}');
    }
  }

  /// Limpia todos los resultados existentes para un metrado específico
  Future<void> _clearExistingResults(int metradoId) async {
    // Eliminar ladrillos
    final ladrillosToDelete = await isarService.ladrillos
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in ladrillosToDelete) {
      await isarService.ladrillos.delete(item.id);
    }

    // Eliminar pisos
    final pisosToDelete = await isarService.pisos
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in pisosToDelete) {
      await isarService.pisos.delete(item.id);
    }

    // Eliminar tarrajeos
    final tarrajeosToDelete = await isarService.tarrajeos
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in tarrajeosToDelete) {
      await isarService.tarrajeos.delete(item.id);
    }

    // Eliminar losas aligeradas
    final losasToDelete = await isarService.losaAligeradas
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in losasToDelete) {
      await isarService.losaAligeradas.delete(item.id);
    }

    // Eliminar columnas
    final columnasToDelete = await isarService.columnas
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in columnasToDelete) {
      await isarService.columnas.delete(item.id);
    }

    // Eliminar vigas
    final vigasToDelete = await isarService.vigas
        .filter()
        .metradoIdEqualTo(metradoId)
        .findAll();
    for (var item in vigasToDelete) {
      await isarService.vigas.delete(item.id);
    }
  }

  /// Guarda un resultado según su tipo
  Future<void> _saveResultByType(dynamic result, int metradoId, Metrado metrado) async {
    if (result is Ladrillo) {
      result.metrado.value = metrado;
      result.metradoId = metradoId;
      await isarService.ladrillos.put(result);
      await result.metrado.save();
    } else if (result is Piso) {
      result.metrado.value = metrado;
      result.metradoId = metradoId;
      await isarService.pisos.put(result);
      await result.metrado.save();
    } else if (result is Tarrajeo) {
      result.metrado.value = metrado;
      result.metradoId = metradoId;
      await isarService.tarrajeos.put(result);
      await result.metrado.save();
    } else if (result is LosaAligerada) {
      result.metrado.value = metrado;
      result.metradoId = metradoId;
      await isarService.losaAligeradas.put(result);
      await result.metrado.save();
    } else if (result is Columna) {
      result.metrado.value = metrado;
      result.metradoId = metradoId;
      await isarService.columnas.put(result);
      await result.metrado.save();
    } else if (result is Viga) {
      result.metrado.value = metrado;
      result.metradoId = metradoId;
      await isarService.vigas.put(result);
      await result.metrado.save();
    } else {
      throw ServerException('Tipo de resultado no soportado: ${result.runtimeType}');
    }
  }

  /// Obtiene estadísticas de resultados para un metrado
  Future<Map<String, int>> getResultStatistics(String metradoId) async {
    final metradoIdInt = int.tryParse(metradoId);

    if (metradoIdInt == null) {
      return {};
    }

    try {
      final stats = <String, int>{};

      stats['ladrillos'] = await isarService.ladrillos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['pisos'] = await isarService.pisos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['tarrajeos'] = await isarService.tarrajeos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['losas'] = await isarService.losaAligeradas
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['columnas'] = await isarService.columnas
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['vigas'] = await isarService.vigas
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      return stats;
    } catch (e) {
      return {};
    }
  }

  /// Verifica si un metrado tiene resultados
  Future<bool> hasResults(String metradoId) async {
    final stats = await getResultStatistics(metradoId);
    return stats.values.any((count) => count > 0);
  }

  /// Elimina todos los resultados de un metrado
  Future<void> deleteAllResults(String metradoId) async {
    final metradoIdInt = int.tryParse(metradoId);

    if (metradoIdInt == null) {
      throw const ServerException('ID de metrado inválido');
    }

    try {
      await isarService.writeTxn(() async {
        await _clearExistingResults(metradoIdInt);
      });
    } catch (e) {
      throw ServerException('Error al eliminar resultados: ${e.toString()}');
    }
  }
}