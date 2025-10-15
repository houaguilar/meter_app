import '../steel_base_models.dart';

/// Detalles del cálculo de una malla de zapata
///
/// Almacena información sobre las barras horizontales y verticales
/// que conforman una malla (inferior o superior) de la zapata.
///
/// **Uso:**
/// ```dart
/// final mallaInferior = MeshCalculationDetails(
///   horizontalQuantity: 12,
///   horizontalLength: 2.5,
///   horizontalTotalLength: 30.0,
///   verticalQuantity: 10,
///   verticalLength: 2.0,
///   verticalTotalLength: 20.0,
/// );
/// ```
class MeshCalculationDetails {
  /// Cantidad de barras horizontales en la malla
  ///
  /// **Cálculo:**
  /// ```dart
  /// cantidad = (ancho / separacion) + 1
  /// ```
  final int horizontalQuantity;

  /// Longitud de cada barra horizontal en metros
  ///
  /// **Cálculo:**
  /// ```dart
  /// longitud = largo + (2 × doblezInferior)
  /// ```
  final double horizontalLength;

  /// Longitud total de todas las barras horizontales en metros
  ///
  /// **Cálculo:**
  /// ```dart
  /// total = horizontalQuantity × horizontalLength × elementos
  /// ```
  final double horizontalTotalLength;

  /// Cantidad de barras verticales en la malla
  ///
  /// **Cálculo:**
  /// ```dart
  /// cantidad = (largo / separacion) + 1
  /// ```
  final int verticalQuantity;

  /// Longitud de cada barra vertical en metros
  ///
  /// **Cálculo:**
  /// ```dart
  /// longitud = ancho + (2 × doblezInferior)
  /// ```
  final double verticalLength;

  /// Longitud total de todas las barras verticales en metros
  ///
  /// **Cálculo:**
  /// ```dart
  /// total = verticalQuantity × verticalLength × elementos
  /// ```
  final double verticalTotalLength;

  /// Constructor principal
  const MeshCalculationDetails({
    required this.horizontalQuantity,
    required this.horizontalLength,
    required this.horizontalTotalLength,
    required this.verticalQuantity,
    required this.verticalLength,
    required this.verticalTotalLength,
  });

  /// Longitud total combinada (horizontal + vertical)
  ///
  /// **Retorna:** Suma de ambas direcciones en metros
  double get totalLength => horizontalTotalLength + verticalTotalLength;

  /// Total de barras en la malla
  ///
  /// **Retorna:** Suma de barras horizontales y verticales
  int get totalBars => horizontalQuantity + verticalQuantity;

  /// Verifica si la malla tiene barras
  bool get hasBars => totalBars > 0;
}

/// Resultado del cálculo de acero para una zapata
///
/// Extiende [BaseSteelCalculationResult] y agrega campos específicos
/// relacionados con mallas inferior y superior.
///
/// **Diferencia con vigas/columnas:** Las zapatas NO usan estribos,
/// usan mallas bidireccionales (horizontal + vertical).
///
/// **Uso:**
/// ```dart
/// final resultado = SteelFootingCalculationResult(
///   footingId: 'zapata-001',
///   description: 'ZAPATA Z-1',
///   totalWeight: 95.5,
///   wireWeight: 1.43,
///   inferiorMesh: mallaInferior,
///   superiorMesh: mallaSuperior, // puede ser null
///   materials: {...},
///   totalsByDiameter: {...},
/// );
/// ```
class SteelFootingCalculationResult extends BaseSteelCalculationResult {
  /// Detalles de la malla inferior (obligatoria)
  ///
  /// Todas las zapatas tienen al menos una malla inferior que
  /// trabaja a tracción por flexión.
  final MeshCalculationDetails inferiorMesh;

  /// Detalles de la malla superior (opcional)
  ///
  /// Algunas zapatas requieren refuerzo superior según el diseño
  /// estructural. Puede ser `null` si no se necesita.
  final MeshCalculationDetails? superiorMesh;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `id`: ID único de la zapata
  /// - `description`: Descripción (ej: "ZAPATA Z-1")
  /// - `totalWeight`: Peso total del acero en kg
  /// - `wireWeight`: Peso del alambre #16 en kg
  /// - `materials`: Materiales por diámetro
  /// - `totalsByDiameter`: Longitudes por diámetro
  ///
  /// **Parámetros específicos de zapata:**
  /// - `inferiorMesh`: Detalles de la malla inferior (obligatorio)
  /// - `superiorMesh`: Detalles de la malla superior (opcional)
  const SteelFootingCalculationResult({
    required String footingId,
    required String description,
    required double totalWeight,
    required double wireWeight,
    required Map<String, MaterialQuantity> materials,
    required Map<String, double> totalsByDiameter,
    required this.inferiorMesh,
    this.superiorMesh,
  }) : super(
    id: footingId,
    description: description,
    totalWeight: totalWeight,
    wireWeight: wireWeight,
    materials: materials,
    totalsByDiameter: totalsByDiameter,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE ZAPATA
  // ===========================================================================

  /// Indica si la zapata tiene malla superior
  bool get hasSuperiorMesh => superiorMesh != null;

  /// Tipo de refuerzo según las mallas
  ///
  /// **Retorna:**
  /// - "Refuerzo Simple" si solo tiene malla inferior
  /// - "Refuerzo Doble" si tiene ambas mallas
  String get reinforcementType => hasSuperiorMesh ? 'Refuerzo Doble' : 'Refuerzo Simple';

  /// Total de barras en la malla inferior
  int get inferiorBarsCount => inferiorMesh.totalBars;

  /// Total de barras en la malla superior (0 si no existe)
  int get superiorBarsCount => superiorMesh?.totalBars ?? 0;

  /// Total de barras en ambas mallas
  int get totalBarsCount => inferiorBarsCount + superiorBarsCount;

  /// Longitud total de la malla inferior en metros
  double get inferiorMeshLength => inferiorMesh.totalLength;

  /// Longitud total de la malla superior en metros (0 si no existe)
  double get superiorMeshLength => superiorMesh?.totalLength ?? 0.0;

  /// Longitud total de ambas mallas en metros
  double get totalMeshLength => inferiorMeshLength + superiorMeshLength;

  /// Porcentaje de acero en malla superior respecto al total
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no hay malla superior
  double get superiorMeshPercentage {
    if (totalMeshLength == 0) return 0.0;
    return (superiorMeshLength / totalMeshLength) * 100;
  }
}

/// Resultado consolidado de múltiples zapatas
///
/// Suma los resultados de todas las zapatas calculadas y provee
/// totales generales del proyecto.
///
/// **Uso:**
/// ```dart
/// final consolidado = ConsolidatedSteelFootingResult(
///   numberOfFooting: 8,
///   totalWeight: 764.0,
///   totalWire: 11.46,
///   footingResults: [...],
///   consolidatedMaterials: {...},
/// );
/// ```
class ConsolidatedSteelFootingResult extends BaseConsolidatedSteelResult {
  /// Lista de resultados individuales de cada zapata
  ///
  /// Permite acceso a los cálculos detallados de cada zapata
  /// para reporting o análisis específico.
  final List<SteelFootingCalculationResult> footingResults;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `numberOfElements`: Cantidad de zapatas consolidadas
  /// - `totalWeight`: Peso total de todas las zapatas en kg
  /// - `totalWire`: Peso total del alambre #16 en kg
  /// - `consolidatedMaterials`: Materiales sumados por diámetro
  ///
  /// **Parámetros específicos:**
  /// - `footingResults`: Lista de resultados individuales
  const ConsolidatedSteelFootingResult({
    required int numberOfFooting,
    required double totalWeight,
    required double totalWire,
    required Map<String, MaterialQuantity> consolidatedMaterials,
    required this.footingResults,
  }) : super(
    numberOfElements: numberOfFooting,
    totalWeight: totalWeight,
    totalWire: totalWire,
    consolidatedMaterials: consolidatedMaterials,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE ZAPATAS CONSOLIDADAS
  // ===========================================================================

  /// Cantidad de zapatas con malla superior
  ///
  /// **Retorna:** Número de zapatas que tienen refuerzo doble
  int get footingsWithSuperiorMesh {
    return footingResults.where((f) => f.hasSuperiorMesh).length;
  }

  /// Cantidad de zapatas sin malla superior
  ///
  /// **Retorna:** Número de zapatas que tienen refuerzo simple
  int get footingsWithoutSuperiorMesh {
    return footingResults.where((f) => !f.hasSuperiorMesh).length;
  }

  /// Porcentaje de zapatas con malla superior
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no hay zapatas
  double get superiorMeshPercentage {
    if (numberOfElements == 0) return 0.0;
    return (footingsWithSuperiorMesh / numberOfElements) * 100;
  }

  /// Zapata con mayor peso
  ///
  /// **Retorna:** El resultado de la zapata más pesada, o null si no hay zapatas
  SteelFootingCalculationResult? get heaviestFooting {
    if (footingResults.isEmpty) return null;
    return footingResults.reduce(
          (a, b) => a.totalWeight > b.totalWeight ? a : b,
    );
  }

  /// Zapata con menor peso
  ///
  /// **Retorna:** El resultado de la zapata más liviana, o null si no hay zapatas
  SteelFootingCalculationResult? get lightestFooting {
    if (footingResults.isEmpty) return null;
    return footingResults.reduce(
          (a, b) => a.totalWeight < b.totalWeight ? a : b,
    );
  }

  /// Zapata con más barras totales
  ///
  /// **Retorna:** El resultado de la zapata con más barras, o null si no hay zapatas
  SteelFootingCalculationResult? get footingWithMostBars {
    if (footingResults.isEmpty) return null;
    return footingResults.reduce(
          (a, b) => a.totalBarsCount > b.totalBarsCount ? a : b,
    );
  }

  /// Total de barras en todas las zapatas
  ///
  /// **Retorna:** Suma de todas las barras (inferior + superior)
  int get totalBars {
    return footingResults.fold(
      0,
          (sum, footing) => sum + footing.totalBarsCount,
    );
  }

  /// Promedio de barras por zapata
  ///
  /// **Retorna:** Cantidad promedio, o 0.0 si no hay zapatas
  double get averageBarsPerFooting {
    return numberOfElements > 0 ? totalBars / numberOfElements : 0.0;
  }

  /// Obtiene una zapata específica por su ID
  ///
  /// **Parámetros:**
  /// - `footingId`: ID de la zapata a buscar
  ///
  /// **Retorna:** El resultado de la zapata, o null si no se encuentra
  SteelFootingCalculationResult? getFootingById(String footingId) {
    try {
      return footingResults.firstWhere((f) => f.id == footingId);
    } catch (e) {
      return null;
    }
  }

  /// Filtra zapatas por peso mínimo
  ///
  /// **Parámetros:**
  /// - `minWeight`: Peso mínimo en kg
  ///
  /// **Retorna:** Lista de zapatas que superan el peso mínimo
  List<SteelFootingCalculationResult> getFootingsAboveWeight(double minWeight) {
    return footingResults.where((f) => f.totalWeight >= minWeight).toList();
  }

  /// Filtra zapatas con malla superior
  ///
  /// **Retorna:** Lista de zapatas con refuerzo doble
  List<SteelFootingCalculationResult> getFootingsWithSuperiorMesh() {
    return footingResults.where((f) => f.hasSuperiorMesh).toList();
  }

  /// Filtra zapatas sin malla superior
  ///
  /// **Retorna:** Lista de zapatas con refuerzo simple
  List<SteelFootingCalculationResult> getFootingsWithoutSuperiorMesh() {
    return footingResults.where((f) => !f.hasSuperiorMesh).toList();
  }

  /// Filtra zapatas por cantidad mínima de barras
  ///
  /// **Parámetros:**
  /// - `minBars`: Cantidad mínima de barras totales
  ///
  /// **Retorna:** Lista de zapatas con al menos esa cantidad de barras
  List<SteelFootingCalculationResult> getFootingsAboveBars(int minBars) {
    return footingResults.where((f) => f.totalBarsCount >= minBars).toList();
  }

  /// Obtiene resumen estadístico de las zapatas
  ///
  /// **Retorna:** Map con estadísticas clave
  ///
  /// **Ejemplo:**
  /// ```dart
  /// {
  ///   'totalFootings': 8,
  ///   'footingsWithSuperiorMesh': 3,
  ///   'footingsWithoutSuperiorMesh': 5,
  ///   'superiorMeshPercentage': 37.5,
  ///   'totalWeight': 764.0,
  ///   'totalBars': 160,
  ///   'averageWeight': 95.5,
  ///   'averageBars': 20.0,
  ///   'heaviestFooting': 'ZAPATA Z-1',
  ///   'lightestFooting': 'ZAPATA Z-5',
  /// }
  /// ```
  Map<String, dynamic> getStatistics() {
    return {
      'totalFootings': numberOfElements,
      'footingsWithSuperiorMesh': footingsWithSuperiorMesh,
      'footingsWithoutSuperiorMesh': footingsWithoutSuperiorMesh,
      'superiorMeshPercentage': superiorMeshPercentage,
      'totalWeight': totalWeight,
      'totalWeightWithWire': totalWeightWithWire,
      'totalWire': totalWire,
      'totalRods': totalRods,
      'totalBars': totalBars,
      'averageWeight': averageWeightPerElement,
      'averageRods': averageRodsPerElement,
      'averageBars': averageBarsPerFooting,
      'heaviestFooting': heaviestFooting?.description,
      'lightestFooting': lightestFooting?.description,
      'footingWithMostBars': footingWithMostBars?.description,
      'diameterCount': diameterCount,
      'usedDiameters': usedDiameters,
    };
  }
}