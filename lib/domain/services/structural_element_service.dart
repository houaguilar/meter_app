// lib/domain/services/structural_element_service.dart
import '../entities/home/estructuras/columna/columna.dart';
import '../entities/home/estructuras/viga/viga.dart';

class StructuralElementService {

  // Factores de materiales según resistencia del concreto (líneas 15-80 del Excel)
  static const Map<String, Map<String, double>> factoresConcreto = {
    "140 kg/cm²": {
      "cemento": 6.8, // bolsas por m³
      "arenaGruesa": 0.58, // m³ por m³
      "piedraConcreto": 0.62, // m³ por m³
      "agua": 0.185, // m³ por m³
    },
    "175 kg/cm²": {
      "cemento": 8.43, // bolsas por m³
      "arenaGruesa": 0.54, // m³ por m³
      "piedraConcreto": 0.55, // m³ por m³
      "agua": 0.185, // m³ por m³
    },
    "210 kg/cm²": {
      "cemento": 9.73, // bolsas por m³
      "arenaGruesa": 0.52, // m³ por m³
      "piedraConcreto": 0.53, // m³ por m³
      "agua": 0.186, // m³ por m³
    },
    "245 kg/cm²": {
      "cemento": 11.5, // bolsas por m³
      "arenaGruesa": 0.5, // m³ por m³
      "piedraConcreto": 0.51, // m³ por m³
      "agua": 0.187, // m³ por m³
    },
    "280 kg/cm²": {
      "cemento": 13.34, // bolsas por m³
      "arenaGruesa": 0.45, // m³ por m³
      "piedraConcreto": 0.51, // m³ por m³
      "agua": 0.189, // m³ por m³
    },
  };

  // Validar si un elemento estructural es válido
  bool esValido(dynamic elemento) {
    if (elemento is Columna) {
      return _esValidaColumna(elemento);
    } else if (elemento is Viga) {
      return _esValidaViga(elemento);
    }
    return false;
  }

  bool _esValidaColumna(Columna columna) {
    // Debe tener volumen O (largo, ancho y altura)
    bool tieneVolumen = columna.volumen != null && columna.volumen!.isNotEmpty;
    bool tieneDimensiones = columna.largo != null &&
        columna.largo!.isNotEmpty &&
        columna.ancho != null &&
        columna.ancho!.isNotEmpty &&
        columna.altura != null &&
        columna.altura!.isNotEmpty;

    return tieneVolumen || tieneDimensiones;
  }

  bool _esValidaViga(Viga viga) {
    // Debe tener volumen O (largo, ancho y altura)
    bool tieneVolumen = viga.volumen != null && viga.volumen!.isNotEmpty;
    bool tieneDimensiones = viga.largo != null &&
        viga.largo!.isNotEmpty &&
        viga.ancho != null &&
        viga.ancho!.isNotEmpty &&
        viga.altura != null &&
        viga.altura!.isNotEmpty;

    return tieneVolumen || tieneDimensiones;
  }

  // Calcular volumen del elemento
  double? calcularVolumen(dynamic elemento) {
    if (elemento is Columna) {
      return _calcularVolumenColumna(elemento);
    } else if (elemento is Viga) {
      return _calcularVolumenViga(elemento);
    }
    return null;
  }

  double? _calcularVolumenColumna(Columna columna) {
    // Si tiene volumen directo, usarlo
    if (columna.volumen != null && columna.volumen!.isNotEmpty) {
      return double.tryParse(columna.volumen!);
    }

    // Si tiene dimensiones, calcular volumen
    if (columna.largo != null && columna.largo!.isNotEmpty &&
        columna.ancho != null && columna.ancho!.isNotEmpty &&
        columna.altura != null && columna.altura!.isNotEmpty) {

      final largo = double.tryParse(columna.largo!);
      final ancho = double.tryParse(columna.ancho!);
      final altura = double.tryParse(columna.altura!);

      if (largo != null && ancho != null && altura != null) {
        return largo * ancho * altura;
      }
    }

    return null;
  }

  double? _calcularVolumenViga(Viga viga) {
    // Si tiene volumen directo, usarlo
    if (viga.volumen != null && viga.volumen!.isNotEmpty) {
      return double.tryParse(viga.volumen!);
    }

    // Si tiene dimensiones, calcular volumen
    if (viga.largo != null && viga.largo!.isNotEmpty &&
        viga.ancho != null && viga.ancho!.isNotEmpty &&
        viga.altura != null && viga.altura!.isNotEmpty) {

      final largo = double.tryParse(viga.largo!);
      final ancho = double.tryParse(viga.ancho!);
      final altura = double.tryParse(viga.altura!);

      if (largo != null && ancho != null && altura != null) {
        return largo * ancho * altura;
      }
    }

    return null;
  }

  // ===== CÁLCULOS DE MATERIALES PARA COLUMNAS =====

  double calcularCementoColumna(List<Columna> columnas) {
    double totalCemento = 0.0;

    for (final columna in columnas) {
      final volumen = calcularVolumen(columna);
      if (volumen != null && volumen > 0) {
        final resistencia = columna.resistencia;
        final factorDesperdicio = double.tryParse(columna.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final cementoPorM3 = factores["cemento"]!;
          final cementoConDesperdicio = cementoPorM3 * (1 + desperdicioDecimal);
          totalCemento += cementoConDesperdicio * volumen;
        }
      }
    }

    return totalCemento;
  }

  double calcularArenaColumna(List<Columna> columnas) {
    double totalArena = 0.0;

    for (final columna in columnas) {
      final volumen = calcularVolumen(columna);
      if (volumen != null && volumen > 0) {
        final resistencia = columna.resistencia;
        final factorDesperdicio = double.tryParse(columna.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final arenaPorM3 = factores["arenaGruesa"]!;
          final arenaConDesperdicio = arenaPorM3 * (1 + desperdicioDecimal);
          totalArena += arenaConDesperdicio * volumen;
        }
      }
    }

    return totalArena;
  }

  double calcularPiedraColumna(List<Columna> columnas) {
    double totalPiedra = 0.0;

    for (final columna in columnas) {
      final volumen = calcularVolumen(columna);
      if (volumen != null && volumen > 0) {
        final resistencia = columna.resistencia;
        final factorDesperdicio = double.tryParse(columna.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final piedraPorM3 = factores["piedraConcreto"]!;
          final piedraConDesperdicio = piedraPorM3 * (1 + desperdicioDecimal);
          totalPiedra += piedraConDesperdicio * volumen;
        }
      }
    }

    return totalPiedra;
  }

  double calcularAguaColumna(List<Columna> columnas) {
    double totalAgua = 0.0;

    for (final columna in columnas) {
      final volumen = calcularVolumen(columna);
      if (volumen != null && volumen > 0) {
        final resistencia = columna.resistencia;
        final factorDesperdicio = double.tryParse(columna.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final aguaPorM3 = factores["agua"]!;
          final aguaConDesperdicio = aguaPorM3 * (1 + desperdicioDecimal);
          totalAgua += aguaConDesperdicio * volumen;
        }
      }
    }

    return totalAgua;
  }

  // ===== CÁLCULOS DE MATERIALES PARA VIGAS =====

  double calcularCementoViga(List<Viga> vigas) {
    double totalCemento = 0.0;

    for (final viga in vigas) {
      final volumen = calcularVolumen(viga);
      if (volumen != null && volumen > 0) {
        final resistencia = viga.resistencia;
        final factorDesperdicio = double.tryParse(viga.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final cementoPorM3 = factores["cemento"]!;
          final cementoConDesperdicio = cementoPorM3 * (1 + desperdicioDecimal);
          totalCemento += cementoConDesperdicio * volumen;
        }
      }
    }

    return totalCemento;
  }

  double calcularArenaViga(List<Viga> vigas) {
    double totalArena = 0.0;

    for (final viga in vigas) {
      final volumen = calcularVolumen(viga);
      if (volumen != null && volumen > 0) {
        final resistencia = viga.resistencia;
        final factorDesperdicio = double.tryParse(viga.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final arenaPorM3 = factores["arenaGruesa"]!;
          final arenaConDesperdicio = arenaPorM3 * (1 + desperdicioDecimal);
          totalArena += arenaConDesperdicio * volumen;
        }
      }
    }

    return totalArena;
  }

  double calcularPiedraViga(List<Viga> vigas) {
    double totalPiedra = 0.0;

    for (final viga in vigas) {
      final volumen = calcularVolumen(viga);
      if (volumen != null && volumen > 0) {
        final resistencia = viga.resistencia;
        final factorDesperdicio = double.tryParse(viga.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final piedraPorM3 = factores["piedraConcreto"]!;
          final piedraConDesperdicio = piedraPorM3 * (1 + desperdicioDecimal);
          totalPiedra += piedraConDesperdicio * volumen;
        }
      }
    }

    return totalPiedra;
  }

  double calcularAguaViga(List<Viga> vigas) {
    double totalAgua = 0.0;

    for (final viga in vigas) {
      final volumen = calcularVolumen(viga);
      if (volumen != null && volumen > 0) {
        final resistencia = viga.resistencia;
        final factorDesperdicio = double.tryParse(viga.factorDesperdicio) ?? 0.0;
        final desperdicioDecimal = factorDesperdicio / 100;

        final factores = factoresConcreto[resistencia];
        if (factores != null) {
          final aguaPorM3 = factores["agua"]!;
          final aguaConDesperdicio = aguaPorM3 * (1 + desperdicioDecimal);
          totalAgua += aguaConDesperdicio * volumen;
        }
      }
    }

    return totalAgua;
  }

  // ===== MÉTODO PARA OBTENER FACTORES DE RESISTENCIA =====

  Map<String, double>? getFactoresResistencia(String resistencia) {
    return factoresConcreto[resistencia];
  }

  // ===== MÉTODO PARA OBTENER RESISTENCIAS DISPONIBLES =====

  List<String> getResistenciasDisponibles() {
    return factoresConcreto.keys.toList();
  }

  // ===== MÉTODO PARA VALIDAR RESISTENCIA =====

  bool esResistenciaValida(String resistencia) {
    return factoresConcreto.containsKey(resistencia);
  }
}