import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constants.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/services/tarrajeo_service.dart';

part 'tarrajeo_derrame_providers.g.dart';

@riverpod
class TipoTarrajeoDerrrame extends _$TipoTarrajeoDerrrame {
  @override
  String build() => 'Tarrajeo Derrame';

  void selectTarrajeoDerrrame(String name) {
    state = name;
  }
}

@riverpod
class TarrajeoDerrameResult extends _$TarrajeoDerrameResult {
  final TarrajeoService _tarrajeoService = TarrajeoService();

  @override
  List<Tarrajeo> build() => [];

  void createTarrajeoDerrrame(
      String tipo,
      String description,
      String factor,
      String proporcionMortero,
      String espesor, {
        String? longitud,
        String? ancho,
        String? area,
      }) {
    final newTarrajeo = Tarrajeo(
      idCoating: uuid.v4(),
      description: description,
      tipo: tipo,
      factorDesperdicio: factor,
      proporcionMortero: proporcionMortero,
      espesor: espesor,
      longitud: longitud,
      ancho: ancho,
      area: area,
    );

    if (!_tarrajeoService.esValido(newTarrajeo)) {
      throw Exception("El tarrajeo derrame debe tener longitud y ancho o área definida.");
    }

    state = [...state, newTarrajeo];
  }

  void clearList() {
    state = [];
  }
}

// ===== NUEVOS PROVIDERS PARA CÁLCULOS ESPECÍFICOS DE DERRAME =====

/// Calculadora de materiales para tarrajeo derrame basada en las fórmulas del Excel
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
  static Map<String, double> calcularMaterialesIndividualDerrrame(Tarrajeo tarrajeo) {
    double volumen = calcularVolumenMorteroDerrrame(tarrajeo);
    double factorDesperdicio = (double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0) / 100.0;

    // Obtener factores de la proporción seleccionada
    String proporcionStr = tarrajeo.proporcionMortero;
    Map<String, double> factores = _factoresMorteroDerrrame[proporcionStr] ?? _factoresMorteroDerrrame['4']!;

    // Calcular materiales sin desperdicio
    double cementoSin = factores['cemento']! * volumen;
    double arenaSin = factores['arena']! * volumen;
    double aguaSin = factores['agua']! * volumen;

    // Aplicar factor de desperdicio
    double cemento = cementoSin * (1 + factorDesperdicio);
    double arena = arenaSin * (1 + factorDesperdicio);
    double agua = aguaSin * (1 + factorDesperdicio);

    return {
      'cemento': cemento,
      'arena': arena,
      'agua': agua,
      'volumen': volumen,
    };
  }

  /// Calcula materiales totales para una lista de tarrajeos derrame
  static Map<String, double> calcularMaterialesTotalesDerrrame(List<Tarrajeo> tarrajeos) {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalAgua = 0.0;
    double totalVolumen = 0.0;

    for (var tarrajeo in tarrajeos) {
      Map<String, double> materiales = calcularMaterialesIndividualDerrrame(tarrajeo);
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

/// Provider para materiales calculados de tarrajeo derrame
@riverpod
class TarrajeoDerrrameMateriales extends _$TarrajeoDerrrameMateriales {
  @override
  TarrajeoDerrrameMaterialesData build() {
    final tarrajeos = ref.watch(tarrajeoDerrameResultProvider);
    if (tarrajeos.isEmpty) {
      return TarrajeoDerrrameMaterialesData.empty();
    }

    final materialesCalculados = TarrajeoDerrameCalculator.calcularMaterialesTotalesDerrrame(tarrajeos);

    return TarrajeoDerrrameMaterialesData(
      cemento: materialesCalculados['cemento']!,
      arena: materialesCalculados['arena']!,
      agua: materialesCalculados['agua']!,
      volumen: materialesCalculados['volumen']!,
    );
  }
}

/// Provider para metrados de tarrajeo derrame
@riverpod
class TarrajeoDerrameMetrados extends _$TarrajeoDerrameMetrados {
  @override
  List<TarrajeoDerrameMetradoData> build() {
    final tarrajeos = ref.watch(tarrajeoDerrameResultProvider);

    return tarrajeos.map((tarrajeo) {
      final area = TarrajeoDerrameCalculator.calcularAreaTarrajeoDerrrame(tarrajeo);
      final volumen = TarrajeoDerrameCalculator.calcularVolumenMorteroDerrrame(tarrajeo);

      return TarrajeoDerrameMetradoData(
        descripcion: tarrajeo.description,
        area: area,
        volumen: volumen,
        espesor: double.tryParse(tarrajeo.espesor) ?? 0.0,
      );
    }).toList();
  }
}

// ===== CLASES DE DATOS =====

/// Clase para almacenar datos de materiales calculados de tarrajeo derrame
class TarrajeoDerrrameMaterialesData {
  final double cemento;
  final double arena;
  final double agua;
  final double volumen;

  TarrajeoDerrrameMaterialesData({
    required this.cemento,
    required this.arena,
    required this.agua,
    required this.volumen,
  });

  factory TarrajeoDerrrameMaterialesData.empty() {
    return TarrajeoDerrrameMaterialesData(
      cemento: 0.0,
      arena: 0.0,
      agua: 0.0,
      volumen: 0.0,
    );
  }

  // Getters formateados para UI
  String get cementoFormateado => cemento.toStringAsFixed(1);
  String get arenaFormateada => arena.toStringAsFixed(1);
  String get aguaFormateada => agua.toStringAsFixed(1);
  String get volumenFormateado => volumen.toStringAsFixed(1);
  String get areaTotalFormateada => "Calculada en metrados";
}

/// Clase para almacenar datos de metrado de tarrajeo derrame
class TarrajeoDerrameMetradoData {
  final String descripcion;
  final double area;
  final double volumen;
  final double espesor;

  TarrajeoDerrameMetradoData({
    required this.descripcion,
    required this.area,
    required this.volumen,
    required this.espesor,
  });

  // Getters formateados para UI
  String get areaFormateada => area.toStringAsFixed(1);
  String get volumenFormateado => volumen.toStringAsFixed(1);
  String get espesorFormateado => espesor.toStringAsFixed(1);
}