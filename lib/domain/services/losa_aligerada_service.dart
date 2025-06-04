import '../entities/home/losas/losas.dart';

class LosaAligeradaService {
  double? calcularArea(LosaAligerada losaAligerada) {
    if (losaAligerada.area != null && losaAligerada.area!.isNotEmpty) {
      return double.tryParse(losaAligerada.area!);
    }
    if (losaAligerada.largo != null && losaAligerada.ancho != null) {
      final largo = double.tryParse(losaAligerada.largo!);
      final ancho = double.tryParse(losaAligerada.ancho!);
      if (largo != null && ancho != null) {
        return largo * ancho;
      }
    }
    return null;
  }

  bool esValido(LosaAligerada losaAligerada) {
    return (losaAligerada.largo != null && losaAligerada.ancho != null) ||
        losaAligerada.area != null;
  }

  // Calcula el volumen de concreto por m² según altura y material
  double _calcularVolumenConcretoM2(LosaAligerada losaAligerada) {
    double volumenConcretoM2;

    if (losaAligerada.materialAligerado == "Bovedillas") {
      switch (losaAligerada.altura) {
        case '17 cm':
          volumenConcretoM2 = 0.0616; // m³/m²
          break;
        case '20 cm':
          volumenConcretoM2 = 0.0712; // m³/m²
          break;
        case '25 cm':
          volumenConcretoM2 = 0.085; // m³/m²
          break;
        default:
          volumenConcretoM2 = 0.0616;
      }
    } else { // Ladrillo hueco
      switch (losaAligerada.altura) {
        case '17 cm':
          volumenConcretoM2 = 0.08; // m³/m²
          break;
        case '20 cm':
          volumenConcretoM2 = 0.0875; // m³/m²
          break;
        case '25 cm':
          volumenConcretoM2 = 0.1001; // m³/m²
          break;
        default:
          volumenConcretoM2 = 0.08;
      }
    }

    return volumenConcretoM2;
  }

  // Obtiene los factores de materiales según la resistencia del concreto
  Map<String, double> _getFactoresMateriales(String resistenciaConcreto) {
    switch (resistenciaConcreto) {
      case '175 kg/cm²':
        return {
          'cemento': 8.43, // bolsas por m³
          'arena': 0.54, // m³ por m³
          'piedra': 0.55, // m³ por m³
          'agua': 0.185, // m³ por m³
        };
      case '210 kg/cm²':
        return {
          'cemento': 9.73, // bolsas por m³
          'arena': 0.52, // m³ por m³
          'piedra': 0.53, // m³ por m³
          'agua': 0.186, // m³ por m³
        };
      case '280 kg/cm²':
        return {
          'cemento': 11.5, // bolsas por m³
          'arena': 0.5, // m³ por m³
          'piedra': 0.51, // m³ por m³
          'agua': 0.187, // m³ por m³
        };
      case '140 kg/cm²':
        return {
          'cemento': 7.0, // bolsas por m³
          'arena': 0.55, // m³ por m³
          'piedra': 0.65, // m³ por m³
          'agua': 0.18, // m³ por m³
        };
      case '245 kg/cm²':
        return {
          'cemento': 10.5, // bolsas por m³
          'arena': 0.51, // m³ por m³
          'piedra': 0.52, // m³ por m³
          'agua': 0.186, // m³ por m³
        };
      default:
        return {
          'cemento': 7.0,
          'arena': 0.55,
          'piedra': 0.65,
          'agua': 0.18,
        };
    }
  }

  // Calculamos el cemento en bolsas
  double calcularCemento(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;
    double volumenConcretoM2 = _calcularVolumenConcretoM2(losaAligerada);
    double volumenConcretoTotal = volumenConcretoM2 * area;

    // Factor de desperdicio de concreto
    double desperdicioConcreto = double.tryParse(
        losaAligerada.desperdicioConcreto) ?? 5.0;
    double factorDesperdicio = 1 + (desperdicioConcreto / 100);

    // Factores según resistencia
    Map<String, double> factores = _getFactoresMateriales(
        losaAligerada.resistenciaConcreto);
    double factorCemento = factores['cemento']!;

    return volumenConcretoTotal * factorCemento * factorDesperdicio;
  }

  // Calculamos la arena gruesa en m³
  double calcularArenaGruesa(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;
    double volumenConcretoM2 = _calcularVolumenConcretoM2(losaAligerada);
    double volumenConcretoTotal = volumenConcretoM2 * area;

    // Factor de desperdicio de concreto
    double desperdicioConcreto = double.tryParse(
        losaAligerada.desperdicioConcreto) ?? 5.0;
    double factorDesperdicio = 1 + (desperdicioConcreto / 100);

    // Factores según resistencia
    Map<String, double> factores = _getFactoresMateriales(
        losaAligerada.resistenciaConcreto);
    double factorArena = factores['arena']!;

    return volumenConcretoTotal * factorArena * factorDesperdicio;
  }

  // Calculamos la piedra chancada en m³
  double calcularPiedraChancada(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;
    double volumenConcretoM2 = _calcularVolumenConcretoM2(losaAligerada);
    double volumenConcretoTotal = volumenConcretoM2 * area;

    // Factor de desperdicio de concreto
    double desperdicioConcreto = double.tryParse(
        losaAligerada.desperdicioConcreto) ?? 5.0;
    double factorDesperdicio = 1 + (desperdicioConcreto / 100);

    // Factores según resistencia
    Map<String, double> factores = _getFactoresMateriales(
        losaAligerada.resistenciaConcreto);
    double factorPiedra = factores['piedra']!;

    return volumenConcretoTotal * factorPiedra * factorDesperdicio;
  }

  // Calculamos el agua en m³
  double calcularAgua(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;
    double volumenConcretoM2 = _calcularVolumenConcretoM2(losaAligerada);
    double volumenConcretoTotal = volumenConcretoM2 * area;

    // Factor de desperdicio de concreto
    double desperdicioConcreto = double.tryParse(
        losaAligerada.desperdicioConcreto) ?? 5.0;
    double factorDesperdicio = 1 + (desperdicioConcreto / 100);

    // Factores según resistencia
    Map<String, double> factores = _getFactoresMateriales(
        losaAligerada.resistenciaConcreto);
    double factorAgua = factores['agua']!;

    return volumenConcretoTotal * factorAgua * factorDesperdicio;
  }

  // Método para obtener el volumen de concreto (útil para mostrar información adicional)
  double calcularVolumenConcreto(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;
    double volumenConcretoM2 = _calcularVolumenConcretoM2(losaAligerada);

    // Factor de desperdicio de concreto
    double desperdicioConcreto = double.tryParse(
        losaAligerada.desperdicioConcreto) ?? 5.0;
    double factorDesperdicio = 1 + (desperdicioConcreto / 100);

    return volumenConcretoM2 * area * factorDesperdicio;
  }
}