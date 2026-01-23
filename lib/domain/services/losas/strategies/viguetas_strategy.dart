import '../../../entities/home/losas/losa.dart';
import '../losa_calculation_strategy.dart';

/// Strategy para losa aligerada con viguetas prefabricadas y bovedillas
///
/// Características:
/// - Material aligerante: Bovedillas (fijo, pre-seleccionado)
/// - Alturas: 17, 20, 25 cm
/// - Resistencias: 210, 280 kg/cm²
/// - Cantidad de bovedillas calculada dinámicamente según dimensiones
class ViguetasStrategy extends LosaCalculationStrategy {
  /// Ratios de volumen de concreto por m² según altura
  ///
  /// Valores específicos para losas con bovedillas
  static const Map<String, double> RATIOS_VOLUMEN_M2 = {
    '17 cm': 0.0616,
    '20 cm': 0.0712,
    '25 cm': 0.085,
  };

  /// Dimensiones de bovedillas según altura (ancho en cm)
  ///
  /// Según Excel: Ancho = 39.5 cm para todas las alturas
  static const Map<String, double> ANCHO_BOVEDILLA_CM = {
    '17 cm': 39.5,
    '20 cm': 39.5,
    '25 cm': 39.5,
  };

  /// Dimensiones de bovedillas según altura (largo en cm)
  ///
  /// Según Excel: Largo = 20 cm para todas las alturas
  static const Map<String, double> LARGO_BOVEDILLA_CM = {
    '17 cm': 20.0,
    '20 cm': 20.0,
    '25 cm': 20.0,
  };

  /// Ancho de vigueta en metros
  ///
  /// Valor constante usado en el cálculo de bovedillas por m²
  static const double ANCHO_VIGUETA_M = 0.10;

  /// Material fijo para este tipo de losa
  static const String MATERIAL_FIJO = 'Bovedillas';

  @override
  double calcularVolumenConcreto(Losa losa) {
    final area = calcularArea(losa);
    final ratio = RATIOS_VOLUMEN_M2[losa.altura] ?? RATIOS_VOLUMEN_M2['17 cm']!;

    // Aplicar desperdicio de concreto
    final desperdicioConcreto = double.tryParse(losa.desperdicioConcreto.trim()) ?? 5.0;
    final factorDesperdicio = 1 + (desperdicioConcreto / 100);

    return area * ratio * factorDesperdicio;
  }

  @override
  double calcularMaterialAligerante(Losa losa) {
    final area = calcularArea(losa);

    // Calcular bovedillas por m² según dimensiones
    // Fórmula Excel: CL = 1 / ((Ancho_bovedilla + Ancho_vigueta) × Largo_bovedilla)
    final anchoCm = ANCHO_BOVEDILLA_CM[losa.altura] ?? ANCHO_BOVEDILLA_CM['17 cm']!;
    final largoCm = LARGO_BOVEDILLA_CM[losa.altura] ?? LARGO_BOVEDILLA_CM['17 cm']!;

    // Convertir a metros
    final anchoM = anchoCm / 100.0;
    final largoM = largoCm / 100.0;

    // Calcular cantidad por m²
    final bovedillasPorM2 = 1.0 / ((anchoM + ANCHO_VIGUETA_M) * largoM);

    // Aplicar desperdicio de bovedillas
    final desperdicioMaterial =
        double.tryParse(losa.desperdicioMaterialAligerante ?? '7') ?? 7.0;
    final factorDesperdicio = 1 + (desperdicioMaterial / 100);

    return area * bovedillasPorM2 * factorDesperdicio;
  }

  @override
  String obtenerUnidadMaterialAligerante() {
    return 'und';
  }

  @override
  String obtenerDescripcionMaterialAligerante(Losa losa) {
    return MATERIAL_FIJO;
  }

  @override
  String? validar(Losa losa) {
    // Validar altura
    if (!RATIOS_VOLUMEN_M2.containsKey(losa.altura)) {
      return 'Altura inválida para losa con viguetas. Use: 17, 20 o 25 cm';
    }

    // Validar resistencia
    const resistenciasValidas = ['210 kg/cm²', '280 kg/cm²'];
    if (!resistenciasValidas.contains(losa.resistenciaConcreto)) {
      return 'Resistencia inválida. Use: 210 o 280 kg/cm²';
    }

    // Validar dimensiones
    final area = calcularArea(losa);
    if (area <= 0) {
      return 'Debe proporcionar área válida o dimensiones (largo y ancho)';
    }

    // Validar desperdicios
    final desperdicioConcreto = double.tryParse(losa.desperdicioConcreto);
    if (desperdicioConcreto == null || desperdicioConcreto < 0 || desperdicioConcreto > 50) {
      return 'Desperdicio de concreto debe estar entre 0% y 50%';
    }

    final desperdicioMaterial = double.tryParse(losa.desperdicioMaterialAligerante ?? '7');
    if (desperdicioMaterial == null || desperdicioMaterial < 0 || desperdicioMaterial > 50) {
      return 'Desperdicio de bovedillas debe estar entre 0% y 50%';
    }

    return null; // Válido
  }

  /// Obtiene las alturas válidas para este tipo
  static List<String> get alturasValidas => RATIOS_VOLUMEN_M2.keys.toList();

  /// Obtiene las resistencias válidas para este tipo
  static List<String> get resistenciasValidas => ['210 kg/cm²', '280 kg/cm²'];
}
