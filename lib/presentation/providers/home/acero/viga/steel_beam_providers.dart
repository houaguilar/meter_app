// lib/presentation/providers/home/acero/viga/steel_beam_providers.dart - VERSIÓN MEJORADA
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/home/acero/steel_constants.dart';
import '../../../../../domain/entities/home/acero/viga/steel_beam.dart';
import '../../../../../domain/entities/home/acero/viga/steel_bar.dart';
import '../../../../../domain/entities/home/acero/viga/stirrup_distribution.dart';

const uuid = Uuid();

// Helper functions para cálculos
double calcularVolumenViga(SteelBeam beam) {
  return beam.height * beam.length * beam.width;
}

double aplicarDesperdicio(double cantidad, double factorDesperdicio) {
  return cantidad * (1 + factorDesperdicio);
}

// ============================================================================
// PROVIDERS PRINCIPALES
// ============================================================================

final steelBeamResultProvider = StateNotifierProvider<SteelBeamResultNotifier, List<SteelBeam>>((ref) {
  return SteelBeamResultNotifier();
});

final steelBarsForBeamProvider = StateNotifierProvider<SteelBarsForBeamNotifier, Map<String, List<SteelBar>>>((ref) {
  return SteelBarsForBeamNotifier();
});

final stirrupDistributionsForBeamProvider = StateNotifierProvider<StirrupDistributionsForBeamNotifier, Map<String, List<StirrupDistribution>>>((ref) {
  return StirrupDistributionsForBeamNotifier();
});

// Provider para calcular resultados individuales por viga
final calculateIndividualSteelProvider = Provider.family<SteelCalculationResult?, String>((ref, beamId) {
  final beams = ref.watch(steelBeamResultProvider);
  final allBars = ref.watch(steelBarsForBeamProvider);
  final allDistributions = ref.watch(stirrupDistributionsForBeamProvider);

  final beam = beams.where((b) => b.idSteelBeam == beamId).firstOrNull;
  if (beam == null) return null;

  final steelBars = allBars[beamId] ?? [];
  final stirrupDistributions = allDistributions[beamId] ?? [];

  return _calculateSteelForBeam(beam, steelBars, stirrupDistributions);
});

// Provider para calcular resultados consolidados de todas las vigas
final calculateConsolidatedSteelProvider = Provider<ConsolidatedSteelResult?>((ref) {
  final beams = ref.watch(steelBeamResultProvider);
  if (beams.isEmpty) return null;

  final List<SteelCalculationResult> beamResults = [];
  double totalWeight = 0;
  double totalWire = 0;
  int totalStirrups = 0;
  final Map<String, MaterialQuantity> consolidatedMaterials = {};

  // Calcular cada viga individualmente
  for (final beam in beams) {
    final result = ref.read(calculateIndividualSteelProvider(beam.idSteelBeam));
    if (result != null) {
      beamResults.add(result);
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

  return ConsolidatedSteelResult(
    numberOfBeams: beams.length,
    totalWeight: totalWeight,
    totalWire: totalWire,
    totalStirrups: totalStirrups,
    beamResults: beamResults,
    consolidatedMaterials: consolidatedMaterials,
  );
});

// Provider para generar texto de resumen consolidado
final consolidatedSummaryProvider = Provider<String>((ref) {
  final result = ref.watch(calculateConsolidatedSteelProvider);
  if (result == null) return "";

  String summary = "=== RESUMEN CONSOLIDADO DE ACERO ===\n\n";

  summary += "📊 RESULTADOS GENERALES:\n";
  summary += "• Número de vigas: ${result.numberOfBeams}\n";
  summary += "• Peso total de acero: ${result.totalWeight.toStringAsFixed(2)} kg\n";
  summary += "• Alambre #16: ${result.totalWire.toStringAsFixed(2)} kg\n";
  summary += "• Total de estribos: ${result.totalStirrups}\n\n";

  summary += "📋 MATERIALES CONSOLIDADOS:\n";
  result.consolidatedMaterials.forEach((diameter, material) {
    summary += "• Acero de $diameter: ${material.quantity.toStringAsFixed(0)} ${material.unit}\n";
  });

  summary += "\n🏗️ DETALLE POR VIGA:\n";
  for (int i = 0; i < result.beamResults.length; i++) {
    final beamResult = result.beamResults[i];
    summary += "\n${i + 1}. ${beamResult.description}:\n";
    summary += "   • Peso: ${beamResult.totalWeight.toStringAsFixed(2)} kg\n";
    summary += "   • Alambre: ${beamResult.wireWeight.toStringAsFixed(2)} kg\n";
    summary += "   • Estribos: ${beamResult.totalStirrups}\n";
  }

  summary += "\n---\nGenerado por MeterApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

  return summary;
});

// Provider para obtener resumen de vigas creadas
final beamsSummaryProvider = Provider<String>((ref) {
  final beams = ref.watch(steelBeamResultProvider);
  if (beams.isEmpty) return "No hay vigas configuradas";

  if (beams.length == 1) {
    return "1 viga: ${beams.first.description}";
  } else {
    return "${beams.length} vigas: ${beams.map((b) => b.description).join(', ')}";
  }
});

// ============================================================================
// NOTIFIERS
// ============================================================================

class SteelBeamResultNotifier extends StateNotifier<List<SteelBeam>> {
  SteelBeamResultNotifier() : super([]);

  void createSteelBeam({
    required String description,
    required double waste,
    required int elements,
    required double cover,
    required double height,
    required double length,
    required double width,
    required double supportA1,
    required double supportA2,
    required double bendLength,
    required bool useSplice,
    required String stirrupDiameter,
    required double stirrupBendLength,
    required double restSeparation,
  }) {
    final newSteelBeam = SteelBeam(
      idSteelBeam: uuid.v4(),
      description: description,
      waste: waste,
      elements: elements,
      cover: cover,
      height: height,
      length: length,
      width: width,
      supportA1: supportA1,
      supportA2: supportA2,
      bendLength: bendLength,
      useSplice: useSplice,
      stirrupDiameter: stirrupDiameter,
      stirrupBendLength: stirrupBendLength,
      restSeparation: restSeparation,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Validar que la viga tenga datos suficientes
    final volumen = calcularVolumenViga(newSteelBeam);
    if (volumen <= 0) {
      throw Exception("La viga debe tener dimensiones válidas.");
    }

    print('✅ Nueva viga de acero creada: ${newSteelBeam.description}, volumen: ${volumen.toStringAsFixed(2)} m³');
    state = [...state, newSteelBeam];
  }

  void updateSteelBeam(int index, SteelBeam updatedBeam) {
    if (index >= 0 && index < state.length) {
      final newList = List<SteelBeam>.from(state);
      newList[index] = updatedBeam.copyWith(updatedAt: DateTime.now());
      state = newList;
    }
  }

  void removeSteelBeam(int index) {
    if (index >= 0 && index < state.length) {
      final newList = List<SteelBeam>.from(state);
      newList.removeAt(index);
      state = newList;
    }
  }

  void clearList() {
    print('🧹 Limpiando lista de vigas de acero');
    state = [];
  }
}

class SteelBarsForBeamNotifier extends StateNotifier<Map<String, List<SteelBar>>> {
  SteelBarsForBeamNotifier() : super({});

  void addSteelBar(String beamId, int quantity, String diameter) {
    final newBar = SteelBar(
      idSteelBar: uuid.v4(),
      quantity: quantity,
      diameter: diameter,
    );

    final currentBars = state[beamId] ?? [];
    state = {
      ...state,
      beamId: [...currentBars, newBar],
    };
  }

  void updateSteelBar(String beamId, int index, SteelBar updatedBar) {
    final currentBars = state[beamId] ?? [];
    if (index >= 0 && index < currentBars.length) {
      final newBars = List<SteelBar>.from(currentBars);
      newBars[index] = updatedBar;
      state = {
        ...state,
        beamId: newBars,
      };
    }
  }

  void removeSteelBar(String beamId, int index) {
    final currentBars = state[beamId] ?? [];
    if (index >= 0 && index < currentBars.length) {
      final newBars = List<SteelBar>.from(currentBars);
      newBars.removeAt(index);
      state = {
        ...state,
        beamId: newBars,
      };
    }
  }

  List<SteelBar> getBarsForBeam(String beamId) {
    return state[beamId] ?? [];
  }

  void clearBarsForBeam(String beamId) {
    final newState = Map<String, List<SteelBar>>.from(state);
    newState.remove(beamId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

class StirrupDistributionsForBeamNotifier extends StateNotifier<Map<String, List<StirrupDistribution>>> {
  StirrupDistributionsForBeamNotifier() : super({});

  void addDistribution(String beamId, int quantity, double separation) {
    final newDistribution = StirrupDistribution(
      idStirrupDistribution: uuid.v4(),
      quantity: quantity,
      separation: separation,
    );

    final currentDistributions = state[beamId] ?? [];
    state = {
      ...state,
      beamId: [...currentDistributions, newDistribution],
    };
  }

  void updateDistribution(String beamId, int index, StirrupDistribution updatedDistribution) {
    final currentDistributions = state[beamId] ?? [];
    if (index >= 0 && index < currentDistributions.length) {
      final newDistributions = List<StirrupDistribution>.from(currentDistributions);
      newDistributions[index] = updatedDistribution;
      state = {
        ...state,
        beamId: newDistributions,
      };
    }
  }

  void removeDistribution(String beamId, int index) {
    final currentDistributions = state[beamId] ?? [];
    if (index >= 0 && index < currentDistributions.length) {
      final newDistributions = List<StirrupDistribution>.from(currentDistributions);
      newDistributions.removeAt(index);
      state = {
        ...state,
        beamId: newDistributions,
      };
    }
  }

  List<StirrupDistribution> getDistributionsForBeam(String beamId) {
    return state[beamId] ?? [];
  }

  void clearDistributionsForBeam(String beamId) {
    final newState = Map<String, List<StirrupDistribution>>.from(state);
    newState.remove(beamId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

// ============================================================================
// FUNCIONES DE CÁLCULO
// ============================================================================

/// Calcula el acero para una viga específica
SteelCalculationResult _calculateSteelForBeam(
    SteelBeam beam,
    List<SteelBar> steelBars,
    List<StirrupDistribution> stirrupDistributions,
    ) {
  final Map<String, double> totalesPorDiametro = {};

  // **CÁLCULO DE ACERO LONGITUDINAL**
  for (final steelBar in steelBars) {
    // Longitud básica por barra
    final longitudBasica = beam.elements * steelBar.quantity * beam.height;
    totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudBasica;

    // Agregar empalme si está habilitado
    if (beam.useSplice) {
      final longitudEmpalme = beam.elements * steelBar.quantity * (SteelConstants.spliceLengths[steelBar.diameter] ?? 0.6);
      totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudEmpalme;
    }

    // Agregar doblez
    final longitudDoblez = beam.elements * steelBar.quantity * beam.bendLength;
    totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudDoblez;
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
  final longitudRestante = beam.height - (longitudCubierta * 2);
  int estribosResto = 0;
  if (beam.restSeparation > 0 && longitudRestante > 0) {
    estribosResto = (longitudRestante / beam.restSeparation).floor();
  }

  // Total de estribos
  final totalEstribos = estribosResto + cantidadEstribosDistribucion;

  // Calcular perímetro del estribo
  final perimetroEstribo = (beam.length - beam.cover) * 2 +
      (beam.width - beam.cover) * 2 +
      beam.stirrupBendLength * 2;

  // Longitud total de estribos
  final longitudTotalEstribos = beam.elements * totalEstribos * perimetroEstribo;
  totalesPorDiametro[beam.stirrupDiameter] =
      (totalesPorDiametro[beam.stirrupDiameter] ?? 0.0) + longitudTotalEstribos;

  // **CÁLCULO DE TOTALES CON DESPERDICIO**
  double pesoTotal = 0;
  final Map<String, MaterialQuantity> materials = {};

  totalesPorDiametro.forEach((diameter, longitud) {
    if (longitud > 0) {
      // Convertir a varillas (9m por varilla)
      final varillas = longitud / SteelConstants.standardRodLength;
      final varillasConDesperdicio = (varillas * (1 + beam.waste)).ceil().toDouble();

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
  final alambreKg = pesoTotal * SteelConstants.wirePercentage * (1 + beam.waste);

  return SteelCalculationResult(
    beamId: beam.idSteelBeam,
    description: beam.description,
    totalWeight: pesoTotal * (1 + beam.waste),
    wireWeight: alambreKg,
    totalStirrups: totalEstribos * beam.elements,
    stirrupPerimeter: perimetroEstribo,
    materials: materials,
    totalsByDiameter: totalesPorDiametro,
  );
}

// ============================================================================
// PROVIDERS ADICIONALES
// ============================================================================

final availableDiametersProvider = Provider<List<String>>((ref) {
  return SteelConstants.availableDiameters;
});

// Provider para datos de compartir (texto consolidado)
final datosShareSteelBeamProvider = Provider<String>((ref) {
  return ref.watch(consolidatedSummaryProvider);
});

// Provider para validar si hay datos listos para calcular
final canCalculateProvider = Provider<bool>((ref) {
  final beams = ref.watch(steelBeamResultProvider);
  return beams.isNotEmpty;
});

// Provider para obtener estadísticas rápidas
final quickStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final result = ref.watch(calculateConsolidatedSteelProvider);
  if (result == null) {
    return {
      'totalBeams': 0,
      'totalWeight': 0.0,
      'totalWire': 0.0,
      'totalStirrups': 0,
    };
  }

  return {
    'totalBeams': result.numberOfBeams,
    'totalWeight': result.totalWeight,
    'totalWire': result.totalWire,
    'totalStirrups': result.totalStirrups,
  };
});

// Provider para limpiar todos los datos
final clearAllDataProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(steelBeamResultProvider.notifier).clearList();
    ref.read(steelBarsForBeamProvider.notifier).clearAll();
    ref.read(stirrupDistributionsForBeamProvider.notifier).clearAll();
  };
});