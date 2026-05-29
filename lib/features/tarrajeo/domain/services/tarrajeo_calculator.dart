import 'package:meter_app/domain/entities/entities.dart';

class TarrajeoCalculator {
  // Factores de materiales según proporción del mortero (basado en Excel líneas 15-164)
  static const Map<String, Map<String, double>> _factoresMortero = {
    "4": {
      'cemento': 8.9, // bolsas por m³
      'arena': 1.0, // m³ por m³
      'agua': 0.272, // m³ por m³
    },
    "5": {
      'cemento': 7.4, // bolsas por m³
      'arena': 1.05, // m³ por m³
      'agua': 0.268, // m³ por m³
    },
    "6": {
      'cemento': 6.13, // bolsas por m³
      'arena': 1.07, // m³ por m³
      'agua': 0.269, // m³ por m³
    },
  };

  /// Calcula el área de tarrajeo
  static double calcularAreaTarrajeo(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!) ?? 0.0;
    } else {
      double longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
      double ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
      return longitud * ancho;
    }
  }

  /// Calcula el volumen de mortero por m²
  static double calcularVolumenMorteroPorM2(double espesorCm) {
    return espesorCm / 100; // convertir cm a metros
  }

  /// Calcula el volumen total de mortero para un tarrajeo
  static double calcularVolumenMortero(Tarrajeo tarrajeo) {
    double area = calcularAreaTarrajeo(tarrajeo);
    double espesor = double.tryParse(tarrajeo.espesor) ?? 0.0;
    return area * calcularVolumenMorteroPorM2(espesor);
  }

  /// Calcula materiales para un tarrajeo individual
  static Map<String, double> calcularMaterialesIndividual(Tarrajeo tarrajeo) {
    double volumen = calcularVolumenMortero(tarrajeo);
    double factorDesperdicio =
        (double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0) / 100.0;

    String proporcionStr = tarrajeo.proporcionMortero;
    Map<String, double> factores =
        _factoresMortero[proporcionStr] ?? _factoresMortero['4']!;

    double cementoSin = factores['cemento']! * volumen;
    double arenaSin = factores['arena']! * volumen;
    double aguaSin = factores['agua']! * volumen;

    return {
      'cemento': cementoSin * (1 + factorDesperdicio),
      'arena': arenaSin * (1 + factorDesperdicio),
      'agua': aguaSin * (1 + factorDesperdicio),
      'volumen': volumen,
    };
  }

  /// Calcula materiales totales para una lista de tarrajeos
  static Map<String, double> calcularMaterialesTotales(
      List<Tarrajeo> tarrajeos) {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalAgua = 0.0;
    double totalVolumen = 0.0;

    for (var tarrajeo in tarrajeos) {
      Map<String, double> materiales = calcularMaterialesIndividual(tarrajeo);
      totalCemento += materiales['cemento']!;
      totalArena += materiales['arena']!;
      totalAgua += materiales['agua']!;
      totalVolumen += materiales['volumen']!;
    }

    return {
      'cemento': totalCemento,
      'arena': totalArena,
      'agua': totalAgua,
      'volumen': totalVolumen,
    };
  }
}
