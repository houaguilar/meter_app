import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/home/acero/columna/steel_column.dart';
import '../../../../../domain/entities/home/acero/steel_beam_constants.dart';
import '../../../../../domain/entities/home/acero/steel_column_constants.dart';
import '../../../../../domain/entities/home/acero/viga/steel_bar.dart';
import '../../../../../domain/entities/home/acero/viga/stirrup_distribution.dart';

const uuid = Uuid();

// ============================================================================
// PROVIDERS PRINCIPALES
// ============================================================================

final steelColumnResultProvider = StateNotifierProvider<SteelColumnResultNotifier, List<SteelColumn>>((ref) {
  return SteelColumnResultNotifier();
});

final steelBarsForColumnProvider = StateNotifierProvider<SteelBarsForColumnNotifier, Map<String, List<SteelBar>>>((ref) {
  return SteelBarsForColumnNotifier();
});

final stirrupDistributionsForColumnProvider = StateNotifierProvider<StirrupDistributionsForColumnNotifier, Map<String, List<StirrupDistribution>>>((ref) {
  return StirrupDistributionsForColumnNotifier();
});

// Provider para calcular resultados individuales por columna
final calculateIndividualColumnSteelProvider = Provider.family<SteelColumnCalculationResult?, String>((ref, columnId) {
  final columns = ref.watch(steelColumnResultProvider);
  final allBars = ref.watch(steelBarsForColumnProvider);
  final allDistributions = ref.watch(stirrupDistributionsForColumnProvider);

  final column = columns.where((c) => c.idSteelColumn == columnId).firstOrNull;
  if (column == null) return null;

  final steelBars = allBars[columnId] ?? [];
  final stirrupDistributions = allDistributions[columnId] ?? [];

  return _calculateSteelForColumn(column, steelBars, stirrupDistributions);
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

/// Calcula el acero para una columna específica siguiendo el Excel
SteelColumnCalculationResult _calculateSteelForColumn(
    SteelColumn column,
    List<SteelBar> steelBars,
    List<StirrupDistribution> stirrupDistributions,
    ) {
  final Map<String, double> totalesPorDiametro = {};

  // **CÁLCULO DE ACERO LONGITUDINAL**
  for (final steelBar in steelBars) {
    // Longitud básica por barra: elementos × cantidad × altura de columna
    final longitudBasica = column.elements * steelBar.quantity * column.height;
    totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudBasica;

    // Agregar empalme si está habilitado
    if (column.useSplice) {
      final longitudEmpalme = column.elements * steelBar.quantity * (SteelBeamConstants.spliceLengths[steelBar.diameter] ?? 0.6);
      totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudEmpalme;
    }

    // Agregar doblez de zapata si está habilitada (solo para zapata)
    if (column.hasFooting) {
      final longitudDoblez = column.elements * steelBar.quantity * column.footingBend;
      totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudDoblez;
    }
  }

  // **CÁLCULO DE ESTRIBOS**
  // Calcular longitud cubierta por distribuciones
  double longitudCubierta = 0;
  int cantidadEstribosDistribucion = 0;

  for (final distribution in stirrupDistributions) {
    longitudCubierta += distribution.quantity * distribution.separation;
    cantidadEstribosDistribucion += distribution.quantity * 2; // x2 para ambos extremos
  }

  // Calcular estribos del resto
  final longitudRestante = column.height - (longitudCubierta * 2);
  int estribosResto = 0;
  if (column.restSeparation > 0 && longitudRestante > 0) {
    estribosResto = (longitudRestante / column.restSeparation).floor();
  }

  // Total de estribos
  final totalEstribos = estribosResto + cantidadEstribosDistribucion;

  // Calcular perímetro del estribo (columna rectangular)
  final perimetroEstribo = (column.length - (column.cover / 100)) * 2 +
      (column.width - (column.cover / 100)) * 2 +
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
      final varillas = longitud / SteelBeamConstants.standardRodLength;
      final varillasConDesperdicio = (varillas * (1 + column.waste)).ceil().toDouble();

      // Calcular peso
      final weightPerMeter = SteelBeamConstants.steelWeights[diameter] ?? 0.0;
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
  final alambreKg = pesoTotal * SteelBeamConstants.wirePercentage * (1 + column.waste);

  return SteelColumnCalculationResult(
    columnId: column.idSteelColumn,
    description: column.description,
    totalWeight: pesoTotal * (1 + column.waste),
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
  summary += "• Peso total de acero: ${result.totalWeight.toStringAsFixed(2)} kg\n";
  summary += "• Alambre #16: ${result.totalWire.toStringAsFixed(2)} kg\n";
  summary += "• Total de estribos: ${result.totalStirrups}\n\n";

  summary += "📋 MATERIALES CONSOLIDADOS:\n";
  result.consolidatedMaterials.forEach((diameter, material) {
    summary += "• Acero de $diameter: ${material.quantity.toStringAsFixed(0)} ${material.unit}\n";
  });

  summary += "\n🏗️ DETALLE POR COLUMNA:\n";
  for (int i = 0; i < result.columnResults.length; i++) {
    final columnResult = result.columnResults[i];
    summary += "\n${i + 1}. ${columnResult.description}:\n";
    summary += "   • Peso: ${columnResult.totalWeight.toStringAsFixed(2)} kg\n";
    summary += "   • Alambre: ${columnResult.wireWeight.toStringAsFixed(2)} kg\n";
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
    ref.read(steelBarsForColumnProvider.notifier).clearAll();
    ref.read(stirrupDistributionsForColumnProvider.notifier).clearAll();
  };
});

class SteelBarsForColumnNotifier extends StateNotifier<Map<String, List<SteelBar>>> {
  SteelBarsForColumnNotifier() : super({});

  void addBar(String columnId, SteelBar newBar) {
    final currentBars = state[columnId] ?? [];
    state = {
      ...state,
      columnId: [...currentBars, newBar],
    };
  }

  void addSteelBar(String columnId, int quantity, String diameter) {
    final newBar = SteelBar(
      idSteelBar: uuid.v4(),
      quantity: quantity,
      diameter: diameter,
    );

    final currentBars = state[columnId] ?? [];
    state = {
      ...state,
      columnId: [...currentBars, newBar],
    };
  }

  void updateBar(String columnId, int index, SteelBar updatedBar) {
    final currentBars = state[columnId] ?? [];
    if (index >= 0 && index < currentBars.length) {
      final newBars = List<SteelBar>.from(currentBars);
      newBars[index] = updatedBar;
      state = {
        ...state,
        columnId: newBars,
      };
    }
  }

  void removeBar(String columnId, int index) {
    final currentBars = state[columnId] ?? [];
    if (index >= 0 && index < currentBars.length) {
      final newBars = List<SteelBar>.from(currentBars);
      newBars.removeAt(index);
      state = {
        ...state,
        columnId: newBars,
      };
    }
  }

  List<SteelBar> getBarsForColumn(String columnId) {
    return state[columnId] ?? [];
  }

  void clearBarsForColumn(String columnId) {
    final newState = Map<String, List<SteelBar>>.from(state);
    newState.remove(columnId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

class StirrupDistributionsForColumnNotifier extends StateNotifier<Map<String, List<StirrupDistribution>>> {
  StirrupDistributionsForColumnNotifier() : super({});

  void addDistribution(String columnId, StirrupDistribution newDistribution) {
    final currentDistributions = state[columnId] ?? [];
    state = {
      ...state,
      columnId: [...currentDistributions, newDistribution],
    };
  }

  void addDistributionByValues(String columnId, int quantity, double separation) {
    final newDistribution = StirrupDistribution(
      idStirrupDistribution: uuid.v4(),
      quantity: quantity,
      separation: separation,
    );

    final currentDistributions = state[columnId] ?? [];
    state = {
      ...state,
      columnId: [...currentDistributions, newDistribution],
    };
  }

  void updateDistribution(String columnId, int index, StirrupDistribution updatedDistribution) {
    final currentDistributions = state[columnId] ?? [];
    if (index >= 0 && index < currentDistributions.length) {
      final newDistributions = List<StirrupDistribution>.from(currentDistributions);
      newDistributions[index] = updatedDistribution;
      state = {
        ...state,
        columnId: newDistributions,
      };
    }
  }

  void removeDistribution(String columnId, int index) {
    final currentDistributions = state[columnId] ?? [];
    if (index >= 0 && index < currentDistributions.length) {
      final newDistributions = List<StirrupDistribution>.from(currentDistributions);
      newDistributions.removeAt(index);
      state = {
        ...state,
        columnId: newDistributions,
      };
    }
  }

  List<StirrupDistribution> getDistributionsForColumn(String columnId) {
    return state[columnId] ?? [];
  }

  void clearDistributionsForColumn(String columnId) {
    final newState = Map<String, List<StirrupDistribution>>.from(state);
    newState.remove(columnId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}