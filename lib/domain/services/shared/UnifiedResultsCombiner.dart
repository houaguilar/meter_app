// lib/domain/services/shared/UnifiedResultsCombiner.dart

import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';

/// Servicio para combinar resultados de múltiples metrados
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
      double totalCost = 0.0;

      // Procesar cada metrado
      for (final metradoData in metradosWithResults) {
        final metrado = metradoData.metrado;
        final results = metradoData.results;

        // Calcular materiales de este metrado
        final metradoMaterials = _calculateMetradoMaterials(results);
        final metradoArea = _calculateMetradoArea(results);
        final metradoCost = _calculateMetradoCost(metradoMaterials);

        // Crear resumen del metrado
        final summary = MetradoSummary(
          metradoId: metrado.id,
          metradoName: metrado.name,
          materials: metradoMaterials,
          area: metradoArea,
          cost: metradoCost,
          resultTypes: _getResultTypes(results),
          itemCount: results.length,
        );
        metradoSummaries.add(summary);

        // Combinar materiales en el total
        _combineMaterials(combinedMaterials, metradoMaterials, metrado.name);

        totalArea += metradoArea;
        totalCost += metradoCost;
      }

      return CombinedCalculationResult(
        combinedMaterials: combinedMaterials,
        metradoSummaries: metradoSummaries,
        totalArea: totalArea,
        totalCost: totalCost,
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

  /// Calcula los materiales de un metrado específico
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

  /// Calcula materiales para un resultado individual usando UnifiedMaterialsCalculator
  static _MaterialCalculationResult _calculateSingleResult(dynamic result) {
    if (result is Ladrillo) {
      return _calculateLadrilloMaterials(result);
    } else if (result is Piso) {
      return _calculatePisoMaterials(result);
    } else if (result is LosaAligerada) {
      return _calculateLosaMaterials(result);
    } else if (result is Tarrajeo) {
      return _calculateTarrajeoMaterials(result);
    } else if (result is Columna) {
      return _calculateColumnaMaterials(result);
    } else if (result is Viga) {
      return _calculateVigaMaterials(result);
    }

    return _MaterialCalculationResult(materials: {}, area: 0.0);
  }

  /// Combina materiales en el mapa total
  static void _combineMaterials(
      Map<String, CombinedMaterial> combinedMaterials,
      Map<String, double> newMaterials,
      String metradoName,
      ) {
    newMaterials.forEach((materialName, quantity) {
      if (combinedMaterials.containsKey(materialName)) {
        // Material existente - sumar cantidad
        final existing = combinedMaterials[materialName]!;
        combinedMaterials[materialName] = existing.copyWith(
          totalQuantity: existing.totalQuantity + quantity,
          contributions: {
            ...existing.contributions,
            metradoName: (existing.contributions[metradoName] ?? 0.0) + quantity,
          },
        );
      } else {
        // Material nuevo - agregar
        combinedMaterials[materialName] = CombinedMaterial(
          name: materialName,
          unit: _getMaterialUnit(materialName),
          totalQuantity: quantity,
          contributions: {metradoName: quantity},
        );
      }
    });
  }

  /// Calcula el área total de un metrado
  static double _calculateMetradoArea(List<dynamic> results) {
    double totalArea = 0.0;

    for (final result in results) {
      if (result is Ladrillo) {
        totalArea += _getLadrilloArea(result);
      } else if (result is Piso) {
        totalArea += _getPisoArea(result);
      } else if (result is LosaAligerada) {
        totalArea += _getLosaArea(result);
      } else if (result is Tarrajeo) {
        totalArea += _getTarrajeoArea(result);
      }
      // Columnas y vigas se manejan por volumen, no área
    }

    return totalArea;
  }

  /// Estima el costo total basado en materiales
  static double _calculateMetradoCost(Map<String, double> materials) {
    double totalCost = 0.0;

    // Precios estimados por unidad (estos deberían venir de una base de datos)
    const materialPrices = {
      'Cemento': 25.0, // por kg
      'Arena': 80.0,   // por m³
      'Agua': 5.0,     // por litro
      'Ladrillos': 0.8, // por unidad
      'Concreto': 300.0, // por m³
      'Acero': 4.5,    // por kg
    };

    materials.forEach((material, quantity) {
      final price = materialPrices[material] ?? 0.0;
      totalCost += quantity * price;
    });

    return totalCost;
  }

  /// Obtiene los tipos de resultados en un metrado
  static List<String> _getResultTypes(List<dynamic> results) {
    final types = <String>{};

    for (final result in results) {
      if (result is Ladrillo) types.add('Ladrillos');
      else if (result is Piso) types.add('Pisos');
      else if (result is LosaAligerada) types.add('Losas');
      else if (result is Tarrajeo) types.add('Tarrajeos');
      else if (result is Columna) types.add('Columnas');
      else if (result is Viga) types.add('Vigas');
    }

    return types.toList();
  }

  /// Obtiene la unidad de medida para un material
  static String _getMaterialUnit(String materialName) {
    const materialUnits = {
      'Cemento': 'kg',
      'Arena': 'm³',
      'Agua': 'L',
      'Ladrillos': 'und',
      'Concreto': 'm³',
      'Acero': 'kg',
      'Ladrillo Hueco': 'und',
      'Ladrillo Sólido': 'und',
      'Mortero': 'm³',
    };

    return materialUnits[materialName] ?? 'und';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS ESPECÍFICOS POR TIPO DE MATERIAL
  // ═══════════════════════════════════════════════════════════════════════════

  static _MaterialCalculationResult _calculateLadrilloMaterials(Ladrillo ladrillo) {
    final materials = <String, double>{};
    final area = _getLadrilloArea(ladrillo);

    // Datos de tipos de ladrillos
    final Map<String, Map<String, double>> tiposLadrillo = {
      'Pandereta': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
      'Kingkong': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
    };

    final Map<String, Map<String, double>> proporcionesMortero = {
      '3': {'cemento': 454.0, 'arena': 1.1, 'agua': 250.0},
      '4': {'cemento': 364.0, 'arena': 1.16, 'agua': 240.0},
      '5': {'cemento': 302.0, 'arena': 1.2, 'agua': 240.0},
      '6': {'cemento': 261.0, 'arena': 1.2, 'agua': 235.0},
    };

    final tipoLadrillo = ladrillo.tipoLadrillo ?? 'Pandereta';
    final tipoAsentado = ladrillo.tipoAsentado ?? '5';

    // Calcular cantidad de ladrillos
    final dimensionesLadrillo = tiposLadrillo[tipoLadrillo] ?? tiposLadrillo['Pandereta']!;
    final areaLadrillo = (dimensionesLadrillo['largo']! * dimensionesLadrillo['alto']!) / 10000; // cm² a m²
    final cantidadLadrillos = (area / areaLadrillo) * 1.05; // 5% desperdicio

    // Calcular mortero
    final proporcionesMorteroData = proporcionesMortero[tipoAsentado] ?? proporcionesMortero['5']!;
    final volumenMortero = area * 0.02; // 2cm de espesor promedio

    materials['Ladrillos'] = cantidadLadrillos;
    materials['Cemento'] = volumenMortero * proporcionesMorteroData['cemento']!;
    materials['Arena'] = volumenMortero * proporcionesMorteroData['arena']!;
    materials['Agua'] = volumenMortero * proporcionesMorteroData['agua']!;

    return _MaterialCalculationResult(materials: materials, area: area);
  }

  static _MaterialCalculationResult _calculatePisoMaterials(Piso piso) {
    final materials = <String, double>{};
    final area = _getPisoArea(piso);

    // Cálculos básicos para pisos (simplificado)
    final espesor = double.tryParse(piso.espesor ?? '0.1') ?? 0.1; // metros
    final volumenConcreto = area * espesor;

    materials['Concreto'] = volumenConcreto;
    materials['Cemento'] = volumenConcreto * 350; // kg por m³
    materials['Arena'] = volumenConcreto * 0.5;
    materials['Agua'] = volumenConcreto * 180; // litros por m³

    return _MaterialCalculationResult(materials: materials, area: area);
  }

  static _MaterialCalculationResult _calculateLosaMaterials(LosaAligerada losa) {
    final materials = <String, double>{};
    final area = _getLosaArea(losa);

    // Cálculos para losa aligerada
    final espesor = double.tryParse(losa.altura ?? '0.2') ?? 0.2;
    final volumenConcreto = area * espesor * 0.6; // 60% concreto, 40% aligerante

    materials['Concreto'] = volumenConcreto;
    materials['Cemento'] = volumenConcreto * 380; // kg por m³
    materials['Arena'] = volumenConcreto * 0.4;
    materials['Acero'] = area * 15; // kg por m²

    return _MaterialCalculationResult(materials: materials, area: area);
  }

  static _MaterialCalculationResult _calculateTarrajeoMaterials(Tarrajeo tarrajeo) {
    final materials = <String, double>{};
    final area = _getTarrajeoArea(tarrajeo);

    // Cálculos para tarrajeo
    final espesor = double.tryParse(tarrajeo.espesor ?? '0.015') ?? 0.015; // 1.5cm
    final volumenMortero = area * espesor;

    materials['Cemento'] = volumenMortero * 400; // kg por m³
    materials['Arena'] = volumenMortero * 1.2;
    materials['Agua'] = volumenMortero * 200; // litros por m³

    return _MaterialCalculationResult(materials: materials, area: area);
  }

  static _MaterialCalculationResult _calculateColumnaMaterials(Columna columna) {
    final materials = <String, double>{};

    // Calcular volumen de la columna
    final largo = double.tryParse(columna.largo ?? '0') ?? 0;
    final ancho = double.tryParse(columna.ancho ?? '0') ?? 0;
    final altura = double.tryParse(columna.altura ?? '0') ?? 0;
    final volumen = (largo * ancho * altura) / 1000000; // cm³ a m³

    materials['Concreto'] = volumen;
    materials['Cemento'] = volumen * 420; // kg por m³
    materials['Arena'] = volumen * 0.4;
    materials['Acero'] = volumen * 120; // kg por m³

    return _MaterialCalculationResult(materials: materials, area: 0.0);
  }

  static _MaterialCalculationResult _calculateVigaMaterials(Viga viga) {
    final materials = <String, double>{};

    // Calcular volumen de la viga
    final largo = double.tryParse(viga.largo ?? '0') ?? 0;
    final ancho = double.tryParse(viga.ancho ?? '0') ?? 0;
    final altura = double.tryParse(viga.altura ?? '0') ?? 0;
    final volumen = (largo * ancho * altura) / 1000000; // cm³ a m³

    materials['Concreto'] = volumen;
    materials['Cemento'] = volumen * 420; // kg por m³
    materials['Arena'] = volumen * 0.4;
    materials['Acero'] = volumen * 100; // kg por m³

    return _MaterialCalculationResult(materials: materials, area: 0.0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES PARA OBTENER ÁREAS
  // ═══════════════════════════════════════════════════════════════════════════

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
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES DE DATOS PARA RESULTADOS COMBINADOS
// ═══════════════════════════════════════════════════════════════════════════

/// Resultado de la combinación de múltiples metrados
class CombinedCalculationResult {
  final Map<String, CombinedMaterial> combinedMaterials;
  final List<MetradoSummary> metradoSummaries;
  final double totalArea;
  final double totalCost;
  final String projectName;
  final DateTime combinationDate;
  final int metradoCount;

  const CombinedCalculationResult({
    required this.combinedMaterials,
    required this.metradoSummaries,
    required this.totalArea,
    required this.totalCost,
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

  /// Estadísticas de la combinación
  CombinationStats get stats {
    return CombinationStats(
      totalMaterials: combinedMaterials.length,
      totalMetrados: metradoCount,
      totalArea: totalArea,
      totalCost: totalCost,
      averageCostPerM2: totalArea > 0 ? totalCost / totalArea : 0,
    );
  }
}

/// Material combinado con contribuciones de cada metrado
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

/// Resumen de un metrado individual
class MetradoSummary {
  final int metradoId;
  final String metradoName;
  final Map<String, double> materials;
  final double area;
  final double cost;
  final List<String> resultTypes;
  final int itemCount;

  const MetradoSummary({
    required this.metradoId,
    required this.metradoName,
    required this.materials,
    required this.area,
    required this.cost,
    required this.resultTypes,
    required this.itemCount,
  });

  /// Costo por metro cuadrado
  double get costPerM2 => area > 0 ? cost / area : 0;

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

/// Estadísticas de la combinación
class CombinationStats {
  final int totalMaterials;
  final int totalMetrados;
  final double totalArea;
  final double totalCost;
  final double averageCostPerM2;

  const CombinationStats({
    required this.totalMaterials,
    required this.totalMetrados,
    required this.totalArea,
    required this.totalCost,
    required this.averageCostPerM2,
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