import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meter_app/domain/entities/home/acero/losa_maciza/mesh_enums.dart';
import 'package:meter_app/domain/entities/home/acero/losa_maciza/steel_slab.dart';
import 'package:meter_app/domain/entities/home/acero/steel_constants.dart';
import 'package:meter_app/domain/entities/home/acero/steel_base_models.dart';
import 'package:meter_app/domain/entities/home/acero/losa_maciza/steel_slab_models.dart';
import 'package:meter_app/core/constants/constant.dart';


// ============================================================================
// PROVIDERS PRINCIPALES
// ============================================================================

final steelSlabResultProvider = NotifierProvider<SteelSlabResultNotifier, List<SteelSlab>>(() {
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

  // Calcula los detalles de una dirección de malla y acumula el total por diámetro
  SlabDirectionCalculation _buildDirection(SteelMeshBarEmbedded? bar, MeshDirection dir) {
    if (bar == null || bar.diameter.isEmpty || bar.separation <= 0) {
      return const SlabDirectionCalculation(
        diameter: '', separation: 0, quantity: 0,
        lengthPerBar: 0, totalLength: 0, weight: 0,
      );
    }
    final int quantity;
    final double lengthPerBar;
    if (dir == MeshDirection.horizontal) {
      quantity = ((slab.width / bar.separation) + 1).floor();
      lengthPerBar = slab.length + (2 * slab.bendLength);
    } else {
      quantity = ((slab.length / bar.separation) + 1).floor();
      lengthPerBar = slab.width + (2 * slab.bendLength);
    }
    final totalLength = slab.elements * quantity * lengthPerBar;
    final weightPerMeter = SteelConstants.steelWeights[bar.diameter] ?? 0.0;
    final weight = totalLength * weightPerMeter;
    totalesPorDiametro[bar.diameter] =
        (totalesPorDiametro[bar.diameter] ?? 0.0) + totalLength;
    return SlabDirectionCalculation(
      diameter: bar.diameter,
      separation: bar.separation,
      quantity: quantity,
      lengthPerBar: lengthPerBar,
      totalLength: totalLength,
      weight: weight,
    );
  }

  // **CÁLCULO DE MALLA INFERIOR** (siempre presente)
  final inferiorH = slab.meshBars
      .where((b) => b.meshType == MeshType.inferior && b.direction == MeshDirection.horizontal)
      .firstOrNull;
  final inferiorV = slab.meshBars
      .where((b) => b.meshType == MeshType.inferior && b.direction == MeshDirection.vertical)
      .firstOrNull;
  final inferiorHCalc = _buildDirection(inferiorH, MeshDirection.horizontal);
  final inferiorVCalc = _buildDirection(inferiorV, MeshDirection.vertical);
  final inferiorMesh = SlabMeshCalculation(
    type: MeshType.inferior,
    horizontal: inferiorHCalc,
    vertical: inferiorVCalc,
    totalWeight: inferiorHCalc.weight + inferiorVCalc.weight,
  );

  // **CÁLCULO DE MALLA SUPERIOR** (opcional)
  SlabMeshCalculation? superiorMesh;
  if (slab.superiorMeshConfig.enabled) {
    final superiorH = slab.meshBars
        .where((b) => b.meshType == MeshType.superior && b.direction == MeshDirection.horizontal)
        .firstOrNull;
    final superiorV = slab.meshBars
        .where((b) => b.meshType == MeshType.superior && b.direction == MeshDirection.vertical)
        .firstOrNull;
    final superiorHCalc = _buildDirection(superiorH, MeshDirection.horizontal);
    final superiorVCalc = _buildDirection(superiorV, MeshDirection.vertical);
    superiorMesh = SlabMeshCalculation(
      type: MeshType.superior,
      horizontal: superiorHCalc,
      vertical: superiorVCalc,
      totalWeight: superiorHCalc.weight + superiorVCalc.weight,
    );
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
    inferiorMesh: inferiorMesh,
    superiorMesh: superiorMesh,
  );
}

// ============================================================================
// STATE NOTIFIER
// ============================================================================

class SteelSlabResultNotifier extends Notifier<List<SteelSlab>> {
  @override
  List<SteelSlab> build() => [];

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

    state = [newSteelSlab];
  }

  void addSlab(SteelSlab slab) {
    state = [slab];
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
    state = [];
  }
}

// Provider para generar texto de resumen consolidado
final consolidatedSlabSummaryProvider = Provider<String>((ref) {
  final result = ref.watch(calculateConsolidatedSlabSteelProvider);
  if (result == null) return "";

  String summary = "=== RESUMEN CONSOLIDADO DE ACERO EN LOSAS ===\n\n";

  summary += "📊 RESULTADOS GENERALES:\n";
  summary += "• Número de losas: ${result.numberOfElements}\n";
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
    'totalSlabs': result.numberOfElements,
    'totalWeight': result.totalWeight,
    'totalWire': result.totalWire,
  };
});

// ============================================================================
