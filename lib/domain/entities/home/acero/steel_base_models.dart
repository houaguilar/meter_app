
/// Cantidad de material calculado para un diámetro específico
///
/// Representa la cantidad de varillas necesarias después de aplicar
/// desperdicio y convertir de metros a varillas estándar de 9m.
///
/// **Uso:**
/// ```dart
/// MaterialQuantity material = MaterialQuantity(
///   quantity: 15.5,
///   unit: 'Varillas',
/// );
/// ```
class MaterialQuantity {
  /// Cantidad de varillas necesarias
  ///
  /// Este valor ya incluye:
  /// - Conversión de metros a varillas (÷ 9.0)
  /// - Desperdicio aplicado
  /// - Redondeo hacia arriba (ceil)
  final double quantity;

  /// Unidad de medida
  ///
  /// Por defecto: "Varillas"
  /// Otras opciones posibles: "kg", "m", etc.
  final String unit;

  /// Constructor principal
  const MaterialQuantity({
    required this.quantity,
    this.unit = 'Varillas',
  });

  /// Crea una copia con valores opcionales modificados
  ///
  /// **Ejemplo:**
  /// ```dart
  /// MaterialQuantity nuevo = original.copyWith(quantity: 20.0);
  /// ```
  MaterialQuantity copyWith({
    double? quantity,
    String? unit,
  }) {
    return MaterialQuantity(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  /// Representación en texto
  ///
  /// **Ejemplo:** "15.5 Varillas"
  @override
  String toString() => '${quantity.toStringAsFixed(2)} $unit';

  /// Compara dos MaterialQuantity por igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialQuantity &&
        other.quantity == quantity &&
        other.unit == unit;
  }

  /// Hash code para uso en colecciones
  @override
  int get hashCode => quantity.hashCode ^ unit.hashCode;

  /// Suma dos cantidades de material
  ///
  /// **Nota:** Ambas deben tener la misma unidad
  ///
  /// **Ejemplo:**
  /// ```dart
  /// MaterialQuantity suma = material1 + material2;
  /// ```
  MaterialQuantity operator +(MaterialQuantity other) {
    if (unit != other.unit) {
      throw ArgumentError('No se pueden sumar materiales con unidades diferentes');
    }
    return MaterialQuantity(
      quantity: quantity + other.quantity,
      unit: unit,
    );
  }

  /// Multiplica la cantidad por un factor
  ///
  /// **Ejemplo:**
  /// ```dart
  /// MaterialQuantity doble = material * 2.0;
  /// ```
  MaterialQuantity operator *(double factor) {
    return MaterialQuantity(
      quantity: quantity * factor,
      unit: unit,
    );
  }
}

// =============================================================================
// CLASE BASE PARA RESULTADOS INDIVIDUALES
// =============================================================================

/// Clase base abstracta para resultados de cálculo de acero
///
/// Contiene los campos comunes a todos los tipos de elementos:
/// - Vigas
/// - Columnas
/// - Zapatas
/// - Losas Macizas
///
/// **Propósito:** Evitar duplicación de código mediante herencia
abstract class BaseSteelCalculationResult {
  /// ID único del elemento calculado
  ///
  /// Generalmente un UUID v4
  final String id;

  /// Descripción del elemento
  ///
  /// Ejemplo: "COLUMNA C-1", "VIGA V-101", "ZAPATA Z-1"
  final String description;

  /// Peso total del acero estructural en kilogramos
  ///
  /// **NO incluye** el peso del alambre #16
  ///
  /// Calculado sumando:
  /// ```dart
  /// totalWeight = Σ(longitud × peso_por_metro) para cada diámetro
  /// ```
  final double totalWeight;

  /// Peso del alambre de amarre #16 en kilogramos
  ///
  /// Calculado como:
  /// ```dart
  /// wireWeight = totalWeight × 0.015 (1.5%)
  /// ```
  final double wireWeight;

  /// Materiales necesarios por diámetro
  ///
  /// **Clave:** Diámetro (ej: "1/2"", "12mm")
  ///
  /// **Valor:** MaterialQuantity con cantidad de varillas
  ///
  /// **Ejemplo:**
  /// ```dart
  /// {
  ///   '1/2"': MaterialQuantity(quantity: 15.0, unit: 'Varillas'),
  ///   '3/4"': MaterialQuantity(quantity: 8.0, unit: 'Varillas'),
  /// }
  /// ```
  final Map<String, MaterialQuantity> materials;

  /// Longitud total en metros por diámetro (antes de conversión a varillas)
  ///
  /// **Clave:** Diámetro (ej: "1/2"", "12mm")
  ///
  /// **Valor:** Longitud total en metros
  ///
  /// **Ejemplo:**
  /// ```dart
  /// {
  ///   '1/2"': 135.0,  // metros
  ///   '3/4"': 72.0,   // metros
  /// }
  /// ```
  final Map<String, double> totalsByDiameter;

  /// Constructor base
  const BaseSteelCalculationResult({
    required this.id,
    required this.description,
    required this.totalWeight,
    required this.wireWeight,
    required this.materials,
    required this.totalsByDiameter,
  });

  // ===========================================================================
  // GETTERS DERIVADOS
  // ===========================================================================

  /// Peso total incluyendo el alambre #16
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalWeightWithWire = totalWeight + wireWeight
  /// ```
  double get totalWeightWithWire => totalWeight + wireWeight;

  /// Cantidad total de varillas (sumando todos los diámetros)
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalRods = Σ(materials[d].quantity) para cada diámetro d
  /// ```
  double get totalRods {
    return materials.values.fold(
      0.0,
          (sum, material) => sum + material.quantity,
    );
  }

  /// Lista de diámetros utilizados en este elemento
  ///
  /// **Retorna:** Lista de strings con los diámetros (ej: ["1/2"", "3/4""])
  List<String> get usedDiameters => materials.keys.toList();

  /// Cantidad de diámetros diferentes utilizados
  ///
  /// **Ejemplo:** Si usa 1/2" y 3/4", retorna 2
  int get diameterCount => materials.length;

  /// Verifica si usa un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro a verificar (ej: "1/2"")
  ///
  /// **Retorna:** `true` si el diámetro está en uso
  bool usesDiameter(String diameter) {
    return materials.containsKey(diameter);
  }

  /// Obtiene la cantidad de varillas para un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro a consultar
  ///
  /// **Retorna:** Cantidad de varillas, o 0.0 si no usa ese diámetro
  double getRodsForDiameter(String diameter) {
    return materials[diameter]?.quantity ?? 0.0;
  }

  /// Obtiene la longitud total para un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro a consultar
  ///
  /// **Retorna:** Longitud en metros, o 0.0 si no usa ese diámetro
  double getLengthForDiameter(String diameter) {
    return totalsByDiameter[diameter] ?? 0.0;
  }
}

// =============================================================================
// CLASE BASE PARA RESULTADOS CONSOLIDADOS
// =============================================================================

/// Clase base abstracta para resultados consolidados
///
/// Agrupa múltiples elementos del mismo tipo y suma sus materiales
///
/// **Propósito:** Proveer totales generales del proyecto o sección
abstract class BaseConsolidatedSteelResult {
  /// Cantidad de elementos procesados y consolidados
  ///
  /// **Ejemplo:** Si consolidó 5 vigas, numberOfElements = 5
  final int numberOfElements;

  /// Peso total de todos los elementos en kilogramos
  ///
  /// **NO incluye** el alambre #16
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalWeight = Σ(elemento.totalWeight) para cada elemento
  /// ```
  final double totalWeight;

  /// Peso total del alambre #16 de todos los elementos en kg
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalWire = Σ(elemento.wireWeight) para cada elemento
  /// ```
  final double totalWire;

  /// Materiales consolidados sumando todos los elementos
  ///
  /// **Clave:** Diámetro (ej: "1/2"", "12mm")
  ///
  /// **Valor:** MaterialQuantity con suma de varillas de todos los elementos
  ///
  /// **Ejemplo:**
  /// ```dart
  /// // Si viga1 usa 10 varillas de 1/2" y viga2 usa 8 varillas de 1/2"
  /// {
  ///   '1/2"': MaterialQuantity(quantity: 18.0, unit: 'Varillas'),
  /// }
  /// ```
  final Map<String, MaterialQuantity> consolidatedMaterials;

  /// Constructor base
  const BaseConsolidatedSteelResult({
    required this.numberOfElements,
    required this.totalWeight,
    required this.totalWire,
    required this.consolidatedMaterials,
  });

  // ===========================================================================
  // GETTERS DERIVADOS
  // ===========================================================================

  /// Peso total incluyendo alambre de todos los elementos
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalWeightWithWire = totalWeight + totalWire
  /// ```
  double get totalWeightWithWire => totalWeight + totalWire;

  /// Cantidad total de varillas consolidadas
  ///
  /// **Cálculo:**
  /// ```dart
  /// totalRods = Σ(consolidatedMaterials[d].quantity) para cada diámetro d
  /// ```
  double get totalRods {
    return consolidatedMaterials.values.fold(
      0.0,
          (sum, material) => sum + material.quantity,
    );
  }

  /// Lista de diámetros utilizados (consolidados)
  List<String> get usedDiameters => consolidatedMaterials.keys.toList();

  /// Cantidad de diámetros diferentes en uso
  int get diameterCount => consolidatedMaterials.length;

  /// Verifica si hay elementos procesados
  bool get hasElements => numberOfElements > 0;

  /// Verifica si está vacío (sin elementos)
  bool get isEmpty => numberOfElements == 0;

  /// Promedio de peso por elemento
  ///
  /// **Retorna:** Peso promedio en kg, o 0.0 si no hay elementos
  double get averageWeightPerElement {
    return numberOfElements > 0 ? totalWeight / numberOfElements : 0.0;
  }

  /// Promedio de varillas por elemento
  ///
  /// **Retorna:** Cantidad promedio de varillas, o 0.0 si no hay elementos
  double get averageRodsPerElement {
    return numberOfElements > 0 ? totalRods / numberOfElements : 0.0;
  }

  /// Obtiene la cantidad consolidada para un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro a consultar
  ///
  /// **Retorna:** Cantidad total de varillas, o 0.0 si no usa ese diámetro
  double getRodsForDiameter(String diameter) {
    return consolidatedMaterials[diameter]?.quantity ?? 0.0;
  }

  /// Verifica si usa un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro a verificar
  ///
  /// **Retorna:** `true` si algún elemento usa ese diámetro
  bool usesDiameter(String diameter) {
    return consolidatedMaterials.containsKey(diameter);
  }

  /// Obtiene el porcentaje que representa un diámetro del total
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro a consultar
  ///
  /// **Retorna:** Porcentaje (0-100), o 0.0 si no usa ese diámetro
  ///
  /// **Ejemplo:**
  /// ```dart
  /// // Si 1/2" tiene 18 varillas y el total es 50 varillas
  /// double porcentaje = getPercentageForDiameter('1/2"');
  /// // porcentaje = 36.0  (18/50 * 100)
  /// ```
  double getPercentageForDiameter(String diameter) {
    if (totalRods == 0) return 0.0;
    final diameterRods = getRodsForDiameter(diameter);
    return (diameterRods / totalRods) * 100;
  }

  /// Obtiene un resumen de materiales en formato Map
  ///
  /// **Útil para:** Exportación, reporting, logs
  ///
  /// **Retorna:**
  /// ```dart
  /// {
  ///   '1/2"': {'quantity': 18.0, 'unit': 'Varillas', 'percentage': 36.0},
  ///   '3/4"': {'quantity': 32.0, 'unit': 'Varillas', 'percentage': 64.0},
  /// }
  /// ```
  Map<String, Map<String, dynamic>> getMaterialsSummary() {
    final summary = <String, Map<String, dynamic>>{};

    consolidatedMaterials.forEach((diameter, material) {
      summary[diameter] = {
        'quantity': material.quantity,
        'unit': material.unit,
        'percentage': getPercentageForDiameter(diameter),
      };
    });

    return summary;
  }
}