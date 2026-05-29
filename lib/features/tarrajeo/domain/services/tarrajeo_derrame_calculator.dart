import 'package:meter_app/domain/entities/entities.dart';

class TarrajeoDerrameCalculator {
  // Factores de materiales según proporción del mortero (basado en Excel TARRAJEO DERRAME)
  static const Map<String, Map<String, double>> _factoresMorteroDerrrame = {
    "4": {
      'cemento': 8.9, // bolsas por m³
      'arena': 1.0, // m³ por m³
      'agua': 0.272, // m³ por m³ (272L convertido)
    },
    "5": {
      'cemento': 7.4, // bolsas por m³
      'arena': 1.05, // m³ por m³
      'agua': 0.268, // m³ por m³ (268L convertido)
    },
    "6": {
      'cemento': 6.13, // bolsas por m³
      'arena': 1.07, // m³ por m³
      'agua': 0.269, // m³ por m³ (269L convertido)
    },
  };

  /// Calcula el área de tarrajeo derrame
  static double calcularAreaTarrajeoDerrrame(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!) ?? 0.0;
    } else {
      double longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
      double ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
      return longitud * ancho;
    }
  }

  /// Calcula el volumen de mortero por m² para derrame
  static double calcularVolumenMorteroPorM2Derrrame(double espesorCm) {
    return espesorCm / 100; // convertir cm a metros
  }

  /// Calcula el volumen total de mortero para un tarrajeo derrame
  static double calcularVolumenMorteroDerrrame(Tarrajeo tarrajeo) {
    double area = calcularAreaTarrajeoDerrrame(tarrajeo);
    double espesor = double.tryParse(tarrajeo.espesor) ?? 0.0;
    return area * calcularVolumenMorteroPorM2Derrrame(espesor);
  }

  /// Calcula materiales para un tarrajeo derrame individual
  static Map<String, double> calcularMaterialesIndividualDerrrame(
      Tarrajeo tarrajeo) {
    double volumen = calcularVolumenMorteroDerrrame(tarrajeo);
    double factorDesperdicio =
        (double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0) / 100.0;

    String proporcionStr = tarrajeo.proporcionMortero;
    Map<String, double> factores =
        _factoresMorteroDerrrame[proporcionStr] ?? _factoresMorteroDerrrame['4']!;

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

  /// Calcula materiales totales para una lista de tarrajeos derrame
  static Map<String, double> calcularMaterialesTotalesDerrrame(
      List<Tarrajeo> tarrajeos) {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalAgua = 0.0;
    double totalVolumen = 0.0;

    for (var tarrajeo in tarrajeos) {
      Map<String, double> materiales =
          calcularMaterialesIndividualDerrrame(tarrajeo);
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
