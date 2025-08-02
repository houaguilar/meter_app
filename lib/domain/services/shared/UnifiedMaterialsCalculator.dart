// lib/domain/services/shared/UnifiedMaterialsCalculator.dart

import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';

/// Calculadora unificada de materiales actualizada con los nuevos cálculos de los providers
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
        // Distinguir entre falso piso y contrapiso
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA LADRILLOS - ACTUALIZADOS DESDE ladrillo_providers.dart
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateLadrilloMaterials(List<Ladrillo> ladrillos) {
    // Especificaciones EXACTAS validadas contra Excel
    const Map<String, Map<String, double>> especificacionesLadrillos = {
      "King Kong": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Pandereta": {"largo": 23.0, "ancho": 12.0, "alto": 9.0},
      "Artesanal": {"largo": 22.0, "ancho": 12.5, "alto": 7.5},
      // Alias para compatibilidad
      "Kingkong": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Kingkong1": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Kingkong2": {"largo": 24.0, "ancho": 13.0, "alto": 9.0},
      "Pandereta1": {"largo": 23.0, "ancho": 12.0, "alto": 9.0},
      "Pandereta2": {"largo": 23.0, "ancho": 12.0, "alto": 9.0},
      "Común": {"largo": 22.0, "ancho": 12.5, "alto": 7.5},
    };

    // Factores EXACTOS validados contra Excel
    const Map<String, Map<String, double>> factoresMortero = {
      '3': {
        'cemento': 10.682353,    // bolsas por m³
        'arena': 1.10,           // m³ por m³
        'agua': 0.250000,        // m³ por m³
      },
      '4': {
        'cemento': 8.565,        // bolsas por m³
        'arena': 1.16,           // m³ por m³
        'agua': 0.291,           // m³ por m³
      },
      '5': {
        'cemento': 7.105882,     // bolsas por m³
        'arena': 1.20,           // m³ por m³
        'agua': 0.242,           // m³ por m³
      },
      '6': {
        'cemento': 6.141176,     // bolsas por m³
        'arena': 1.20,           // m³ por m³
        'agua': 0.235000,        // m³ por m³
      },
    };

    // Juntas fijas
    const double juntaHorizontal = 1.5;
    const double juntaVertical = 1.5;

    double ladrillosTotal = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;
    double areaTotal = 0.0;

    for (var ladrillo in ladrillos) {
      final area = _obtenerAreaLadrillo(ladrillo);
      areaTotal += area;

      // Factores de desperdicio
      final desperdicioLadrillo = (double.tryParse(ladrillo.factorDesperdicio) ?? 5.0) / 100;
      final desperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

      // Obtener dimensiones del tipo de ladrillo
      final tipoLadrilloKey = _normalizarTipoLadrillo(ladrillo.tipoLadrillo);
      final specs = especificacionesLadrillos[tipoLadrilloKey] ?? especificacionesLadrillos["Pandereta"]!;

      final largo = specs["largo"]!;
      final ancho = specs["ancho"]!;
      final alto = specs["alto"]!;

      // Determinar grosor del muro y dimensiones según forma
      double grosorMuro, dim1, dim2;
      if (ladrillo.tipoAsentado == "soga") {
        grosorMuro = ancho;
        dim1 = largo;
        dim2 = alto;
      } else if (ladrillo.tipoAsentado == "cabeza") {
        grosorMuro = largo;
        dim1 = ancho;
        dim2 = alto;
      } else { // canto
        grosorMuro = alto;
        dim1 = largo;
        dim2 = ancho;
      }

      // Calcular ladrillos por m²
      final dim1ConJunta = (dim1 / 100) + (juntaHorizontal / 100);
      final dim2ConJunta = (dim2 / 100) + (juntaVertical / 100);
      final ladrillosPorM2 = 1.0 / (dim1ConJunta * dim2ConJunta);

      // Cantidad total de ladrillos con desperdicio
      final ladrillosParaEstaArea = ladrillosPorM2 * area * (1 + desperdicioLadrillo);
      ladrillosTotal += ladrillosParaEstaArea;

      // Calcular volumen de mortero
      final volumenMuroPorM2 = grosorMuro / 100; // m³ por m²
      final volumenLadrilloUnitario = (largo * ancho * alto) / 1000000; // m³
      final morteroPorM2 = volumenMuroPorM2 - (ladrillosPorM2 * volumenLadrilloUnitario);
      final morteroParaEstaArea = morteroPorM2 * area * (1 + desperdicioMortero);

      // Calcular materiales del mortero según proporción
      final proporcionStr = ladrillo.proporcionMortero;
      final factores = factoresMortero[proporcionStr] ?? factoresMortero['4']!;

      // Calcular materiales del mortero
      cementoTotal += morteroParaEstaArea * factores['cemento']!;
      arenaTotal += morteroParaEstaArea * factores['arena']!;
      aguaTotal += morteroParaEstaArea * factores['agua']!;
    }

    final materials = <Material>[
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: cementoTotal.ceil().toString(),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: arenaTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: aguaTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Ladrillo',
        unit: 'und',
        quantity: ladrillosTotal.ceil().toString(),
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
      totalValue: areaTotal,
      totalUnit: 'm²',
      additionalInfo: {
        'tipoAsentado': ladrillos.first.tipoAsentado,
        'proporcionMortero': '1:${ladrillos.first.proporcionMortero}',
        'desperdicioLadrillo': '${double.tryParse(ladrillos.first.factorDesperdicio) ?? 5}%',
        'desperdicioMortero': '${double.tryParse(ladrillos.first.factorDesperdicioMortero) ?? 10}%',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA PISOS - SEPARADOS EN FALSO PISO Y CONTRAPISO
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculatePisoMaterials(List<Piso> pisos) {
    // Determinar si son falsos pisos o contrapisos basado en el tipo
    final primerPiso = pisos.first;
    final esFalsoPiso = primerPiso.tipo.toLowerCase().contains('falso');

    if (esFalsoPiso) {
      return _calculateFalsoPisoMaterials(pisos);
    } else {
      return _calculateContrapisoMaterials(pisos);
    }
  }

  static CalculationResult _calculateFalsoPisoMaterials(List<Piso> pisos) {
    // Factores corregidos del Excel (líneas 15-226)
    const Map<String, Map<String, double>> factoresConcreto = {
      '140': {
        'cemento': 7.01,  // bolsas por m³
        'arena': 0.56,    // m³ por m³
        'piedra': 0.64,   // m³ por m³
        'agua': 0.184,    // m³ por m³
      },
      '175': {
        'cemento': 8.43,
        'arena': 0.54,
        'piedra': 0.55,
        'agua': 0.185,
      },
      '210': {
        'cemento': 9.73,
        'arena': 0.52,
        'piedra': 0.53,
        'agua': 0.186,
      },
      '245': {
        'cemento': 11.50,
        'arena': 0.50,
        'piedra': 0.51,
        'agua': 0.187,
      },
      '280': {
        'cemento': 13.34,
        'arena': 0.45,
        'piedra': 0.51,
        'agua': 0.189,
      },
    };

    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;
    double areaTotal = 0.0;

    for (var piso in pisos) {
      final resistenciaStr = _extractResistenciaValue(piso.resistencia ?? '175 kg/cm²');
      final espesor = double.tryParse(piso.espesor) ?? 5.0;
      final desperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0;

      final factores = factoresConcreto[resistenciaStr] ?? factoresConcreto['175']!;

      final area = _obtenerAreaPiso(piso);
      areaTotal += area;

      final volumen = area * (espesor / 100); // convertir cm a metros

      // Calcular materiales con desperdicio
      cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
      arenaTotal += factores['arena']! * volumen * (1 + desperdicio);
      piedraTotal += factores['piedra']! * volumen * (1 + desperdicio);
      aguaTotal += factores['agua']! * volumen * (1 + desperdicio);
    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(3)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(3)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(3)),
    ];

    final measurements = pisos.map((piso) => MeasurementData(
      description: piso.description,
      value: _obtenerAreaPiso(piso),
      unit: 'm²',
    )).toList();

    return CalculationResult(
      type: CalculationType.piso,
      materials: materials,
      measurements: measurements,
      totalValue: areaTotal,
      totalUnit: 'm²',
      additionalInfo: {
        'tipoPiso': 'Falso Piso',
        'resistencia': pisos.first.resistencia ?? '175 kg/cm²',
        'espesor': '${pisos.first.espesor} cm',
        'desperdicio': '${double.tryParse(pisos.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  static CalculationResult _calculateContrapisoMaterials(List<Piso> pisos) {
    // Factores basados en el Excel (líneas 15-164)
    const Map<String, Map<String, double>> factoresMortero = {
      '3': {
        'cemento': 10.5, // bolsas por m³
        'arena': 0.95,   // m³ por m³
        'agua': 0.285,   // m³ por m³
      },
      '4': {
        'cemento': 8.9,
        'arena': 1.0,
        'agua': 0.272,
      },
      '5': {
        'cemento': 7.4,
        'arena': 1.05,
        'agua': 0.268,
      },
      '6': {
        'cemento': 6.3,
        'arena': 1.08,
        'agua': 0.265,
      },
    };

    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;
    double areaTotal = 0.0;

    for (var piso in pisos) {
      final proporcion = piso.proporcionMortero ?? '5';
      final espesor = double.tryParse(piso.espesor) ?? 5.0;
      final desperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0;

      final factores = factoresMortero[proporcion] ?? factoresMortero['5']!;

      final area = _obtenerAreaPiso(piso);
      areaTotal += area;

      final volumen = area * (espesor / 100);

      // Calcular materiales con desperdicio
      cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
      arenaTotal += factores['arena']! * volumen * (1 + desperdicio);
      aguaTotal += factores['agua']! * volumen * (1 + desperdicio);
    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena fina', unit: 'm³', quantity: arenaTotal.toStringAsFixed(3)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(3)),
    ];

    final measurements = pisos.map((piso) => MeasurementData(
      description: piso.description,
      value: _obtenerAreaPiso(piso),
      unit: 'm²',
    )).toList();

    return CalculationResult(
      type: CalculationType.piso,
      materials: materials,
      measurements: measurements,
      totalValue: areaTotal,
      totalUnit: 'm²',
      additionalInfo: {
        'tipoPiso': 'Contrapiso',
        'proporcionMortero': '1:${pisos.first.proporcionMortero ?? '5'}',
        'espesor': '${pisos.first.espesor} cm',
        'desperdicio': '${double.tryParse(pisos.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA LOSAS ALIGERADAS - ACTUALIZADOS
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateLosaAligeradaMaterials(List<LosaAligerada> losas) {
    // Volumen de concreto por m² según altura y material (desde losas_aligeradas_providers)
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
      '140 kg/cm²': {'cemento': 7.01, 'arena': 0.56, 'piedra': 0.64, 'agua': 0.184},
      '175 kg/cm²': {'cemento': 8.43, 'arena': 0.54, 'piedra': 0.55, 'agua': 0.185},
      '210 kg/cm²': {'cemento': 9.73, 'arena': 0.52, 'piedra': 0.53, 'agua': 0.186},
      '245 kg/cm²': {'cemento': 11.50, 'arena': 0.50, 'piedra': 0.51, 'agua': 0.187},
      '280 kg/cm²': {'cemento': 13.34, 'arena': 0.45, 'piedra': 0.51, 'agua': 0.189},
    };

    double totalArea = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;
    double ladrillosTotal = 0.0;

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
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(3)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(3)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(3)),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA TARRAJEO - ACTUALIZADOS
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateTarrajeoMaterials(List<Tarrajeo> tarrajeos) {
    // Factores según proporción del mortero (desde tarrajeo_providers)
    const Map<String, Map<String, double>> factoresMortero = {
      '3': {
        'cemento': 10.5,  // bolsas por m³
        'arena': 0.95,    // m³ por m³
        'agua': 0.285,    // m³ por m³
      },
      '4': {
        'cemento': 8.9,
        'arena': 1.0,
        'agua': 0.272,
      },
      '5': {
        'cemento': 7.4,
        'arena': 1.05,
        'agua': 0.268,
      },
      '6': {
        'cemento': 6.13,
        'arena': 1.07,
        'agua': 0.269,
      },
    };

    double totalArea = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;

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
      Material(description: 'Arena fina', unit: 'm³', quantity: arenaTotal.toStringAsFixed(3)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(3)),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA COLUMNAS - ACTUALIZADOS DESDE structural_element_providers
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateColumnaMaterials(List<Columna> columnas) {
    // Factores según resistencia del concreto (desde structural_element_providers)
    const Map<String, Map<String, double>> factoresConcreto = {
      "175 kg/cm²": {
        "cemento": 8.43,        // bolsas por m³
        "arenaGruesa": 0.54,    // m³ por m³
        "piedraConcreto": 0.55, // m³ por m³
        "agua": 0.185,          // m³ por m³
      },
      "210 kg/cm²": {
        "cemento": 9.73,
        "arenaGruesa": 0.52,
        "piedraConcreto": 0.53,
        "agua": 0.186,
      },
      "245 kg/cm²": {
        "cemento": 11.5,
        "arenaGruesa": 0.5,
        "piedraConcreto": 0.51,
        "agua": 0.187,
      },
    };

    double totalVolumen = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;

    for (var columna in columnas) {
      double volumen = _calcularVolumenElemento(columna);
      totalVolumen += volumen;

      final factores = factoresConcreto[columna.resistencia];

      if (factores != null && volumen > 0) {
        final desperdicio = (double.tryParse(columna.factorDesperdicio) ?? 5.0) / 100.0;

        cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
        arenaTotal += factores['arenaGruesa']! * volumen * (1 + desperdicio);
        piedraTotal += factores['piedraConcreto']! * volumen * (1 + desperdicio);
        aguaTotal += factores['agua']! * volumen * (1 + desperdicio);
      }
    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(3)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(3)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(3)),
    ];

    final measurements = columnas.map((columna) => MeasurementData(
      description: columna.description,
      value: _calcularVolumenElemento(columna),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA VIGAS - ACTUALIZADOS DESDE structural_element_providers
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateVigaMaterials(List<Viga> vigas) {
    // Factores según resistencia del concreto (mismo que columnas)
    const Map<String, Map<String, double>> factoresConcreto = {
      "175 kg/cm²": {
        "cemento": 8.43,
        "arenaGruesa": 0.54,
        "piedraConcreto": 0.55,
        "agua": 0.185,
      },
      "210 kg/cm²": {
        "cemento": 9.73,
        "arenaGruesa": 0.52,
        "piedraConcreto": 0.53,
        "agua": 0.186,
      },
      "245 kg/cm²": {
        "cemento": 11.5,
        "arenaGruesa": 0.5,
        "piedraConcreto": 0.51,
        "agua": 0.187,
      },
    };

    double totalVolumen = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;

    for (var viga in vigas) {
      double volumen = _calcularVolumenElemento(viga);
      totalVolumen += volumen;

      final factores = factoresConcreto[viga.resistencia];

      if (factores != null && volumen > 0) {
        final desperdicio = (double.tryParse(viga.factorDesperdicio) ?? 5.0) / 100.0;

        cementoTotal += factores['cemento']! * volumen * (1 + desperdicio);
        arenaTotal += factores['arenaGruesa']! * volumen * (1 + desperdicio);
        piedraTotal += factores['piedraConcreto']! * volumen * (1 + desperdicio);
        aguaTotal += factores['agua']! * volumen * (1 + desperdicio);
      }
    }

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(3)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(3)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(3)),
    ];

    final measurements = vigas.map((viga) => MeasurementData(
      description: viga.description,
      value: _calcularVolumenElemento(viga),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Normaliza el tipo de ladrillo para la búsqueda en especificaciones
  static String _normalizarTipoLadrillo(String tipo) {
    final tipoLower = tipo.toLowerCase();

    if (tipoLower.contains('king') || tipoLower.contains('kong')) {
      return 'King Kong';
    } else if (tipoLower.contains('pandereta')) {
      return 'Pandereta';
    } else if (tipoLower.contains('artesanal') || tipoLower.contains('común') || tipoLower.contains('comun')) {
      return 'Artesanal';
    } else {
      return 'Pandereta'; // Default
    }
  }

  /// Obtiene el área de un ladrillo
  static double _obtenerAreaLadrillo(Ladrillo ladrillo) {
    if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
      return double.tryParse(ladrillo.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
      final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
      return largo * altura;
    }
  }

  /// Obtiene el área de un piso
  static double _obtenerAreaPiso(Piso piso) {
    if (piso.area != null && piso.area!.isNotEmpty) {
      return double.tryParse(piso.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }

  /// Extrae el valor numérico de la resistencia del formato "175 kg/cm²"
  static String _extractResistenciaValue(String resistencia) {
    final match = RegExp(r'\d+').firstMatch(resistencia);
    final valor = match?.group(0) ?? '175';

    // Validar que la resistencia exista en la tabla
    const resistenciasValidas = ['140', '175', '210', '245', '280'];
    if (!resistenciasValidas.contains(valor)) {
      return '175'; // Valor por defecto
    }

    return valor;
  }

  /// Calcula el volumen de un elemento estructural (columna o viga)
  static double _calcularVolumenElemento(dynamic elemento) {
    if (elemento.volumen != null && elemento.volumen!.isNotEmpty) {
      return double.tryParse(elemento.volumen!) ?? 0.0;
    } else {
      final largo = double.tryParse(elemento.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(elemento.ancho ?? '') ?? 0.0;
      final altura = double.tryParse(elemento.altura ?? '') ?? 0.0;
      return largo * ancho * altura;
    }
  }

  /// Calcula el área de una losa aligerada
  static double _calcularAreaLosa(LosaAligerada losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(losa.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }

  /// Calcula el área de un tarrajeo
  static double _calcularAreaTarrajeo(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!) ?? 0.0;
    } else {
      final longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
      final ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
      return longitud * ancho;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES DE SOPORTE
// ═══════════════════════════════════════════════════════════════════════════

/// Enumeración de tipos de cálculo
enum CalculationType {
  ladrillo,
  piso,
  losaAligerada,
  tarrajeo,
  columna,
  viga,
}

/// Clase para representar un material calculado
class Material {
  final String description;
  final String unit;
  final String quantity;

  const Material({
    required this.description,
    required this.unit,
    required this.quantity,
  });

  @override
  String toString() => '$description: $quantity $unit';
}

/// Clase para representar datos de medición
class MeasurementData {
  final String description;
  final double value;
  final String unit;

  const MeasurementData({
    required this.description,
    required this.value,
    required this.unit,
  });

  @override
  String toString() => '$description: ${value.toStringAsFixed(2)} $unit';
}

/// Clase para el resultado final del cálculo
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

  /// Constructor para resultado vacío
  const CalculationResult.empty()
      : type = CalculationType.ladrillo,
        materials = const [],
        measurements = const [],
        totalValue = 0.0,
        totalUnit = '',
        additionalInfo = const {},
        errorMessage = null;

  /// Constructor para errores
  const CalculationResult.error(String error)
      : type = CalculationType.ladrillo,
        materials = const [],
        measurements = const [],
        totalValue = 0.0,
        totalUnit = '',
        additionalInfo = const {},
        errorMessage = error;

  /// Indica si hay error
  bool get hasError => errorMessage != null;

  /// Indica si está vacío
  bool get isEmpty => materials.isEmpty && measurements.isEmpty;

  @override
  String toString() {
    if (hasError) return 'Error: $errorMessage';
    if (isEmpty) return 'Resultado vacío';

    final materialsStr = materials.map((m) => '  • ${m.toString()}').join('\n');
    final measurementsStr = measurements.map((m) => '  • ${m.toString()}').join('\n');

    return '''
Tipo: ${type.name}
Total: ${totalValue.toStringAsFixed(2)} $totalUnit

Materiales:
$materialsStr

Mediciones:
$measurementsStr

Información adicional:
${additionalInfo.entries.map((e) => '  • ${e.key}: ${e.value}').join('\n')}
''';
  }
}