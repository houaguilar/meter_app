// lib/domain/entities/home/acero/zapata/steel_foundation_calculation_result.dart
import '../steel_beam_constants.dart';

/// Resultado del cálculo de acero para una zapata
class SteelFootingCalculationResult {
  final String footingId;
  final String description;
  final double totalWeight; // Peso total en kg
  final double wireWeight; // Alambre #16 en kg
  final Map<String, MaterialQuantity> materials; // Materiales por diámetro
  final Map<String, double> totalsByDiameter; // Totales en metros por diámetro
  final MeshCalculationDetails inferiorMesh; // Detalles de malla inferior
  final MeshCalculationDetails? superiorMesh; // Detalles de malla superior (opcional)

  const SteelFootingCalculationResult({
    required this.footingId,
    required this.description,
    required this.totalWeight,
    required this.wireWeight,
    required this.materials,
    required this.totalsByDiameter,
    required this.inferiorMesh,
    this.superiorMesh,
  });
}

/// Detalles del cálculo de una malla
class MeshCalculationDetails {
  final int horizontalQuantity; // Cantidad de barras horizontales
  final double horizontalLength; // Longitud por barra horizontal
  final double horizontalTotalLength; // Longitud total horizontal
  final int verticalQuantity; // Cantidad de barras verticales
  final double verticalLength; // Longitud por barra vertical
  final double verticalTotalLength; // Longitud total vertical

  const MeshCalculationDetails({
    required this.horizontalQuantity,
    required this.horizontalLength,
    required this.horizontalTotalLength,
    required this.verticalQuantity,
    required this.verticalLength,
    required this.verticalTotalLength,
  });
}

/// Resultado consolidado de múltiples zapatas
class ConsolidatedSteelFootingResult {
  final int numberOfFooting;
  final double totalWeight; // Peso total general en kg
  final double totalWire; // Alambre total en kg
  final List<SteelFootingCalculationResult> footingResults; // Resultados individuales
  final Map<String, MaterialQuantity> consolidatedMaterials; // Materiales consolidados

  const ConsolidatedSteelFootingResult({
    required this.numberOfFooting,
    required this.totalWeight,
    required this.totalWire,
    required this.footingResults,
    required this.consolidatedMaterials,
  });
}