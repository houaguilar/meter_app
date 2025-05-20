
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
    return (losaAligerada.largo != null && losaAligerada.ancho != null) || losaAligerada.area != null;
  }

  // Calculamos la cantidad de ladrillos según la altura de la losa y el área
  double calcularLadrillos(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;
    double desperdicio = double.tryParse(losaAligerada.desperdicioLadrillo) ?? 5.0;
    double factorDesperdicio = 1 + (desperdicio / 100);

    // Ladrillos por m2 según altura de losa
    int ladrillosPorM2;
    switch (losaAligerada.altura) {
      case '17 cm':
        ladrillosPorM2 = 8;
        break;
      case '20 cm':
        ladrillosPorM2 = 8;
        break;
      case '25 cm':
        ladrillosPorM2 = 7;
        break;
      case '30 cm':
        ladrillosPorM2 = 6;
        break;
      default:
        ladrillosPorM2 = 8; // valor por defecto
    }

    return area * ladrillosPorM2 * factorDesperdicio;
  }

  // Calculamos el concreto en m3
  double calcularConcreto(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;
    double desperdicio = double.tryParse(losaAligerada.desperdicioConcreto) ?? 5.0;
    double factorDesperdicio = 1 + (desperdicio / 100);

    // Factores de concreto por m2 según altura de losa
    double concretoPorM2;
    switch (losaAligerada.altura) {
      case '17 cm':
        concretoPorM2 = 0.084;
        break;
      case '20 cm':
        concretoPorM2 = 0.089;
        break;
      case '25 cm':
        concretoPorM2 = 0.100;
        break;
      case '30 cm':
        concretoPorM2 = 0.110;
        break;
      default:
        concretoPorM2 = 0.084; // valor por defecto
    }

    return area * concretoPorM2 * factorDesperdicio;
  }

  // Calculamos el acero en kg
  double calcularAcero(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;

    // Factores de acero por m2 según altura de losa
    double aceroPorM2;
    switch (losaAligerada.altura) {
      case '17 cm':
        aceroPorM2 = 3.00;
        break;
      case '20 cm':
        aceroPorM2 = 4.00;
        break;
      case '25 cm':
        aceroPorM2 = 5.00;
        break;
      case '30 cm':
        aceroPorM2 = 6.00;
        break;
      default:
        aceroPorM2 = 3.00; // valor por defecto
    }

    return area * aceroPorM2;
  }

  // Calculamos la madera en p2 (pies cuadrados)
  double calcularMadera(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;

    // Factores de madera por m2 según altura de losa
    double maderaPorM2;
    switch (losaAligerada.altura) {
      case '17 cm':
        maderaPorM2 = 5.15;
        break;
      case '20 cm':
        maderaPorM2 = 5.15;
        break;
      case '25 cm':
        maderaPorM2 = 5.70;
        break;
      case '30 cm':
        maderaPorM2 = 6.30;
        break;
      default:
        maderaPorM2 = 5.15; // valor por defecto
    }

    return area * maderaPorM2;
  }

  // Calculamos la arena gruesa en m3
  double calcularArenaGruesa(LosaAligerada losaAligerada) {
    double volumenConcreto = calcularConcreto(losaAligerada);

    // Cantidad de arena por m3 de concreto según resistencia
    double factorArena;
    switch (losaAligerada.resistenciaConcreto) {
      case '210 kg/cm²':
        factorArena = 0.56;
        break;
      case '175 kg/cm²':
        factorArena = 0.61;
        break;
      default:
        factorArena = 0.56; // valor por defecto
    }

    return volumenConcreto * factorArena;
  }

  // Calculamos la piedra chancada en m3
  double calcularPiedraChancada(LosaAligerada losaAligerada) {
    double volumenConcreto = calcularConcreto(losaAligerada);

    // Cantidad de piedra por m3 de concreto según resistencia
    double factorPiedra;
    switch (losaAligerada.resistenciaConcreto) {
      case '210 kg/cm²':
        factorPiedra = 0.67;
        break;
      case '175 kg/cm²':
        factorPiedra = 0.76;
        break;
      default:
        factorPiedra = 0.67; // valor por defecto
    }

    return volumenConcreto * factorPiedra;
  }

  // Calculamos el cemento en bolsas
  double calcularCemento(LosaAligerada losaAligerada) {
    double volumenConcreto = calcularConcreto(losaAligerada);

    // Bolsas de cemento por m3 de concreto según resistencia
    double factorCemento;
    switch (losaAligerada.resistenciaConcreto) {
      case '210 kg/cm²':
        factorCemento = 8.43;
        break;
      case '175 kg/cm²':
        factorCemento = 7.01;
        break;
      default:
        factorCemento = 8.43; // valor por defecto
    }

    return volumenConcreto * factorCemento;
  }

  // Calculamos el agua en litros
  double calcularAgua(LosaAligerada losaAligerada) {
    double volumenConcreto = calcularConcreto(losaAligerada);

    // Litros de agua por m3 de concreto según resistencia
    double factorAgua;
    switch (losaAligerada.resistenciaConcreto) {
      case '210 kg/cm²':
        factorAgua = 186;
        break;
      case '175 kg/cm²':
        factorAgua = 181;
        break;
      default:
        factorAgua = 186; // valor por defecto
    }

    return volumenConcreto * factorAgua;
  }

  // Calculamos la alambre #8 en kg
  double calcularAlambre8(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;

    // Factores de alambre #8 por m2 según altura de losa
    double alambrePorM2;
    switch (losaAligerada.altura) {
      case '17 cm':
        alambrePorM2 = 0.20;
        break;
      case '20 cm':
        alambrePorM2 = 0.25;
        break;
      case '25 cm':
        alambrePorM2 = 0.30;
        break;
      case '30 cm':
        alambrePorM2 = 0.35;
        break;
      default:
        alambrePorM2 = 0.20; // valor por defecto
    }

    return area * alambrePorM2;
  }

  // Calculamos la alambre #16 en kg
  double calcularAlambre16(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;

    // Factores de alambre #16 por m2 según altura de losa
    double alambrePorM2;
    switch (losaAligerada.altura) {
      case '17 cm':
        alambrePorM2 = 0.10;
        break;
      case '20 cm':
        alambrePorM2 = 0.15;
        break;
      case '25 cm':
        alambrePorM2 = 0.25;
        break;
      case '30 cm':
        alambrePorM2 = 0.30;
        break;
      default:
        alambrePorM2 = 0.10; // valor por defecto
    }

    return area * alambrePorM2;
  }

  // Calculamos los clavos en kg
  double calcularClavos(LosaAligerada losaAligerada) {
    double area = calcularArea(losaAligerada) ?? 0.0;

    // Factores de clavos por m2 según altura de losa
    double clavosPorM2;
    switch (losaAligerada.altura) {
      case '17 cm':
        clavosPorM2 = 0.15;
        break;
      case '20 cm':
        clavosPorM2 = 0.18;
        break;
      case '25 cm':
        clavosPorM2 = 0.24;
        break;
      case '30 cm':
        clavosPorM2 = 0.26;
        break;
      default:
        clavosPorM2 = 0.15; // valor por defecto
    }

    return area * clavosPorM2;
  }
}