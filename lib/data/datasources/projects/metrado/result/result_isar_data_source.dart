import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import 'package:meter_app/domain/entities/home/estructuras/columna/columna.dart';
import 'package:meter_app/domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import 'package:meter_app/domain/entities/home/estructuras/solado/solado.dart';
import 'package:meter_app/domain/entities/home/estructuras/viga/viga.dart';

import '../../../../../config/constants/error/exceptions.dart';
import '../../../../../domain/datasources/projects/metrados/result/result_local_data_source.dart';
import '../../../../../domain/entities/entities.dart';
import '../../../../../domain/entities/home/acero/columna/steel_column.dart';
import '../../../../../domain/entities/home/acero/losa_maciza/steel_slab.dart';
import '../../../../../domain/entities/home/acero/viga/steel_beam.dart';
import '../../../../../domain/entities/home/acero/zapata/steel_footing.dart';

class ResultIsarDataSource implements ResultLocalDataSource {
  final Isar isarService;

  ResultIsarDataSource(this.isarService);

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

      // Losas del sistema unificado (3 tipos)
      final losas = await isarService.losas
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

      final steelColumns = await isarService.steelColumns
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final steelBeams = await isarService.steelBeams
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final steelSlabs = await isarService.steelSlabs
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .findAll();

      final steelFootings = await isarService.steelFootings
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

      allResults.addAll(steelColumns);
      allResults.addAll(steelBeams);
      allResults.addAll(steelSlabs);
      allResults.addAll(steelFootings);

      return allResults;
    } catch (e) {
      throw ServerException('Error al cargar resultados: ${e.toString()}');
    }
  }

  /// Limpia todos los resultados existentes para un metrado específico

// ✅ FIX: Método optimizado para limpiar resultados
  Future<void> _clearExistingResults(int metradoId) async {
    try {
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

      // Limpiar losas del sistema unificado
      await isarService.losas
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

      await isarService.steelColumns
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.steelBeams
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.steelSlabs
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      await isarService.steelFootings
          .filter()
          .metradoIdEqualTo(metradoId)
          .deleteAll();

      print('🧹 Resultados existentes eliminados para metrado $metradoId');
    } catch (e) {
      print('❌ Error limpiando resultados existentes: $e');
      throw ServerException('Error al limpiar resultados existentes: ${e.toString()}');
    }
  }

  Future<void> _saveResultByType(dynamic result, int metradoId, Metrado metrado) async {
    try {
      if (result is Ladrillo) {
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

      } else if (result is Losa) {
        // Guardar losa del sistema unificado (3 tipos)
        final newResult = Losa(
          idLosa: result.idLosa,
          description: result.description,
          tipo: result.tipo,
          altura: result.altura,
          resistenciaConcreto: result.resistenciaConcreto,
          desperdicioConcreto: result.desperdicioConcreto,
          materialAligerante: result.materialAligerante,
          desperdicioMaterialAligerante: result.desperdicioMaterialAligerante,
          largo: result.largo,
          ancho: result.ancho,
          area: result.area,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.losas.put(newResult);
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

      } else if (result is SteelColumn) {
        // ✅ Crear copias profundas de las listas embebidas
        final steelBarsCopy = result.steelBars.map((bar) => SteelBarEmbedded()
          ..idSteelBar = bar.idSteelBar
          ..quantity = bar.quantity
          ..diameter = bar.diameter
        ).toList();

        final stirrupsCopy = result.stirrupDistributions.map((dist) => StirrupDistributionEmbedded()
          ..idStirrupDistribution = dist.idStirrupDistribution
          ..quantity = dist.quantity
          ..separation = dist.separation
        ).toList();

        print('  🔍 SteelColumn - Barras originales: ${result.steelBars.length}, copiadas: ${steelBarsCopy.length}');
        print('  🔍 SteelColumn - Estribos originales: ${result.stirrupDistributions.length}, copiados: ${stirrupsCopy.length}');

        final newResult = SteelColumn(
          idSteelColumn: result.idSteelColumn,
          description: result.description,
          waste: result.waste,
          elements: result.elements,
          cover: result.cover,
          height: result.height,
          length: result.length,
          width: result.width,
          hasFooting: result.hasFooting,
          footingHeight: result.footingHeight,
          footingBend: result.footingBend,
          useSplice: result.useSplice,
          stirrupDiameter: result.stirrupDiameter,
          stirrupBendLength: result.stirrupBendLength,
          restSeparation: result.restSeparation,
          steelBars: steelBarsCopy,
          stirrupDistributions: stirrupsCopy,
          createdAt: result.createdAt,
          updatedAt: result.updatedAt,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.steelColumns.put(newResult);
        await newResult.metrado.save();

        print('  ✅ SteelColumn guardado: ${newResult.description}');
      }

      else if (result is SteelBeam) {
        // ✅ Crear copias profundas de las listas embebidas
        final steelBarsCopy = result.steelBars.map((bar) => SteelBeamBarEmbedded()
          ..idSteelBar = bar.idSteelBar
          ..quantity = bar.quantity
          ..diameter = bar.diameter
        ).toList();

        final stirrupsCopy = result.stirrupDistributions.map((dist) => SteelBeamStirrupDistributionEmbedded()
          ..idStirrupDistribution = dist.idStirrupDistribution
          ..quantity = dist.quantity
          ..separation = dist.separation
        ).toList();

        print('  🔍 SteelBeam - Barras originales: ${result.steelBars.length}, copiadas: ${steelBarsCopy.length}');
        print('  🔍 SteelBeam - Estribos originales: ${result.stirrupDistributions.length}, copiados: ${stirrupsCopy.length}');

        final newResult = SteelBeam(
          idSteelBeam: result.idSteelBeam,
          description: result.description,
          waste: result.waste,
          elements: result.elements,
          cover: result.cover,
          height: result.height,
          length: result.length,
          width: result.width,
          supportA1: result.supportA1,
          supportA2: result.supportA2,
          bendLength: result.bendLength,
          useSplice: result.useSplice,
          stirrupDiameter: result.stirrupDiameter,
          stirrupBendLength: result.stirrupBendLength,
          restSeparation: result.restSeparation,
          steelBars: steelBarsCopy,
          stirrupDistributions: stirrupsCopy,
          createdAt: result.createdAt,
          updatedAt: result.updatedAt,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.steelBeams.put(newResult);
        await newResult.metrado.save();

        print('  ✅ SteelBeam guardado: ${newResult.description}');
      }

      else if (result is SteelSlab) {
        // ✅ Crear copias profundas de las listas embebidas
        final meshBarsCopy = result.meshBars.map((bar) => SteelMeshBarEmbedded()
          ..idSteelMeshBar = bar.idSteelMeshBar
          ..meshType = bar.meshType
          ..direction = bar.direction
          ..diameter = bar.diameter
          ..separation = bar.separation
        ).toList();

        final superiorMeshConfigCopy = SuperiorMeshConfigEmbedded()
          ..idConfig = result.superiorMeshConfig.idConfig
          ..enabled = result.superiorMeshConfig.enabled;

        print('  🔍 SteelSlab - MeshBars originales: ${result.meshBars.length}, copiadas: ${meshBarsCopy.length}');

        final newResult = SteelSlab(
          idSteelSlab: result.idSteelSlab,
          description: result.description,
          waste: result.waste,
          elements: result.elements,
          length: result.length,
          width: result.width,
          bendLength: result.bendLength,
          meshBars: meshBarsCopy,
          superiorMeshConfig: superiorMeshConfigCopy,
          createdAt: result.createdAt,
          updatedAt: result.updatedAt,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.steelSlabs.put(newResult);
        await newResult.metrado.save();

        print('  ✅ SteelSlab guardado: ${newResult.description}');
      }

      else if (result is SteelFooting) {
        print('  🔍 SteelFooting - Guardando zapata de acero');

        final newResult = SteelFooting(
          idSteelFooting: result.idSteelFooting,
          description: result.description,
          waste: result.waste,
          elements: result.elements,
          cover: result.cover,
          length: result.length,
          width: result.width,
          inferiorHorizontalDiameter: result.inferiorHorizontalDiameter,
          inferiorHorizontalSeparation: result.inferiorHorizontalSeparation,
          inferiorVerticalDiameter: result.inferiorVerticalDiameter,
          inferiorVerticalSeparation: result.inferiorVerticalSeparation,
          inferiorBendLength: result.inferiorBendLength,
          hasSuperiorMesh: result.hasSuperiorMesh,
          superiorHorizontalDiameter: result.superiorHorizontalDiameter,
          superiorHorizontalSeparation: result.superiorHorizontalSeparation,
          superiorVerticalDiameter: result.superiorVerticalDiameter,
          superiorVerticalSeparation: result.superiorVerticalSeparation,
          createdAt: result.createdAt,
          updatedAt: result.updatedAt,
        );

        newResult.metradoId = metradoId;
        newResult.metrado.value = metrado;

        await isarService.steelFootings.put(newResult);
        await newResult.metrado.save();

        print('  ✅ SteelFooting guardado: ${newResult.description}');
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

      stats['losas'] = await isarService.losas
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

      stats['steelColumns'] = await isarService.steelColumns
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['steelBeams'] = await isarService.steelBeams
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['steelSlabs'] = await isarService.steelSlabs
          .filter()
          .metradoIdEqualTo(metradoIdInt)
          .count();

      stats['steelFootings'] = await isarService.steelFootings
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