import '../steel_base_models.dart';

/// Resultado del cálculo de acero para una viga
///
/// Extiende [BaseSteelCalculationResult] y agrega campos específicos
/// relacionados con estribos.
///
/// **Uso:**
/// ```dart
/// final resultado = SteelBeamCalculationResult(
///   beamId: 'viga-001',
///   description: 'VIGA V-101',
///   totalWeight: 125.5,
///   wireWeight: 1.88,
///   totalStirrups: 45,
///   stirrupPerimeter: 2.0,
///   materials: {...},
///   totalsByDiameter: {...},
/// );
/// ```
class SteelBeamCalculationResult extends BaseSteelCalculationResult {
  /// Total de estribos calculados para esta viga
  ///
  /// Incluye:
  /// - Estribos de las distribuciones especiales (en extremos)
  /// - Estribos del resto (zona central)
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalStirrups = estribosDistribuciones + estribosResto
  /// ```
  final int totalStirrups;

  /// Perímetro de un estribo individual en metros
  ///
  /// Calculado según las dimensiones de la viga y el recubrimiento:
  /// ```dart
  /// perimetro = 2 × (alto - 2×recubrimiento) +
  ///             2 × (ancho - 2×recubrimiento) +
  ///             2 × doblezEstribo
  /// ```
  ///
  /// **Ejemplo:** Para una viga de 0.25m × 0.50m con recubrimiento de 0.04m
  /// y doblez de 0.08m:
  /// ```dart
  /// perimetro = 2×(0.50-0.08) + 2×(0.25-0.08) + 2×0.08 = 1.34m
  /// ```
  final double stirrupPerimeter;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `id`: ID único de la viga
  /// - `description`: Descripción (ej: "VIGA V-101")
  /// - `totalWeight`: Peso total del acero en kg
  /// - `wireWeight`: Peso del alambre #16 en kg
  /// - `materials`: Materiales por diámetro
  /// - `totalsByDiameter`: Longitudes por diámetro
  ///
  /// **Parámetros específicos de viga:**
  /// - `totalStirrups`: Total de estribos
  /// - `stirrupPerimeter`: Perímetro del estribo en metros
  const SteelBeamCalculationResult({
    required String beamId,
    required String description,
    required double totalWeight,
    required double wireWeight,
    required Map<String, MaterialQuantity> materials,
    required Map<String, double> totalsByDiameter,
    required this.totalStirrups,
    required this.stirrupPerimeter,
  }) : super(
    id: beamId,
    description: description,
    totalWeight: totalWeight,
    wireWeight: wireWeight,
    materials: materials,
    totalsByDiameter: totalsByDiameter,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE VIGA
  // ===========================================================================

  /// Longitud total de acero usado en estribos (metros)
  ///
  /// **Cálculo:**
  /// ```dart
  /// longitudEstribos = totalStirrups × stirrupPerimeter
  /// ```
  double get totalStirrupLength => totalStirrups * stirrupPerimeter;

  /// Verifica si la viga tiene estribos
  bool get hasStirrups => totalStirrups > 0;

  /// Densidad de estribos (estribos por metro de viga)
  ///
  /// Útil para verificar si cumple con normas de diseño
  ///
  /// **Parámetros requeridos:** Necesita la longitud de la viga
  /// (no almacenada en el resultado, debe calcularse externamente)
  double stirrupDensity(double beamLength) {
    if (beamLength <= 0) return 0.0;
    return totalStirrups / beamLength;
  }
}

/// Resultado consolidado de múltiples vigas
///
/// Suma los resultados de todas las vigas calculadas y provee
/// totales generales del proyecto.
///
/// **Uso:**
/// ```dart
/// final consolidado = ConsolidatedBeamSteelResult(
///   numberOfBeams: 10,
///   totalWeight: 1250.0,
///   totalWire: 18.75,
///   totalStirrups: 450,
///   beamResults: [...],
///   consolidatedMaterials: {...},
/// );
/// ```
class ConsolidatedBeamSteelResult extends BaseConsolidatedSteelResult {
  /// Total de estribos de todas las vigas sumadas
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalStirrups = Σ(viga.totalStirrups) para cada viga
  /// ```
  final int totalStirrups;

  /// Lista de resultados individuales de cada viga
  ///
  /// Permite acceso a los cálculos detallados de cada viga
  /// para reporting o análisis específico.
  final List<SteelBeamCalculationResult> beamResults;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `numberOfElements`: Cantidad de vigas consolidadas
  /// - `totalWeight`: Peso total de todas las vigas en kg
  /// - `totalWire`: Peso total del alambre #16 en kg
  /// - `consolidatedMaterials`: Materiales sumados por diámetro
  ///
  /// **Parámetros específicos:**
  /// - `totalStirrups`: Total de estribos de todas las vigas
  /// - `beamResults`: Lista de resultados individuales
  const ConsolidatedBeamSteelResult({
    required int numberOfBeams,
    required double totalWeight,
    required double totalWire,
    required Map<String, MaterialQuantity> consolidatedMaterials,
    required this.totalStirrups,
    required this.beamResults,
  }) : super(
    numberOfElements: numberOfBeams,
    totalWeight: totalWeight,
    totalWire: totalWire,
    consolidatedMaterials: consolidatedMaterials,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE VIGAS CONSOLIDADAS
  // ===========================================================================

  /// Promedio de estribos por viga
  ///
  /// **Retorna:** Cantidad promedio, o 0.0 si no hay vigas
  double get averageStirrupsPerBeam {
    return numberOfElements > 0 ? totalStirrups / numberOfElements : 0.0;
  }

  /// Viga con mayor peso
  ///
  /// **Retorna:** El resultado de la viga más pesada, o null si no hay vigas
  SteelBeamCalculationResult? get heaviestBeam {
    if (beamResults.isEmpty) return null;
    return beamResults.reduce(
          (a, b) => a.totalWeight > b.totalWeight ? a : b,
    );
  }

  /// Viga con menor peso
  ///
  /// **Retorna:** El resultado de la viga más liviana, o null si no hay vigas
  SteelBeamCalculationResult? get lightestBeam {
    if (beamResults.isEmpty) return null;
    return beamResults.reduce(
          (a, b) => a.totalWeight < b.totalWeight ? a : b,
    );
  }

  /// Viga con más estribos
  ///
  /// **Retorna:** El resultado de la viga con más estribos, o null si no hay vigas
  SteelBeamCalculationResult? get beamWithMostStirrups {
    if (beamResults.isEmpty) return null;
    return beamResults.reduce(
          (a, b) => a.totalStirrups > b.totalStirrups ? a : b,
    );
  }

  /// Obtiene una viga específica por su ID
  ///
  /// **Parámetros:**
  /// - `beamId`: ID de la viga a buscar
  ///
  /// **Retorna:** El resultado de la viga, o null si no se encuentra
  SteelBeamCalculationResult? getBeamById(String beamId) {
    try {
      return beamResults.firstWhere((beam) => beam.id == beamId);
    } catch (e) {
      return null;
    }
  }

  /// Filtra vigas por peso mínimo
  ///
  /// **Parámetros:**
  /// - `minWeight`: Peso mínimo en kg
  ///
  /// **Retorna:** Lista de vigas que superan el peso mínimo
  List<SteelBeamCalculationResult> getBeamsAboveWeight(double minWeight) {
    return beamResults.where((beam) => beam.totalWeight >= minWeight).toList();
  }

  /// Filtra vigas por cantidad mínima de estribos
  ///
  /// **Parámetros:**
  /// - `minStirrups`: Cantidad mínima de estribos
  ///
  /// **Retorna:** Lista de vigas con al menos esa cantidad de estribos
  List<SteelBeamCalculationResult> getBeamsAboveStirrups(int minStirrups) {
    return beamResults.where((beam) => beam.totalStirrups >= minStirrups).toList();
  }

  /// Obtiene resumen estadístico de las vigas
  ///
  /// **Retorna:** Map con estadísticas clave
  ///
  /// **Ejemplo:**
  /// ```dart
  /// {
  ///   'totalBeams': 10,
  ///   'totalWeight': 1250.0,
  ///   'totalStirrups': 450,
  ///   'averageWeight': 125.0,
  ///   'averageStirrups': 45.0,
  ///   'heaviestBeam': 'VIGA V-101',
  ///   'lightestBeam': 'VIGA V-105',
  /// }
  /// ```
  Map<String, dynamic> getStatistics() {
    return {
      'totalBeams': numberOfElements,
      'totalWeight': totalWeight,
      'totalWeightWithWire': totalWeightWithWire,
      'totalWire': totalWire,
      'totalStirrups': totalStirrups,
      'totalRods': totalRods,
      'averageWeight': averageWeightPerElement,
      'averageRods': averageRodsPerElement,
      'averageStirrups': averageStirrupsPerBeam,
      'heaviestBeam': heaviestBeam?.description,
      'lightestBeam': lightestBeam?.description,
      'beamWithMostStirrups': beamWithMostStirrups?.description,
      'diameterCount': diameterCount,
      'usedDiameters': usedDiameters,
    };
  }
}