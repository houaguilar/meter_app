
import '../entities/home/estructuras/columna/columna.dart';
import '../entities/home/estructuras/viga/viga.dart';

class StructuralElementService {
  // Common service methods for both Column and Beam
  double? calcularVolumen(dynamic elemento) {
    if (elemento.volumen != null && elemento.volumen!.isNotEmpty) {
      return double.tryParse(elemento.volumen!);
    }
    if (elemento.largo != null && elemento.ancho != null && elemento.altura != null) {
      final largo = double.tryParse(elemento.largo!);
      final ancho = double.tryParse(elemento.ancho!);
      final altura = double.tryParse(elemento.altura!);
      if (largo != null && ancho != null && altura != null) {
        return largo * ancho * altura;
      }
    }
    return null;
  }

  bool esValido(dynamic elemento) {
    return (elemento.largo != null && elemento.ancho != null && elemento.altura != null) ||
        (elemento.volumen != null && elemento.volumen!.isNotEmpty);
  }

  // Métodos específicos para Columnas
  double calcularCementoColumna(List<Columna> columnas) {
    double totalCemento = 0.0;

    for (var columna in columnas) {
      double volumen = calcularVolumen(columna) ?? 0.0;
      double factorDesperdicio = double.tryParse(columna.factorDesperdicio) != null
          ? double.parse(columna.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de cemento según resistencia de concreto
      double factorCemento;
      switch (columna.resistencia) {
        case "175 kg/cm²":
          factorCemento = 7.0; // 7.0 bolsas por m³
          break;
        case "210 kg/cm²":
          factorCemento = 8.0; // 8.0 bolsas por m³
          break;
        case "280 kg/cm²":
          factorCemento = 9.0; // 9.0 bolsas por m³
          break;
        default:
          factorCemento = 8.0; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalCemento += volumen * factorCemento * (1 + factorDesperdicio);
    }

    return totalCemento;
  }

  double calcularArenaColumna(List<Columna> columnas) {
    double totalArena = 0.0;

    for (var columna in columnas) {
      double volumen = calcularVolumen(columna) ?? 0.0;
      double factorDesperdicio = double.tryParse(columna.factorDesperdicio) != null
          ? double.parse(columna.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de arena según resistencia
      double factorArena;
      switch (columna.resistencia) {
        case "175 kg/cm²":
          factorArena = 0.56; // 0.56 m³ por m³ de concreto
          break;
        case "210 kg/cm²":
          factorArena = 0.54; // 0.54 m³ por m³ de concreto
          break;
        case "280 kg/cm²":
          factorArena = 0.50; // 0.50 m³ por m³ de concreto
          break;
        default:
          factorArena = 0.54; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalArena += volumen * factorArena * (1 + factorDesperdicio);
    }

    return totalArena;
  }

  double calcularPiedraColumna(List<Columna> columnas) {
    double totalPiedra = 0.0;

    for (var columna in columnas) {
      double volumen = calcularVolumen(columna) ?? 0.0;
      double factorDesperdicio = double.tryParse(columna.factorDesperdicio) != null
          ? double.parse(columna.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de piedra según resistencia
      double factorPiedra;
      switch (columna.resistencia) {
        case "175 kg/cm²":
          factorPiedra = 0.67; // 0.67 m³ por m³ de concreto
          break;
        case "210 kg/cm²":
          factorPiedra = 0.66; // 0.66 m³ por m³ de concreto
          break;
        case "280 kg/cm²":
          factorPiedra = 0.64; // 0.64 m³ por m³ de concreto
          break;
        default:
          factorPiedra = 0.66; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalPiedra += volumen * factorPiedra * (1 + factorDesperdicio);
    }

    return totalPiedra;
  }

  double calcularAguaColumna(List<Columna> columnas) {
    double totalAgua = 0.0;

    for (var columna in columnas) {
      double volumen = calcularVolumen(columna) ?? 0.0;
      double factorDesperdicio = double.tryParse(columna.factorDesperdicio) != null
          ? double.parse(columna.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de agua según resistencia (litros por m³ convertidos a m³)
      double factorAgua;
      switch (columna.resistencia) {
        case "175 kg/cm²":
          factorAgua = 0.184; // 184 litros por m³ convertido a m³
          break;
        case "210 kg/cm²":
          factorAgua = 0.182; // 182 litros por m³ convertido a m³
          break;
        case "280 kg/cm²":
          factorAgua = 0.178; // 178 litros por m³ convertido a m³
          break;
        default:
          factorAgua = 0.182; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalAgua += volumen * factorAgua * (1 + factorDesperdicio);
    }

    return totalAgua;
  }

  // Métodos específicos para Vigas (similar a columnas pero con factores específicos)
  double calcularCementoViga(List<Viga> vigas) {
    double totalCemento = 0.0;

    for (var viga in vigas) {
      double volumen = calcularVolumen(viga) ?? 0.0;
      double factorDesperdicio = double.tryParse(viga.factorDesperdicio) != null
          ? double.parse(viga.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de cemento según resistencia de concreto
      double factorCemento;
      switch (viga.resistencia) {
        case "175 kg/cm²":
          factorCemento = 7.0; // 7.0 bolsas por m³
          break;
        case "210 kg/cm²":
          factorCemento = 8.0; // 8.0 bolsas por m³
          break;
        case "280 kg/cm²":
          factorCemento = 9.0; // 9.0 bolsas por m³
          break;
        default:
          factorCemento = 8.0; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalCemento += volumen * factorCemento * (1 + factorDesperdicio);
    }

    return totalCemento;
  }

  double calcularArenaViga(List<Viga> vigas) {
    double totalArena = 0.0;

    for (var viga in vigas) {
      double volumen = calcularVolumen(viga) ?? 0.0;
      double factorDesperdicio = double.tryParse(viga.factorDesperdicio) != null
          ? double.parse(viga.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de arena según resistencia
      double factorArena;
      switch (viga.resistencia) {
        case "175 kg/cm²":
          factorArena = 0.56; // 0.56 m³ por m³ de concreto
          break;
        case "210 kg/cm²":
          factorArena = 0.54; // 0.54 m³ por m³ de concreto
          break;
        case "280 kg/cm²":
          factorArena = 0.50; // 0.50 m³ por m³ de concreto
          break;
        default:
          factorArena = 0.54; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalArena += volumen * factorArena * (1 + factorDesperdicio);
    }

    return totalArena;
  }

  double calcularPiedraViga(List<Viga> vigas) {
    double totalPiedra = 0.0;

    for (var viga in vigas) {
      double volumen = calcularVolumen(viga) ?? 0.0;
      double factorDesperdicio = double.tryParse(viga.factorDesperdicio) != null
          ? double.parse(viga.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de piedra según resistencia
      double factorPiedra;
      switch (viga.resistencia) {
        case "175 kg/cm²":
          factorPiedra = 0.67; // 0.67 m³ por m³ de concreto
          break;
        case "210 kg/cm²":
          factorPiedra = 0.66; // 0.66 m³ por m³ de concreto
          break;
        case "280 kg/cm²":
          factorPiedra = 0.64; // 0.64 m³ por m³ de concreto
          break;
        default:
          factorPiedra = 0.66; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalPiedra += volumen * factorPiedra * (1 + factorDesperdicio);
    }

    return totalPiedra;
  }

  double calcularAguaViga(List<Viga> vigas) {
    double totalAgua = 0.0;

    for (var viga in vigas) {
      double volumen = calcularVolumen(viga) ?? 0.0;
      double factorDesperdicio = double.tryParse(viga.factorDesperdicio) != null
          ? double.parse(viga.factorDesperdicio) / 100
          : 0.05; // 5% por defecto

      // Factor de agua según resistencia (litros por m³ convertidos a m³)
      double factorAgua;
      switch (viga.resistencia) {
        case "175 kg/cm²":
          factorAgua = 0.184; // 184 litros por m³ convertido a m³
          break;
        case "210 kg/cm²":
          factorAgua = 0.182; // 182 litros por m³ convertido a m³
          break;
        case "280 kg/cm²":
          factorAgua = 0.178; // 178 litros por m³ convertido a m³
          break;
        default:
          factorAgua = 0.182; // Valor predeterminado
      }

      // Cálculo final con desperdicio
      totalAgua += volumen * factorAgua * (1 + factorDesperdicio);
    }

    return totalAgua;
  }
}