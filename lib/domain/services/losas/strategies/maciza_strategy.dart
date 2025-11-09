import '../../../entities/home/losas/losa.dart';
import '../losa_calculation_strategy.dart';

/// Strategy para losa maciza de concreto sólido
///
/// Características:
/// - Sin material aligerante
/// - Alturas: 15, 20, 25 cm
/// - Resistencias: 210, 280 kg/cm²
/// - Cálculo directo de volumen: área × espesor
class MacizaStrategy extends LosaCalculationStrategy {
  /// Alturas válidas para losa maciza (diferentes de aligeradas)
  static const List<String> ALTURAS_VALIDAS = ['15 cm', '20 cm', '25 cm'];

  @override
  double calcularVolumenConcreto(Losa losa) {
    final area = calcularArea(losa);

    // Obtener espesor en metros
    final alturaCm = int.tryParse(losa.altura.replaceAll(' cm', '')) ?? 20;
    final espesorMetros = alturaCm / 100.0;

    // Cálculo directo: área × espesor
    final volumenBase = area * espesorMetros;

    // Aplicar desperdicio de concreto
    final desperdicioConcreto = double.tryParse(losa.desperdicioConcreto) ?? 5.0;
    final factorDesperdicio = 1 + (desperdicioConcreto / 100);

    return volumenBase * factorDesperdicio;
  }

  @override
  double? calcularMaterialAligerante(Losa losa) {
    // Losa maciza NO tiene material aligerante
    return null;
  }

  @override
  String obtenerUnidadMaterialAligerante() {
    // No aplica para losa maciza
    return '';
  }

  @override
  String obtenerDescripcionMaterialAligerante(Losa losa) {
    // No aplica para losa maciza
    return '';
  }

  @override
  String? validar(Losa losa) {
    // Validar altura
    if (!ALTURAS_VALIDAS.contains(losa.altura)) {
      return 'Altura inválida para losa maciza. Use: 15, 20 o 25 cm';
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

    // Validar desperdicio de concreto
    final desperdicioConcreto = double.tryParse(losa.desperdicioConcreto);
    if (desperdicioConcreto == null || desperdicioConcreto < 0 || desperdicioConcreto > 50) {
      return 'Desperdicio de concreto debe estar entre 0% y 50%';
    }

    // La losa maciza NO debe tener material aligerante
    if (losa.materialAligerante != null && losa.materialAligerante!.isNotEmpty) {
      return 'Losa maciza no debe tener material aligerante';
    }

    return null; // Válido
  }

  /// Obtiene las alturas válidas para este tipo
  static List<String> get alturasValidas => ALTURAS_VALIDAS;

  /// Obtiene las resistencias válidas para este tipo
  static List<String> get resistenciasValidas => ['210 kg/cm²', '280 kg/cm²'];
}
