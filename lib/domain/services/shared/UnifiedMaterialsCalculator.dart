// lib/domain/services/calculations/unified_materials_calculator.dart

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
      // Calcular área
      double area = _obtenerAreaLadrillo(ladrillo);
      totalArea += area;

      // Factores de desperdicio
      double factorDesperdicioLadrillo = (double.tryParse(ladrillo.factorDesperdicio) ?? 5.0) / 100;
      double factorDesperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

      // Datos del tipo de ladrillo
      String tipoLadrilloKey = _normalizarTipoLadrillo(ladrillo.tipoLadrillo);
      Map<String, double>? dimensiones = tiposLadrillo[tipoLadrilloKey] ?? tiposLadrillo['Pandereta']!;

      // Calcular ladrillos por m²
      double ladrillosPorM2 = _calcularLadrillosPorM2(dimensiones, ladrillo.tipoAsentado);

      // Calcular volumen de mortero
      double volumenMortero = _calcularVolumenMortero(dimensiones, ladrillo.tipoAsentado, ladrillosPorM2);

      // Datos de proporción de mortero
      String proporcionStr = ladrillo.proporcionMortero;
      Map<String, double>? datosProporcion = proporcionesMortero[proporcionStr] ?? proporcionesMortero['4']!;

      // Calcular materiales
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
        'tipoLadrillo': ladrillos.first.tipoLadrillo,
        'tipoAsentado': ladrillos.first.tipoAsentado,
        'proporcionMortero': '1:${ladrillos.first.proporcionMortero}',
        'desperdicioLadrillo': '${double.tryParse(ladrillos.first.factorDesperdicio) ?? 5}%',
        'desperdicioMortero': '${double.tryParse(ladrillos.first.factorDesperdicioMortero) ?? 10}%',
      },
    );
  }

  // Métodos auxiliares para cálculos de ladrillos
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

  /// Cálculos para pisos
  static CalculationResult _calculatePisoMaterials(List<Piso> pisos) {
    // Implementación simplificada - puedes expandir basándote en la lógica existente
    double totalVolumen = 0.0;

    final measurements = pisos.map((piso) {
      double volumen = _calcularVolumenPiso(piso);
      totalVolumen += volumen;
      return MeasurementData(
        description: piso.description,
        value: volumen,
        unit: 'm³',
      );
    }).toList();

    // Cálculo simplificado de materiales
    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: (totalVolumen * 7).ceil().toString()),
      Material(description: 'Arena', unit: 'm³', quantity: (totalVolumen * 1.15).toStringAsFixed(2)),
      Material(description: 'Agua', unit: 'm³', quantity: (totalVolumen * 0.20).toStringAsFixed(2)),
    ];

    return CalculationResult(
      type: CalculationType.piso,
      materials: materials,
      measurements: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
    );
  }

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

  /// Cálculos para losas aligeradas
  static CalculationResult _calculateLosaAligeradaMaterials(List<LosaAligerada> losas) {
    // Implementación basada en la lógica existente
    double totalArea = 0.0;

    final measurements = losas.map((losa) {
      double area = _calcularAreaLosa(losa);
      totalArea += area;
      return MeasurementData(
        description: losa.description,
        value: area,
        unit: 'm²',
      );
    }).toList();

    // Cálculos simplificados
    final materials = <Material>[
      Material(description: 'Ladrillo', unit: 'und', quantity: (totalArea * 9).ceil().toString()),
      Material(description: 'Cemento', unit: 'bls', quantity: (totalArea * 2.8).ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: (totalArea * 0.18).toStringAsFixed(2)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: (totalArea * 0.28).toStringAsFixed(2)),
      Material(description: 'Acero', unit: 'kg', quantity: (totalArea * 4.5).toStringAsFixed(2)),
    ];

    return CalculationResult(
      type: CalculationType.losaAligerada,
      materials: materials,
      measurements: measurements,
      totalValue: totalArea,
      totalUnit: 'm²',
    );
  }

  static double _calcularAreaLosa(LosaAligerada losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    } else {
      double largo = double.tryParse(losa.largo ?? '') ?? 0.0;
      double ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }

  /// Cálculos para tarrajeo
  static CalculationResult _calculateTarrajeoMaterials(List<Tarrajeo> tarrajeos) {
    double totalArea = 0.0;

    final measurements = tarrajeos.map((tarrajeo) {
      double area = _calcularAreaTarrajeo(tarrajeo);
      totalArea += area;
      return MeasurementData(
        description: tarrajeo.description,
        value: area,
        unit: 'm²',
      );
    }).toList();

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: (totalArea * 0.15).ceil().toString()),
      Material(description: 'Arena fina', unit: 'm³', quantity: (totalArea * 0.025).toStringAsFixed(2)),
      Material(description: 'Agua', unit: 'm³', quantity: (totalArea * 0.006).toStringAsFixed(2)),
    ];

    return CalculationResult(
      type: CalculationType.tarrajeo,
      materials: materials,
      measurements: measurements,
      totalValue: totalArea,
      totalUnit: 'm²',
    );
  }

  static double _calcularAreaTarrajeo(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!) ?? 0.0;
    } else {
      double longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
      double ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
      return longitud * ancho;
    }
  }

  /// Cálculos para columnas
  static CalculationResult _calculateColumnaMaterials(List<Columna> columnas) {
    double totalVolumen = 0.0;

    final measurements = columnas.map((columna) {
      double volumen = _calcularVolumenColumna(columna);
      totalVolumen += volumen;
      return MeasurementData(
        description: columna.description,
        value: volumen,
        unit: 'm³',
      );
    }).toList();

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: (totalVolumen * 8.5).ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: (totalVolumen * 0.5).toStringAsFixed(2)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: (totalVolumen * 0.8).toStringAsFixed(2)),
      Material(description: 'Acero', unit: 'kg', quantity: (totalVolumen * 120).toStringAsFixed(2)),
    ];

    return CalculationResult(
      type: CalculationType.columna,
      materials: materials,
      measurements: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
    );
  }

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

  /// Cálculos para vigas
  static CalculationResult _calculateVigaMaterials(List<Viga> vigas) {
    double totalVolumen = 0.0;

    final measurements = vigas.map((viga) {
      double volumen = _calcularVolumenViga(viga);
      totalVolumen += volumen;
      return MeasurementData(
        description: viga.description,
        value: volumen,
        unit: 'm³',
      );
    }).toList();

    final materials = <Material>[
      Material(description: 'Cemento', unit: 'bls', quantity: (totalVolumen * 8.5).ceil().toString()),
      Material(description: 'Arena gruesa', unit: 'm³', quantity: (totalVolumen * 0.45).toStringAsFixed(2)),
      Material(description: 'Piedra chancada', unit: 'm³', quantity: (totalVolumen * 0.75).toStringAsFixed(2)),
      Material(description: 'Acero', unit: 'kg', quantity: (totalVolumen * 100).toStringAsFixed(2)),
    ];

    return CalculationResult(
      type: CalculationType.viga,
      materials: materials,
      measurements: measurements,
      totalValue: totalVolumen,
      totalUnit: 'm³',
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'type': type.displayName,
      'materials': materials.map((m) => m.toJson()).toList(),
      'measurements': measurements.map((m) => m.toJson()).toList(),
      'totalValue': totalValue,
      'totalUnit': totalUnit,
      'additionalInfo': additionalInfo,
      'errorMessage': errorMessage,
    };
  }
}