// lib/domain/services/shared/UnifiedResultsCombiner.dart

import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';

/// Servicio para combinar resultados de múltiples metrados (sin precios)
class UnifiedResultsCombiner {

  /// Combina los resultados de múltiples metrados
  static CombinedCalculationResult combineMetrados({
    required List<MetradoWithResults> metradosWithResults,
    required String projectName,
  }) {
    try {
      final combinedMaterials = <String, CombinedMaterial>{};
      final metradoSummaries = <MetradoSummary>[];
      double totalArea = 0.0;

      // Procesar cada metrado
      for (final metradoData in metradosWithResults) {
        final metrado = metradoData.metrado;
        final results = metradoData.results;

        // Calcular materiales de este metrado
        final metradoMaterials = _calculateMetradoMaterials(results);
        final metradoArea = _calculateMetradoArea(results);

        // Crear resumen del metrado
        final summary = MetradoSummary(
          metradoId: metrado.id,
          metradoName: metrado.name,
          materials: metradoMaterials,
          area: metradoArea,
          resultTypes: _getResultTypes(results),
          itemCount: results.length,
        );
        metradoSummaries.add(summary);

        // Combinar materiales en el total
        _combineMaterials(combinedMaterials, metradoMaterials, metrado.name);

        totalArea += metradoArea;
      }

      return CombinedCalculationResult(
        combinedMaterials: combinedMaterials,
        metradoSummaries: metradoSummaries,
        totalArea: totalArea,
        projectName: projectName,
        combinationDate: DateTime.now(),
        metradoCount: metradosWithResults.length,
      );

    } catch (e) {
      throw CombinationException(
        'Error al combinar metrados: ${e.toString()}',
      );
    }
  }

  /// Calcula los materiales de un metrado específico usando los providers correctos
  static Map<String, double> _calculateMetradoMaterials(List<dynamic> results) {
    final materials = <String, double>{};

    for (final result in results) {
      final calculationResult = _calculateSingleResult(result);

      // Combinar materiales del resultado individual
      calculationResult.materials.forEach((material, quantity) {
        materials[material] = (materials[material] ?? 0.0) + quantity;
      });
    }

    return materials;
  }

  /// Calcula materiales para un resultado individual usando los cálculos de providers
  static _MaterialCalculationResult _calculateSingleResult(dynamic result) {
    if (result is Ladrillo) {
      return _calculateLadrilloMaterials([result]);
    } else if (result is Piso) {
      return _calculatePisoMaterials([result]);
    } else if (result is LosaAligerada) {
      return _calculateLosaMaterials([result]);
    } else if (result is Tarrajeo) {
      return _calculateTarrajeoMaterials([result]);
    } else if (result is Columna) {
      return _calculateColumnaMaterials([result]);
    } else if (result is Viga) {
      return _calculateVigaMaterials([result]);
    }

    return const _MaterialCalculationResult(materials: {}, area: 0.0);
  }

  /// Cálculos para ladrillos basados en el provider
  static _MaterialCalculationResult _calculateLadrilloMaterials(List<Ladrillo> ladrillos) {
    // Especificaciones exactas del provider
    const Map<String, Map<String, double>> especificacionesLadrillos = {
      "King Kong": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Pandereta": {"largo": 23.0, "ancho": 12.0, "alto": 9.0},
      "Artesanal": {"largo": 22.0, "ancho": 12.5, "alto": 7.5},
      "Kingkong": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Kingkong1": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Kingkong2": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Pandereta1": {"largo": 23.0, "ancho": 12.0, "alto": 9.0},
      "Pandereta2": {"largo": 23.0, "ancho": 12.0, "alto": 9.0},
      "Común": {"largo": 22.0, "ancho": 12.5, "alto": 7.5},
    };

    // Factores de mortero del provider
    const Map<String, Map<String, double>> factoresMortero = {
      '3': {'cemento': 10.682353, 'arena': 1.10, 'agua': 0.250000},
      '4': {'cemento': 8.565, 'arena': 1.16, 'agua': 0.291},
      '5': {'cemento': 7.105882, 'arena': 1.20, 'agua': 0.242},
      '6': {'cemento': 6.141176, 'arena': 1.20, 'agua': 0.235000},
    };

    const double juntaHorizontal = 1.5;
    const double juntaVertical = 1.5;

    double ladrillosTotal = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;
    double areaTotal = 0.0;

    for (var ladrillo in ladrillos) {
      final area = _getLadrilloArea(ladrillo);
      areaTotal += area;

      final desperdicioLadrillo = (double.tryParse(ladrillo.factorDesperdicio) ?? 5.0) / 100;
      final desperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

      final tipoNormalizado = _normalizarTipoLadrillo(ladrillo.tipoLadrillo);
      final especificaciones = especificacionesLadrillos[tipoNormalizado] ?? especificacionesLadrillos['Pandereta']!;

      final largoLadrillo = especificaciones['largo']! / 100;
      final altoLadrillo = especificaciones['alto']! / 100;

      final ladrilloConJunta = (largoLadrillo + juntaHorizontal / 100) * (altoLadrillo + juntaVertical / 100);
      final cantidadLadrillos = area / ladrilloConJunta;
      ladrillosTotal += cantidadLadrillos * (1 + desperdicioLadrillo);

      // Calcular volumen de mortero
      final volumeOfBricks = cantidadLadrillos * especificaciones['largo']! * especificaciones['ancho']! * especificaciones['alto']! / 1000000;
      final volumeOfJoints = area * (especificaciones['alto']! / 100) - volumeOfBricks;
      final morteroParaEstaArea = volumeOfJoints * (1 + desperdicioMortero);

      final factores = factoresMortero[ladrillo.proporcionMortero] ?? factoresMortero['4']!;

      cementoTotal += morteroParaEstaArea * factores['cemento']!;
      arenaTotal += morteroParaEstaArea * factores['arena']!;
      aguaTotal += morteroParaEstaArea * factores['agua']!;
    }

    return _MaterialCalculationResult(
      materials: {
        'Ladrillos': ladrillosTotal,
        'Cemento': cementoTotal,
        'Arena gruesa': arenaTotal,
        'Agua': aguaTotal,
      },
      area: areaTotal,
    );
  }

  /// Cálculos para estructuras (columnas y vigas) basados en el provider
  static _MaterialCalculationResult _calculateColumnaMaterials(List<Columna> columnas) {
    return _calculateStructuralMaterials(columnas);
  }

  static _MaterialCalculationResult _calculateVigaMaterials(List<Viga> vigas) {
    return _calculateStructuralMaterials(vigas);
  }

  static _MaterialCalculationResult _calculateStructuralMaterials(List<dynamic> elementos) {
    // Factores del provider de estructuras
    const Map<String, Map<String, double>> factoresConcreto = {
      "175 kg/cm²": {"cemento": 8.43, "arenaGruesa": 0.54, "piedraConcreto": 0.55, "agua": 0.185},
      "210 kg/cm²": {"cemento": 9.73, "arenaGruesa": 0.52, "piedraConcreto": 0.53, "agua": 0.186},
      "245 kg/cm²": {"cemento": 11.5, "arenaGruesa": 0.5, "piedraConcreto": 0.51, "agua": 0.187},
    };

    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;
    double areaTotal = 0.0;

    for (final elemento in elementos) {
      final volumen = _getStructuralVolume(elemento);
      if (volumen > 0) {
        final resistencia = elemento.resistencia ?? "175 kg/cm²";
        final factorDesperdicio = double.tryParse(elemento.factorDesperdicio ?? '0') ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia] ?? factoresConcreto["175 kg/cm²"]!;

        cementoTotal += factores["cemento"]! * volumen * (1 + desperdicioDecimal);
        arenaTotal += factores["arenaGruesa"]! * volumen * (1 + desperdicioDecimal);
        piedraTotal += factores["piedraConcreto"]! * volumen * (1 + desperdicioDecimal);
        aguaTotal += factores["agua"]! * volumen * (1 + desperdicioDecimal);

        // Para estructuras, el área es más bien el volumen total
        areaTotal += volumen;
      }
    }

    return _MaterialCalculationResult(
      materials: {
        'Cemento': cementoTotal,
        'Arena gruesa': arenaTotal,
        'Piedra chancada': piedraTotal,
        'Agua': aguaTotal,
      },
      area: areaTotal,
    );
  }

  /// Cálculos para losas basados en el provider
  static _MaterialCalculationResult _calculateLosaMaterials(List<LosaAligerada> losas) {
    const Map<String, Map<String, double>> volumenConcretoM2 = {
      'Ladrillo Hueco': {'17 cm': 0.08, '20 cm': 0.0875, '25 cm': 0.1001},
      'Bovedillas': {'17 cm': 0.0616, '20 cm': 0.0712, '25 cm': 0.085},
    };

    const Map<String, Map<String, double>> factoresConcreto = {
      '140 kg/cm²': {'cemento': 7.0, 'arena': 0.55, 'piedra': 0.65, 'agua': 0.18},
      '175 kg/cm²': {'cemento': 8.43, 'arena': 0.54, 'piedra': 0.55, 'agua': 0.185},
      '210 kg/cm²': {'cemento': 9.73, 'arena': 0.52, 'piedra': 0.53, 'agua': 0.186},
      '245 kg/cm²': {'cemento': 10.5, 'arena': 0.51, 'piedra': 0.52, 'agua': 0.186},
      '280 kg/cm²': {'cemento': 11.5, 'arena': 0.5, 'piedra': 0.51, 'agua': 0.187},
    };

    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;
    double ladrillosTotal = 0.0;
    double areaTotal = 0.0;

    for (var losa in losas) {
      double area = _getLosaArea(losa);
      areaTotal += area;

      double volConcretoM2 = volumenConcretoM2[losa.materialAligerado]?[losa.altura] ?? 0.08;
      double volConcretoTotal = volConcretoM2 * area;

      double desperdicioConcreto = (double.tryParse(losa.desperdicioConcreto ?? '5') ?? 5.0) / 100.0;
      double desperdicioLadrillo = (double.tryParse(losa.desperdicioLadrillo ?? '5') ?? 5.0) / 100.0;

      final factores = factoresConcreto[losa.resistenciaConcreto] ?? factoresConcreto['175 kg/cm²']!;

      cementoTotal += factores['cemento']! * volConcretoTotal * (1 + desperdicioConcreto);
      arenaTotal += factores['arena']! * volConcretoTotal * (1 + desperdicioConcreto);
      piedraTotal += factores['piedra']! * volConcretoTotal * (1 + desperdicioConcreto);
      aguaTotal += factores['agua']! * volConcretoTotal * (1 + desperdicioConcreto);

      ladrillosTotal += 9 * area * (1 + desperdicioLadrillo);
    }

    return _MaterialCalculationResult(
      materials: {
        'Cemento': cementoTotal,
        'Arena gruesa': arenaTotal,
        'Piedra chancada': piedraTotal,
        'Agua': aguaTotal,
        'Ladrillo hueco': ladrillosTotal,
      },
      area: areaTotal,
    );
  }

  /// Cálculos para tarrajeo basados en el provider
  static _MaterialCalculationResult _calculateTarrajeoMaterials(List<Tarrajeo> tarrajeos) {
    const Map<String, Map<String, double>> factoresMortero = {
      '4': {'cemento': 8.9, 'arena': 1.0, 'agua': 0.272},
      '5': {'cemento': 7.4, 'arena': 1.05, 'agua': 0.268},
      '6': {'cemento': 6.13, 'arena': 1.07, 'agua': 0.269},
    };

    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;
    double areaTotal = 0.0;

    for (var tarrajeo in tarrajeos) {
      double area = _getTarrajeoArea(tarrajeo);
      areaTotal += area;

      double espesor = double.tryParse(tarrajeo.espesor ?? '1.5') ?? 1.5;
      double volumen = area * (espesor / 100);

      double desperdicio = (double.tryParse(tarrajeo.factorDesperdicio ?? '5') ?? 5.0) / 100.0;

      final factores = factoresMortero[tarrajeo.proporcionMortero] ?? factoresMortero['5']!;

      cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
      arenaTotal += factores['arena']! * volumen * (1 + desperdicio);
      aguaTotal += factores['agua']! * volumen * (1 + desperdicio);
    }

    return _MaterialCalculationResult(
      materials: {
        'Cemento': cementoTotal,
        'Arena fina': arenaTotal,
        'Agua': aguaTotal,
      },
      area: areaTotal,
    );
  }

  /// Cálculos para pisos basados en el provider
  static _MaterialCalculationResult _calculatePisoMaterials(List<Piso> pisos) {
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;
    double areaTotal = 0.0;

    for (var piso in pisos) {
      double area = _getPisoArea(piso);
      areaTotal += area;

      double espesor = double.tryParse(piso.espesor ?? '5') ?? 5.0;
      double volumen = area * (espesor / 100);

      double desperdicio = (double.tryParse(piso.factorDesperdicio ?? '5') ?? 5.0) / 100.0;

      // Factores típicos para pisos (pueden ajustarse según el provider específico)
      cementoTotal += 7.0 * volumen * (1 + desperdicio);
      arenaTotal += 1.0 * volumen * (1 + desperdicio);
      aguaTotal += 0.25 * volumen * (1 + desperdicio);
    }

    return _MaterialCalculationResult(
      materials: {
        'Cemento': cementoTotal,
        'Arena gruesa': arenaTotal,
        'Agua': aguaTotal,
      },
      area: areaTotal,
    );
  }

  /// Combina materiales de diferentes metrados
  static void _combineMaterials(
      Map<String, CombinedMaterial> combinedMaterials,
      Map<String, double> metradoMaterials,
      String metradoName,
      ) {
    metradoMaterials.forEach((materialName, quantity) {
      if (combinedMaterials.containsKey(materialName)) {
        final existing = combinedMaterials[materialName]!;
        final newContributions = Map<String, double>.from(existing.contributions);
        newContributions[metradoName] = (newContributions[metradoName] ?? 0.0) + quantity;

        combinedMaterials[materialName] = existing.copyWith(
          totalQuantity: existing.totalQuantity + quantity,
          contributions: newContributions,
        );
      } else {
        combinedMaterials[materialName] = CombinedMaterial(
          name: materialName,
          unit: _getMaterialUnit(materialName),
          totalQuantity: quantity,
          contributions: {metradoName: quantity},
        );
      }
    });
  }

  /// Obtiene la unidad correcta para cada material
  static String _getMaterialUnit(String materialName) {
    final name = materialName.toLowerCase();
    if (name.contains('cemento')) return 'bls';
    if (name.contains('arena') || name.contains('piedra') || name.contains('agua')) return 'm³';
    if (name.contains('ladrillo')) return 'und';
    return 'und';
  }

  /// Calcula el área total de un metrado
  static double _calculateMetradoArea(List<dynamic> results) {
    double totalArea = 0.0;
    for (final result in results) {
      totalArea += _getSingleResultArea(result);
    }
    return totalArea;
  }

  /// Obtiene el área de un resultado individual
  static double _getSingleResultArea(dynamic result) {
    if (result is Ladrillo) return _getLadrilloArea(result);
    if (result is Piso) return _getPisoArea(result);
    if (result is LosaAligerada) return _getLosaArea(result);
    if (result is Tarrajeo) return _getTarrajeoArea(result);
    if (result is Columna || result is Viga) return _getStructuralVolume(result);
    return 0.0;
  }

  /// Obtiene los tipos de resultados en un metrado
  static List<String> _getResultTypes(List<dynamic> results) {
    final types = <String>{};
    for (final result in results) {
      if (result is Ladrillo) types.add('Ladrillo');
      if (result is Piso) types.add('Piso');
      if (result is LosaAligerada) types.add('Losa');
      if (result is Tarrajeo) types.add('Tarrajeo');
      if (result is Columna) types.add('Columna');
      if (result is Viga) types.add('Viga');
    }
    return types.toList();
  }

  // Funciones auxiliares para obtener áreas y volúmenes
  static double _getLadrilloArea(Ladrillo ladrillo) {
    if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
      return double.tryParse(ladrillo.area!) ?? 0.0;
    }
    final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
    final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
    return largo * altura;
  }

  static double _getPisoArea(Piso piso) {
    if (piso.area != null && piso.area!.isNotEmpty) {
      return double.tryParse(piso.area!) ?? 0.0;
    }
    final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
    final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
    return largo * ancho;
  }

  static double _getLosaArea(LosaAligerada losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    }
    final largo = double.tryParse(losa.largo ?? '') ?? 0.0;
    final ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
    return largo * ancho;
  }

  static double _getTarrajeoArea(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!) ?? 0.0;
    }
    final largo = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
    final altura = double.tryParse(tarrajeo.espesor ?? '') ?? 0.0;
    return largo * altura;
  }

  static double _getStructuralVolume(dynamic elemento) {
    if (elemento.volumen != null && elemento.volumen!.isNotEmpty) {
      return double.tryParse(elemento.volumen!) ?? 0.0;
    }
    final largo = double.tryParse(elemento.largo ?? '') ?? 0.0;
    final ancho = double.tryParse(elemento.ancho ?? '') ?? 0.0;
    final altura = double.tryParse(elemento.altura ?? '') ?? 0.0;
    return largo * ancho * altura;
  }

  static String _normalizarTipoLadrillo(String tipo) {
    final tipoLower = tipo.toLowerCase();
    if (tipoLower.contains('king') || tipoLower.contains('kong')) {
      return 'King Kong';
    } else if (tipoLower.contains('pandereta')) {
      return 'Pandereta';
    } else if (tipoLower.contains('artesanal') || tipoLower.contains('común')) {
      return 'Artesanal';
    }
    return 'Pandereta';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES DE DATOS PARA RESULTADOS COMBINADOS (SIN PRECIOS)
// ═══════════════════════════════════════════════════════════════════════════

/// Resultado de la combinación de múltiples metrados (sin precios)
class CombinedCalculationResult {
  final Map<String, CombinedMaterial> combinedMaterials;
  final List<MetradoSummary> metradoSummaries;
  final double totalArea;
  final String projectName;
  final DateTime combinationDate;
  final int metradoCount;

  const CombinedCalculationResult({
    required this.combinedMaterials,
    required this.metradoSummaries,
    required this.totalArea,
    required this.projectName,
    required this.combinationDate,
    required this.metradoCount,
  });

  /// Lista ordenada de materiales por cantidad
  List<CombinedMaterial> get sortedMaterials {
    final materials = combinedMaterials.values.toList();
    materials.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    return materials;
  }

  /// Material más usado
  CombinedMaterial? get topMaterial {
    if (combinedMaterials.isEmpty) return null;
    return sortedMaterials.first;
  }

  /// Estadísticas de la combinación (sin precios)
  CombinationStats get stats {
    return CombinationStats(
      totalMaterials: combinedMaterials.length,
      totalMetrados: metradoCount,
      totalArea: totalArea,
    );
  }
}

/// Material combinado con contribuciones de cada metrado (sin precios)
class CombinedMaterial {
  final String name;
  final String unit;
  final double totalQuantity;
  final Map<String, double> contributions;

  const CombinedMaterial({
    required this.name,
    required this.unit,
    required this.totalQuantity,
    required this.contributions,
  });

  CombinedMaterial copyWith({
    String? name,
    String? unit,
    double? totalQuantity,
    Map<String, double>? contributions,
  }) {
    return CombinedMaterial(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      contributions: contributions ?? this.contributions,
    );
  }

  /// Obtiene el porcentaje de contribución de un metrado específico
  double getContributionPercentage(String metradoName) {
    final contribution = contributions[metradoName] ?? 0.0;
    return totalQuantity > 0 ? (contribution / totalQuantity) * 100 : 0.0;
  }

  /// Metrado que más contribuye a este material
  String get topContributor {
    if (contributions.isEmpty) return '';
    return contributions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// Resumen de un metrado individual (sin precios)
class MetradoSummary {
  final int metradoId;
  final String metradoName;
  final Map<String, double> materials;
  final double area;
  final List<String> resultTypes;
  final int itemCount;

  const MetradoSummary({
    required this.metradoId,
    required this.metradoName,
    required this.materials,
    required this.area,
    required this.resultTypes,
    required this.itemCount,
  });

  /// Material principal de este metrado
  String get primaryMaterial {
    if (materials.isEmpty) return 'N/A';
    return materials.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// Datos de entrada para la combinación
class MetradoWithResults {
  final Metrado metrado;
  final List<dynamic> results;

  const MetradoWithResults({
    required this.metrado,
    required this.results,
  });
}

/// Estadísticas de la combinación (sin precios)
class CombinationStats {
  final int totalMaterials;
  final int totalMetrados;
  final double totalArea;

  const CombinationStats({
    required this.totalMaterials,
    required this.totalMetrados,
    required this.totalArea,
  });
}

/// Resultado interno para cálculos de materiales
class _MaterialCalculationResult {
  final Map<String, double> materials;
  final double area;

  const _MaterialCalculationResult({
    required this.materials,
    required this.area,
  });
}

/// Excepción para errores en la combinación
class CombinationException implements Exception {
  final String message;

  const CombinationException(this.message);

  @override
  String toString() => 'CombinationException: $message';
}