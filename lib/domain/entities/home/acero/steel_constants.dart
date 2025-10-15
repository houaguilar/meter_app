// lib/domain/entities/home/acero/shared/steel_constants.dart

/// Constantes globales para cálculos de acero estructural
///
/// Aplicables a: Vigas, Columnas, Zapatas y Losas Macizas
/// Fuente: Excel "CALCULO DE MATERIALES POR PARTIDA 4.xlsx"
///
/// Todas las hojas de acero (viga, columna, zapata, losa) comparten
/// las mismas constantes de pesos, empalmes y longitudes.
class SteelConstants {
  // Constructor privado para prevenir instanciación
  SteelConstants._();

  // ===========================================================================
  // PESOS ESPECÍFICOS DEL ACERO
  // ===========================================================================

  /// Peso del acero por metro lineal según diámetro
  ///
  /// Utilizado para convertir longitud total a peso:
  /// ```dart
  /// double peso = longitudTotal * SteelConstants.steelWeights[diametro]!;
  /// ```
  ///
  /// **Unidades:** kg/m
  ///
  /// **Fuente:** Fila 31 de todas las hojas de acero en Excel
  ///
  /// **Aplicable a:** Vigas, Columnas, Zapatas, Losas Macizas
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
    '1 3/8"': 7.907, // Presente en Excel, faltaba en código anterior
  };

  // ===========================================================================
  // LONGITUDES DE EMPALME
  // ===========================================================================

  /// Longitud de empalme requerida según diámetro de varilla
  ///
  /// Solo aplicable a diámetros grandes (≥ 12mm o ≥ 1/2")
  /// Se usa cuando `useSplice = true` en la entidad de cálculo
  ///
  /// **Unidades:** metros
  ///
  /// **Fuente:** Tabla de empalme en Excel (filas 38-42)
  ///
  /// **Aplicable a:** Vigas, Columnas, Losas Macizas
  ///
  /// **NO aplicable a:** Zapatas (no utilizan empalme)
  ///
  /// **Uso en cálculo:**
  /// ```dart
  /// if (useSplice && SteelConstants.requiresSplice(diameter)) {
  ///   double spliceLength = SteelConstants.spliceLengths[diameter]!;
  ///   double totalWithSplice = baseLength + spliceLength;
  /// }
  /// ```
  static const Map<String, double> spliceLengths = {
    '1/2"': 0.55,
    '12mm': 0.55,
    '5/8"': 0.60,
    '3/4"': 0.70,
    '1"': 0.80,
  };

  // ===========================================================================
  // DIÁMETROS DISPONIBLES
  // ===========================================================================

  /// Lista completa de diámetros de acero disponibles
  ///
  /// Usado en dropdowns, selectores y validaciones de UI
  ///
  /// **Notación:** Mixta entre milímetros (6mm, 8mm, 12mm) y
  /// pulgadas (1/4", 3/8", 1/2", 5/8", 3/4", 1", 1 3/8")
  ///
  /// **Total:** 10 diámetros estándar
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
    '1 3/8"',
  ];

  // ===========================================================================
  // LONGITUD ESTÁNDAR DE VARILLA
  // ===========================================================================

  /// Longitud comercial estándar de una varilla de acero
  ///
  /// Usado para convertir longitud total a cantidad de varillas:
  /// ```dart
  /// int varillas = (longitudTotal / SteelConstants.standardRodLength).ceil();
  /// ```
  ///
  /// **Unidades:** metros
  ///
  /// **Valor:** 9.0 metros (estándar del mercado peruano)
  ///
  /// **Aplicable a:** Todos los elementos de acero
  static const double standardRodLength = 9.0;

  // ===========================================================================
  // PORCENTAJE DE ALAMBRE #16
  // ===========================================================================

  /// Porcentaje de alambre de amarre #16 respecto al peso total del acero
  ///
  /// El alambre #16 se usa para amarrar las varillas y estribos durante
  /// el armado de la estructura. Se calcula como porcentaje del peso total.
  ///
  /// **Valor:** 1.5% (0.015)
  ///
  /// **Unidades:** Decimal (no porcentaje)
  ///
  /// **Cálculo:**
  /// ```dart
  /// double alambre = pesoTotalAcero * SteelConstants.wirePercentage;
  /// ```
  ///
  /// **Aplicable a:** Todos los elementos de acero
  static const double wirePercentage = 0.015;

  // ===========================================================================
  // DESPERDICIO POR DEFECTO
  // ===========================================================================

  /// Porcentaje de desperdicio por defecto en el cálculo de acero
  ///
  /// Considera pérdidas por cortes, desperdicios, traslapes y errores
  /// de construcción típicos en obra.
  ///
  /// **Valor:** 7% (0.07)
  ///
  /// **Fuente:** Fila 2 de las hojas de acero en Excel ("Desperdicio=7%")
  ///
  /// **Nota:** El usuario puede modificar este valor en el formulario
  /// según sus necesidades específicas del proyecto.
  ///
  /// **Aplicable a:** Vigas, Columnas, Zapatas
  /// (Losas puede tener valor diferente o no especificado)
  static const double defaultWaste = 0.07;

  // ===========================================================================
  // MÉTODOS DE UTILIDAD
  // ===========================================================================

  /// Obtiene el peso por metro para un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro del acero (ej: "1/2"", "12mm")
  ///
  /// **Retorna:**
  /// - Peso en kg/m, o `null` si el diámetro no existe
  ///
  /// **Ejemplo:**
  /// ```dart
  /// double? peso = SteelConstants.getWeightPerMeter('1/2"');
  /// // peso = 0.994
  /// ```
  static double? getWeightPerMeter(String diameter) {
    return steelWeights[diameter];
  }

  /// Obtiene la longitud de empalme para un diámetro específico
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro del acero (ej: "1/2"", "3/4"")
  ///
  /// **Retorna:**
  /// - Longitud de empalme en metros, o `null` si el diámetro no
  ///   requiere empalme o no existe
  ///
  /// **Ejemplo:**
  /// ```dart
  /// double? empalme = SteelConstants.getSpliceLength('3/4"');
  /// // empalme = 0.70
  /// ```
  static double? getSpliceLength(String diameter) {
    return spliceLengths[diameter];
  }

  /// Verifica si un diámetro requiere empalme
  ///
  /// Solo diámetros grandes (≥ 12mm o ≥ 1/2") requieren empalme
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro del acero
  ///
  /// **Retorna:**
  /// - `true` si requiere empalme, `false` en caso contrario
  ///
  /// **Ejemplo:**
  /// ```dart
  /// bool requiere = SteelConstants.requiresSplice('6mm');
  /// // requiere = false
  ///
  /// bool requiere2 = SteelConstants.requiresSplice('1/2"');
  /// // requiere2 = true
  /// ```
  static bool requiresSplice(String diameter) {
    return spliceLengths.containsKey(diameter);
  }

  /// Verifica si un diámetro es válido y existe en el catálogo
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro del acero a validar
  ///
  /// **Retorna:**
  /// - `true` si el diámetro existe, `false` en caso contrario
  ///
  /// **Ejemplo:**
  /// ```dart
  /// bool valido = SteelConstants.isValidDiameter('1/2"');
  /// // valido = true
  ///
  /// bool invalido = SteelConstants.isValidDiameter('2"');
  /// // invalido = false
  /// ```
  static bool isValidDiameter(String diameter) {
    return availableDiameters.contains(diameter);
  }

  /// Convierte longitud total a cantidad de varillas estándar
  ///
  /// Calcula cuántas varillas de 9m se necesitan para cubrir
  /// una longitud total, redondeando hacia arriba.
  ///
  /// **Parámetros:**
  /// - `totalLength`: Longitud total en metros
  ///
  /// **Retorna:**
  /// - Cantidad de varillas necesarias (redondeado hacia arriba)
  ///
  /// **Ejemplo:**
  /// ```dart
  /// int varillas = SteelConstants.calculateRods(45.5);
  /// // varillas = 6 (porque 45.5 / 9.0 = 5.055... → ceil = 6)
  /// ```
  static int calculateRods(double totalLength) {
    if (totalLength <= 0) return 0;
    return (totalLength / standardRodLength).ceil();
  }

  /// Calcula el peso total dado una longitud y diámetro
  ///
  /// **Parámetros:**
  /// - `length`: Longitud del acero en metros
  /// - `diameter`: Diámetro del acero
  ///
  /// **Retorna:**
  /// - Peso en kg, o `null` si el diámetro no existe
  ///
  /// **Ejemplo:**
  /// ```dart
  /// double? peso = SteelConstants.calculateWeight(10.0, '1/2"');
  /// // peso = 9.94 kg (10.0 * 0.994)
  /// ```
  static double? calculateWeight(double length, String diameter) {
    final weightPerMeter = getWeightPerMeter(diameter);
    if (weightPerMeter == null || length <= 0) return null;
    return length * weightPerMeter;
  }

  /// Calcula el peso del alambre #16 dado el peso total del acero
  ///
  /// **Parámetros:**
  /// - `totalSteelWeight`: Peso total del acero en kg
  ///
  /// **Retorna:**
  /// - Peso del alambre #16 en kg (1.5% del peso total)
  ///
  /// **Ejemplo:**
  /// ```dart
  /// double alambre = SteelConstants.calculateWireWeight(100.0);
  /// // alambre = 1.5 kg (100.0 * 0.015)
  /// ```
  static double calculateWireWeight(double totalSteelWeight) {
    if (totalSteelWeight <= 0) return 0.0;
    return totalSteelWeight * wirePercentage;
  }

  /// Aplica el factor de desperdicio a una cantidad
  ///
  /// **Parámetros:**
  /// - `quantity`: Cantidad base
  /// - `wastePercentage`: Porcentaje de desperdicio (default: 7%)
  ///
  /// **Retorna:**
  /// - Cantidad con desperdicio aplicado
  ///
  /// **Ejemplo:**
  /// ```dart
  /// double conDesperdicio = SteelConstants.applyWaste(100.0, 0.07);
  /// // conDesperdicio = 107.0 (100.0 * 1.07)
  /// ```
  static double applyWaste(double quantity, [double wastePercentage = defaultWaste]) {
    if (quantity <= 0) return 0.0;
    return quantity * (1 + wastePercentage);
  }

  /// Obtiene todos los diámetros que requieren empalme
  ///
  /// **Retorna:**
  /// - Lista de diámetros que tienen longitud de empalme definida
  ///
  /// **Ejemplo:**
  /// ```dart
  /// List<String> diametrosEmpalme = SteelConstants.getDiametersWithSplice();
  /// // diametrosEmpalme = ['1/2"', '12mm', '5/8"', '3/4"', '1"']
  /// ```
  static List<String> getDiametersWithSplice() {
    return spliceLengths.keys.toList();
  }

  /// Obtiene información completa de un diámetro
  ///
  /// **Parámetros:**
  /// - `diameter`: Diámetro del acero
  ///
  /// **Retorna:**
  /// - Mapa con información del diámetro, o `null` si no existe
  ///
  /// **Ejemplo:**
  /// ```dart
  /// Map<String, dynamic>? info = SteelConstants.getDiameterInfo('1/2"');
  /// // info = {
  /// //   'diameter': '1/2"',
  /// //   'weightPerMeter': 0.994,
  /// //   'spliceLength': 0.55,
  /// //   'requiresSplice': true,
  /// // }
  /// ```
  static Map<String, dynamic>? getDiameterInfo(String diameter) {
    if (!isValidDiameter(diameter)) return null;

    return {
      'diameter': diameter,
      'weightPerMeter': getWeightPerMeter(diameter),
      'spliceLength': getSpliceLength(diameter),
      'requiresSplice': requiresSplice(diameter),
    };
  }
}