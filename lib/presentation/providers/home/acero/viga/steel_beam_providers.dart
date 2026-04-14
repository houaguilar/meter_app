// lib/presentation/providers/home/acero/viga/steel_beam_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/domain/entities/home/acero/steel_constants.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/home/acero/viga/steel_beam.dart';

const uuid = Uuid();

// ============================================================================
// PROVIDERS PRINCIPALES
// ============================================================================

final steelBeamResultProvider = NotifierProvider<SteelBeamResultNotifier, List<SteelBeam>>(() {
  return SteelBeamResultNotifier();
});

// Provider para calcular resultados individuales por viga
final calculateIndividualSteelProvider = Provider.family<SteelBeamCalculationResult?, String>((ref, beamId) {
  final beams = ref.watch(steelBeamResultProvider);

  final beam = beams.where((b) => b.idSteelBeam == beamId).firstOrNull;
  if (beam == null) return null;

  return _calculateSteelForBeam(beam);
});

// Provider para calcular resultados consolidados de todas las vigas
final calculateConsolidatedSteelProvider = Provider<ConsolidatedBeamSteelResult?>((ref) {
  final beams = ref.watch(steelBeamResultProvider);
  if (beams.isEmpty) return null;

  final List<SteelBeamCalculationResult> beamResults = [];
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

  return ConsolidatedBeamSteelResult(
    numberOfBeams: beams.length,
    totalWeight: totalWeight,
    totalWire: totalWire,
    totalStirrups: totalStirrups,
    beamResults: beamResults,
    consolidatedMaterials: consolidatedMaterials,
  );
});

// ============================================================================
// FUNCIONES DE CÁLCULO ESPECÍFICAS PARA VIGAS
// ============================================================================

/// Calcula el acero para una viga específica usando listas embebidas
SteelBeamCalculationResult _calculateSteelForBeam(SteelBeam beam) {
  final Map<String, double> totalesPorDiametro = {};

  // **CÁLCULO DE ACERO LONGITUDINAL** - Ahora usando beam.steelBars directamente
  for (final steelBar in beam.steelBars) {
    // ✅ BUG FIX #1: Longitud básica solo usa ALTURA (no largo, no apoyos)
    // Fórmula Excel: elementos × cantidad × altura
    final longitudBasica = beam.elements * steelBar.quantity * beam.height;

    totalesPorDiametro[steelBar.diameter] =
        (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudBasica;

    // Agregar empalme si está habilitado
    if (beam.useSplice) {
      final longitudEmpalme = beam.elements * steelBar.quantity *
          (SteelConstants.spliceLengths[steelBar.diameter] ?? 0.6);
      totalesPorDiametro[steelBar.diameter] =
          (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudEmpalme;
    }

    // ✅ BUG FIX #1: Doblez se suma por separado (igual que en Excel)
    // Fórmula Excel: elementos × cantidad × doblez (en filas separadas del Excel)
    final longitudDoblez = beam.elements * steelBar.quantity * (beam.bendLength * 2);
    totalesPorDiametro[steelBar.diameter] =
        (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudDoblez;
  }

  // **CÁLCULO DE ESTRIBOS** - Ahora usando beam.stirrupDistributions directamente
  // Calcular longitud cubierta por distribuciones
  double longitudCubierta = 0;
  int cantidadEstribosDistribucion = 0;

  for (final distribution in beam.stirrupDistributions) {
    longitudCubierta += distribution.quantity * distribution.separation;
    cantidadEstribosDistribucion += distribution.quantity * 2; // x2 para ambos extremos
  }

  // ✅ BUG FIX #2: Calcular altura efectiva restando los apoyos
  // Fórmula Excel: altura_efectiva = altura - apoyo1 - apoyo2
  final alturaEfectiva = beam.height - beam.supportA1 - beam.supportA2;

  // ✅ BUG FIX #2: Usar altura efectiva en lugar de beam.length
  // Fórmula Excel: longitud_restante = altura_efectiva - (longitud_cubierta*2)
  final longitudRestante = alturaEfectiva - (longitudCubierta * 2);
  int estribosResto = 0;
  if (beam.restSeparation > 0 && longitudRestante > 0) {
    estribosResto = (longitudRestante / beam.restSeparation).floor();
  }

  // Total de estribos
  final totalEstribos = estribosResto + cantidadEstribosDistribucion;

  // Calcular perímetro del estribo
  final perimetroEstribo = (beam.height - (beam.cover * 2)) * 2 +
      (beam.width - (beam.cover * 2)) * 2 +
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
      final varillasConDesperdicio = varillas * (1 + beam.waste);  // Mantiene decimales (Excel no redondea)

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

  return SteelBeamCalculationResult(
    beamId: beam.idSteelBeam,
    description: beam.description,
    totalWeight: pesoTotal,  // Peso sin desperdicio (Excel no aplica desperdicio al peso)
    wireWeight: alambreKg,
    totalStirrups: totalEstribos * beam.elements,
    stirrupPerimeter: perimetroEstribo,
    materials: materials,
    totalsByDiameter: totalesPorDiametro,
  );
}

// ============================================================================
// STATE NOTIFIERS
// ============================================================================

class SteelBeamResultNotifier extends Notifier<List<SteelBeam>> {
  @override
  List<SteelBeam> build() => [];

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
    required List<SteelBeamBarEmbedded> steelBars,
    required List<SteelBeamStirrupDistributionEmbedded> stirrupDistributions,
  }) {
    final newBeam = SteelBeam(
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
      steelBars: steelBars,
      stirrupDistributions: stirrupDistributions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = [...state, newBeam];
  }

  void addBeam(SteelBeam beam) {
    state = [...state, beam];
  }

  void updateBeam(int index, SteelBeam updatedBeam) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList[index] = updatedBeam;
      state = newList;
    }
  }

  void removeBeam(int index) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    }
  }

  void clearList() {
    print('🧹 Limpiando lista de vigas de acero');
    state = [];
  }
}

// Provider para generar texto de resumen consolidado
final consolidatedSummaryProvider = Provider<String>((ref) {
  final result = ref.watch(calculateConsolidatedSteelProvider);
  if (result == null) return "";

  String summary = "=== RESUMEN CONSOLIDADO DE ACERO ===\n\n";

  summary += "📊 RESULTADOS GENERALES:\n";
  summary += "• Número de vigas: ${result.numberOfBeams}\n";
  summary += "• Peso total de acero: ${result.totalWeight.toStringAsFixed(1)} kg\n";
  summary += "• Alambre #16: ${result.totalWire.toStringAsFixed(1)} kg\n";
  summary += "• Total de estribos: ${result.totalStirrups}\n\n";

  summary += "📋 MATERIALES CONSOLIDADOS:\n";
  result.consolidatedMaterials.forEach((diameter, material) {
    summary += "• Acero de $diameter: ${material.quantity.toStringAsFixed(0)} ${material.unit}\n";
  });

  summary += "\n🏗️ DETALLE POR VIGA:\n";
  for (int i = 0; i < result.beamResults.length; i++) {
    final beamResult = result.beamResults[i];
    summary += "\n${i + 1}. ${beamResult.description}:\n";
    summary += "   • Peso: ${beamResult.totalWeight.toStringAsFixed(1)} kg\n";
    summary += "   • Alambre: ${beamResult.wireWeight.toStringAsFixed(1)} kg\n";
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

class SteelBeamCalculationResult {
  final String beamId;
  final String description;
  final double totalWeight;
  final double wireWeight;
  final int totalStirrups;
  final double stirrupPerimeter;
  final Map<String, MaterialQuantity> materials;
  final Map<String, double> totalsByDiameter;

  const SteelBeamCalculationResult({
    required this.beamId,
    required this.description,
    required this.totalWeight,
    required this.wireWeight,
    required this.totalStirrups,
    required this.stirrupPerimeter,
    required this.materials,
    required this.totalsByDiameter,
  });
}

class ConsolidatedBeamSteelResult {
  final int numberOfBeams;
  final double totalWeight;
  final double totalWire;
  final int totalStirrups;
  final List<SteelBeamCalculationResult> beamResults;
  final Map<String, MaterialQuantity> consolidatedMaterials;

  const ConsolidatedBeamSteelResult({
    required this.numberOfBeams,
    required this.totalWeight,
    required this.totalWire,
    required this.totalStirrups,
    required this.beamResults,
    required this.consolidatedMaterials,
  });
}
