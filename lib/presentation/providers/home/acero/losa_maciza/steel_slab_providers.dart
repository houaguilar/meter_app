// lib/presentation/providers/home/acero/losa/steel_slab_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/domain/entities/home/acero/viga/steel_beam.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/home/acero/losa_maciza/mesh_enums.dart';
import '../../../../../domain/entities/home/acero/losa_maciza/steel_mesh_bar.dart';
import '../../../../../domain/entities/home/acero/losa_maciza/steel_slab.dart';
import '../../../../../domain/entities/home/acero/losa_maciza/steel_slab_constants.dart';
import '../../../../../domain/entities/home/acero/losa_maciza/superior_mesh_config.dart';
import '../../../../../domain/entities/home/acero/steel_beam_constants.dart' hide MaterialQuantity;

const uuid = Uuid();

// Helper functions para cálculos (siguiendo el patrón de vigas)
double calcularAreaLosa(SteelSlab slab) {
  return slab.length * slab.width;
}

double aplicarDesperdicio(double cantidad, double factorDesperdicio) {
  return cantidad * (1 + factorDesperdicio);
}

// ============================================================================
// PROVIDERS PRINCIPALES (MISMO PATRÓN QUE VIGAS)
// ============================================================================

final steelSlabResultProvider = StateNotifierProvider<SteelSlabResultNotifier, List<SteelSlab>>((ref) {
  return SteelSlabResultNotifier();
});

final steelMeshBarsForSlabProvider = StateNotifierProvider<SteelMeshBarsForSlabNotifier, Map<String, List<SteelMeshBar>>>((ref) {
  return SteelMeshBarsForSlabNotifier();
});

final superiorMeshConfigForSlabProvider = StateNotifierProvider<SuperiorMeshConfigForSlabNotifier, Map<String, SuperiorMeshConfig>>((ref) {
  return SuperiorMeshConfigForSlabNotifier();
});

// Provider para calcular resultados individuales por losa (siguiendo el patrón)
final calculateIndividualSlabSteelProvider = Provider.family<SteelSlabCalculationResult?, String>((ref, slabId) {
  final slabs = ref.watch(steelSlabResultProvider);
  final allMeshBars = ref.watch(steelMeshBarsForSlabProvider);
  final allConfigs = ref.watch(superiorMeshConfigForSlabProvider);

  final slab = slabs.where((s) => s.idSteelSlab == slabId).firstOrNull;
  if (slab == null) return null;

  final meshBars = allMeshBars[slabId] ?? [];
  final superiorConfig = allConfigs[slabId];

  return _calculateSteelForSlab(slab, meshBars, superiorConfig);
});

// Provider para calcular resultados consolidados (siguiendo el patrón)
final calculateConsolidatedSlabSteelProvider = Provider<ConsolidatedSteelSlabResult?>((ref) {
  final slabs = ref.watch(steelSlabResultProvider);
  if (slabs.isEmpty) return null;

  final List<SteelSlabCalculationResult> slabResults = [];
  double totalWeight = 0;
  double totalWire = 0;
  final Map<String, MaterialQuantity> consolidatedMaterials = {};

  // Calcular cada losa individualmente
  for (final slab in slabs) {
    final result = ref.read(calculateIndividualSlabSteelProvider(slab.idSteelSlab));
    if (result != null) {
      slabResults.add(result);
      totalWeight += result.totalWeight;
      totalWire += result.wireWeight;

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

  return ConsolidatedSteelSlabResult(
    numberOfSlabs: slabs.length,
    totalWeight: totalWeight,
    totalWire: totalWire,
    slabResults: slabResults,
    consolidatedMaterials: consolidatedMaterials,
  );
});

// Provider para generar texto de resumen consolidado (siguiendo el patrón)
final consolidatedSlabSummaryProvider = Provider<String>((ref) {
  final result = ref.watch(calculateConsolidatedSlabSteelProvider);
  if (result == null) return "";

  String summary = "=== RESUMEN CONSOLIDADO DE ACERO EN LOSAS ===\n\n";

  summary += "📊 RESULTADOS GENERALES:\n";
  summary += "• Número de losas: ${result.numberOfSlabs}\n";
  summary += "• Peso total de acero: ${result.totalWeight.toStringAsFixed(2)} kg\n";
  summary += "• Alambre #16: ${result.totalWire.toStringAsFixed(2)} kg\n\n";

  summary += "📋 MATERIALES CONSOLIDADOS:\n";
  result.consolidatedMaterials.forEach((diameter, material) {
    summary += "• Acero de $diameter: ${material.quantity.toStringAsFixed(0)} ${material.unit}\n";
  });

  summary += "\n🏗️ DETALLE POR LOSA:\n";
  for (int i = 0; i < result.slabResults.length; i++) {
    final slabResult = result.slabResults[i];
    summary += "\n${i + 1}. ${slabResult.description}:\n";
    summary += "   • Peso: ${slabResult.totalWeight.toStringAsFixed(2)} kg\n";
    summary += "   • Alambre: ${slabResult.wireWeight.toStringAsFixed(2)} kg\n";
  }

  summary += "\n---\nGenerado por MeterApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

  return summary;
});

// ============================================================================
// NOTIFIERS (SIGUIENDO EL PATRÓN DE VIGAS)
// ============================================================================

class SteelSlabResultNotifier extends StateNotifier<List<SteelSlab>> {
  SteelSlabResultNotifier() : super([]);

  void createSteelSlab({
    required String description,
    required double waste,
    required int elements,
    required double length,
    required double width,
    required double bendLength,
  }) {
    final newSteelSlab = SteelSlab(
      idSteelSlab: uuid.v4(),
      description: description,
      waste: waste,
      elements: elements,
      length: length,
      width: width,
      bendLength: bendLength,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Validar que la losa tenga datos suficientes
    final area = calcularAreaLosa(newSteelSlab);
    if (area <= 0) {
      throw Exception("La losa debe tener dimensiones válidas.");
    }

    print('✅ Nueva losa de acero creada: ${newSteelSlab.description}, área: ${area.toStringAsFixed(2)} m²');
    state = [...state, newSteelSlab];
  }

  void updateSteelSlab(int index, SteelSlab updatedSlab) {
    if (index >= 0 && index < state.length) {
      final newList = List<SteelSlab>.from(state);
      newList[index] = updatedSlab.copyWith(updatedAt: DateTime.now());
      state = newList;
    }
  }

  void removeSteelSlab(int index) {
    if (index >= 0 && index < state.length) {
      final newList = List<SteelSlab>.from(state);
      newList.removeAt(index);
      state = newList;
    }
  }

  void clearList() {
    print('🧹 Limpiando lista de losas de acero');
    state = [];
  }
}

class SteelMeshBarsForSlabNotifier extends StateNotifier<Map<String, List<SteelMeshBar>>> {
  SteelMeshBarsForSlabNotifier() : super({});

  void addMeshBar(String slabId, MeshType meshType, MeshDirection direction, String diameter, double separation) {
    final newMeshBar = SteelMeshBar(
      idSteelMeshBar: uuid.v4(),
      meshType: meshType,
      direction: direction,
      diameter: diameter,
      separation: separation,
    );

    final currentBars = state[slabId] ?? [];
    state = {
      ...state,
      slabId: [...currentBars, newMeshBar],
    };
  }

  void updateMeshBar(String slabId, int index, SteelMeshBar updatedBar) {
    final currentBars = state[slabId] ?? [];
    if (index >= 0 && index < currentBars.length) {
      final newBars = List<SteelMeshBar>.from(currentBars);
      newBars[index] = updatedBar;
      state = {
        ...state,
        slabId: newBars,
      };
    }
  }

  void removeMeshBar(String slabId, int index) {
    final currentBars = state[slabId] ?? [];
    if (index >= 0 && index < currentBars.length) {
      final newBars = List<SteelMeshBar>.from(currentBars);
      newBars.removeAt(index);
      state = {
        ...state,
        slabId: newBars,
      };
    }
  }

  List<SteelMeshBar> getBarsForSlab(String slabId) {
    return state[slabId] ?? [];
  }

  void clearBarsForSlab(String slabId) {
    final newState = Map<String, List<SteelMeshBar>>.from(state);
    newState.remove(slabId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

class SuperiorMeshConfigForSlabNotifier extends StateNotifier<Map<String, SuperiorMeshConfig>> {
  SuperiorMeshConfigForSlabNotifier() : super({});

  void setSuperioryMeshEnabled(String slabId, bool enabled) {
    final config = SuperiorMeshConfig(
      idConfig: uuid.v4(),
      enabled: enabled,
    );

    state = {
      ...state,
      slabId: config,
    };
  }

  bool isSuperioryMeshEnabled(String slabId) {
    return state[slabId]?.enabled ?? false;
  }

  void clearConfigForSlab(String slabId) {
    final newState = Map<String, SuperiorMeshConfig>.from(state);
    newState.remove(slabId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

// ============================================================================
// FUNCIONES DE CÁLCULO (SIGUIENDO LA LÓGICA DEL EXCEL)
// ============================================================================

/// Calcula el acero para una losa específica
SteelSlabCalculationResult _calculateSteelForSlab(
    SteelSlab slab,
    List<SteelMeshBar> meshBars,
    SuperiorMeshConfig? superiorConfig,
    ) {
  final Map<String, double> totalesPorDiametro = {};

  // Separar barras por malla
  final inferiorBars = meshBars.where((bar) => bar.meshType == MeshType.inferior).toList();
  final superiorBars = meshBars.where((bar) => bar.meshType == MeshType.superior).toList();

  // **CÁLCULO DE MALLA INFERIOR** (siempre presente)
  final inferiorMeshCalc = _calculateMeshSteel(slab, inferiorBars, MeshType.inferior);

  // **CÁLCULO DE MALLA SUPERIOR** (solo si está habilitada)
  SlabMeshCalculation? superiorMeshCalc;
  if (superiorConfig?.enabled == true && superiorBars.isNotEmpty) {
    superiorMeshCalc = _calculateMeshSteel(slab, superiorBars, MeshType.superior);
  }

  // Agregar totales por diámetro
  _addMeshTotals(totalesPorDiametro, inferiorMeshCalc, slab.elements);
  if (superiorMeshCalc != null) {
    _addMeshTotals(totalesPorDiametro, superiorMeshCalc, slab.elements);
  }

  // **CÁLCULO DE TOTALES CON DESPERDICIO**
  double pesoTotal = 0;
  final Map<String, MaterialQuantity> materials = {};

  totalesPorDiametro.forEach((diameter, longitud) {
    if (longitud > 0) {
      // Convertir a varillas (9m por varilla)
      final varillas = longitud / SteelBeamConstants.standardRodLength;
      final varillasConDesperdicio = (varillas * (1 + slab.waste)).ceil().toDouble();

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
  final alambreKg = pesoTotal * SteelBeamConstants.wirePercentage * (1 + slab.waste);

  return SteelSlabCalculationResult(
    slabId: slab.idSteelSlab,
    description: slab.description,
    totalWeight: pesoTotal * (1 + slab.waste),
    wireWeight: alambreKg,
    materials: materials,
    totalsByDiameter: totalesPorDiametro,
    inferiorMesh: inferiorMeshCalc,
    superiorMesh: superiorMeshCalc,
  );
}

/// Calcula el acero para una malla específica (siguiendo la lógica del Excel)
SlabMeshCalculation _calculateMeshSteel(SteelSlab slab, List<SteelMeshBar> meshBars, MeshType meshType) {
  // Separar por dirección
  final horizontalBar = meshBars.where((bar) => bar.direction == MeshDirection.horizontal).firstOrNull;
  final verticalBar = meshBars.where((bar) => bar.direction == MeshDirection.vertical).firstOrNull;

  // Calcular horizontal
  final horizontalCalc = _calculateDirectionSteel(slab, horizontalBar, MeshDirection.horizontal);

  // Calcular vertical
  final verticalCalc = _calculateDirectionSteel(slab, verticalBar, MeshDirection.vertical);

  // Peso total de la malla
  final totalWeight = horizontalCalc.weight + verticalCalc.weight;

  return SlabMeshCalculation(
    type: meshType,
    horizontal: horizontalCalc,
    vertical: verticalCalc,
    totalWeight: totalWeight,
  );
}

/// Calcula el acero para una dirección específica (horizontal o vertical)
SlabDirectionCalculation _calculateDirectionSteel(SteelSlab slab, SteelMeshBar? meshBar, MeshDirection direction) {
  if (meshBar == null) {
    return SlabDirectionCalculation(
      diameter: '',
      separation: 0,
      quantity: 0,
      lengthPerBar: 0,
      totalLength: 0,
      weight: 0,
    );
  }

  // Según el Excel:
  // Cantidad horizontal = ROUNDUP(ancho/separación + 1, 0)
  // Cantidad vertical = ROUNDUP(largo/separación + 1, 0)
  // Longitud horizontal = largo + doblez
  // Longitud vertical = ancho + doblez

  final int quantity;
  final double lengthPerBar;

  if (direction == MeshDirection.horizontal) {
    quantity = ((slab.width / meshBar.separation) + 1).ceil();
    lengthPerBar = slab.length + slab.bendLength;
  } else {
    quantity = ((slab.length / meshBar.separation) + 1).ceil();
    lengthPerBar = slab.width + slab.bendLength;
  }

  final totalLength = quantity * lengthPerBar;
  final weightPerMeter = SteelBeamConstants.steelWeights[meshBar.diameter] ?? 0.0;
  final weight = totalLength * weightPerMeter;

  return SlabDirectionCalculation(
    diameter: meshBar.diameter,
    separation: meshBar.separation,
    quantity: quantity,
    lengthPerBar: lengthPerBar,
    totalLength: totalLength,
    weight: weight,
  );
}

/// Agrega los totales de una malla al mapa de totales por diámetro
void _addMeshTotals(Map<String, double> totalesPorDiametro, SlabMeshCalculation meshCalc, int elements) {
  // Horizontal
  if (meshCalc.horizontal.totalLength > 0) {
    final diameter = meshCalc.horizontal.diameter;
    totalesPorDiametro[diameter] = (totalesPorDiametro[diameter] ?? 0.0) +
        (meshCalc.horizontal.totalLength * elements);
  }

  // Vertical
  if (meshCalc.vertical.totalLength > 0) {
    final diameter = meshCalc.vertical.diameter;
    totalesPorDiametro[diameter] = (totalesPorDiametro[diameter] ?? 0.0) +
        (meshCalc.vertical.totalLength * elements);
  }
}

// ============================================================================
// PROVIDERS ADICIONALES (SIGUIENDO EL PATRÓN)
// ============================================================================

final availableDiametersProvider = Provider<List<String>>((ref) {
  return SteelBeamConstants.availableDiameters;
});

// Provider para datos de compartir (texto consolidado)
final datosShareSteelSlabProvider = Provider<String>((ref) {
  return ref.watch(consolidatedSlabSummaryProvider);
});

// Provider para validar si hay datos listos para calcular
final canCalculateSlabProvider = Provider<bool>((ref) {
  final slabs = ref.watch(steelSlabResultProvider);
  return slabs.isNotEmpty;
});

// Provider para obtener estadísticas rápidas
final quickSlabStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final result = ref.watch(calculateConsolidatedSlabSteelProvider);
  if (result == null) {
    return {
      'totalSlabs': 0,
      'totalWeight': 0.0,
      'totalWire': 0.0,
    };
  }

  return {
    'totalSlabs': result.numberOfSlabs,
    'totalWeight': result.totalWeight,
    'totalWire': result.totalWire,
  };
});

// Provider para limpiar todos los datos
final clearAllSlabDataProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(steelSlabResultProvider.notifier).clearList();
    ref.read(steelMeshBarsForSlabProvider.notifier).clearAll();
    ref.read(superiorMeshConfigForSlabProvider.notifier).clearAll();
  };
});