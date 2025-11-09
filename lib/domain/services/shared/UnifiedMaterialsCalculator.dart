
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/estructuras/zapata/zapata.dart';
import '../../../domain/entities/home/losas/losa.dart';
import '../../entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import '../../entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import '../../entities/home/estructuras/solado/solado.dart';
import '../../entities/home/acero/columna/steel_column.dart';
import '../../entities/home/acero/viga/steel_beam.dart';
import '../../entities/home/acero/losa_maciza/steel_slab.dart';
import '../../entities/home/acero/zapata/steel_footing.dart';
import '../../entities/home/acero/steel_constants.dart';
import '../losas/losa_service.dart';

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
      } else if (firstResult is Losa) {
        // Arquitectura unificada de losas (3 tipos)
        return _calculateLosaMaterials(results.cast<Losa>());
      } else if (firstResult is Tarrajeo) {
        return _calculateTarrajeoMaterials(results.cast<Tarrajeo>());
      } else if (firstResult is Columna) {
        return _calculateColumnaMaterials(results.cast<Columna>());
      } else if (firstResult is Viga) {
        return _calculateVigaMaterials(results.cast<Viga>());
      } else if (firstResult is Zapata) {
        return _calculateZapataMaterials(results.cast<Zapata>());
      } else if (firstResult is Sobrecimiento) {
        return _calculateSobrecimientoMaterials(results.cast<Sobrecimiento>());
      } else if (firstResult is CimientoCorrido) {
        return _calculateCimientoCorridoMaterials(results.cast<CimientoCorrido>());
      } else if (firstResult is Solado) {
        return _calculateSoladoMaterials(results.cast<Solado>());
      } else if (firstResult is SteelColumn) {
        return _calculateSteelColumnMaterials(results.cast<SteelColumn>());
      } else if (firstResult is SteelBeam) {
        return _calculateSteelBeamMaterials(results.cast<SteelBeam>());
      } else if (firstResult is SteelSlab) {
        return _calculateSteelSlabMaterials(results.cast<SteelSlab>());
      } else if (firstResult is SteelFooting) {
        return _calculateSteelFootingMaterials(results.cast<SteelFooting>());
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
      details: measurements,
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
      details: measurements,
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
      details: measurements,
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
  // CÁLCULOS PARA LOSAS - ARQUITECTURA UNIFICADA (3 tipos)
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateLosaMaterials(List<Losa> losas) {
    double totalArea = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraTotal = 0.0;
    double aguaTotal = 0.0;
    double aditivoTotal = 0.0;

    // Map para agrupar materiales aligerantes por descripción
    final Map<String, double> materialesAligerantes = {};

    for (var losa in losas) {
      double area = _calcularAreaLosa(losa);
      totalArea += area;

      // Obtener el servicio de cálculo según el tipo de losa
      final service = LosaService(losa.tipoLosa);

      // Calcular materiales de concreto (desperdicio ya incluido en el servicio)
      cementoTotal += service.calcularCemento(losa);
      arenaTotal += service.calcularArenaGruesa(losa);
      piedraTotal += service.calcularPiedraChancada(losa);
      aguaTotal += service.calcularAgua(losa);
      aditivoTotal += service.calcularAditivoPlastificante(losa);

      // Calcular material aligerante si aplica (desperdicio ya incluido)
      final cantidadAligerante = service.calcularMaterialAligerante(losa);
      if (cantidadAligerante != null && cantidadAligerante > 0) {
        final descripcionAligerante = service.obtenerDescripcionMaterialAligerante(losa);

        materialesAligerantes[descripcionAligerante] =
            (materialesAligerantes[descripcionAligerante] ?? 0.0) + cantidadAligerante;
      }
    }

    // Construir lista de materiales
    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: cementoTotal.ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: arenaTotal.toStringAsFixed(3)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: piedraTotal.toStringAsFixed(3)),
      Material(description: 'Agua', unit: 'm³', quantity: aguaTotal.toStringAsFixed(3)),
      Material(description: 'Aditivo plastificante', unit: 'L', quantity: aditivoTotal.toStringAsFixed(2)),
    ];

    // Agregar materiales aligerantes si existen
    materialesAligerantes.forEach((descripcion, cantidad) {
      materials.add(Material(
        description: descripcion,
        unit: 'und',
        quantity: cantidad.ceil().toString(),
      ));
    });

    final measurements = losas.map((losa) => MeasurementData(
      description: losa.description,
      value: _calcularAreaLosa(losa),
      unit: 'm²',
    )).toList();

    return CalculationResult(
      type: CalculationType.losaAligerada,
      materials: materials,
      details: measurements,
      totalValue: totalArea,
      totalUnit: 'm²',
      additionalInfo: {
        'tipoLosa': losas.first.tipoLosa.displayName,
        'altura': losas.first.altura,
        'resistenciaConcreto': losas.first.resistenciaConcreto,
        'desperdicioConcreto': '${losas.first.desperdicioConcreto}%',
        if (losas.first.materialAligerante != null)
          'materialAligerante': losas.first.materialAligerante!,
        if (losas.first.desperdicioMaterialAligerante != null)
          'desperdicioMaterialAligerante': '${losas.first.desperdicioMaterialAligerante}%',
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
      details: measurements,
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
      details: measurements,
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
      details: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
      additionalInfo: {
        'resistencia': vigas.first.resistencia,
        'desperdicio': '${double.tryParse(vigas.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA ZAPATAS - ACTUALIZADOS DESDE structural_element_providers
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateZapataMaterials(List<Zapata> zapatas) {
    // Factores según resistencia del concreto (mismo que columnas y vigas)
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
      "280 kg/cm²": {
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

    for (var zapata in zapatas) {
      double volumen = _calcularVolumenElemento(zapata);
      totalVolumen += volumen;

      final factores = factoresConcreto[zapata.resistencia];

      if (factores != null && volumen > 0) {
        final desperdicio = (double.tryParse(zapata.factorDesperdicio) ?? 5.0) / 100.0;

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

    final measurements = zapatas.map((zapata) => MeasurementData(
      description: zapata.description,
      value: _calcularVolumenElemento(zapata),
      unit: 'm³',
    )).toList();

    return CalculationResult(
      type: CalculationType.zapata,
      materials: materials,
      details: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
      additionalInfo: {
        'resistencia': zapatas.first.resistencia,
        'desperdicio': '${double.tryParse(zapatas.first.factorDesperdicio) ?? 5}%',
      },
    );
  }

  static CalculationResult _calculateSobrecimientoMaterials(List<Sobrecimiento> sobrecimientos) {
    const Map<String, Map<String, double>> factoresSobrecimiento = {
      "175 kg/cm²": {
        "cemento": 8.43,
        "arenaGruesa": 0.45,
        "piedraChancada": 0.40,
        "piedraGrande": 0.25,
        "agua": 0.139,
      },
      "210 kg/cm²": {
        "cemento": 9.20,
        "arenaGruesa": 0.42,
        "piedraChancada": 0.38,
        "piedraGrande": 0.23,
        "agua": 0.135,
      },
      "280 kg/cm²": {
        "cemento": 10.80,
        "arenaGruesa": 0.38,
        "piedraChancada": 0.35,
        "piedraGrande": 0.20,
        "agua": 0.125,
      },
    };

    double volumenTotal = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraChancadaTotal = 0.0;
    double piedraGrandeTotal = 0.0;
    double aguaTotal = 0.0;

    for (final sobrecimiento in sobrecimientos) {
      final volumen = _calcularVolumenElemento(sobrecimiento);
      volumenTotal += volumen;

      final factores = factoresSobrecimiento[sobrecimiento.resistencia] ??
          factoresSobrecimiento["175 kg/cm²"]!;

      final desperdicio = (double.tryParse(sobrecimiento.factorDesperdicio) ?? 5.0) / 100;
      final volumenConDesperdicio = volumen * (1 + desperdicio);

      cementoTotal += factores['cemento']! * volumenConDesperdicio;
      arenaTotal += factores['arenaGruesa']! * volumenConDesperdicio;
      piedraChancadaTotal += factores['piedraChancada']! * volumenConDesperdicio;
      piedraGrandeTotal += factores['piedraGrande']! * volumenConDesperdicio;
      aguaTotal += factores['agua']! * volumenConDesperdicio;
    }

    final materials = <Material>[
      Material(
        description: 'Cemento',
        unit: 'bolsas',
        quantity: cementoTotal.toStringAsFixed(2),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: arenaTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Piedra chancada 3/4"',
        unit: 'm³',
        quantity: piedraChancadaTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Piedra grande (máx. 10")',
        unit: 'm³',
        quantity: piedraGrandeTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: aguaTotal.toStringAsFixed(3),
      ),
    ];

    final details = sobrecimientos.map((s) => MeasurementData(
      description: s.description,
      value: _calcularVolumenElemento(s),
      unit: 'm³',
    )).toList();

    return CalculationResult(
      type: CalculationType.sobrecimiento,
      materials: materials,
      details: details,
      totalValue: volumenTotal,
      totalUnit: 'm³',
      additionalInfo: {
        'resistencia': sobrecimientos.first.resistencia,
        'factorDesperdicio': '${sobrecimientos.first.factorDesperdicio}%',
        'tipoElemento': 'Sobrecimiento',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA CIMIENTO CORRIDO
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateCimientoCorridoMaterials(List<CimientoCorrido> cimientos) {
    const Map<String, Map<String, double>> factoresCimiento = {
      "175 kg/cm²": {
        "cemento": 8.43,
        "arenaGruesa": 0.45,
        "piedraChancada": 0.35,
        "piedraZanja": 0.30,
        "agua": 0.139,
      },
      "210 kg/cm²": {
        "cemento": 9.20,
        "arenaGruesa": 0.42,
        "piedraChancada": 0.33,
        "piedraZanja": 0.28,
        "agua": 0.135,
      },
      "280 kg/cm²": {
        "cemento": 10.80,
        "arenaGruesa": 0.38,
        "piedraChancada": 0.30,
        "piedraZanja": 0.25,
        "agua": 0.125,
      },
    };

    double volumenTotal = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraChancadaTotal = 0.0;
    double piedraZanjaTotal = 0.0;
    double aguaTotal = 0.0;

    for (final cimiento in cimientos) {
      final volumen = _calcularVolumenElemento(cimiento);
      volumenTotal += volumen;

      final factores = factoresCimiento[cimiento.resistencia] ??
          factoresCimiento["175 kg/cm²"]!;

      final desperdicio = (double.tryParse(cimiento.factorDesperdicio) ?? 5.0) / 100;
      final volumenConDesperdicio = volumen * (1 + desperdicio);

      cementoTotal += factores['cemento']! * volumenConDesperdicio;
      arenaTotal += factores['arenaGruesa']! * volumenConDesperdicio;
      piedraChancadaTotal += factores['piedraChancada']! * volumenConDesperdicio;
      piedraZanjaTotal += factores['piedraZanja']! * volumenConDesperdicio;
      aguaTotal += factores['agua']! * volumenConDesperdicio;
    }

    final materials = <Material>[
      Material(
        description: 'Cemento',
        unit: 'bolsas',
        quantity: cementoTotal.toStringAsFixed(2),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: arenaTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Piedra chancada 3/4"',
        unit: 'm³',
        quantity: piedraChancadaTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Piedra de zanja (máx. 10")',
        unit: 'm³',
        quantity: piedraZanjaTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: aguaTotal.toStringAsFixed(3),
      ),
    ];

    final details = cimientos.map((c) => MeasurementData(
      description: c.description,
      value: _calcularVolumenElemento(c),
      unit: 'm³',
    )).toList();

    return CalculationResult(
      type: CalculationType.cimientoCorrido,
      materials: materials,
      details: details,
      totalValue: volumenTotal,
      totalUnit: 'm³',
      additionalInfo: {
        'resistencia': cimientos.first.resistencia,
        'factorDesperdicio': '${cimientos.first.factorDesperdicio}%',
        'tipoElemento': 'Cimiento Corrido',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA SOLADO
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateSoladoMaterials(List<Solado> solados) {
    const Map<String, Map<String, double>> factoresSolado = {
      "175 kg/cm²": {
        "cemento": 8.43,
        "arenaGruesa": 0.54,
        "piedraChancada": 0.55,
        "agua": 0.185,
      },
      "210 kg/cm²": {
        "cemento": 9.20,
        "arenaGruesa": 0.51,
        "piedraChancada": 0.52,
        "agua": 0.180,
      },
      "280 kg/cm²": {
        "cemento": 10.80,
        "arenaGruesa": 0.48,
        "piedraChancada": 0.49,
        "agua": 0.175,
      },
    };

    double areaTotal = 0.0;
    double volumenTotal = 0.0;
    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double piedraChancadaTotal = 0.0;
    double aguaTotal = 0.0;

    for (final solado in solados) {
      final area = _calcularAreaSolado(solado);
      areaTotal += area;

      final volumen = area * solado.espesorFijo; // Siempre 0.1 m
      volumenTotal += volumen;

      final factores = factoresSolado[solado.resistencia] ??
          factoresSolado["175 kg/cm²"]!;

      final desperdicio = (double.tryParse(solado.factorDesperdicio) ?? 5.0) / 100;
      final volumenConDesperdicio = volumen * (1 + desperdicio);

      cementoTotal += factores['cemento']! * volumenConDesperdicio;
      arenaTotal += factores['arenaGruesa']! * volumenConDesperdicio;
      piedraChancadaTotal += factores['piedraChancada']! * volumenConDesperdicio;
      aguaTotal += factores['agua']! * volumenConDesperdicio;
    }

    final materials = <Material>[
      Material(
        description: 'Cemento',
        unit: 'bolsas',
        quantity: cementoTotal.toStringAsFixed(3),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: arenaTotal.toStringAsFixed(6),
      ),
      Material(
        description: 'Piedra chancada',
        unit: 'm³',
        quantity: piedraChancadaTotal.toStringAsFixed(6),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: aguaTotal.toStringAsFixed(6),
      ),
    ];

    final details = solados.map((s) => MeasurementData(
      description: s.description,
      value: _calcularAreaSolado(s),
      unit: 'm²',
    )).toList();

    return CalculationResult(
      type: CalculationType.solado,
      materials: materials,
      details: details,
      totalValue: areaTotal,
      totalUnit: 'm²',
      additionalInfo: {
        'resistencia': solados.first.resistencia,
        'factorDesperdicio': '${solados.first.factorDesperdicio}%',
        'espesorFijo': '${solados.first.espesorFijo * 100} cm',
        'tipoElemento': 'Solado',
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

    if (elemento is Solado) {
      return _calcularAreaSolado(elemento) * elemento.espesorFijo;
    }

    if (elemento.volumen != null && elemento.volumen!.isNotEmpty) {
      return double.tryParse(elemento.volumen!) ?? 0.0;
    }

    if (elemento.largo != null && elemento.largo!.isNotEmpty &&
        elemento.ancho != null && elemento.ancho!.isNotEmpty &&
        elemento.altura != null && elemento.altura!.isNotEmpty) {
      final largo = double.tryParse(elemento.largo!) ?? 0.0;
      final ancho = double.tryParse(elemento.ancho!) ?? 0.0;
      final altura = double.tryParse(elemento.altura!) ?? 0.0;
      return largo * ancho * altura;
    }

    return 0.0;
  }

  static double _calcularAreaSolado(Solado solado) {
    if (solado.area != null && solado.area!.isNotEmpty) {
      return double.tryParse(solado.area!) ?? 0.0;
    }

    if (solado.largo != null && solado.largo!.isNotEmpty &&
        solado.ancho != null && solado.ancho!.isNotEmpty) {
      final largo = double.tryParse(solado.largo!) ?? 0.0;
      final ancho = double.tryParse(solado.ancho!) ?? 0.0;
      return largo * ancho;
    }

    return 0.0;
  }

  /// Calcula el área de una losa
  static double _calcularAreaLosa(Losa losa) {
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA ACERO EN COLUMNAS
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateSteelColumnMaterials(List<SteelColumn> steelColumns) {
    final Map<String, double> consolidatedByDiameter = {};
    double totalWeight = 0;
    double totalWire = 0;
    final measurements = <MeasurementData>[];

    // Calcular cada columna
    for (var column in steelColumns) {
      final Map<String, double> totalesPorDiametro = {};

      // CÁLCULO DE ACERO LONGITUDINAL
      for (final steelBar in column.steelBars) {
        // Longitud básica por barra
        final longitudBasica = column.elements * steelBar.quantity * column.height;
        totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudBasica;

        // Agregar empalme si está habilitado
        if (column.useSplice) {
          final longitudEmpalme = column.elements * steelBar.quantity * (SteelConstants.spliceLengths[steelBar.diameter] ?? 0.6);
          totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudEmpalme;
        }

        // Agregar doblez de zapata si está habilitada
        if (column.hasFooting) {
          final longitudDoblez = column.elements * steelBar.quantity * column.footingBend;
          totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudDoblez;
        }
      }

      // CÁLCULO DE ESTRIBOS
      double longitudCubierta = 0;
      int cantidadEstribosDistribucion = 0;

      for (final distribution in column.stirrupDistributions) {
        longitudCubierta += distribution.quantity * distribution.separation;
        cantidadEstribosDistribucion += distribution.quantity * 2; // x2 para ambos extremos
      }

      // Calcular estribos del resto
      final longitudRestante = column.height - (longitudCubierta * 2);
      int estribosResto = 0;
      if (column.restSeparation > 0 && longitudRestante > 0) {
        estribosResto = (longitudRestante / column.restSeparation).floor();
      }

      // Total de estribos
      final totalEstribos = estribosResto + cantidadEstribosDistribucion;

      // Calcular perímetro del estribo
      final perimetroEstribo = (column.length - (column.cover / 100)) * 2 +
          (column.width - (column.cover / 100)) * 2 +
          column.stirrupBendLength * 2;

      // Longitud total de estribos
      final longitudTotalEstribos = column.elements * totalEstribos * perimetroEstribo;
      totalesPorDiametro[column.stirrupDiameter] =
          (totalesPorDiametro[column.stirrupDiameter] ?? 0.0) + longitudTotalEstribos;

      // CONSOLIDAR Y CALCULAR PESO
      double pesoColumna = 0;
      totalesPorDiametro.forEach((diameter, longitud) {
        if (longitud > 0) {
          // Consolidar longitudes
          consolidatedByDiameter[diameter] = (consolidatedByDiameter[diameter] ?? 0.0) + longitud;

          // Calcular peso
          final weightPerMeter = SteelConstants.steelWeights[diameter] ?? 0.0;
          pesoColumna += longitud * weightPerMeter;
        }
      });

      totalWeight += pesoColumna;

      // Agregar medición por columna
      measurements.add(MeasurementData(
        description: column.description,
        value: pesoColumna * (1 + column.waste),
        unit: 'kg',
      ));
    }

    // Calcular alambre
    totalWire = totalWeight * SteelConstants.wirePercentage * (1 + steelColumns.first.waste);

    // GENERAR MATERIALES POR DIÁMETRO
    final materials = <Material>[];
    consolidatedByDiameter.forEach((diameter, longitud) {
      if (longitud > 0) {
        // Convertir a varillas
        final varillas = longitud / SteelConstants.standardRodLength;
        final varillasConDesperdicio = (varillas * (1 + steelColumns.first.waste)).ceil();

        if (varillasConDesperdicio > 0) {
          materials.add(Material(
            description: 'Acero $diameter',
            unit: 'varillas',
            quantity: varillasConDesperdicio.toString(),
          ));
        }
      }
    });

    // Agregar alambre
    materials.add(Material(
      description: 'Alambre #16',
      unit: 'kg',
      quantity: totalWire.toStringAsFixed(2),
    ));

    return CalculationResult(
      type: CalculationType.steelColumn,
      materials: materials,
      details: measurements,
      totalValue: totalWeight * (1 + steelColumns.first.waste),
      totalUnit: 'kg',
      additionalInfo: {
        'desperdicio': '${(steelColumns.first.waste * 100).toStringAsFixed(1)}%',
        'recubrimiento': '${(steelColumns.first.cover * 100).toStringAsFixed(1)} cm',
        'pesoAlambre': '${totalWire.toStringAsFixed(2)} kg',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA ACERO EN VIGAS
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateSteelBeamMaterials(List<SteelBeam> steelBeams) {
    final Map<String, double> consolidatedByDiameter = {};
    double totalWeight = 0;
    double totalWire = 0;
    final measurements = <MeasurementData>[];

    for (var beam in steelBeams) {
      final Map<String, double> totalesPorDiametro = {};

      // CÁLCULO DE ACERO LONGITUDINAL
      for (final steelBar in beam.steelBars) {
        // Longitud con apoyos y doblez
        final longitudTotal = beam.elements * steelBar.quantity *
            (beam.length + beam.supportA1 + beam.supportA2 + beam.bendLength);
        totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudTotal;

        // Empalme si está habilitado
        if (beam.useSplice) {
          final longitudEmpalme = beam.elements * steelBar.quantity * (SteelConstants.spliceLengths[steelBar.diameter] ?? 0.6);
          totalesPorDiametro[steelBar.diameter] = (totalesPorDiametro[steelBar.diameter] ?? 0.0) + longitudEmpalme;
        }
      }

      // CÁLCULO DE ESTRIBOS (similar a columnas)
      double longitudCubierta = 0;
      int cantidadEstribosDistribucion = 0;

      for (final distribution in beam.stirrupDistributions) {
        longitudCubierta += distribution.quantity * distribution.separation;
        cantidadEstribosDistribucion += distribution.quantity * 2;
      }

      final longitudRestante = beam.length - (longitudCubierta * 2);
      int estribosResto = 0;
      if (beam.restSeparation > 0 && longitudRestante > 0) {
        estribosResto = (longitudRestante / beam.restSeparation).floor();
      }

      final totalEstribos = estribosResto + cantidadEstribosDistribucion;
      final perimetroEstribo = (beam.height - (beam.cover / 100)) * 2 +
          (beam.width - (beam.cover / 100)) * 2 + beam.stirrupBendLength * 2;
      final longitudTotalEstribos = beam.elements * totalEstribos * perimetroEstribo;
      totalesPorDiametro[beam.stirrupDiameter] = (totalesPorDiametro[beam.stirrupDiameter] ?? 0.0) + longitudTotalEstribos;

      // Calcular peso
      double pesoViga = 0;
      totalesPorDiametro.forEach((diameter, longitud) {
        consolidatedByDiameter[diameter] = (consolidatedByDiameter[diameter] ?? 0.0) + longitud;
        pesoViga += longitud * (SteelConstants.steelWeights[diameter] ?? 0.0);
      });
      totalWeight += pesoViga;

      measurements.add(MeasurementData(
        description: beam.description,
        value: pesoViga * (1 + beam.waste),
        unit: 'kg',
      ));
    }

    totalWire = totalWeight * SteelConstants.wirePercentage * (1 + steelBeams.first.waste);

    final materials = <Material>[];
    consolidatedByDiameter.forEach((diameter, longitud) {
      if (longitud > 0) {
        final varillasConDesperdicio = ((longitud / SteelConstants.standardRodLength) * (1 + steelBeams.first.waste)).ceil();
        if (varillasConDesperdicio > 0) {
          materials.add(Material(
            description: 'Acero $diameter',
            unit: 'varillas',
            quantity: varillasConDesperdicio.toString(),
          ));
        }
      }
    });

    materials.add(Material(
      description: 'Alambre #16',
      unit: 'kg',
      quantity: totalWire.toStringAsFixed(2),
    ));

    return CalculationResult(
      type: CalculationType.steelBeam,
      materials: materials,
      details: measurements,
      totalValue: totalWeight * (1 + steelBeams.first.waste),
      totalUnit: 'kg',
      additionalInfo: {
        'desperdicio': '${(steelBeams.first.waste * 100).toStringAsFixed(1)}%',
        'recubrimiento': '${(steelBeams.first.cover * 100).toStringAsFixed(1)} cm',
        'pesoAlambre': '${totalWire.toStringAsFixed(2)} kg',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA ACERO EN LOSAS MACIZAS
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateSteelSlabMaterials(List<SteelSlab> steelSlabs) {
    final Map<String, double> consolidatedByDiameter = {};
    double totalWeight = 0;
    double totalWire = 0;
    final measurements = <MeasurementData>[];

    for (var slab in steelSlabs) {
      final Map<String, double> totalesPorDiametro = {};

      // CÁLCULO DE BARRAS DE MALLA
      for (final meshBar in slab.meshBars) {
        double longitudTotal = 0;

        // Calcular longitud según dirección
        if (meshBar.direction.name == 'horizontal') {
          // Cantidad de barras: ancho / separación + 1
          final cantidad = ((slab.width / meshBar.separation) + 1).floor();
          // Longitud por barra: largo + 2*doblez
          final longitudPorBarra = slab.length + (2 * slab.bendLength);
          longitudTotal = slab.elements * cantidad * longitudPorBarra;
        } else {
          // Vertical
          // Cantidad de barras: largo / separación + 1
          final cantidad = ((slab.length / meshBar.separation) + 1).floor();
          // Longitud por barra: ancho + 2*doblez
          final longitudPorBarra = slab.width + (2 * slab.bendLength);
          longitudTotal = slab.elements * cantidad * longitudPorBarra;
        }

        // Agregar al total por diámetro
        totalesPorDiametro[meshBar.diameter] =
            (totalesPorDiametro[meshBar.diameter] ?? 0.0) + longitudTotal;
      }

      // Calcular peso de la losa
      double pesoLosa = 0;
      totalesPorDiametro.forEach((diameter, longitud) {
        if (longitud > 0) {
          consolidatedByDiameter[diameter] = (consolidatedByDiameter[diameter] ?? 0.0) + longitud;
          final weightPerMeter = SteelConstants.steelWeights[diameter] ?? 0.0;
          pesoLosa += longitud * weightPerMeter;
        }
      });

      totalWeight += pesoLosa;

      // Agregar medición por losa
      measurements.add(MeasurementData(
        description: slab.description,
        value: pesoLosa * (1 + slab.waste),
        unit: 'kg',
      ));
    }

    // Calcular alambre (1.5% del peso total con desperdicio)
    totalWire = totalWeight * SteelConstants.wirePercentage * (1 + steelSlabs.first.waste);

    // GENERAR MATERIALES POR DIÁMETRO
    final materials = <Material>[];
    consolidatedByDiameter.forEach((diameter, longitud) {
      if (longitud > 0) {
        // Convertir a varillas
        final varillas = longitud / SteelConstants.standardRodLength;
        final varillasConDesperdicio = (varillas * (1 + steelSlabs.first.waste)).ceil();

        if (varillasConDesperdicio > 0) {
          materials.add(Material(
            description: 'Acero $diameter',
            unit: 'varillas',
            quantity: varillasConDesperdicio.toString(),
          ));
        }
      }
    });

    // Agregar alambre
    materials.add(Material(
      description: 'Alambre #16',
      unit: 'kg',
      quantity: totalWire.toStringAsFixed(2),
    ));

    return CalculationResult(
      type: CalculationType.steelSlab,
      materials: materials,
      details: measurements,
      totalValue: totalWeight * (1 + steelSlabs.first.waste),
      totalUnit: 'kg',
      additionalInfo: {
        'desperdicio': '${(steelSlabs.first.waste * 100).toStringAsFixed(1)}%',
        'pesoAlambre': '${totalWire.toStringAsFixed(2)} kg',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS PARA ACERO EN ZAPATAS
  // ═══════════════════════════════════════════════════════════════════════════

  static CalculationResult _calculateSteelFootingMaterials(List<SteelFooting> steelFootings) {
    final Map<String, double> consolidatedByDiameter = {};
    double totalWeight = 0;
    double totalWire = 0;
    final measurements = <MeasurementData>[];

    for (var footing in steelFootings) {
      final Map<String, double> totalesPorDiametro = {};

      // CÁLCULO DE MALLA INFERIOR (siempre presente)
      // Barras horizontales
      final inferiorHorizontalQuantity = ((footing.width / footing.inferiorHorizontalSeparation) + 1).floor();
      final inferiorHorizontalLength = footing.length - (2 * footing.cover) + (2 * footing.inferiorBendLength);
      final inferiorHorizontalTotal = footing.elements * inferiorHorizontalQuantity * inferiorHorizontalLength;

      // Barras verticales
      final inferiorVerticalQuantity = ((footing.length / footing.inferiorVerticalSeparation) + 1).floor();
      final inferiorVerticalLength = footing.width - (2 * footing.cover) + (2 * footing.inferiorBendLength);
      final inferiorVerticalTotal = footing.elements * inferiorVerticalQuantity * inferiorVerticalLength;

      // Agregar malla inferior
      totalesPorDiametro[footing.inferiorHorizontalDiameter] =
          (totalesPorDiametro[footing.inferiorHorizontalDiameter] ?? 0.0) + inferiorHorizontalTotal;
      totalesPorDiametro[footing.inferiorVerticalDiameter] =
          (totalesPorDiametro[footing.inferiorVerticalDiameter] ?? 0.0) + inferiorVerticalTotal;

      // CÁLCULO DE MALLA SUPERIOR (opcional)
      if (footing.hasSuperiorMesh &&
          footing.superiorHorizontalSeparation != null &&
          footing.superiorVerticalSeparation != null &&
          footing.superiorHorizontalDiameter != null &&
          footing.superiorVerticalDiameter != null) {

        // Barras horizontales superiores
        final superiorHorizontalQuantity = ((footing.width / footing.superiorHorizontalSeparation!) + 1).floor();
        final superiorHorizontalLength = footing.length - (2 * footing.cover) + (2 * footing.inferiorBendLength);
        final superiorHorizontalTotal = footing.elements * superiorHorizontalQuantity * superiorHorizontalLength;

        // Barras verticales superiores
        final superiorVerticalQuantity = ((footing.length / footing.superiorVerticalSeparation!) + 1).floor();
        final superiorVerticalLength = footing.width - (2 * footing.cover) + (2 * footing.inferiorBendLength);
        final superiorVerticalTotal = footing.elements * superiorVerticalQuantity * superiorVerticalLength;

        // Agregar malla superior
        totalesPorDiametro[footing.superiorHorizontalDiameter!] =
            (totalesPorDiametro[footing.superiorHorizontalDiameter!] ?? 0.0) + superiorHorizontalTotal;
        totalesPorDiametro[footing.superiorVerticalDiameter!] =
            (totalesPorDiametro[footing.superiorVerticalDiameter!] ?? 0.0) + superiorVerticalTotal;
      }

      // Calcular peso de la zapata
      double pesoZapata = 0;
      totalesPorDiametro.forEach((diameter, longitud) {
        if (longitud > 0) {
          consolidatedByDiameter[diameter] = (consolidatedByDiameter[diameter] ?? 0.0) + longitud;
          final weightPerMeter = SteelConstants.steelWeights[diameter] ?? 0.0;
          pesoZapata += longitud * weightPerMeter;
        }
      });

      totalWeight += pesoZapata;

      // Agregar medición por zapata
      measurements.add(MeasurementData(
        description: footing.description,
        value: pesoZapata * (1 + footing.waste),
        unit: 'kg',
      ));
    }

    // Calcular alambre (1.5% del peso total con desperdicio * 0.8)
    totalWire = totalWeight * SteelConstants.wirePercentage * (1 + steelFootings.first.waste) * 0.8;

    // GENERAR MATERIALES POR DIÁMETRO
    final materials = <Material>[];
    consolidatedByDiameter.forEach((diameter, longitud) {
      if (longitud > 0) {
        // Convertir a varillas
        final varillas = longitud / SteelConstants.standardRodLength;
        final varillasConDesperdicio = (varillas * (1 + steelFootings.first.waste)).ceil();

        if (varillasConDesperdicio > 0) {
          materials.add(Material(
            description: 'Acero $diameter',
            unit: 'varillas',
            quantity: varillasConDesperdicio.toString(),
          ));
        }
      }
    });

    // Agregar alambre
    materials.add(Material(
      description: 'Alambre #16',
      unit: 'kg',
      quantity: totalWire.toStringAsFixed(2),
    ));

    return CalculationResult(
      type: CalculationType.steelFooting,
      materials: materials,
      details: measurements,
      totalValue: totalWeight * (1 + steelFootings.first.waste),
      totalUnit: 'kg',
      additionalInfo: {
        'desperdicio': '${(steelFootings.first.waste * 100).toStringAsFixed(1)}%',
        'recubrimiento': '${(steelFootings.first.cover * 100).toStringAsFixed(1)} cm',
        'pesoAlambre': '${totalWire.toStringAsFixed(2)} kg',
      },
    );
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
  zapata,
  sobrecimiento,
  cimientoCorrido,
  solado,
  steelColumn,
  steelBeam,
  steelSlab,
  steelFooting,
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
  final List<MeasurementData> details;
  final double totalValue;
  final String totalUnit;
  final Map<String, String> additionalInfo;
  final String? errorMessage;

  const CalculationResult({
    required this.type,
    required this.materials,
    required this.details,
    required this.totalValue,
    required this.totalUnit,
    this.additionalInfo = const {},
    this.errorMessage,
  });

  /// Constructor para resultado vacío
  const CalculationResult.empty()
      : type = CalculationType.ladrillo,
        materials = const [],
        details = const [],
        totalValue = 0.0,
        totalUnit = '',
        additionalInfo = const {},
        errorMessage = null;

  /// Constructor para errores
  const CalculationResult.error(String error)
      : type = CalculationType.ladrillo,
        materials = const [],
        details = const [],
        totalValue = 0.0,
        totalUnit = '',
        additionalInfo = const {},
        errorMessage = error;

  /// Indica si hay error
  bool get hasError => errorMessage != null;

  /// Indica si está vacío
  bool get isEmpty => materials.isEmpty && details.isEmpty;

  @override
  String toString() {
    if (hasError) return 'Error: $errorMessage';
    if (isEmpty) return 'Resultado vacío';

    final materialsStr = materials.map((m) => '  • ${m.toString()}').join('\n');
    final measurementsStr = details.map((m) => '  • ${m.toString()}').join('\n');

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