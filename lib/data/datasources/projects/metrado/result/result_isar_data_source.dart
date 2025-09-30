import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import 'package:meter_app/domain/entities/home/estructuras/columna/columna.dart';
import 'package:meter_app/domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import 'package:meter_app/domain/entities/home/estructuras/solado/solado.dart';
import 'package:meter_app/domain/entities/home/estructuras/viga/viga.dart';
import 'package:meter_app/domain/entities/home/losas/losas.dart';

import '../../../../../config/constants/error/exceptions.dart';
import '../../../../../domain/datasources/projects/metrados/result/result_local_data_source.dart';
import '../../../../../domain/entities/entities.dart';

class ResultIsarDataSource implements ResultLocalDataSource {
  final Isar isarService;

  ResultIsarDataSource(this.isarService);

 /* @override
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
*/
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

      final sobrecimientos = await isarService.sobrecimientos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final cimientosCorridos = await isarService.cimientoCorridos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final solados = await isarService.solados
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
      allResults.addAll(sobrecimientos);
      allResults.addAll(cimientosCorridos);
      allResults.addAll(solados);

      return allResults;
    } catch (e) {
      throw ServerException('Error al cargar resultados: ${e.toString()}');
    }
  }

  /// Limpia todos los resultados existentes para un metrado específico

// ✅ FIX: Método optimizado para limpiar resultados
  Future<void> _clearExistingResults(int metradoId) async {
    try {
      // ✅ Usar deleteAll() para mejor rendimiento y atomicidad
      await isarService.ladrillos
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.pisos
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.tarrajeos
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.losaAligeradas
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.columnas
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.vigas
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.sobrecimientos
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.cimientoCorridos
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.solados
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      print('🧹 Resultados existentes eliminados para metrado $metradoId');
    } catch (e) {
      print('❌ Error limpiando resultados existentes: $e');
      throw ServerException('Error al limpiar resultados existentes: ${e.toString()}');
    }
  }

// ✅ FIX: Método mejorado para guardar por tipo con validación
  Future<void> _saveResultByType(dynamic result, int metradoId, Metrado metrado) async {
    try {
      if (result is Ladrillo) {
        // ✅ Validar que el resultado no tenga ID previo (crear nuevo)
        final newResult = Ladrillo(
          idLadrillo: result.idLadrillo,
          description: result.description,
          tipoLadrillo: result.tipoLadrillo,
          factorDesperdicio: result.factorDesperdicio,
          factorDesperdicioMortero: result.factorDesperdicioMortero,
          proporcionMortero: result.proporcionMortero,
          tipoAsentado: result.tipoAsentado,
          largo: result.largo,
          altura: result.altura,
          area: result.area,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.ladrillos.put(newResult);
        await newResult.metrado.save();

      } else if (result is Piso) {
        final newResult = Piso(
          idPiso: result.idPiso,
          description: result.description,
          tipo: result.tipo,
          factorDesperdicio: result.factorDesperdicio,
          espesor: result.espesor,
          resistencia: result.resistencia,
          proporcionMortero: result.proporcionMortero,
          largo: result.largo,
          ancho: result.ancho,
          area: result.area,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.pisos.put(newResult);
        await newResult.metrado.save();

      } else if (result is Tarrajeo) {
        final newResult = Tarrajeo(
          idCoating: result.idCoating,
          description: result.description,
          tipo: result.tipo,
          factorDesperdicio: result.factorDesperdicio,
          espesor: result.espesor,
          proporcionMortero: result.proporcionMortero,
          longitud: result.longitud,
          ancho: result.ancho,
          area: result.area,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.tarrajeos.put(newResult);
        await newResult.metrado.save();

      } else if (result is LosaAligerada) {
        final newResult = LosaAligerada(
          idLosaAligerada: result.idLosaAligerada,
          description: result.description,
          altura: result.altura,
          materialAligerado: result.materialAligerado,
          resistenciaConcreto: result.resistenciaConcreto,
          desperdicioConcreto: result.desperdicioConcreto,
          desperdicioLadrillo: result.desperdicioLadrillo,
          largo: result.largo,
          ancho: result.ancho,
          area: result.area,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.losaAligeradas.put(newResult);
        await newResult.metrado.save();

      } else if (result is Columna) {
        final newResult = Columna(
          idColumna: result.idColumna,
          description: result.description,
          resistencia: result.resistencia,
          factorDesperdicio: result.factorDesperdicio,
          largo: result.largo,
          ancho: result.ancho,
          altura: result.altura,
          volumen: result.volumen,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.columnas.put(newResult);
        await newResult.metrado.save();

      } else if (result is Viga) {
        final newResult = Viga(
          idViga: result.idViga,
          description: result.description,
          resistencia: result.resistencia,
          factorDesperdicio: result.factorDesperdicio,
          largo: result.largo,
          ancho: result.ancho,
          altura: result.altura,
          volumen: result.volumen,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.vigas.put(newResult);
        await newResult.metrado.save();

      } else if (result is Sobrecimiento) {
        final newResult = Sobrecimiento(
          idSobrecimiento: result.idSobrecimiento,
          description: result.description,
          resistencia: result.resistencia,
          factorDesperdicio: result.factorDesperdicio,
          largo: result.largo,
          ancho: result.ancho,
          altura: result.altura,
          volumen: result.volumen,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.sobrecimientos.put(newResult);
        await newResult.metrado.save();

      } else if (result is CimientoCorrido) {
        final newResult = CimientoCorrido(
          idCimientoCorrido: result.idCimientoCorrido,
          description: result.description,
          resistencia: result.resistencia,
          factorDesperdicio: result.factorDesperdicio,
          largo: result.largo,
          ancho: result.ancho,
          altura: result.altura,
          volumen: result.volumen,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.cimientoCorridos.put(newResult);
        await newResult.metrado.save();

      } else if (result is Solado) {
        final newResult = Solado(
          idSolado: result.idSolado,
          description: result.description,
          resistencia: result.resistencia,
          factorDesperdicio: result.factorDesperdicio,
          largo: result.largo,
          ancho: result.ancho,
          area: result.area,
          espesorFijo: result.espesorFijo,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.solados.put(newResult);
        await newResult.metrado.save();

      } else {
        throw ServerException('Tipo de resultado no soportado: ${result.runtimeType}');
      }

      print('✅ Resultado ${result.runtimeType} guardado correctamente');
    } catch (e) {
      print('❌ Error guardando resultado ${result.runtimeType}: $e');
      throw ServerException('Error al guardar resultado ${result.runtimeType}: ${e.toString()}');
    }
  }

// ✅ FIX: Método principal mejorado con logging y validaciones
  @override
  Future<void> saveResults(List<dynamic> results, String metradoId) async {
    print('🔄 Iniciando guardado de ${results.length} resultados para metrado $metradoId');

    if (results.isEmpty) {
      throw const ServerException('No hay resultados para guardar');
    }

    final isar = isarService;
    final metradoIdInt = int.tryParse(metradoId);

    if (metradoIdInt == null) {
      throw ServerException('ID de metrado inválido: $metradoId');
    }

    // ✅ Validar que el metrado existe ANTES de proceder
    final metrado = await isar.metrados.get(metradoIdInt);
    if (metrado == null) {
      throw ServerException('Metrado no encontrado con ID: $metradoId');
    }

    try {
      await isar.writeTxn(() async {
        // ✅ Paso 1: Limpiar resultados existentes
        print('🧹 Limpiando resultados existentes...');
        await _clearExistingResults(metradoIdInt);

        // ✅ Paso 2: Guardar nuevos resultados
        print('💾 Guardando ${results.length} nuevos resultados...');
        for (int i = 0; i < results.length; i++) {
          print('  📝 Guardando resultado ${i + 1}/${results.length}: ${results[i].runtimeType}');
          await _saveResultByType(results[i], metradoIdInt, metrado);
        }
      });

      print('✅ Todos los resultados guardados exitosamente');
    } catch (e) {
      print('❌ Error en transacción de guardado: $e');
      throw ServerException('Error al guardar resultados: ${e.toString()}');
    }
  }
  /// Guarda un resultado según su tipo
/*
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
*/

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
      stats['sobrecimientos'] = await isarService.sobrecimientos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();
      stats['cimientoCorridos'] = await isarService.cimientoCorridos
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['solados'] = await isarService.solados
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