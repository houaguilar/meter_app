// lib/config/constants/steel_constants.dart
/// Constantes para acero
class SteelConstants {
  // Pesos específicos del acero (kg/m)
  static const Map<String, double> steelWeights = {
    '6mm': 0.222,
    '1/4"': 0.250,
    '8mm': 0.395,
    '3/8"': 0.560,
    '12mm': 0.888,
    '1/2"': 0.994,
    '5/8"': 1.552,
    '3/4"': 2.235,
    '1"': 3.973,
  };

  // Longitudes de empalme según diámetro (metros)
  static const Map<String, double> spliceLengths = {
    '1/2"': 0.55,
    '12mm': 0.55,
    '5/8"': 0.60,
    '3/4"': 0.70,
    '1"': 0.80,
  };

  // Diámetros disponibles
  static const List<String> availableDiameters = [
    '6mm',
    '1/4"',
    '8mm',
    '3/8"',
    '12mm',
    '1/2"',
    '5/8"',
    '3/4"',
    '1"',
  ];

  // Longitud estándar de varilla
  static const double standardRodLength = 9.0; // metros

  // Porcentaje de alambre #16
  static const double wirePercentage = 0.015; // 1.5%
}

// lib/domain/entities/home/acero/viga/steel_calculation_result.dart
/// Resultado del cálculo de acero para una viga
class SteelCalculationResult {
  final String beamId;
  final String description;
  final double totalWeight; // Peso total en kg
  final double wireWeight; // Alambre #16 en kg
  final int totalStirrups; // Total de estribos
  final double stirrupPerimeter; // Perímetro del estribo en metros
  final Map<String, MaterialQuantity> materials; // Materiales por diámetro
  final Map<String, double> totalsByDiameter; // Totales en metros por diámetro

  const SteelCalculationResult({
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

/// Cantidad de material
class MaterialQuantity {
  final double quantity; // Cantidad en varillas
  final String unit; // Unidad (Varillas)

  const MaterialQuantity({
    required this.quantity,
    required this.unit,
  });
}

/// Resultado consolidado de múltiples vigas
class ConsolidatedSteelResult {
  final int numberOfBeams;
  final double totalWeight; // Peso total general en kg
  final double totalWire; // Alambre total en kg
  final int totalStirrups; // Total de estribos
  final List<SteelCalculationResult> beamResults; // Resultados individuales
  final Map<String, MaterialQuantity> consolidatedMaterials; // Materiales consolidados

  const ConsolidatedSteelResult({
    required this.numberOfBeams,
    required this.totalWeight,
    required this.totalWire,
    required this.totalStirrups,
    required this.beamResults,
    required this.consolidatedMaterials,
  });
}