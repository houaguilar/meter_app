// ============================================================================
// MODELOS DE RESULTADOS PARA COLUMNAS
// ============================================================================

import 'package:meter_app/domain/entities/home/acero/steel_beam_constants.dart';

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
