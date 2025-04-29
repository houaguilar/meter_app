import '../entities/entities.dart';

class LadrilloService {
  double? calcularArea(Ladrillo ladrillo) {
    if (ladrillo.area != null) {
      return double.tryParse(ladrillo.area!);
    }
    if (ladrillo.largo != null && ladrillo.altura != null) {
      final largo = double.tryParse(ladrillo.largo!);
      final altura = double.tryParse(ladrillo.altura!);
      if (largo != null && altura != null) {
        return largo * altura;
      }
    }
    return null;
  }

  bool esValido(Ladrillo ladrillo) {
    return (ladrillo.largo != null && ladrillo.altura != null) || ladrillo.area != null;
  }

  // Calcula la cantidad de ladrillos
  double calcularLadrillosTotal(List<Ladrillo> ladrillos) {
    double totalLadrillos = 0.0;

    for (var ladrillo in ladrillos) {
      double area = calcularArea(ladrillo) ?? 0.0;
      double factorDesperdicio = double.tryParse(ladrillo.factorDesperdicio) != null
          ? double.parse(ladrillo.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      double ladrillosPorM2 = 0.0;

      // Cálculo basado en el tipo de ladrillo y asentado
      switch (ladrillo.tipoLadrillo) {
        case 'Kingkong':
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              ladrillosPorM2 = (1 / ((24 / 100 + 0.015) * (9 / 100 + 0.015)));
              break;
            case 'canto':
              ladrillosPorM2 = (1 / ((24 / 100 + 0.015) * (13 / 100 + 0.015)));
              break;
            case 'cabeza':
              ladrillosPorM2 = (1 / ((13 / 100 + 0.015) * (9 / 100 + 0.015)));
              break;
            default:
              ladrillosPorM2 = (1 / ((24 / 100 + 0.015) * (9 / 100 + 0.015)));
          }
          break;
        case 'Pandereta':
        default:
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              ladrillosPorM2 = (1 / ((23 / 100 + 0.015) * (9 / 100 + 0.015)));
              break;
            case 'canto':
              ladrillosPorM2 = (1 / ((23 / 100 + 0.015) * (12 / 100 + 0.015)));
              break;
            case 'cabeza':
              ladrillosPorM2 = (1 / ((12 / 100 + 0.015) * (9 / 100 + 0.015)));
              break;
            default:
              ladrillosPorM2 = (1 / ((23 / 100 + 0.015) * (9 / 100 + 0.015)));
          }
      }

      // Aplicar factor de desperdicio
      ladrillosPorM2 = ladrillosPorM2 * (1 + factorDesperdicio);

      // Multiplicar por el área total del muro
      totalLadrillos += ladrillosPorM2 * area;
    }

    return totalLadrillos;
  }

  // Calcula la cantidad total de cemento en bolsas
  double calcularCementoTotal(List<Ladrillo> ladrillos) {
    double totalCemento = 0.0;

    for (var ladrillo in ladrillos) {
      double area = calcularArea(ladrillo) ?? 0.0;
      double factorDesperdicio = 0.10; // 10% de desperdicio para mortero
      String proporcionStr;
      if (ladrillo.proporcionMortero.contains(":")) {
        proporcionStr = ladrillo.proporcionMortero.replaceAll("1 : ", "");
      } else {
        proporcionStr = ladrillo.proporcionMortero;
      }
      int proporcion = int.tryParse(proporcionStr) ?? 4;

      double volumenMortero = 0.0;

      // Cálculo del volumen de mortero según tipo de ladrillo y asentado
      switch (ladrillo.tipoLadrillo) {
        case 'Kingkong':
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              volumenMortero = 0.020;
              break;
            case 'canto':
              volumenMortero = 0.010;
              break;
            case 'cabeza':
              volumenMortero = 0.046;
              break;
            default:
              volumenMortero = 0.020;
          }
          break;
        case 'Pandereta':
        default:
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              volumenMortero = 0.023;
              break;
            case 'canto':
              volumenMortero = 0.015;
              break;
            case 'cabeza':
              volumenMortero = 0.057;
              break;
            default:
              volumenMortero = 0.023;
          }
      }

      // Proporción de cemento según proporción de mortero
      double proporcionCemento = proporcion == 4 ? 8.56 : 7.10; // bolsas/m³

      // Cálculo final con desperdicio
      double cementoPorM2 = volumenMortero * proporcionCemento;
      double cementoConDesperdicio = cementoPorM2 * (1 + factorDesperdicio);

      totalCemento += cementoConDesperdicio * area;
    }

    return totalCemento;
  }

  // Calcula la cantidad total de arena en m³
  double calcularArenaTotal(List<Ladrillo> ladrillos) {
    double totalArena = 0.0;

    for (var ladrillo in ladrillos) {
      double area = calcularArea(ladrillo) ?? 0.0;
      double factorDesperdicio = 0.10; // 10% de desperdicio para mortero
      String proporcionStr;
      if (ladrillo.proporcionMortero.contains(":")) {
        proporcionStr = ladrillo.proporcionMortero.replaceAll("1 : ", "");
      } else {
        proporcionStr = ladrillo.proporcionMortero;
      }
      int proporcion = int.tryParse(proporcionStr) ?? 4;
      double volumenMortero = 0.0;

      // Cálculo del volumen de mortero según tipo de ladrillo y asentado
      switch (ladrillo.tipoLadrillo) {
        case 'Kingkong':
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              volumenMortero = 0.020;
              break;
            case 'canto':
              volumenMortero = 0.010;
              break;
            case 'cabeza':
              volumenMortero = 0.046;
              break;
            default:
              volumenMortero = 0.020;
          }
          break;
        case 'Pandereta':
        default:
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              volumenMortero = 0.023;
              break;
            case 'canto':
              volumenMortero = 0.015;
              break;
            case 'cabeza':
              volumenMortero = 0.057;
              break;
            default:
              volumenMortero = 0.023;
          }
      }

      // Factor de arena según proporción
      double factorArena = proporcion == 4 ? 1.16 : 1.20; // m³/m³ de mortero

      // Cálculo final con desperdicio
      double arenaPorM2 = volumenMortero * factorArena;
      double arenaConDesperdicio = arenaPorM2 * (1 + factorDesperdicio);

      totalArena += arenaConDesperdicio * area;
    }

    return totalArena;
  }

  // Calcula la cantidad total de agua en m³
  double calcularAguaTotal(List<Ladrillo> ladrillos) {
    double totalAgua = 0.0;

    for (var ladrillo in ladrillos) {
      double area = calcularArea(ladrillo) ?? 0.0;
      double factorDesperdicio = 0.10; // 10% de desperdicio para mortero
      String proporcionStr;
      if (ladrillo.proporcionMortero.contains(":")) {
        proporcionStr = ladrillo.proporcionMortero.replaceAll("1 : ", "");
      } else {
        proporcionStr = ladrillo.proporcionMortero;
      }
      int proporcion = int.tryParse(proporcionStr) ?? 4;
      print("ladrillo.proporcionMortero");
      print(ladrillo.proporcionMortero);

      double volumenMortero = 0.0;

      // Cálculo del volumen de mortero según tipo de ladrillo y asentado
      switch (ladrillo.tipoLadrillo) {
        case 'Kingkong':
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              volumenMortero = 0.020;
              break;
            case 'canto':
              volumenMortero = 0.010;
              break;
            case 'cabeza':
              volumenMortero = 0.046;
              break;
            default:
              volumenMortero = 0.020;
          }
          break;
        case 'Pandereta':
        default:
          switch (ladrillo.tipoAsentado) {
            case 'soga':
              volumenMortero = 0.023;
              break;
            case 'canto':
              volumenMortero = 0.015;
              break;
            case 'cabeza':
              volumenMortero = 0.057;
              break;
            default:
              volumenMortero = 0.023;
          }
      }

      // Factor de agua según proporción (litros convertidos a m³)
      double factorAgua = proporcion == 4 ? 0.240 : 0.240; // m³/m³ de mortero

      // Cálculo final con desperdicio
      double aguaPorM2 = volumenMortero * factorAgua;
      double aguaConDesperdicio = aguaPorM2 * (1 + factorDesperdicio);

      totalAgua += aguaConDesperdicio * area;
    }

    return totalAgua;
  }
}
