import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../data/models/models.dart';
import '../../../domain/services/ladrillo_service.dart';

part 'ladrillo_providers.g.dart';

@riverpod
class TipoLadrillo extends _$TipoLadrillo {
  @override
  String build() => '';

  void selectLadrillo(String name) {
    state = name;
  }
}

@riverpod
class LadrilloResult extends _$LadrilloResult {
  final LadrilloService _ladrilloService = LadrilloService();

  @override
  List<Ladrillo> build() => [];

  void createLadrillo(
      String description,
      String tipoLadrillo,
      String factor,
      String factorMortero,
      String proporcionMortero,
      String tipoAsentado, {
        String? largo,
        String? altura,
        String? area,
      }) {
    final newLadrillo = Ladrillo(
      idLadrillo: uuid.v4(),
      description: description,
      tipoLadrillo: tipoLadrillo,
      factorDesperdicio: factor,
      factorDesperdicioMortero: factorMortero,
      proporcionMortero: proporcionMortero,
      tipoAsentado: tipoAsentado,
      largo: largo,
      altura: altura,
      area: area,
    );

    if (!_ladrilloService.esValido(newLadrillo)) {
      throw Exception("El ladrillo debe tener largo y altura o área definida.");
    }

    state = [...state, newLadrillo];
  }

  void clearList() {
    state = [];
  }
}

@riverpod
List<double> areaLadrillo(AreaLadrilloRef ref) {
  final ladrilloService = LadrilloService();
  final ladrillos = ref.watch(ladrilloResultProvider);

  return ladrillos
      .map((ladrillo) => ladrilloService.calcularArea(ladrillo) ?? 0.0)
      .toList();
}

@riverpod
List<String> descriptionLadrillo(DescriptionLadrilloRef ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);
  return ladrillos.map((e) => e.description).toList();
}

@riverpod
String datosShareLadrillo(DatosShareLadrilloRef ref) {
  final description = ref.watch(descriptionLadrilloProvider);
  final area = ref.watch(areaLadrilloProvider);

  String datos = "";
  if (description.length == area.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${area[i].toStringAsFixed(2)} m²\n";
    }
    datos = datos.substring(0, datos.length - 2);
  }
  return datos;
}

/// Provider para configuración de ladrillo
@riverpod
class LadrilloConfig extends _$LadrilloConfig {
  @override
  LadrilloConfiguration build() => const LadrilloConfiguration();

  void updateFactorLadrillo(String factor) {
    state = state.copyWith(factorLadrillo: factor);
  }

  void updateFactorMortero(String factor) {
    state = state.copyWith(factorMortero: factor);
  }

  void updateProporcionMortero(String proporcion) {
    state = state.copyWith(proporcionMortero: proporcion);
  }

  void updateTipoAsentado(String tipo) {
    state = state.copyWith(tipoAsentado: tipo);
  }
}

/// Clase de configuración para ladrillo
class LadrilloConfiguration {
  final String factorLadrillo;
  final String factorMortero;
  final String proporcionMortero;
  final String tipoAsentado;

  const LadrilloConfiguration({
    this.factorLadrillo = "5",
    this.factorMortero = "10",
    this.proporcionMortero = "4",
    this.tipoAsentado = "soga",
  });

  LadrilloConfiguration copyWith({
    String? factorLadrillo,
    String? factorMortero,
    String? proporcionMortero,
    String? tipoAsentado,
  }) {
    return LadrilloConfiguration(
      factorLadrillo: factorLadrillo ?? this.factorLadrillo,
      factorMortero: factorMortero ?? this.factorMortero,
      proporcionMortero: proporcionMortero ?? this.proporcionMortero,
      tipoAsentado: tipoAsentado ?? this.tipoAsentado,
    );
  }
}

/// Provider principal para cálculos de materiales de ladrillo
@riverpod
LadrilloMaterials ladrilloMaterials(LadrilloMaterialsRef ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);

  if (ladrillos.isEmpty) {
    return const LadrilloMaterials();
  }

  return _calcularMaterialesLadrillo(ladrillos);
}

/// Función auxiliar para calcular materiales basada en el Excel mejorado
LadrilloMaterials _calcularMaterialesLadrillo(List<Ladrillo> ladrillos) {
  // Datos de tipos de ladrillos con sus dimensiones (en cm) - basado en el Excel
  const Map<String, Map<String, double>> tiposLadrillo = {
    'Pandereta': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
    'Pandereta1': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
    'Pandereta2': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
    'Kingkong': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
    'Kingkong1': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
    'Kingkong2': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
    'Común': {'largo': 24.0, 'ancho': 12.0, 'alto': 8.0},
  };

  // Proporciones de mortero con sus factores - basado en el Excel
  const Map<String, Map<String, double>> proporcionesMortero = {
    '3': {'cemento': 454.0, 'arena': 1.1, 'agua': 250.0},
    '4': {'cemento': 364.0, 'arena': 1.16, 'agua': 240.0},
    '5': {'cemento': 302.0, 'arena': 1.2, 'agua': 240.0},
    '6': {'cemento': 261.0, 'arena': 1.2, 'agua': 235.0},
  };

  double ladrillosTotal = 0.0;
  double cementoTotal = 0.0;
  double arenaTotal = 0.0;
  double aguaTotal = 0.0;
  double areaTotal = 0.0;

  for (var ladrillo in ladrillos) {
    final area = _obtenerAreaLadrillo(ladrillo);
    areaTotal += area;

    final factorDesperdicioLadrillo = (double.tryParse(ladrillo.factorDesperdicio) ?? 5.0) / 100;
    final factorDesperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

    final tipoLadrilloKey = _normalizarTipoLadrillo(ladrillo.tipoLadrillo);
    final dimensiones = tiposLadrillo[tipoLadrilloKey] ?? tiposLadrillo['Pandereta']!;

    final largo = dimensiones['largo']!;
    final ancho = dimensiones['ancho']!;
    final alto = dimensiones['alto']!;

    // Cálculo de ladrillos por m² según forma de asentado
    double ladrillosPorM2;
    double volumenMorteroM3PorM2;
    double espesorMuro;

    if (ladrillo.tipoAsentado == 'soga') {
      ladrillosPorM2 = 1 / ((((largo + 1.5) / 100) * ((alto + 1.5) / 100)));
      espesorMuro = ancho / 100; // ancho del ladrillo en metros
    } else if (ladrillo.tipoAsentado == 'cabeza') {
      ladrillosPorM2 = 1 / ((((ancho + 1.5) / 100) * ((alto + 1.5) / 100)));
      espesorMuro = largo / 100; // largo del ladrillo en metros
    } else { // canto
      ladrillosPorM2 = 1 / ((((largo + 1.5) / 100) * ((ancho + 1.5) / 100)));
      espesorMuro = alto / 100; // alto del ladrillo en metros
    }

    // Volumen del ladrillo individual en metros
    final volumenLadrillo = (largo / 100) * (ancho / 100) * (alto / 100);

    // Volumen de mortero por m² = Volumen bruto - Volumen ocupado por ladrillos
    volumenMorteroM3PorM2 = (1.0 * 1.0 * espesorMuro) - (ladrillosPorM2 * volumenLadrillo);

    // Aplicar factor de desperdicio de ladrillo
    final ladrillosPorM2ConDesperdicio = ladrillosPorM2 * (1 + factorDesperdicioLadrillo);
    ladrillosTotal += ladrillosPorM2ConDesperdicio * area;

    // Cálculo de materiales de mortero
    final proporcionStr = ladrillo.proporcionMortero;
    final datosProporcion = proporcionesMortero[proporcionStr] ?? proporcionesMortero['4']!;

    // Volumen de mortero para este ladrillo
    final volumenMortero = volumenMorteroM3PorM2 * area;

    // Factor cemento (bolsas por m³ de mortero)
    final factorCemento = datosProporcion['cemento']! / 42.5; // 42.5 kg por bolsa

    // Cálculo de materiales con desperdicio de mortero
    final cementoSinDesperdicio = factorCemento * volumenMortero;
    final arenaSinDesperdicio = datosProporcion['arena']! * volumenMortero;
    final aguaSinDesperdicio = ((factorCemento * (42.5 * 0.8)) / 1000) * volumenMortero;

    cementoTotal += cementoSinDesperdicio * (1 + factorDesperdicioMortero);
    arenaTotal += arenaSinDesperdicio * (1 + factorDesperdicioMortero);
    aguaTotal += aguaSinDesperdicio * (1 + factorDesperdicioMortero);
  }

  return LadrilloMaterials(
    ladrillos: ladrillosTotal,
    cemento: cementoTotal,
    arena: arenaTotal,
    agua: aguaTotal,
    areaTotal: areaTotal,
  );
}

/// Función auxiliar para normalizar el tipo de ladrillo
String _normalizarTipoLadrillo(String tipo) {
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
    case 'común':
    case 'comun':
      return 'Común';
    default:
      return 'Pandereta';
  }
}

/// Función auxiliar para obtener el área de un ladrillo
double _obtenerAreaLadrillo(Ladrillo ladrillo) {
  if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
    return double.tryParse(ladrillo.area!) ?? 0.0;
  } else {
    final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
    final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
    return largo * altura;
  }
}

/// Clase para almacenar materiales calculados de ladrillo
class LadrilloMaterials {
  final double ladrillos;
  final double cemento;
  final double arena;
  final double agua;
  final double areaTotal;

  const LadrilloMaterials({
    this.ladrillos = 0.0,
    this.cemento = 0.0,
    this.arena = 0.0,
    this.agua = 0.0,
    this.areaTotal = 0.0,
  });

  LadrilloMaterials copyWith({
    double? ladrillos,
    double? cemento,
    double? arena,
    double? agua,
    double? areaTotal,
  }) {
    return LadrilloMaterials(
      ladrillos: ladrillos ?? this.ladrillos,
      cemento: cemento ?? this.cemento,
      arena: arena ?? this.arena,
      agua: agua ?? this.agua,
      areaTotal: areaTotal ?? this.areaTotal,
    );
  }

  /// Convierte a Map para facilitar el uso
  Map<String, dynamic> toMap() {
    return {
      'ladrillos': ladrillos,
      'cemento': cemento,
      'arena': arena,
      'agua': agua,
      'areaTotal': areaTotal,
    };
  }

  /// Obtiene materiales como lista de strings formateados
  List<String> toFormattedList() {
    return [
      'Ladrillos: ${ladrillos.toStringAsFixed(0)} und',
      'Cemento: ${cemento.ceil()} bls',
      'Arena gruesa: ${arena.toStringAsFixed(2)} m³',
      'Agua: ${agua.toStringAsFixed(2)} m³',
    ];
  }

  /// Obtiene string para compartir
  String toShareString(String datosMetrado) {
    return '''DATOS METRADO
$datosMetrado
-------------
LISTA DE MATERIALES
*Ladrillos: ${ladrillos.toStringAsFixed(0)} und
*Cemento: ${cemento.ceil()} bls
*Arena gruesa: ${arena.toStringAsFixed(2)} m³
*Agua: ${agua.toStringAsFixed(2)} m³''';
  }

  /// Obtiene información de configuración para mostrar
  String getConfigInfo(List<Ladrillo> ladrillos) {
    if (ladrillos.isEmpty) return '';

    final primerLadrillo = ladrillos.first;
    final desperdicioLadrillo = double.tryParse(primerLadrillo.factorDesperdicio) ?? 5.0;
    final desperdicioMortero = double.tryParse(primerLadrillo.factorDesperdicioMortero) ?? 10.0;

    return '''
*Desperdicio Ladrillo: ${desperdicioLadrillo.toStringAsFixed(1)}%
*Desperdicio Mortero: ${desperdicioMortero.toStringAsFixed(1)}%''';
  }

  @override
  String toString() {
    return 'LadrilloMaterials(ladrillos: $ladrillos, cemento: $cemento, arena: $arena, agua: $agua, area: $areaTotal)';
  }
}