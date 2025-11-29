import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/home/acero/losa_maciza/mesh_enums.dart';
import '../../../../../domain/entities/home/acero/losa_maciza/steel_slab.dart';
import '../../../../../domain/entities/home/acero/steel_constants.dart';

const uuid = Uuid();

// ============================================================================
// PROVIDERS PRINCIPALES
// ============================================================================

final steelSlabResultProvider = StateNotifierProvider<SteelSlabResultNotifier, List<SteelSlab>>((ref) {
  return SteelSlabResultNotifier();
});

// Provider para calcular resultados individuales por losa
final calculateIndividualSlabSteelProvider = Provider.family<SteelSlabCalculationResult?, String>((ref, slabId) {
  final slabs = ref.watch(steelSlabResultProvider);

  final slab = slabs.where((s) => s.idSteelSlab == slabId).firstOrNull;
  if (slab == null) return null;

  return _calculateSteelForSlab(slab);
});

// Provider para calcular resultados consolidados
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

// ============================================================================
// FUNCIONES DE CÁLCULO
// ============================================================================

/// Calcula el acero para una losa específica usando listas embebidas
SteelSlabCalculationResult _calculateSteelForSlab(SteelSlab slab) {
  final Map<String, double> totalesPorDiametro = {};

  // **CÁLCULO DE BARRAS DE MALLA** - Ahora usando slab.meshBars directamente
  for (final meshBar in slab.meshBars) {
    double longitudTotal = 0;

    // Calcular longitud según dirección
    if (meshBar.direction == MeshDirection.horizontal) {
      // Cantidad de barras: ancho / separación + 1
      final cantidad = ((slab.width / meshBar.separation) + 1).floor();
      // Longitud por barra: largo + 2*doblez
      final longitudPorBarra = slab.length + (2 * slab.bendLength);
      longitudTotal = slab.elements * cantidad * longitudPorBarra;
    } else {
      // Vertical
      // Cantidad de barras: largo / separación + 1
      final cantidad = ((slab.length / meshBar.separation) + 1).floor();
      // Longitud por barra: ancho + 2*doblez
      final longitudPorBarra = slab.width + (2 * slab.bendLength);
      longitudTotal = slab.elements * cantidad * longitudPorBarra;
    }

    // Agregar al total por diámetro
    totalesPorDiametro[meshBar.diameter] =
        (totalesPorDiametro[meshBar.diameter] ?? 0.0) + longitudTotal;
  }

  // **CÁLCULO DE TOTALES CON DESPERDICIO**
  double pesoTotal = 0;
  final Map<String, MaterialQuantity> materials = {};

  totalesPorDiametro.forEach((diameter, longitud) {
    if (longitud > 0) {
      // Convertir a varillas (9m por varilla)
      final varillas = longitud / SteelConstants.standardRodLength;
      final varillasConDesperdicio = varillas * (1 + slab.waste);  // Mantiene decimales (Excel no redondea)

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
  final alambreKg = pesoTotal * SteelConstants.wirePercentage * (1 + slab.waste);

  return SteelSlabCalculationResult(
    slabId: slab.idSteelSlab,
    description: slab.description,
    totalWeight: pesoTotal,  // Peso sin desperdicio (Excel no aplica desperdicio al peso)
    wireWeight: alambreKg,
    materials: materials,
    totalsByDiameter: totalesPorDiametro,
    hasSuperiorMesh: slab.superiorMeshConfig.enabled,
  );
}

// ============================================================================
// STATE NOTIFIER
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
    required List<SteelMeshBarEmbedded> meshBars,
    required SuperiorMeshConfigEmbedded superiorMeshConfig,
  }) {
    final newSteelSlab = SteelSlab(
      idSteelSlab: uuid.v4(),
      description: description,
      waste: waste,
      elements: elements,
      length: length,
      width: width,
      bendLength: bendLength,
      meshBars: meshBars,
      superiorMeshConfig: superiorMeshConfig,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = [...state, newSteelSlab];
  }

  void addSlab(SteelSlab slab) {
    state = [...state, slab];
  }

  void updateSlab(int index, SteelSlab updatedSlab) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList[index] = updatedSlab;
      state = newList;
    }
  }

  void removeSlab(int index) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    }
  }

  void clearList() {
    print('🧹 Limpiando lista de losas de acero');
    state = [];
  }
}

// Provider para generar texto de resumen consolidado
final consolidatedSlabSummaryProvider = Provider<String>((ref) {
  final result = ref.watch(calculateConsolidatedSlabSteelProvider);
  if (result == null) return "";

  String summary = "=== RESUMEN CONSOLIDADO DE ACERO EN LOSAS ===\n\n";

  summary += "📊 RESULTADOS GENERALES:\n";
  summary += "• Número de losas: ${result.numberOfSlabs}\n";
  summary += "• Peso total de acero: ${result.totalWeight.toStringAsFixed(1)} kg\n";
  summary += "• Alambre #16: ${result.totalWire.toStringAsFixed(1)} kg\n\n";

  summary += "📋 MATERIALES CONSOLIDADOS:\n";
  result.consolidatedMaterials.forEach((diameter, material) {
    summary += "• Acero de $diameter: ${material.quantity.toStringAsFixed(0)} ${material.unit}\n";
  });

  summary += "\n🏗️ DETALLE POR LOSA:\n";
  for (int i = 0; i < result.slabResults.length; i++) {
    final slabResult = result.slabResults[i];
    summary += "\n${i + 1}. ${slabResult.description}:\n";
    summary += "   • Peso: ${slabResult.totalWeight.toStringAsFixed(1)} kg\n";
    summary += "   • Alambre: ${slabResult.wireWeight.toStringAsFixed(1)} kg\n";
    if (slabResult.hasSuperiorMesh) {
      summary += "   • Con malla superior\n";
    }
  }

  summary += "\n---\nGenerado por MeterApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

  return summary;
});

// Provider para obtener resumen de losas creadas
final slabsSummaryProvider = Provider<String>((ref) {
  final slabs = ref.watch(steelSlabResultProvider);
  if (slabs.isEmpty) return "No hay losas configuradas";

  if (slabs.length == 1) {
    return "1 losa: ${slabs.first.description}";
  } else {
    return "${slabs.length} losas: ${slabs.map((s) => s.description).join(', ')}";
  }
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

class SteelSlabCalculationResult {
  final String slabId;
  final String description;
  final double totalWeight;
  final double wireWeight;
  final Map<String, MaterialQuantity> materials;
  final Map<String, double> totalsByDiameter;
  final bool hasSuperiorMesh;

  const SteelSlabCalculationResult({
    required this.slabId,
    required this.description,
    required this.totalWeight,
    required this.wireWeight,
    required this.materials,
    required this.totalsByDiameter,
    required this.hasSuperiorMesh,
  });
}

class ConsolidatedSteelSlabResult {
  final int numberOfSlabs;
  final double totalWeight;
  final double totalWire;
  final List<SteelSlabCalculationResult> slabResults;
  final Map<String, MaterialQuantity> consolidatedMaterials;

  const ConsolidatedSteelSlabResult({
    required this.numberOfSlabs,
    required this.totalWeight,
    required this.totalWire,
    required this.slabResults,
    required this.consolidatedMaterials,
  });
}
