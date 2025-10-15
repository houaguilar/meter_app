import '../steel_base_models.dart';
import 'mesh_enums.dart';

/// Cálculo de una dirección específica (horizontal o vertical) de la malla
///
/// Contiene todos los detalles del cálculo de barras en una dirección,
/// incluyendo diámetro, separación, cantidad y pesos.
///
/// **Uso:**
/// ```dart
/// final horizontal = SlabDirectionCalculation(
///   diameter: '1/2"',
///   separation: 0.20,
///   quantity: 15,
///   lengthPerBar: 5.5,
///   totalLength: 82.5,
///   weight: 82.0,
/// );
/// ```
class SlabDirectionCalculation {
  /// Diámetro de las barras en esta dirección
  ///
  /// **Ejemplo:** "1/2"", "12mm", "3/8""
  final String diameter;

  /// Separación entre barras en metros
  ///
  /// **Valores típicos:** 0.15m, 0.20m, 0.25m, 0.30m
  final double separation;

  /// Cantidad de barras en esta dirección
  ///
  /// **Cálculo:**
  /// - Horizontal: `(ancho / separacion) + 1`
  /// - Vertical: `(largo / separacion) + 1`
  final int quantity;

  /// Longitud de cada barra individual en metros
  ///
  /// **Cálculo:**
  /// - Horizontal: `largo + (2 × doblez)`
  /// - Vertical: `ancho + (2 × doblez)`
  final double lengthPerBar;

  /// Longitud total de todas las barras en metros
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalLength = quantity × lengthPerBar × elementos
  /// ```
  final double totalLength;

  /// Peso total de esta dirección en kilogramos
  ///
  /// **Cálculo:**
  /// ```dart
  /// weight = totalLength × SteelConstants.steelWeights[diameter]
  /// ```
  final double weight;

  /// Constructor principal
  const SlabDirectionCalculation({
    required this.diameter,
    required this.separation,
    required this.quantity,
    required this.lengthPerBar,
    required this.totalLength,
    required this.weight,
  });

  /// Verifica si tiene barras
  bool get hasBars => quantity > 0;

  /// Densidad de barras (barras por metro)
  ///
  /// **Retorna:** Cantidad de barras por metro según la separación
  ///
  /// **Ejemplo:** Si separación = 0.20m → densidad = 5 barras/m
  double get barDensity => separation > 0 ? 1 / separation : 0.0;
}

/// Cálculo de una malla específica (inferior o superior)
///
/// Agrupa el cálculo completo de una malla, incluyendo ambas direcciones
/// (horizontal y vertical) y el peso total de la malla.
///
/// **Uso:**
/// ```dart
/// final mallaInferior = SlabMeshCalculation(
///   type: MeshType.inferior,
///   horizontal: calculoHorizontal,
///   vertical: calculoVertical,
///   totalWeight: 164.0,
/// );
/// ```
class SlabMeshCalculation {
  /// Tipo de malla (inferior o superior)
  ///
  /// Utiliza el enum [MeshType] para distinguir entre:
  /// - `MeshType.inferior`: Malla inferior (obligatoria)
  /// - `MeshType.superior`: Malla superior (opcional)
  final MeshType type;

  /// Cálculo de las barras horizontales
  ///
  /// Barras que corren en la dirección del largo de la losa
  final SlabDirectionCalculation horizontal;

  /// Cálculo de las barras verticales
  ///
  /// Barras que corren en la dirección del ancho de la losa
  final SlabDirectionCalculation vertical;

  /// Peso total de esta malla en kilogramos
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalWeight = horizontal.weight + vertical.weight
  /// ```
  final double totalWeight;

  /// Constructor principal
  const SlabMeshCalculation({
    required this.type,
    required this.horizontal,
    required this.vertical,
    required this.totalWeight,
  });

  /// Nombre descriptivo del tipo de malla
  ///
  /// **Retorna:** "Malla Inferior" o "Malla Superior"
  String get meshTypeName {
    return type == MeshType.inferior ? 'Malla Inferior' : 'Malla Superior';
  }

  /// Total de barras en esta malla (horizontal + vertical)
  int get totalBars => horizontal.quantity + vertical.quantity;

  /// Longitud total combinada de ambas direcciones en metros
  double get totalLength => horizontal.totalLength + vertical.totalLength;

  /// Verifica si la malla tiene barras
  bool get hasBars => totalBars > 0;

  /// Porcentaje de peso de barras horizontales respecto al total de la malla
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no hay peso total
  double get horizontalWeightPercentage {
    if (totalWeight == 0) return 0.0;
    return (horizontal.weight / totalWeight) * 100;
  }

  /// Porcentaje de peso de barras verticales respecto al total de la malla
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no hay peso total
  double get verticalWeightPercentage {
    if (totalWeight == 0) return 0.0;
    return (vertical.weight / totalWeight) * 100;
  }
}

/// Resultado del cálculo de acero para una losa maciza
///
/// Extiende [BaseSteelCalculationResult] y agrega campos específicos
/// relacionados con mallas inferior y superior.
///
/// **Similar a zapatas pero con más detalle:** Las losas tienen la misma
/// estructura de mallas que las zapatas, pero con información más detallada
/// por dirección.
///
/// **Uso:**
/// ```dart
/// final resultado = SteelSlabCalculationResult(
///   slabId: 'losa-001',
///   description: 'LOSA L-1',
///   totalWeight: 328.0,
///   wireWeight: 4.92,
///   inferiorMesh: mallaInferior,
///   superiorMesh: mallaSuperior, // puede ser null
///   materials: {...},
///   totalsByDiameter: {...},
/// );
/// ```
class SteelSlabCalculationResult extends BaseSteelCalculationResult {
  /// Cálculos de la malla inferior (obligatoria)
  ///
  /// Todas las losas tienen al menos una malla inferior que
  /// trabaja a tracción por flexión.
  final SlabMeshCalculation inferiorMesh;

  /// Cálculos de la malla superior (opcional)
  ///
  /// Algunas losas requieren refuerzo superior según el diseño
  /// estructural o para control de fisuras. Puede ser `null`.
  final SlabMeshCalculation? superiorMesh;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `id`: ID único de la losa
  /// - `description`: Descripción (ej: "LOSA L-1")
  /// - `totalWeight`: Peso total del acero en kg
  /// - `wireWeight`: Peso del alambre #16 en kg
  /// - `materials`: Materiales por diámetro
  /// - `totalsByDiameter`: Longitudes por diámetro
  ///
  /// **Parámetros específicos de losa:**
  /// - `inferiorMesh`: Cálculos de la malla inferior (obligatorio)
  /// - `superiorMesh`: Cálculos de la malla superior (opcional)
  const SteelSlabCalculationResult({
    required String slabId,
    required String description,
    required double totalWeight,
    required double wireWeight,
    required Map<String, MaterialQuantity> materials,
    required Map<String, double> totalsByDiameter,
    required this.inferiorMesh,
    this.superiorMesh,
  }) : super(
    id: slabId,
    description: description,
    totalWeight: totalWeight,
    wireWeight: wireWeight,
    materials: materials,
    totalsByDiameter: totalsByDiameter,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE LOSA
  // ===========================================================================

  /// Indica si la losa tiene malla superior
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

  /// Peso de la malla inferior en kilogramos
  double get inferiorMeshWeight => inferiorMesh.totalWeight;

  /// Peso de la malla superior en kilogramos (0 si no existe)
  double get superiorMeshWeight => superiorMesh?.totalWeight ?? 0.0;

  /// Longitud total de la malla inferior en metros
  double get inferiorMeshLength => inferiorMesh.totalLength;

  /// Longitud total de la malla superior en metros (0 si no existe)
  double get superiorMeshLength => superiorMesh?.totalLength ?? 0.0;

  /// Longitud total de ambas mallas en metros
  double get totalMeshLength => inferiorMeshLength + superiorMeshLength;

  /// Porcentaje de acero en malla superior respecto al peso total
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no hay malla superior
  double get superiorMeshWeightPercentage {
    if (totalWeight == 0) return 0.0;
    return (superiorMeshWeight / totalWeight) * 100;
  }

  /// Obtiene el diámetro usado en una dirección específica de una malla
  ///
  /// **Parámetros:**
  /// - `meshType`: Tipo de malla (inferior/superior)
  /// - `isHorizontal`: true para horizontal, false para vertical
  ///
  /// **Retorna:** Diámetro usado, o null si no existe esa malla
  String? getDiameterForDirection(MeshType meshType, bool isHorizontal) {
    final mesh = meshType == MeshType.inferior ? inferiorMesh : superiorMesh;
    if (mesh == null) return null;
    return isHorizontal ? mesh.horizontal.diameter : mesh.vertical.diameter;
  }

  /// Obtiene la separación usada en una dirección específica de una malla
  ///
  /// **Parámetros:**
  /// - `meshType`: Tipo de malla (inferior/superior)
  /// - `isHorizontal`: true para horizontal, false para vertical
  ///
  /// **Retorna:** Separación en metros, o null si no existe esa malla
  double? getSeparationForDirection(MeshType meshType, bool isHorizontal) {
    final mesh = meshType == MeshType.inferior ? inferiorMesh : superiorMesh;
    if (mesh == null) return null;
    return isHorizontal ? mesh.horizontal.separation : mesh.vertical.separation;
  }
}

/// Resultado consolidado de múltiples losas macizas
///
/// Suma los resultados de todas las losas calculadas y provee
/// totales generales del proyecto.
///
/// **Uso:**
/// ```dart
/// final consolidado = ConsolidatedSteelSlabResult(
///   numberOfSlabs: 6,
///   totalWeight: 1968.0,
///   totalWire: 29.52,
///   slabResults: [...],
///   consolidatedMaterials: {...},
/// );
/// ```
class ConsolidatedSteelSlabResult extends BaseConsolidatedSteelResult {
  /// Lista de resultados individuales de cada losa
  ///
  /// Permite acceso a los cálculos detallados de cada losa
  /// para reporting o análisis específico.
  final List<SteelSlabCalculationResult> slabResults;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `numberOfElements`: Cantidad de losas consolidadas
  /// - `totalWeight`: Peso total de todas las losas en kg
  /// - `totalWire`: Peso total del alambre #16 en kg
  /// - `consolidatedMaterials`: Materiales sumados por diámetro
  ///
  /// **Parámetros específicos:**
  /// - `slabResults`: Lista de resultados individuales
  const ConsolidatedSteelSlabResult({
    required int numberOfSlabs,
    required double totalWeight,
    required double totalWire,
    required Map<String, MaterialQuantity> consolidatedMaterials,
    required this.slabResults,
  }) : super(
    numberOfElements: numberOfSlabs,
    totalWeight: totalWeight,
    totalWire: totalWire,
    consolidatedMaterials: consolidatedMaterials,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE LOSAS CONSOLIDADAS
  // ===========================================================================

  /// Cantidad de losas con malla superior
  ///
  /// **Retorna:** Número de losas que tienen refuerzo doble
  int get slabsWithSuperiorMesh {
    return slabResults.where((s) => s.hasSuperiorMesh).length;
  }

  /// Cantidad de losas sin malla superior
  ///
  /// **Retorna:** Número de losas que tienen refuerzo simple
  int get slabsWithoutSuperiorMesh {
    return slabResults.where((s) => !s.hasSuperiorMesh).length;
  }

  /// Porcentaje de losas con malla superior
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no hay losas
  double get superiorMeshPercentage {
    if (numberOfElements == 0) return 0.0;
    return (slabsWithSuperiorMesh / numberOfElements) * 100;
  }

  /// Losa con mayor peso
  ///
  /// **Retorna:** El resultado de la losa más pesada, o null si no hay losas
  SteelSlabCalculationResult? get heaviestSlab {
    if (slabResults.isEmpty) return null;
    return slabResults.reduce(
          (a, b) => a.totalWeight > b.totalWeight ? a : b,
    );
  }

  /// Losa con menor peso
  ///
  /// **Retorna:** El resultado de la losa más liviana, o null si no hay losas
  SteelSlabCalculationResult? get lightestSlab {
    if (slabResults.isEmpty) return null;
    return slabResults.reduce(
          (a, b) => a.totalWeight < b.totalWeight ? a : b,
    );
  }

  /// Losa con más barras totales
  ///
  /// **Retorna:** El resultado de la losa con más barras, o null si no hay losas
  SteelSlabCalculationResult? get slabWithMostBars {
    if (slabResults.isEmpty) return null;
    return slabResults.reduce(
          (a, b) => a.totalBarsCount > b.totalBarsCount ? a : b,
    );
  }

  /// Total de barras en todas las losas
  ///
  /// **Retorna:** Suma de todas las barras (inferior + superior)
  int get totalBars {
    return slabResults.fold(
      0,
          (sum, slab) => sum + slab.totalBarsCount,
    );
  }

  /// Promedio de barras por losa
  ///
  /// **Retorna:** Cantidad promedio, o 0.0 si no hay losas
  double get averageBarsPerSlab {
    return numberOfElements > 0 ? totalBars / numberOfElements : 0.0;
  }

  /// Obtiene una losa específica por su ID
  ///
  /// **Parámetros:**
  /// - `slabId`: ID de la losa a buscar
  ///
  /// **Retorna:** El resultado de la losa, o null si no se encuentra
  SteelSlabCalculationResult? getSlabById(String slabId) {
    try {
      return slabResults.firstWhere((s) => s.id == slabId);
    } catch (e) {
      return null;
    }
  }

  /// Filtra losas por peso mínimo
  ///
  /// **Parámetros:**
  /// - `minWeight`: Peso mínimo en kg
  ///
  /// **Retorna:** Lista de losas que superan el peso mínimo
  List<SteelSlabCalculationResult> getSlabsAboveWeight(double minWeight) {
    return slabResults.where((s) => s.totalWeight >= minWeight).toList();
  }

  /// Filtra losas con malla superior
  ///
  /// **Retorna:** Lista de losas con refuerzo doble
  List<SteelSlabCalculationResult> getSlabsWithSuperiorMesh() {
    return slabResults.where((s) => s.hasSuperiorMesh).toList();
  }

  /// Filtra losas sin malla superior
  ///
  /// **Retorna:** Lista de losas con refuerzo simple
  List<SteelSlabCalculationResult> getSlabsWithoutSuperiorMesh() {
    return slabResults.where((s) => !s.hasSuperiorMesh).toList();
  }

  /// Filtra losas por cantidad mínima de barras
  ///
  /// **Parámetros:**
  /// - `minBars`: Cantidad mínima de barras totales
  ///
  /// **Retorna:** Lista de losas con al menos esa cantidad de barras
  List<SteelSlabCalculationResult> getSlabsAboveBars(int minBars) {
    return slabResults.where((s) => s.totalBarsCount >= minBars).toList();
  }

  /// Obtiene todas las losas que usan un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro a buscar (ej: "1/2"", "12mm")
  ///
  /// **Retorna:** Lista de losas que usan ese diámetro en cualquier dirección
  List<SteelSlabCalculationResult> getSlabsUsingDiameter(String diameter) {
    return slabResults.where((s) => s.usesDiameter(diameter)).toList();
  }

  /// Obtiene resumen estadístico de las losas
  ///
  /// **Retorna:** Map con estadísticas clave
  ///
  /// **Ejemplo:**
  /// ```dart
  /// {
  ///   'totalSlabs': 6,
  ///   'slabsWithSuperiorMesh': 2,
  ///   'slabsWithoutSuperiorMesh': 4,
  ///   'superiorMeshPercentage': 33.33,
  ///   'totalWeight': 1968.0,
  ///   'totalBars': 360,
  ///   'averageWeight': 328.0,
  ///   'averageBars': 60.0,
  ///   'heaviestSlab': 'LOSA L-1',
  ///   'lightestSlab': 'LOSA L-4',
  /// }
  /// ```
  Map<String, dynamic> getStatistics() {
    return {
      'totalSlabs': numberOfElements,
      'slabsWithSuperiorMesh': slabsWithSuperiorMesh,
      'slabsWithoutSuperiorMesh': slabsWithoutSuperiorMesh,
      'superiorMeshPercentage': superiorMeshPercentage,
      'totalWeight': totalWeight,
      'totalWeightWithWire': totalWeightWithWire,
      'totalWire': totalWire,
      'totalRods': totalRods,
      'totalBars': totalBars,
      'averageWeight': averageWeightPerElement,
      'averageRods': averageRodsPerElement,
      'averageBars': averageBarsPerSlab,
      'heaviestSlab': heaviestSlab?.description,
      'lightestSlab': lightestSlab?.description,
      'slabWithMostBars': slabWithMostBars?.description,
      'diameterCount': diameterCount,
      'usedDiameters': usedDiameters,
    };
  }

  /// Obtiene resumen por tipo de malla
  ///
  /// **Retorna:** Map con estadísticas separadas por malla inferior y superior
  ///
  /// **Ejemplo:**
  /// ```dart
  /// {
  ///   'inferiorMesh': {
  ///     'totalSlabs': 6,
  ///     'totalBars': 240,
  ///     'totalWeight': 1200.0,
  ///   },
  ///   'superiorMesh': {
  ///     'totalSlabs': 2,
  ///     'totalBars': 120,
  ///     'totalWeight': 768.0,
  ///   }
  /// }
  /// ```
  Map<String, Map<String, dynamic>> getMeshStatistics() {
    int inferiorBars = 0;
    double inferiorWeight = 0.0;
    int superiorBars = 0;
    double superiorWeight = 0.0;

    for (final slab in slabResults) {
      inferiorBars += slab.inferiorBarsCount;
      inferiorWeight += slab.inferiorMeshWeight;

      if (slab.hasSuperiorMesh) {
        superiorBars += slab.superiorBarsCount;
        superiorWeight += slab.superiorMeshWeight;
      }
    }

    return {
      'inferiorMesh': {
        'totalSlabs': numberOfElements,
        'totalBars': inferiorBars,
        'totalWeight': inferiorWeight,
        'averageBars': numberOfElements > 0 ? inferiorBars / numberOfElements : 0.0,
        'averageWeight': numberOfElements > 0 ? inferiorWeight / numberOfElements : 0.0,
      },
      'superiorMesh': {
        'totalSlabs': slabsWithSuperiorMesh,
        'totalBars': superiorBars,
        'totalWeight': superiorWeight,
        'averageBars': slabsWithSuperiorMesh > 0 ? superiorBars / slabsWithSuperiorMesh : 0.0,
        'averageWeight': slabsWithSuperiorMesh > 0 ? superiorWeight / slabsWithSuperiorMesh : 0.0,
      },
    };
  }
}