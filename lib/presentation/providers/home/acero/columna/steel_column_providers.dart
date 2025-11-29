import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/entities/home/acero/columna/steel_column.dart';
import '../../../../../domain/entities/home/acero/steel_constants.dart';

// ============================================================================
// PROVIDERS PRINCIPALES
// ============================================================================

final steelColumnResultProvider = StateNotifierProvider<SteelColumnResultNotifier, List<SteelColumn>>((ref) {
  return SteelColumnResultNotifier();
});

// Provider para calcular resultados individuales por columna
final calculateIndividualColumnSteelProvider = Provider.family<SteelColumnCalculationResult?, String>((ref, columnId) {
  final columns = ref.watch(steelColumnResultProvider);

  final column = columns.where((c) => c.idSteelColumn == columnId).firstOrNull;
  if (column == null) return null;

  return _calculateSteelForColumn(column);
});

// Provider para calcular resultados consolidados de todas las columnas
final calculateConsolidatedColumnSteelProvider = Provider<ConsolidatedColumnSteelResult?>((ref) {
  final columns = ref.watch(steelColumnResultProvider);
  if (columns.isEmpty) return null;

  final List<SteelColumnCalculationResult> columnResults = [];
  double totalWeight = 0;
  double totalWire = 0;
  int totalStirrups = 0;
  final Map<String, MaterialQuantity> consolidatedMaterials = {};

  // Calcular cada columna individualmente
  for (final column in columns) {
    final result = ref.read(calculateIndividualColumnSteelProvider(column.idSteelColumn));
    if (result != null) {
      columnResults.add(result);
      totalWeight += result.totalWeight;
      totalWire += result.wireWeight;
      totalStirrups += result.totalStirrups;

      // Consolidar materiales por diámetro
      result.materials.forEach((diameter, material) {
        if (consolidatedMaterials.containsKey(diameter)) {
          final existing = consolidatedMaterials[diameter]!;
          consolidatedMaterials[diameter] = MaterialQuantity(
            quantity: existing.quantity + material.quantity,
            unit: material.unit,
          );
        } else {
          consolidatedMaterials[diameter] = material;
        }
      });
    }
  }

  return ConsolidatedColumnSteelResult(
    numberOfColumns: columns.length,
    totalWeight: totalWeight,
    totalWire: totalWire,
    totalStirrups: totalStirrups,
    columnResults: columnResults,
    consolidatedMaterials: consolidatedMaterials,
  );
});

// ============================================================================
// FUNCIONES DE CÁLCULO ESPECÍFICAS PARA COLUMNAS
// ============================================================================

/// Calcula el acero para una columna específica usando listas embebidas
SteelColumnCalculationResult _calculateSteelForColumn(SteelColumn column) {
  final Map<String, double> totalesPorDiametro = {};

  // **CÁLCULO DE ACERO LONGITUDINAL** - Ahora usando column.steelBars directamente
  for (final steelBar in column.steelBars) {
    // Calcular altura total (columna + zapata si está habilitada)
    double alturaTotal = column.height;
    if (column.hasFooting) {
      alturaTotal += column.footingHeight;
    }

    // Longitud básica por barra: elementos × cantidad × altura total
    final longitudBasica = column.elements * steelBar.quantity * alturaTotal;
    totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudBasica;

    // Agregar empalme si está habilitado
    if (column.useSplice) {
      final longitudEmpalme = column.elements * steelBar.quantity * (SteelConstants.spliceLengths[steelBar.diameter] ?? 0.6);
      totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudEmpalme;
    }

    // Agregar doblez de zapata si está habilitada (solo para zapata)
    if (column.hasFooting) {
      final longitudDoblez = column.elements * steelBar.quantity * column.footingBend;
      totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudDoblez;
    }
  }

  // **CÁLCULO DE ESTRIBOS** - Ahora usando column.stirrupDistributions directamente
  // Calcular altura total para estribos (columna + zapata si está habilitada)
  double alturaTotalEstribos = column.height;
  if (column.hasFooting) {
    alturaTotalEstribos += column.footingHeight;
  }

  // Calcular longitud cubierta por distribuciones
  double longitudCubierta = 0;
  int cantidadEstribosDistribucion = 0;

  for (final distribution in column.stirrupDistributions) {
    longitudCubierta += distribution.quantity * distribution.separation;
    cantidadEstribosDistribucion += distribution.quantity * 2; // x2 para ambos extremos
  }

  // Calcular estribos del resto usando altura total
  final longitudRestante = alturaTotalEstribos - (longitudCubierta * 2);
  int estribosResto = 0;
  if (column.restSeparation > 0 && longitudRestante > 0) {
    estribosResto = (longitudRestante / column.restSeparation).floor();
  }

  // Total de estribos
  final totalEstribos = estribosResto + cantidadEstribosDistribucion;

  // Calcular perímetro del estribo (columna rectangular)
  // Nota: El recubrimiento de estribos se resta dos veces (ambos lados)
  // Usa stirrupCover (no cover) como en el Excel
  final perimetroEstribo = (column.length - (column.stirrupCover / 100 * 2)) * 2 +
      (column.width - (column.stirrupCover / 100 * 2)) * 2 +
      column.stirrupBendLength * 2;

  // Longitud total de estribos
  final longitudTotalEstribos = column.elements * totalEstribos * perimetroEstribo;
  totalesPorDiametro[column.stirrupDiameter] =
      (totalesPorDiametro[column.stirrupDiameter] ?? 0.0) + longitudTotalEstribos;

  // **CÁLCULO DE TOTALES CON DESPERDICIO**
  double pesoTotal = 0;
  final Map<String, MaterialQuantity> materials = {};

  totalesPorDiametro.forEach((diameter, longitud) {
    if (longitud > 0) {
      // Convertir a varillas (9m por varilla)
      final varillas = longitud / SteelConstants.standardRodLength;
      final varillasConDesperdicio = varillas * (1 + column.waste);

      // Calcular peso
      final weightPerMeter = SteelConstants.steelWeights[diameter] ?? 0.0;
      final pesoKg = longitud * weightPerMeter;
      pesoTotal += pesoKg;

      if (varillasConDesperdicio > 0) {
        materials[diameter] = MaterialQuantity(
          quantity: varillasConDesperdicio,
          unit: 'Varillas',
        );
      }
    }
  });

  // Calcular alambre (1.5% del peso total con desperdicio)
  final alambreKg = pesoTotal * SteelConstants.wirePercentage * (1 + column.waste);

  return SteelColumnCalculationResult(
    columnId: column.idSteelColumn,
    description: column.description,
    totalWeight: pesoTotal,  // Peso sin desperdicio (el desperdicio ya se aplicó a las varillas)
    wireWeight: alambreKg,
    totalStirrups: totalEstribos * column.elements,
    stirrupPerimeter: perimetroEstribo,
    materials: materials,
    totalsByDiameter: totalesPorDiametro,
    hasFooting: column.hasFooting,
  );
}

// ============================================================================
// STATE NOTIFIERS PARA COLUMNAS
// ============================================================================

class SteelColumnResultNotifier extends StateNotifier<List<SteelColumn>> {
  SteelColumnResultNotifier() : super([]);

  void addColumn(SteelColumn column) {
    state = [...state, column];
  }

  void updateColumn(int index, SteelColumn updatedColumn) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList[index] = updatedColumn;
      state = newList;
    }
  }

  void removeColumn(int index) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    }
  }

  void clearList() {
    print('🧹 Limpiando lista de columnas de acero');
    state = [];
  }
}

// Provider para generar texto de resumen consolidado de columnas
final consolidatedColumnSummaryProvider = Provider<String>((ref) {
  final result = ref.watch(calculateConsolidatedColumnSteelProvider);
  if (result == null) return "";

  String summary = "=== RESUMEN CONSOLIDADO DE ACERO EN COLUMNAS ===\n\n";

  summary += "📊 RESULTADOS GENERALES:\n";
  summary += "• Número de columnas: ${result.numberOfColumns}\n";
  summary += "• Peso total de acero: ${result.totalWeight.toStringAsFixed(1)} kg\n";
  summary += "• Alambre #16: ${result.totalWire.toStringAsFixed(1)} kg\n";
  summary += "• Total de estribos: ${result.totalStirrups}\n\n";

  summary += "📋 MATERIALES CONSOLIDADOS:\n";
  result.consolidatedMaterials.forEach((diameter, material) {
    summary += "• Acero de $diameter: ${material.quantity.toStringAsFixed(0)} ${material.unit}\n";
  });

  summary += "\n🏗️ DETALLE POR COLUMNA:\n";
  for (int i = 0; i < result.columnResults.length; i++) {
    final columnResult = result.columnResults[i];
    summary += "\n${i + 1}. ${columnResult.description}:\n";
    summary += "   • Peso: ${columnResult.totalWeight.toStringAsFixed(1)} kg\n";
    summary += "   • Alambre: ${columnResult.wireWeight.toStringAsFixed(1)} kg\n";
    summary += "   • Estribos: ${columnResult.totalStirrups}\n";
    if (columnResult.hasFooting) {
      summary += "   • Con zapata: Sí\n";
    }
  }

  summary += "\n---\nGenerado por MeterApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

  return summary;
});

// Provider para obtener resumen de columnas creadas
final columnsSummaryProvider = Provider<String>((ref) {
  final columns = ref.watch(steelColumnResultProvider);
  if (columns.isEmpty) return "No hay columnas configuradas";

  if (columns.length == 1) {
    return "1 columna: ${columns.first.description}";
  } else {
    return "${columns.length} columnas: ${columns.map((c) => c.description).join(', ')}";
  }
});

// Provider para obtener estadísticas rápidas de columnas
final quickStatsColumnProvider = Provider<Map<String, dynamic>>((ref) {
  final result = ref.watch(calculateConsolidatedColumnSteelProvider);
  if (result == null) {
    return {
      'totalColumns': 0,
      'totalWeight': 0.0,
      'totalWire': 0.0,
      'totalStirrups': 0,
    };
  }

  return {
    'totalColumns': result.numberOfColumns,
    'totalWeight': result.totalWeight,
    'totalWire': result.totalWire,
    'totalStirrups': result.totalStirrups,
  };
});

// Provider para datos de compartir (texto consolidado) de columnas
final datosShareSteelColumnProvider = Provider<String>((ref) {
  return ref.watch(consolidatedColumnSummaryProvider);
});

// Provider para validar si hay datos listos para calcular columnas
final canCalculateColumnProvider = Provider<bool>((ref) {
  final columns = ref.watch(steelColumnResultProvider);
  return columns.isNotEmpty;
});

// Provider para limpiar todos los datos de columnas
final clearAllColumnDataProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(steelColumnResultProvider.notifier).clearList();
  };
});

// ============================================================================
// CLASES DE DATOS PARA RESULTADOS
// ============================================================================

class MaterialQuantity {
  final double quantity;
  final String unit;

  const MaterialQuantity({
    required this.quantity,
    required this.unit,
  });
}

class SteelColumnCalculationResult {
  final String columnId;
  final String description;
  final double totalWeight;
  final double wireWeight;
  final int totalStirrups;
  final double stirrupPerimeter;
  final Map<String, MaterialQuantity> materials;
  final Map<String, double> totalsByDiameter;
  final bool hasFooting;

  const SteelColumnCalculationResult({
    required this.columnId,
    required this.description,
    required this.totalWeight,
    required this.wireWeight,
    required this.totalStirrups,
    required this.stirrupPerimeter,
    required this.materials,
    required this.totalsByDiameter,
    required this.hasFooting,
  });
}

class ConsolidatedColumnSteelResult {
  final int numberOfColumns;
  final double totalWeight;
  final double totalWire;
  final int totalStirrups;
  final List<SteelColumnCalculationResult> columnResults;
  final Map<String, MaterialQuantity> consolidatedMaterials;

  const ConsolidatedColumnSteelResult({
    required this.numberOfColumns,
    required this.totalWeight,
    required this.totalWire,
    required this.totalStirrups,
    required this.columnResults,
    required this.consolidatedMaterials,
  });
}
