import '../../../entities/home/losas/losa.dart';
import '../losa_calculation_strategy.dart';

/// Strategy para losa aligerada tradicional con ladrillos
///
/// Características:
/// - Material aligerante: Ladrillo hueco o Ladrillo casetón
/// - Alturas: 17, 20, 25 cm
/// - Resistencias: 210, 280 kg/cm²
/// - Ladrillos por m²: 11.11 (hueco) o 2.78 (casetón)
/// - Dimensiones ladrillo: 30×30×(altura-5) cm
class TradicionalStrategy extends LosaCalculationStrategy {
  /// Ratios de volumen de concreto por m² según tipo de ladrillo y altura
  ///
  /// MISMO para ambos tipos de ladrillo
  static const Map<String, double> RATIOS_VOLUMEN_M2 = {
    '17 cm': 0.080036,
    '20 cm': 0.087545,
    '25 cm': 0.10006,
  };

  /// Cantidad de ladrillos por m² según tipo
  static const Map<String, double> LADRILLOS_POR_M2 = {
    'Ladrillo hueco': 8.33,
    'Ladrillo casetón': 2.08,
  };

  /// Tipos de ladrillo válidos
  static const List<String> TIPOS_LADRILLO_VALIDOS = [
    'Ladrillo hueco',
    'Ladrillo casetón',
  ];

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

    // Obtener ladrillos por m² según tipo
    final tipoLadrillo = losa.materialAligerante ?? 'Ladrillo hueco';
    final ladrillosPorM2 = LADRILLOS_POR_M2[tipoLadrillo] ?? LADRILLOS_POR_M2['Ladrillo hueco']!;

    // Aplicar desperdicio de ladrillo
    final desperdicioMaterial =
        double.tryParse(losa.desperdicioMaterialAligerante ?? '7') ?? 7.0;
    final factorDesperdicio = 1 + (desperdicioMaterial / 100);

    return area * ladrillosPorM2 * factorDesperdicio;
  }

  @override
  String obtenerUnidadMaterialAligerante() {
    return 'und';
  }

  @override
  String obtenerDescripcionMaterialAligerante(Losa losa) {
    // Calcular alto del ladrillo: altura_losa - 5 cm
    final alturaCm = int.tryParse(losa.altura.replaceAll(' cm', '')) ?? 20;
    final altoLadrillo = alturaCm - 5;

    final tipoLadrillo = losa.materialAligerante ?? 'Ladrillo hueco';

    // Dimensiones según tipo de ladrillo
    // Hueco: 30×30×(altura-5) cm
    // Casetón: 120×30×(altura-5) cm
    if (tipoLadrillo == 'Ladrillo casetón') {
      return '$tipoLadrillo 120×30×$altoLadrillo cm';
    } else {
      return '$tipoLadrillo 30×30×$altoLadrillo cm';
    }
  }

  @override
  String? validar(Losa losa) {
    // Validar altura
    if (!RATIOS_VOLUMEN_M2.containsKey(losa.altura)) {
      return 'Altura inválida para losa tradicional. Use: 17, 20 o 25 cm';
    }

    // Validar tipo de ladrillo
    final tipoLadrillo = losa.materialAligerante;
    if (tipoLadrillo == null || !TIPOS_LADRILLO_VALIDOS.contains(tipoLadrillo)) {
      return 'Tipo de ladrillo inválido. Use: Ladrillo hueco o Ladrillo casetón';
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
      return 'Desperdicio de ladrillo debe estar entre 0% y 50%';
    }

    return null; // Válido
  }

  /// Obtiene las alturas válidas para este tipo
  static List<String> get alturasValidas => RATIOS_VOLUMEN_M2.keys.toList();

  /// Obtiene las resistencias válidas para este tipo
  static List<String> get resistenciasValidas => ['210 kg/cm²', '280 kg/cm²'];

  /// Obtiene los tipos de ladrillo válidos
  static List<String> get tiposLadrilloValidos => TIPOS_LADRILLO_VALIDOS;
}
