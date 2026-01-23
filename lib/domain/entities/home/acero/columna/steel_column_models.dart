import '../steel_base_models.dart';

/// Resultado del cálculo de acero para una columna
///
/// Extiende [BaseSteelCalculationResult] y agrega campos específicos
/// de columnas: estribos y doblez de zapata.
///
/// **Uso:**
/// ```dart
/// final resultado = SteelColumnCalculationResult(
///   columnId: 'columna-001',
///   description: 'COLUMNA C-1',
///   totalWeight: 185.5,
///   wireWeight: 2.78,
///   totalStirrups: 60,
///   stirrupPerimeter: 2.0,
///   hasFooting: true,
///   materials: {...},
///   totalsByDiameter: {...},
/// );
/// ```
class SteelColumnCalculationResult extends BaseSteelCalculationResult {
  /// Total de estribos calculados para esta columna
  ///
  /// Incluye:
  /// - Estribos de las distribuciones especiales (confinamiento)
  /// - Estribos del resto (zona central)
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalStirrups = estribosDistribuciones + estribosResto
  /// ```
  final double totalStirrups;

  /// Perímetro de un estribo individual en metros
  ///
  /// Calculado según las dimensiones de la columna y el recubrimiento:
  /// ```dart
  /// perimetro = 2 × (alto - 2×recubrimiento) +
  ///             2 × (largo - 2×recubrimiento) +
  ///             2 × doblezEstribo
  /// ```
  ///
  /// **Ejemplo:** Para una columna de 0.25m × 0.40m con recubrimiento
  /// de 0.04m y doblez de 0.08m:
  /// ```dart
  /// perimetro = 2×(0.40-0.08) + 2×(0.25-0.08) + 2×0.08 = 1.14m
  /// ```
  final double stirrupPerimeter;

  /// Indica si la columna tiene doblez hacia la zapata
  ///
  /// Cuando es `true`, el acero longitudinal incluye una longitud
  /// adicional de doblez que se ancla en la zapata para continuidad
  /// estructural.
  ///
  /// **Longitud de doblez:** Definida en la entidad SteelColumn
  /// (típicamente 0.4m - 0.6m)
  final bool hasFooting;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `id`: ID único de la columna
  /// - `description`: Descripción (ej: "COLUMNA C-1")
  /// - `totalWeight`: Peso total del acero en kg
  /// - `wireWeight`: Peso del alambre #16 en kg
  /// - `materials`: Materiales por diámetro
  /// - `totalsByDiameter`: Longitudes por diámetro
  ///
  /// **Parámetros específicos de columna:**
  /// - `totalStirrups`: Total de estribos
  /// - `stirrupPerimeter`: Perímetro del estribo en metros
  /// - `hasFooting`: Si tiene doblez de zapata
  const SteelColumnCalculationResult({
    required String columnId,
    required String description,
    required double totalWeight,
    required double wireWeight,
    required Map<String, MaterialQuantity> materials,
    required Map<String, double> totalsByDiameter,
    required this.totalStirrups,
    required this.stirrupPerimeter,
    required this.hasFooting,
  }) : super(
    id: columnId,
    description: description,
    totalWeight: totalWeight,
    wireWeight: wireWeight,
    materials: materials,
    totalsByDiameter: totalsByDiameter,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE COLUMNA
  // ===========================================================================

  /// Longitud total de acero usado en estribos (metros)
  ///
  /// **Cálculo:**
  /// ```dart
  /// longitudEstribos = totalStirrups × stirrupPerimeter
  /// ```
  double get totalStirrupLength => totalStirrups * stirrupPerimeter;

  /// Verifica si la columna tiene estribos
  bool get hasStirrups => totalStirrups > 0;

  /// Densidad de estribos (estribos por metro de columna)
  ///
  /// Útil para verificar si cumple con normas de confinamiento
  ///
  /// **Parámetros requeridos:** Necesita la altura de la columna
  /// (no almacenada en el resultado, debe calcularse externamente)
  ///
  /// **Ejemplo:**
  /// ```dart
  /// double densidad = resultado.stirrupDensity(3.5); // columna de 3.5m
  /// // Si tiene 60 estribos: densidad = 17.14 estribos/m
  /// ```
  double stirrupDensity(double columnHeight) {
    if (columnHeight <= 0) return 0.0;
    return totalStirrups / columnHeight;
  }

  /// Tipo de columna según conexión con zapata
  ///
  /// **Retorna:**
  /// - "Con Zapata" si hasFooting es true
  /// - "Sin Zapata" si hasFooting es false
  String get footingType => hasFooting ? 'Con Zapata' : 'Sin Zapata';
}

/// Resultado consolidado de múltiples columnas
///
/// Suma los resultados de todas las columnas calculadas y provee
/// totales generales del proyecto.
///
/// **Uso:**
/// ```dart
/// final consolidado = ConsolidatedColumnSteelResult(
///   numberOfColumns: 15,
///   totalWeight: 2775.0,
///   totalWire: 41.63,
///   totalStirrups: 900,
///   columnResults: [...],
///   consolidatedMaterials: {...},
/// );
/// ```
class ConsolidatedColumnSteelResult extends BaseConsolidatedSteelResult {
  /// Total de estribos de todas las columnas sumadas
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalStirrups = Σ(columna.totalStirrups) para cada columna
  /// ```
  final int totalStirrups;

  /// Lista de resultados individuales de cada columna
  ///
  /// Permite acceso a los cálculos detallados de cada columna
  /// para reporting o análisis específico.
  final List<SteelColumnCalculationResult> columnResults;

  /// Constructor principal
  ///
  /// **Parámetros heredados:**
  /// - `numberOfElements`: Cantidad de columnas consolidadas
  /// - `totalWeight`: Peso total de todas las columnas en kg
  /// - `totalWire`: Peso total del alambre #16 en kg
  /// - `consolidatedMaterials`: Materiales sumados por diámetro
  ///
  /// **Parámetros específicos:**
  /// - `totalStirrups`: Total de estribos de todas las columnas
  /// - `columnResults`: Lista de resultados individuales
  const ConsolidatedColumnSteelResult({
    required int numberOfColumns,
    required double totalWeight,
    required double totalWire,
    required Map<String, MaterialQuantity> consolidatedMaterials,
    required this.totalStirrups,
    required this.columnResults,
  }) : super(
    numberOfElements: numberOfColumns,
    totalWeight: totalWeight,
    totalWire: totalWire,
    consolidatedMaterials: consolidatedMaterials,
  );

  // ===========================================================================
  // GETTERS ESPECÍFICOS DE COLUMNAS CONSOLIDADAS
  // ===========================================================================

  /// Promedio de estribos por columna
  ///
  /// **Retorna:** Cantidad promedio, o 0.0 si no hay columnas
  double get averageStirrupsPerColumn {
    return numberOfElements > 0 ? totalStirrups / numberOfElements : 0.0;
  }

  /// Cantidad de columnas con zapata
  ///
  /// **Retorna:** Número de columnas que tienen hasFooting = true
  int get columnsWithFooting {
    return columnResults.where((col) => col.hasFooting).length;
  }

  /// Cantidad de columnas sin zapata
  ///
  /// **Retorna:** Número de columnas que tienen hasFooting = false
  int get columnsWithoutFooting {
    return columnResults.where((col) => !col.hasFooting).length;
  }

  /// Porcentaje de columnas con zapata
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no hay columnas
  double get footingPercentage {
    if (numberOfElements == 0) return 0.0;
    return (columnsWithFooting / numberOfElements) * 100;
  }

  /// Columna con mayor peso
  ///
  /// **Retorna:** El resultado de la columna más pesada, o null si no hay columnas
  SteelColumnCalculationResult? get heaviestColumn {
    if (columnResults.isEmpty) return null;
    return columnResults.reduce(
          (a, b) => a.totalWeight > b.totalWeight ? a : b,
    );
  }

  /// Columna con menor peso
  ///
  /// **Retorna:** El resultado de la columna más liviana, o null si no hay columnas
  SteelColumnCalculationResult? get lightestColumn {
    if (columnResults.isEmpty) return null;
    return columnResults.reduce(
          (a, b) => a.totalWeight < b.totalWeight ? a : b,
    );
  }

  /// Columna con más estribos
  ///
  /// **Retorna:** El resultado de la columna con más estribos, o null si no hay columnas
  SteelColumnCalculationResult? get columnWithMostStirrups {
    if (columnResults.isEmpty) return null;
    return columnResults.reduce(
          (a, b) => a.totalStirrups > b.totalStirrups ? a : b,
    );
  }

  /// Obtiene una columna específica por su ID
  ///
  /// **Parámetros:**
  /// - `columnId`: ID de la columna a buscar
  ///
  /// **Retorna:** El resultado de la columna, o null si no se encuentra
  SteelColumnCalculationResult? getColumnById(String columnId) {
    try {
      return columnResults.firstWhere((col) => col.id == columnId);
    } catch (e) {
      return null;
    }
  }

  /// Filtra columnas por peso mínimo
  ///
  /// **Parámetros:**
  /// - `minWeight`: Peso mínimo en kg
  ///
  /// **Retorna:** Lista de columnas que superan el peso mínimo
  List<SteelColumnCalculationResult> getColumnsAboveWeight(double minWeight) {
    return columnResults.where((col) => col.totalWeight >= minWeight).toList();
  }

  /// Filtra columnas por cantidad mínima de estribos
  ///
  /// **Parámetros:**
  /// - `minStirrups`: Cantidad mínima de estribos
  ///
  /// **Retorna:** Lista de columnas con al menos esa cantidad de estribos
  List<SteelColumnCalculationResult> getColumnsAboveStirrups(int minStirrups) {
    return columnResults.where((col) => col.totalStirrups >= minStirrups).toList();
  }

  /// Filtra columnas con zapata
  ///
  /// **Retorna:** Lista de columnas que tienen hasFooting = true
  List<SteelColumnCalculationResult> getColumnsWithFooting() {
    return columnResults.where((col) => col.hasFooting).toList();
  }

  /// Filtra columnas sin zapata
  ///
  /// **Retorna:** Lista de columnas que tienen hasFooting = false
  List<SteelColumnCalculationResult> getColumnsWithoutFooting() {
    return columnResults.where((col) => !col.hasFooting).toList();
  }

  /// Obtiene resumen estadístico de las columnas
  ///
  /// **Retorna:** Map con estadísticas clave
  ///
  /// **Ejemplo:**
  /// ```dart
  /// {
  ///   'totalColumns': 15,
  ///   'columnsWithFooting': 10,
  ///   'columnsWithoutFooting': 5,
  ///   'footingPercentage': 66.67,
  ///   'totalWeight': 2775.0,
  ///   'totalStirrups': 900,
  ///   'averageWeight': 185.0,
  ///   'averageStirrups': 60.0,
  ///   'heaviestColumn': 'COLUMNA C-1',
  ///   'lightestColumn': 'COLUMNA C-5',
  /// }
  /// ```
  Map<String, dynamic> getStatistics() {
    return {
      'totalColumns': numberOfElements,
      'columnsWithFooting': columnsWithFooting,
      'columnsWithoutFooting': columnsWithoutFooting,
      'footingPercentage': footingPercentage,
      'totalWeight': totalWeight,
      'totalWeightWithWire': totalWeightWithWire,
      'totalWire': totalWire,
      'totalStirrups': totalStirrups,
      'totalRods': totalRods,
      'averageWeight': averageWeightPerElement,
      'averageRods': averageRodsPerElement,
      'averageStirrups': averageStirrupsPerColumn,
      'heaviestColumn': heaviestColumn?.description,
      'lightestColumn': lightestColumn?.description,
      'columnWithMostStirrups': columnWithMostStirrups?.description,
      'diameterCount': diameterCount,
      'usedDiameters': usedDiameters,
    };
  }
}