import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';

/// Calculadora unificada de materiales para todos los tipos de construcción
class UnifiedMaterialsCalculator {

  /// Calcula materiales basado en el tipo de resultado
  static CalculationResult calculateMaterials(List<dynamic> results) {
    if (results.isEmpty) {
      return CalculationResult.empty();
    }

    try {
      final firstResult = results.first;

      if (firstResult is Ladrillo) {
        return _calculateLadrilloMaterials(results.cast<Ladrillo>());
      } else if (firstResult is Piso) {
        return _calculatePisoMaterials(results.cast<Piso>());
      } else if (firstResult is LosaAligerada) {
        return _calculateLosaAligeradaMaterials(results.cast<LosaAligerada>());
      } else if (firstResult is Tarrajeo) {
        return _calculateTarrajeoMaterials(results.cast<Tarrajeo>());
      } else if (firstResult is Columna) {
        return _calculateColumnaMaterials(results.cast<Columna>());
      } else if (firstResult is Viga) {
        return _calculateVigaMaterials(results.cast<Viga>());
      }

      return CalculationResult.error('Tipo de cálculo no soportado');
    } catch (e) {
      return CalculationResult.error('Error en cálculo: ${e.toString()}');
    }
  }

  /// Cálculos para ladrillos (basado en ResultLadrilloScreen)
  static CalculationResult _calculateLadrilloMaterials(List<Ladrillo> ladrillos) {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalLadrillos = 0.0;
    double totalAgua = 0.0;
    double totalArea = 0.0;

    // Datos de tipos de ladrillos (igual que en ResultLadrilloScreen)
    final Map<String, Map<String, double>> tiposLadrillo = {
      'Pandereta': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
      'Pandereta1': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
      'Pandereta2': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
      'Kingkong': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
      'Kingkong1': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
      'Kingkong2': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
    };

    final Map<String, Map<String, double>> proporcionesMortero = {
      '3': {'cemento': 454.0, 'arena': 1.1, 'agua': 250.0},
      '4': {'cemento': 364.0, 'arena': 1.16, 'agua': 240.0},
      '5': {'cemento': 302.0, 'arena': 1.2, 'agua': 240.0},
      '6': {'cemento': 261.0, 'arena': 1.2, 'agua': 235.0},
    };

    for (var ladrillo in ladrillos) {
      double area = _obtenerAreaLadrillo(ladrillo);
      totalArea += area;

      double factorDesperdicioLadrillo = (double.tryParse(ladrillo.factorDesperdicio) ?? 5.0) / 100;
      double factorDesperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

      String tipoLadrilloKey = _normalizarTipoLadrillo(ladrillo.tipoLadrillo);
      Map<String, double>? dimensiones = tiposLadrillo[tipoLadrilloKey] ?? tiposLadrillo['Pandereta']!;

      double ladrillosPorM2 = _calcularLadrillosPorM2(dimensiones, ladrillo.tipoAsentado);
      double volumenMortero = _calcularVolumenMortero(dimensiones, ladrillo.tipoAsentado, ladrillosPorM2);

      String proporcionStr = ladrillo.proporcionMortero;
      Map<String, double>? datosProporcion = proporcionesMortero[proporcionStr] ?? proporcionesMortero['4']!;

      double ladrillosArea = ladrillosPorM2 * (1 + factorDesperdicioLadrillo) * area;
      double cementoArea = (datosProporcion['cemento']! / 42.5) * volumenMortero * (1 + factorDesperdicioMortero) * area;
      double arenaArea = datosProporcion['arena']! * volumenMortero * (1 + factorDesperdicioMortero) * area;
      double aguaArea = ((datosProporcion['cemento']! / 42.5) * (42.5 * 0.8) / 1000) * volumenMortero * (1 + factorDesperdicioMortero) * area;

      totalLadrillos += ladrillosArea;
      totalCemento += cementoArea;
      totalArena += arenaArea;
      totalAgua += aguaArea;
    }

    final materials = <Material>[
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: totalCemento.ceil().toString(),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: totalArena.toStringAsFixed(2),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: totalAgua.toStringAsFixed(2),
      ),
      Material(
        description: 'Ladrillo',
        unit: 'und',
        quantity: totalLadrillos.ceil().toString(),
      ),
    ];

    final measurements = ladrillos.map((l) => MeasurementData(
      description: l.description,
      value: _obtenerAreaLadrillo(l),
      unit: 'm²',
    )).toList();

    return CalculationResult(
      type: CalculationType.ladrillo,
      materials: materials,
      measurements: measurements,
      totalValue: totalArea,
      totalUnit: 'm²',
      additionalInfo: {
        'tipoAsentado': ladrillos.first.tipoAsentado,
        'proporcionMortero': '1:${ladrillos.first.proporcionMortero}',
        'desperdicioLadrillo': '${double.tryParse(ladrillos.first.factorDesperdicio) ?? 5}%',
        'desperdicioMortero': '${double.tryParse(ladrillos.first.factorDesperdicioMortero) ?? 10}%',
      },
    );
  }

  /// Cálculos para pisos mejorados
  static CalculationResult _calculatePisoMaterials(List<Piso> pisos) {
    double totalVolumen = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;
    double piedraTotal = 0.0;

    // Factores según el tipo de piso
    const Map<String, Map<String, Map<String, double>>> factoresPiso = {
      'falso': { // Falso piso - concreto
        '175': {'cemento': 8.43, 'arena': 0.54, 'piedra': 0.55, 'agua': 0.185},
        '210': {'cemento': 9.73, 'arena': 0.52, 'piedra': 0.53, 'agua': 0.186},
        '245': {'cemento': 11.5, 'arena': 0.5, 'piedra': 0.51, 'agua': 0.187},
      },
      'contrapiso': { // Contrapiso - mortero
        '3': {'cemento': 10.5, 'arena': 0.95, 'agua': 0.285},
        '4': {'cemento': 8.9, 'arena': 1.0, 'agua': 0.272},
        '5': {'cemento': 7.4, 'arena': 1.05, 'agua': 0.268},
        '6': {'cemento': 6.3, 'arena': 1.08, 'agua': 0.265},
      },
    };

    for (var piso in pisos) {
      double volumen = _calcularVolumenPiso(piso);
      totalVolumen += volumen;

      double desperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0;

      if (piso.tipo == 'falso' || piso.tipo == 'Falso piso') {
        // Falso piso - usar resistencia
        String resistencia = _extractResistenciaValue(piso.resistencia ?? '175 kg/cm²');
        final Map<String, double>? factoresMap = factoresPiso['falso']?[resistencia] ?? factoresPiso['falso']?['175'];

        if (factoresMap != null) {
          cementoTotal += (factoresMap['cemento'] ?? 0.0) * volumen * (1 + desperdicio);
          arenaTotal += (factoresMap['arena'] ?? 0.0) * volumen * (1 + desperdicio);
          piedraTotal += (factoresMap['piedra'] ?? 0.0) * volumen * (1 + desperdicio);
          aguaTotal += (factoresMap['agua'] ?? 0.0) * volumen * (1 + desperdicio);
        }
      } else {
        // Contrapiso - usar proporción de mortero
        String proporcion = piso.proporcionMortero ?? '5';
        final Map<String, double>? factoresMap = factoresPiso['contrapiso']?[proporcion] ?? factoresPiso['contrapiso']?['5'];

        if (factoresMap != null) {
          cementoTotal += (factoresMap['cemento'] ?? 0.0) * volumen * (1 + desperdicio);
          arenaTotal += (factoresMap['arena'] ?? 0.0) * volumen * (1 + desperdicio);
          aguaTotal += (factoresMap['agua'] ?? 0.0) * volumen * (1 + desperdicio);
        }
      }
    }

    List<Material> materials = [
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena', unit: 'm³', quantity: arenaTotal.toStringAsFixed(2)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(2)),
    ];

    if (piedraTotal > 0) {
      materials.add(Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(2)));
    }

    final measurements = pisos.map((piso) {
      return MeasurementData(
        description: piso.description,
        value: _calcularVolumenPiso(piso),
        unit: 'm³',
      );
    }).toList();

    return CalculationResult(
      type: CalculationType.piso,
      materials: materials,
      measurements: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
      additionalInfo: {
        'tipoPiso': pisos.first.tipo,
        'espesor': '${pisos.first.espesor} cm',
        'desperdicio': '${double.tryParse(pisos.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  /// Cálculos para losas aligeradas mejorados
  static CalculationResult _calculateLosaAligeradaMaterials(List<LosaAligerada> losas) {
    double totalArea = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;
    double ladrillosTotal = 0.0;

    // Volumen de concreto por m² según altura y material
    const Map<String, Map<String, double>> volumenConcretoM2 = {
      'Ladrillo Hueco': {
        '17 cm': 0.08,
        '20 cm': 0.0875,
        '25 cm': 0.1001,
      },
      'Bovedillas': {
        '17 cm': 0.0616,
        '20 cm': 0.0712,
        '25 cm': 0.085,
      },
    };

    // Factores según resistencia del concreto
    const Map<String, Map<String, double>> factoresConcreto = {
      '140 kg/cm²': {'cemento': 7.0, 'arena': 0.55, 'piedra': 0.65, 'agua': 0.18},
      '175 kg/cm²': {'cemento': 8.43, 'arena': 0.54, 'piedra': 0.55, 'agua': 0.185},
      '210 kg/cm²': {'cemento': 9.73, 'arena': 0.52, 'piedra': 0.53, 'agua': 0.186},
      '245 kg/cm²': {'cemento': 10.5, 'arena': 0.51, 'piedra': 0.52, 'agua': 0.186},
      '280 kg/cm²': {'cemento': 11.5, 'arena': 0.5, 'piedra': 0.51, 'agua': 0.187},
    };

    for (var losa in losas) {
      double area = _calcularAreaLosa(losa);
      totalArea += area;

      // Obtener volumen de concreto por m²
      double volConcretoM2 = volumenConcretoM2[losa.materialAligerado]?[losa.altura] ?? 0.08;
      double volConcretoTotal = volConcretoM2 * area;

      // Factores de desperdicio
      double desperdicioConcreto = (double.tryParse(losa.desperdicioConcreto) ?? 5.0) / 100.0;
      double desperdicioLadrillo = (double.tryParse(losa.desperdicioLadrillo) ?? 5.0) / 100.0;

      // Factores de materiales según resistencia
      final factores = factoresConcreto[losa.resistenciaConcreto] ?? factoresConcreto['175 kg/cm²']!;

      // Calcular materiales de concreto
      cementoTotal += factores['cemento']! * volConcretoTotal * (1 + desperdicioConcreto);
      arenaTotal += factores['arena']! * volConcretoTotal * (1 + desperdicioConcreto);
      piedraTotal += factores['piedra']! * volConcretoTotal * (1 + desperdicioConcreto);
      aguaTotal += factores['agua']! * volConcretoTotal * (1 + desperdicioConcreto);

      // Calcular ladrillos aligerantes (aproximadamente 9 por m²)
      ladrillosTotal += 9 * area * (1 + desperdicioLadrillo);
    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(2)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(2)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(2)),
      Material(description: 'Ladrillo hueco', unit: 'und', quantity: ladrillosTotal.ceil().toString()),
    ];

    final measurements = losas.map((losa) => MeasurementData(
      description: losa.description,
      value: _calcularAreaLosa(losa),
      unit: 'm²',
    )).toList();

    return CalculationResult(
      type: CalculationType.losaAligerada,
      materials: materials,
      measurements: measurements,
      totalValue: totalArea,
      totalUnit: 'm²',
      additionalInfo: {
        'altura': losas.first.altura,
        'materialAligerado': losas.first.materialAligerado,
        'resistenciaConcreto': losas.first.resistenciaConcreto,
        'desperdicioConcreto': '${losas.first.desperdicioConcreto}%',
        'desperdicioLadrillo': '${losas.first.desperdicioLadrillo}%',
      },
    );
  }

  /// Cálculos para tarrajeo mejorados
  static CalculationResult _calculateTarrajeoMaterials(List<Tarrajeo> tarrajeos) {
    double totalArea = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;

    // Factores según proporción del mortero
    const Map<String, Map<String, double>> factoresMortero = {
      '4': {'cemento': 8.9, 'arena': 1.0, 'agua': 0.272},
      '5': {'cemento': 7.4, 'arena': 1.05, 'agua': 0.268},
      '6': {'cemento': 6.13, 'arena': 1.07, 'agua': 0.269},
    };

    for (var tarrajeo in tarrajeos) {
      double area = _calcularAreaTarrajeo(tarrajeo);
      totalArea += area;

      double espesor = double.tryParse(tarrajeo.espesor) ?? 1.5;
      double volumen = area * (espesor / 100); // convertir cm a metros

      double desperdicio = (double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0) / 100.0;

      final factores = factoresMortero[tarrajeo.proporcionMortero] ?? factoresMortero['5']!;

      cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
      arenaTotal += factores['arena']! * volumen * (1 + desperdicio);
      aguaTotal += factores['agua']! * volumen * (1 + desperdicio);
    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena fina', unit: 'm³', quantity: arenaTotal.toStringAsFixed(2)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(2)),
    ];

    final measurements = tarrajeos.map((tarrajeo) => MeasurementData(
      description: tarrajeo.description,
      value: _calcularAreaTarrajeo(tarrajeo),
      unit: 'm²',
    )).toList();

    return CalculationResult(
      type: CalculationType.tarrajeo,
      materials: materials,
      measurements: measurements,
      totalValue: totalArea,
      totalUnit: 'm²',
      additionalInfo: {
        'tipo': tarrajeos.first.tipo,
        'espesor': '${tarrajeos.first.espesor} cm',
        'proporcionMortero': '1:${tarrajeos.first.proporcionMortero}',
        'desperdicio': '${double.tryParse(tarrajeos.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  /// Cálculos para columnas mejorados
  static CalculationResult _calculateColumnaMaterials(List<Columna> columnas) {
    double totalVolumen = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;

    // Factores según resistencia del concreto
    const Map<String, Map<String, double>> factoresConcreto = {
      '175 kg/cm²': {'cemento': 8.43, 'arena': 0.54, 'piedra': 0.55, 'agua': 0.185},
      '210 kg/cm²': {'cemento': 9.73, 'arena': 0.52, 'piedra': 0.53, 'agua': 0.186},
      '245 kg/cm²': {'cemento': 11.5, 'arena': 0.5, 'piedra': 0.51, 'agua': 0.187},
    };

    for (var columna in columnas) {
      double volumen = _calcularVolumenColumna(columna);
      totalVolumen += volumen;

      double desperdicio = (double.tryParse(columna.factorDesperdicio) ?? 5.0) / 100.0;

      final factores = factoresConcreto[columna.resistencia] ?? factoresConcreto['210 kg/cm²']!;

      cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
      arenaTotal += factores['arena']! * volumen * (1 + desperdicio);
      piedraTotal += factores['piedra']! * volumen * (1 + desperdicio);
      aguaTotal += factores['agua']! * volumen * (1 + desperdicio);
    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(2)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(2)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(2)),
    ];

    final measurements = columnas.map((columna) => MeasurementData(
      description: columna.description,
      value: _calcularVolumenColumna(columna),
      unit: 'm³',
    )).toList();

    return CalculationResult(
      type: CalculationType.columna,
      materials: materials,
      measurements: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
      additionalInfo: {
        'resistencia': columnas.first.resistencia,
        'desperdicio': '${double.tryParse(columnas.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  /// Cálculos para vigas mejorados
  static CalculationResult _calculateVigaMaterials(List<Viga> vigas) {
    double totalVolumen = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;

    // Factores según resistencia del concreto
    const Map<String, Map<String, double>> factoresConcreto = {
      '175 kg/cm²': {'cemento': 8.43, 'arena': 0.54, 'piedra': 0.55, 'agua': 0.185},
      '210 kg/cm²': {'cemento': 9.73, 'arena': 0.52, 'piedra': 0.53, 'agua': 0.186},
      '245 kg/cm²': {'cemento': 11.5, 'arena': 0.5, 'piedra': 0.51, 'agua': 0.187},
    };

    for (var viga in vigas) {
      double volumen = _calcularVolumenViga(viga);
      totalVolumen += volumen;

      double desperdicio = (double.tryParse(viga.factorDesperdicio) ?? 5.0) / 100.0;

      final factores = factoresConcreto[viga.resistencia] ?? factoresConcreto['210 kg/cm²']!;

      cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
      arenaTotal += factores['arena']! * volumen * (1 + desperdicio);
      piedraTotal += factores['piedra']! * volumen * (1 + desperdicio);
      aguaTotal += factores['agua']! * volumen * (1 + desperdicio);

    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(2)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(2)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(2)),
    ];

    final measurements = vigas.map((viga) => MeasurementData(
      description: viga.description,
      value: _calcularVolumenViga(viga),
      unit: 'm³',
    )).toList();

    return CalculationResult(
      type: CalculationType.viga,
      materials: materials,
      measurements: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
      additionalInfo: {
        'resistencia': vigas.first.resistencia,
        'desperdicio': '${double.tryParse(vigas.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  // =============== MÉTODOS AUXILIARES ===============

  /// Métodos auxiliares para cálculos de ladrillos
  static double _obtenerAreaLadrillo(Ladrillo ladrillo) {
    if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
      return double.tryParse(ladrillo.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
      final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
      return largo * altura;
    }
  }

  static String _normalizarTipoLadrillo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'pandereta':
      case 'pandereta1':
      case 'pandereta2':
        return 'Pandereta';
      case 'kingkong':
      case 'kingkong1':
      case 'kingkong2':
      case 'king kong':
        return 'Kingkong';
      default:
        return 'Pandereta';
    }
  }

  static double _calcularLadrillosPorM2(Map<String, double> dimensiones, String tipoAsentado) {
    double largo = dimensiones['largo']!;
    double ancho = dimensiones['ancho']!;
    double alto = dimensiones['alto']!;

    switch (tipoAsentado) {
      case 'soga':
        return 1 / (((largo + 1.5) / 100) * ((alto + 1.5) / 100));
      case 'cabeza':
        return 1 / (((ancho + 1.5) / 100) * ((alto + 1.5) / 100));
      case 'canto':
        return 1 / (((largo + 1.5) / 100) * ((ancho + 1.5) / 100));
      default:
        return 1 / (((largo + 1.5) / 100) * ((alto + 1.5) / 100));
    }
  }

  static double _calcularVolumenMortero(Map<String, double> dimensiones, String tipoAsentado, double ladrillosPorM2) {
    double largo = dimensiones['largo']! / 100;
    double ancho = dimensiones['ancho']! / 100;
    double alto = dimensiones['alto']! / 100;

    double volumenLadrillo = largo * ancho * alto;

    double espesorMuro;
    switch (tipoAsentado) {
      case 'soga':
        espesorMuro = ancho;
        break;
      case 'cabeza':
        espesorMuro = largo;
        break;
      case 'canto':
        espesorMuro = alto;
        break;
      default:
        espesorMuro = ancho;
    }

    return (1.0 * 1.0 * espesorMuro) - (ladrillosPorM2 * volumenLadrillo);
  }

  /// Métodos auxiliares para pisos
  static double _calcularVolumenPiso(Piso piso) {
    double espesor = (double.tryParse(piso.espesor) ?? 0.0) / 100;

    if (piso.area != null && piso.area!.isNotEmpty) {
      double area = double.tryParse(piso.area!) ?? 0.0;
      return area * espesor;
    } else {
      double largo = double.tryParse(piso.largo ?? '') ?? 0.0;
      double ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
      return largo * ancho * espesor;
    }
  }

  static String _extractResistenciaValue(String resistencia) {
    final match = RegExp(r'\d+').firstMatch(resistencia);
    return match?.group(0) ?? '175';
  }

  /// Métodos auxiliares para losas aligeradas
  static double _calcularAreaLosa(LosaAligerada losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    } else {
      double largo = double.tryParse(losa.largo ?? '') ?? 0.0;
      double ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }

  /// Métodos auxiliares para tarrajeo
  static double _calcularAreaTarrajeo(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!) ?? 0.0;
    } else {
      double longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
      double ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
      return longitud * ancho;
    }
  }

  /// Métodos auxiliares para columnas
  static double _calcularVolumenColumna(Columna columna) {
    if (columna.volumen != null && columna.volumen!.isNotEmpty) {
      return double.tryParse(columna.volumen!) ?? 0.0;
    } else {
      double largo = double.tryParse(columna.largo ?? '') ?? 0.0;
      double ancho = double.tryParse(columna.ancho ?? '') ?? 0.0;
      double altura = double.tryParse(columna.altura ?? '') ?? 0.0;
      return largo * ancho * altura;
    }
  }

  /// Métodos auxiliares para vigas
  static double _calcularVolumenViga(Viga viga) {
    if (viga.volumen != null && viga.volumen!.isNotEmpty) {
      return double.tryParse(viga.volumen!) ?? 0.0;
    } else {
      double largo = double.tryParse(viga.largo ?? '') ?? 0.0;
      double ancho = double.tryParse(viga.ancho ?? '') ?? 0.0;
      double altura = double.tryParse(viga.altura ?? '') ?? 0.0;
      return largo * ancho * altura;
    }
  }
}

/// Tipos de cálculo soportados
enum CalculationType {
  ladrillo,
  piso,
  losaAligerada,
  tarrajeo,
  columna,
  viga;

  String get displayName {
    switch (this) {
      case CalculationType.ladrillo:
        return 'Cálculo de Ladrillo';
      case CalculationType.piso:
        return 'Cálculo de Piso';
      case CalculationType.losaAligerada:
        return 'Cálculo de Losa Aligerada';
      case CalculationType.tarrajeo:
        return 'Cálculo de Tarrajeo';
      case CalculationType.columna:
        return 'Cálculo de Columna';
      case CalculationType.viga:
        return 'Cálculo de Viga';
    }
  }

  String get icon {
    switch (this) {
      case CalculationType.ladrillo:
        return 'Icons.grid_view';
      case CalculationType.piso:
        return 'Icons.grid_on';
      case CalculationType.losaAligerada:
        return 'Icons.layers';
      case CalculationType.tarrajeo:
        return 'Icons.brush';
      case CalculationType.columna:
        return 'Icons.view_column';
      case CalculationType.viga:
        return 'Icons.horizontal_rule';
    }
  }
}

/// Modelo unificado para materiales
class Material {
  final String description;
  final String unit;
  final String quantity;

  const Material({
    required this.description,
    required this.unit,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'unit': unit,
      'quantity': quantity,
    };
  }

  @override
  String toString() => '$description: $quantity $unit';
}

/// Modelo para datos de medición
class MeasurementData {
  final String description;
  final double value;
  final String unit;

  const MeasurementData({
    required this.description,
    required this.value,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'value': value,
      'unit': unit,
    };
  }

  @override
  String toString() => '$description: ${value.toStringAsFixed(2)} $unit';
}

/// Resultado unificado de cálculos
class CalculationResult {
  final CalculationType type;
  final List<Material> materials;
  final List<MeasurementData> measurements;
  final double totalValue;
  final String totalUnit;
  final Map<String, String> additionalInfo;
  final String? errorMessage;

  const CalculationResult({
    required this.type,
    required this.materials,
    required this.measurements,
    required this.totalValue,
    required this.totalUnit,
    this.additionalInfo = const {},
    this.errorMessage,
  });

  factory CalculationResult.empty() {
    return const CalculationResult(
      type: CalculationType.ladrillo,
      materials: [],
      measurements: [],
      totalValue: 0.0,
      totalUnit: '',
    );
  }

  factory CalculationResult.error(String message) {
    return CalculationResult(
      type: CalculationType.ladrillo,
      materials: const [],
      measurements: const [],
      totalValue: 0.0,
      totalUnit: '',
      errorMessage: message,
    );
  }

  bool get hasError => errorMessage != null;
  bool get isEmpty => materials.isEmpty && measurements.isEmpty;

  /// Obtiene un resumen de los materiales para mostrar en UI
  String get materialsSummary {
    if (materials.isEmpty) return 'Sin materiales';

    final summary = materials.take(3).map((m) => '${m.description}: ${m.quantity} ${m.unit}').join('\n');
    final remaining = materials.length - 3;

    if (remaining > 0) {
      return '$summary\n... y $remaining más';
    }

    return summary;
  }

  /// Obtiene información de configuración formateada
  String get configurationSummary {
    if (additionalInfo.isEmpty) return '';

    return additionalInfo.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  /// Calcula el costo estimado (placeholder para futuras implementaciones)
  double get estimatedCost {
    // Implementar lógica de cálculo de costos basada en precios actuales
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.displayName,
      'materials': materials.map((m) => m.toJson()).toList(),
      'measurements': measurements.map((m) => m.toJson()).toList(),
      'totalValue': totalValue,
      'totalUnit': totalUnit,
      'additionalInfo': additionalInfo,
      'errorMessage': errorMessage,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    if (hasError) return 'CalculationResult.error($errorMessage)';

    return '''
CalculationResult(
  type: ${type.displayName},
  total: ${totalValue.toStringAsFixed(2)} $totalUnit,
  materials: ${materials.length},
  measurements: ${measurements.length}
)''';
  }

  /// Crea una copia con modificaciones
  CalculationResult copyWith({
    CalculationType? type,
    List<Material>? materials,
    List<MeasurementData>? measurements,
    double? totalValue,
    String? totalUnit,
    Map<String, String>? additionalInfo,
    String? errorMessage,
  }) {
    return CalculationResult(
      type: type ?? this.type,
      materials: materials ?? this.materials,
      measurements: measurements ?? this.measurements,
      totalValue: totalValue ?? this.totalValue,
      totalUnit: totalUnit ?? this.totalUnit,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      errorMessage: errorMessage,
    );
  }

  /// Combina múltiples resultados del mismo tipo
  static CalculationResult combine(List<CalculationResult> results) {
    if (results.isEmpty) return CalculationResult.empty();

    final firstResult = results.first;
    if (results.any((r) => r.type != firstResult.type)) {
      return CalculationResult.error('No se pueden combinar resultados de diferentes tipos');
    }

    final combinedMaterials = <String, Material>{};
    final combinedMeasurements = <MeasurementData>[];
    double combinedTotal = 0.0;

    for (final result in results) {
      if (result.hasError) continue;

      // Combinar materiales
      for (final material in result.materials) {
        final key = '${material.description}_${material.unit}';
        if (combinedMaterials.containsKey(key)) {
          final existing = combinedMaterials[key]!;
          final existingQty = double.tryParse(existing.quantity) ?? 0.0;
          final newQty = double.tryParse(material.quantity) ?? 0.0;
          final totalQty = existingQty + newQty;

          combinedMaterials[key] = Material(
            description: material.description,
            unit: material.unit,
            quantity: totalQty.toStringAsFixed(2),
          );
        } else {
          combinedMaterials[key] = material;
        }
      }

      // Combinar mediciones
      combinedMeasurements.addAll(result.measurements);
      combinedTotal += result.totalValue;
    }

    return CalculationResult(
      type: firstResult.type,
      materials: combinedMaterials.values.toList(),
      measurements: combinedMeasurements,
      totalValue: combinedTotal,
      totalUnit: firstResult.totalUnit,
      additionalInfo: firstResult.additionalInfo,
    );
  }
}