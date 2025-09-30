import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/home/acero/steel_beam_constants.dart';
import '../../../../../domain/entities/home/acero/zapata/steel_footing.dart';
import '../../../../../domain/entities/home/acero/zapata/steel_footing_constants.dart';

const uuid = Uuid();

// Helper functions para cálculos
double calcularVolumenZapata(SteelFooting footing) {
  return footing.length * footing.width;
}

double aplicarDesperdicio(double cantidad, double factorDesperdicio) {
  return cantidad * (1 + factorDesperdicio);
}

// ============================================================================
// PROVIDERS PRINCIPALES
// ============================================================================

final steelFootingResultProvider = StateNotifierProvider<SteelFootingResultNotifier, List<SteelFooting>>((ref) {
  return SteelFootingResultNotifier();
});

// Provider para calcular resultados individuales por zapata
final calculateIndividualFootingSteelProvider = Provider.family<SteelFootingCalculationResult?, String>((ref, footingId) {
  final footings = ref.watch(steelFootingResultProvider);

  final footing = footings.where((f) => f.idSteelFooting == footingId).firstOrNull;
  if (footing == null) return null;

  return _calculateSteelForFooting(footing);
});

// Provider para calcular resultados consolidados de todas las zapatas
final calculateConsolidatedFootingSteelProvider = Provider<ConsolidatedSteelFootingResult?>((ref) {
  final footings = ref.watch(steelFootingResultProvider);
  if (footings.isEmpty) return null;

  final List<SteelFootingCalculationResult> footingResults = [];
  double totalWeight = 0;
  double totalWire = 0;
  final Map<String, MaterialQuantity> consolidatedMaterials = {};

  // Calcular cada zapata individualmente
  for (final footing in footings) {
    final result = ref.read(calculateIndividualFootingSteelProvider(footing.idSteelFooting));
    if (result != null) {
      footingResults.add(result);
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

  return ConsolidatedSteelFootingResult(
    numberOfFooting: footings.length,
    totalWeight: totalWeight,
    totalWire: totalWire,
    footingResults: footingResults,
    consolidatedMaterials: consolidatedMaterials,
  );
});

// Provider para generar texto de resumen consolidado
final consolidatedFootingSummaryProvider = Provider<String>((ref) {
  final result = ref.watch(calculateConsolidatedFootingSteelProvider);
  if (result == null) return "";

  String summary = "=== RESUMEN CONSOLIDADO DE ACERO EN ZAPATAS ===\n\n";

  summary += "📊 RESULTADOS GENERALES:\n";
  summary += "• Número de zapatas: ${result.numberOfFooting}\n";
  summary += "• Peso total de acero: ${result.totalWeight.toStringAsFixed(2)} kg\n";
  summary += "• Alambre #16: ${result.totalWire.toStringAsFixed(2)} kg\n\n";

  summary += "📋 MATERIALES CONSOLIDADOS:\n";
  result.consolidatedMaterials.forEach((diameter, material) {
    summary += "• Acero de $diameter: ${material.quantity.toStringAsFixed(0)} ${material.unit}\n";
  });

  summary += "\n🏗️ DETALLE POR ZAPATA:\n";
  for (int i = 0; i < result.footingResults.length; i++) {
    final footingResult = result.footingResults[i];
    summary += "\n${i + 1}. ${footingResult.description}:\n";
    summary += "   • Peso: ${footingResult.totalWeight.toStringAsFixed(2)} kg\n";
    summary += "   • Alambre: ${footingResult.wireWeight.toStringAsFixed(2)} kg\n";

    // Detalles de mallas
    summary += "   • Malla inferior:\n";
    summary += "     - Horizontal: ${footingResult.inferiorMesh.horizontalQuantity} barras x ${footingResult.inferiorMesh.horizontalLength.toStringAsFixed(2)}m\n";
    summary += "     - Vertical: ${footingResult.inferiorMesh.verticalQuantity} barras x ${footingResult.inferiorMesh.verticalLength.toStringAsFixed(2)}m\n";

    if (footingResult.superiorMesh != null) {
      summary += "   • Malla superior:\n";
      summary += "     - Horizontal: ${footingResult.superiorMesh!.horizontalQuantity} barras x ${footingResult.superiorMesh!.horizontalLength.toStringAsFixed(2)}m\n";
      summary += "     - Vertical: ${footingResult.superiorMesh!.verticalQuantity} barras x ${footingResult.superiorMesh!.verticalLength.toStringAsFixed(2)}m\n";
    }
  }

  summary += "\n---\nGenerado por MeterApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

  return summary;
});

// Provider para obtener resumen de zapatas creadas
final footingsSummaryProvider = Provider<String>((ref) {
  final footings = ref.watch(steelFootingResultProvider);
  if (footings.isEmpty) return "No hay zapatas configuradas";

  if (footings.length == 1) {
    return "1 zapata: ${footings.first.description}";
  } else {
    return "${footings.length} zapatas: ${footings.map((f) => f.description).join(', ')}";
  }
});

// Provider para datos de compartir (texto consolidado)
final datosShareSteelFootingProvider = Provider<String>((ref) {
  return ref.watch(consolidatedFootingSummaryProvider);
});

// Provider para validar si hay datos listos para calcular
final canCalculateFootingProvider = Provider<bool>((ref) {
  final footings = ref.watch(steelFootingResultProvider);
  return footings.isNotEmpty;
});

// Provider para obtener estadísticas rápidas
final quickFootingStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final result = ref.watch(calculateConsolidatedFootingSteelProvider);
  if (result == null) {
    return {
      'totalFootings': 0,
      'totalWeight': 0.0,
      'totalWire': 0.0,
    };
  }

  return {
    'totalFootings': result.numberOfFooting,
    'totalWeight': result.totalWeight,
    'totalWire': result.totalWire,
  };
});

// Provider para limpiar todos los datos
final clearAllFootingDataProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(steelFootingResultProvider.notifier).clearList();
  };
});

// ============================================================================
// FUNCIONES DE CÁLCULO
// ============================================================================

/// Calcula el acero para una zapata específica
SteelFootingCalculationResult _calculateSteelForFooting(SteelFooting footing) {
  final Map<String, double> totalesPorDiametro = {};

  // **CÁLCULO DE MALLA INFERIOR** (siempre presente)
  final inferiorMesh = _calculateMesh(
    footing.length,
    footing.width,
    footing.inferiorHorizontalSeparation,
    footing.inferiorVerticalSeparation,
    footing.inferiorBendLength,
    footing.cover,
  );

  // Agregar longitudes de malla inferior
  final inferiorHorizontalTotal = footing.elements * inferiorMesh.horizontalTotalLength;
  final inferiorVerticalTotal = footing.elements * inferiorMesh.verticalTotalLength;

  totalesPorDiametro[footing.inferiorHorizontalDiameter] =
      (totalesPorDiametro[footing.inferiorHorizontalDiameter] ?? 0.0) + inferiorHorizontalTotal;
  totalesPorDiametro[footing.inferiorVerticalDiameter] =
      (totalesPorDiametro[footing.inferiorVerticalDiameter] ?? 0.0) + inferiorVerticalTotal;

  // **CÁLCULO DE MALLA SUPERIOR** (opcional)
  MeshCalculationDetails? superiorMesh;
  if (footing.hasSuperiorMesh &&
      footing.superiorHorizontalSeparation != null &&
      footing.superiorVerticalSeparation != null) {

    superiorMesh = _calculateMesh(
      footing.length,
      footing.width,
      footing.superiorHorizontalSeparation!,
      footing.superiorVerticalSeparation!,
      footing.inferiorBendLength, // Usar el mismo doblez
      footing.cover,
    );

    // Agregar longitudes de malla superior
    final superiorHorizontalTotal = footing.elements * superiorMesh.horizontalTotalLength;
    final superiorVerticalTotal = footing.elements * superiorMesh.verticalTotalLength;

    totalesPorDiametro[footing.superiorHorizontalDiameter!] =
        (totalesPorDiametro[footing.superiorHorizontalDiameter!] ?? 0.0) + superiorHorizontalTotal;
    totalesPorDiametro[footing.superiorVerticalDiameter!] =
        (totalesPorDiametro[footing.superiorVerticalDiameter!] ?? 0.0) + superiorVerticalTotal;
  }

  // **CÁLCULO DE TOTALES CON DESPERDICIO**
  double pesoTotal = 0;
  final Map<String, MaterialQuantity> materials = {};

  totalesPorDiametro.forEach((diameter, longitud) {
    if (longitud > 0) {
      // Convertir a varillas (9m por varilla)
      final varillas = longitud / SteelBeamConstants.standardRodLength;
      final varillasConDesperdicio = (varillas * (1 + footing.waste)).ceil().toDouble();

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
  final alambreKg = pesoTotal * SteelBeamConstants.wirePercentage * (1 + footing.waste);

  return SteelFootingCalculationResult(
    footingId: footing.idSteelFooting,
    description: footing.description,
    totalWeight: pesoTotal * (1 + footing.waste),
    wireWeight: alambreKg,
    materials: materials,
    totalsByDiameter: totalesPorDiametro,
    inferiorMesh: inferiorMesh,
    superiorMesh: superiorMesh,
  );
}

/// Calcula los detalles de una malla (inferior o superior)
MeshCalculationDetails _calculateMesh(
    double footingLength,
    double footingWidth,
    double horizontalSeparation,
    double verticalSeparation,
    double bendLength,
    double cover,
    ) {
  // **CÁLCULO DE BARRAS HORIZONTALES**
  // Cantidad: ancho de zapata / separación + 1
  final horizontalQuantity = ((footingWidth / horizontalSeparation) + 1).floor();

  // Longitud por barra: largo - 2*recubrimiento + 2*doblez
  final horizontalLength = footingLength - (2 * cover) + (2 * bendLength);

  // Longitud total horizontal
  final horizontalTotalLength = horizontalQuantity * horizontalLength;

  // **CÁLCULO DE BARRAS VERTICALES**
  // Cantidad: largo de zapata / separación + 1
  final verticalQuantity = ((footingLength / verticalSeparation) + 1).floor();

  // Longitud por barra: ancho - 2*recubrimiento + 2*doblez
  final verticalLength = footingWidth - (2 * cover) + (2 * bendLength);

  // Longitud total vertical
  final verticalTotalLength = verticalQuantity * verticalLength;

  return MeshCalculationDetails(
    horizontalQuantity: horizontalQuantity,
    horizontalLength: horizontalLength,
    horizontalTotalLength: horizontalTotalLength,
    verticalQuantity: verticalQuantity,
    verticalLength: verticalLength,
    verticalTotalLength: verticalTotalLength,
  );
}

// ============================================================================
// NOTIFIERS
// ============================================================================

class SteelFootingResultNotifier extends StateNotifier<List<SteelFooting>> {
  SteelFootingResultNotifier() : super([]);

  void createSteelFooting({
    required String description,
    required double waste,
    required int elements,
    required double cover,
    required double length,
    required double width,
    required String inferiorHorizontalDiameter,
    required double inferiorHorizontalSeparation,
    required String inferiorVerticalDiameter,
    required double inferiorVerticalSeparation,
    required double inferiorBendLength,
    required bool hasSuperiorMesh,
    String? superiorHorizontalDiameter,
    double? superiorHorizontalSeparation,
    String? superiorVerticalDiameter,
    double? superiorVerticalSeparation,
  }) {
    final newSteelFooting = SteelFooting(
      idSteelFooting: uuid.v4(),
      description: description,
      waste: waste,
      elements: elements,
      cover: cover,
      length: length,
      width: width,
      inferiorHorizontalDiameter: inferiorHorizontalDiameter,
      inferiorHorizontalSeparation: inferiorHorizontalSeparation,
      inferiorVerticalDiameter: inferiorVerticalDiameter,
      inferiorVerticalSeparation: inferiorVerticalSeparation,
      inferiorBendLength: inferiorBendLength,
      hasSuperiorMesh: hasSuperiorMesh,
      superiorHorizontalDiameter: superiorHorizontalDiameter,
      superiorHorizontalSeparation: superiorHorizontalSeparation,
      superiorVerticalDiameter: superiorVerticalDiameter,
      superiorVerticalSeparation: superiorVerticalSeparation,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Validar que la zapata tenga datos suficientes
    final area = calcularVolumenZapata(newSteelFooting);
    if (area <= 0) {
      throw Exception("La zapata debe tener dimensiones válidas.");
    }

    if (hasSuperiorMesh && (superiorHorizontalSeparation == null || superiorVerticalSeparation == null)) {
      throw Exception("Si se habilita la malla superior, debe configurar las separaciones.");
    }

    state = [...state, newSteelFooting];
  }

  void addFooting(SteelFooting footing) {
    state = [...state, footing];
  }

  void updateFooting(String footingId, SteelFooting updatedFooting) {
    state = state.map((footing) {
      if (footing.idSteelFooting == footingId) {
        return updatedFooting.copyWith(updatedAt: DateTime.now());
      }
      return footing;
    }).toList();
  }

  void removeFooting(String footingId) {
    state = state.where((footing) => footing.idSteelFooting != footingId).toList();
  }

  void clearList() {
    state = [];
  }

  List<SteelFooting> get footings => state;

  SteelFooting? getFootingById(String id) {
    try {
      return state.firstWhere((footing) => footing.idSteelFooting == id);
    } catch (e) {
      return null;
    }
  }

  bool hasFootings() {
    return state.isNotEmpty;
  }

  int get footingCount => state.length;
}