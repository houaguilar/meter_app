import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../config/utils/number_formatter.dart';
import '../../../data/models/models.dart';
import '../../../domain/entities/home/muro/tipo_ladrillo.dart' as enums;
import '../../../domain/services/ladrillo_service.dart';
import '../home/muro/custom_brick_providers.dart';

part 'ladrillo_providers.g.dart';

@Riverpod(keepAlive: true)
@riverpod
class TipoLadrilloNotifier extends _$TipoLadrilloNotifier {
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
    // ✅ NUEVO: Si es Custom, obtener dimensiones del provider
    double? brickLength;
    double? brickWidth;
    double? brickHeight;

    // ✅ Verificación case-insensitive para detectar custom bricks
    final isCustomBrick = tipoLadrillo.toLowerCase().contains('custom') ||
                          tipoLadrillo.toLowerCase().contains('personalizado');

    if (isCustomBrick) {
      try {
        final customConfig = ref.read(customBrickDimensionsProvider);
        brickLength = customConfig.length;
        brickWidth = customConfig.width;
        brickHeight = customConfig.height;
        print('✅ [createLadrillo] Tipo: "$tipoLadrillo" - Guardando dimensiones custom: ${brickLength}×${brickWidth}×${brickHeight} cm');
      } catch (e) {
        print('⚠️ [createLadrillo] Error obteniendo dimensiones custom para tipo "$tipoLadrillo": $e');
      }
    } else {
      print('ℹ️ [createLadrillo] Tipo: "$tipoLadrillo" - No es custom, dimensiones = null');
    }

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
      brickLength: brickLength,   // ✅ NUEVO
      brickWidth: brickWidth,      // ✅ NUEVO
      brickHeight: brickHeight,    // ✅ NUEVO
    );

    // 🔍 Log para debugging
    print('🏗️ [createLadrillo] Ladrillo creado:');
    print('   - Tipo: "$tipoLadrillo"');
    print('   - Descripción: "$description"');
    print('   - Dimensiones brick: ${brickLength ?? "null"}×${brickWidth ?? "null"}×${brickHeight ?? "null"} cm');

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
List<double> areaLadrillo(Ref ref) {
  final ladrilloService = LadrilloService();
  final ladrillos = ref.watch(ladrilloResultProvider);

  return ladrillos
      .map((ladrillo) => ladrilloService.calcularArea(ladrillo) ?? 0.0)
      .toList();
}

@riverpod
List<String> descriptionLadrillo(Ref ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);
  return ladrillos.map((e) => e.description).toList();
}

@riverpod
String datosShareLadrillo(Ref ref) {
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

/// Provider principal para cálculos de materiales de ladrillo - CORREGIDO 100% VALIDADO
@riverpod
LadrilloMaterials ladrilloMaterials(Ref ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);

  if (ladrillos.isEmpty) {
    return const LadrilloMaterials();
  }

  return _calcularMaterialesLadrillo(ladrillos, ref);
}

/// Función auxiliar para calcular materiales basada en el análisis 100% validado vs Excel
LadrilloMaterials _calcularMaterialesLadrillo(List<Ladrillo> ladrillos, Ref ref) {
  // NOTA: Las especificaciones ahora vienen del ENUM TipoLadrillo
  // No se usa más el Map hardcodeado

  // Factores EXACTOS validados contra Excel para TODAS las proporciones
  const Map<String, Map<String, double>> factoresMortero = {
    '3': {
      'cemento': 10.682353,        // bolsas por m³
      'arena': 1.10,               // m³ por m³
      'agua': 0.250000,            // m³ por m³
    },
    '4': {
      'cemento': 8.565,         // bolsas por m³
      'arena': 1.16,               // m³ por m³
      'agua': 0.291,            // m³ por m³
    },
    '5': {
      'cemento': 7.105882,         // bolsas por m³
      'arena': 1.20,               // m³ por m³
      'agua': 0.242,            // m³ por m³
    },
    '6': {
      'cemento': 6.141176,         // bolsas por m³
      'arena': 1.20,               // m³ por m³
      'agua': 0.235000,            // m³ por m³
    },
  };

  // Juntas FIJAS (no cambiables por el usuario)
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

    // Obtener dimensiones del tipo de ladrillo usando ENUM
    final tipoEnum = _obtenerTipoLadrilloEnum(ladrillo.tipoLadrillo);

    // ✅ Si es Custom Y tiene dimensiones guardadas, usarlas directamente
    final double largo;
    final double ancho;
    final double alto;

    if (tipoEnum == enums.TipoLadrillo.custom &&
        ladrillo.brickLength != null &&
        ladrillo.brickWidth != null &&
        ladrillo.brickHeight != null) {
      largo = ladrillo.brickLength!;
      ancho = ladrillo.brickWidth!;
      alto = ladrillo.brickHeight!;
      print('✅ [ladrilloMaterials] Custom brick - usando dimensiones guardadas: ${largo}×${ancho}×${alto} cm');
    } else {
      largo = tipoEnum.largo;
      ancho = tipoEnum.ancho;
      alto = tipoEnum.alto;
      if (tipoEnum == enums.TipoLadrillo.custom) {
        print('⚠️ [ladrilloMaterials] Custom brick PERO dimensiones son NULL!');
        print('   - tipoLadrillo: "${ladrillo.tipoLadrillo}"');
        print('   - brickLength: ${ladrillo.brickLength}');
        print('   - brickWidth: ${ladrillo.brickWidth}');
        print('   - brickHeight: ${ladrillo.brickHeight}');
        print('   - Fallback a enum: ${largo}×${ancho}×${alto} cm (esto causará resultados = 0)');
      }
    }
    print('  Forma asentado: "${ladrillo.tipoAsentado}"');
    print('---');

    // ALGORITMO VALIDADO: Determinar grosor del muro y dimensiones según forma
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

    // Calcular ladrillos por m² (FÓRMULA VALIDADA)
    final dim1ConJunta = (dim1 / 100) + (juntaHorizontal / 100);
    final dim2ConJunta = (dim2 / 100) + (juntaVertical / 100);
    final ladrillosPorM2 = 1.0 / (dim1ConJunta * dim2ConJunta);

    // Cantidad total de ladrillos con desperdicio
    final ladrillosParaEstaArea = ladrillosPorM2 * area * (1 + desperdicioLadrillo);
    ladrillosTotal += ladrillosParaEstaArea;

    // Calcular volumen de mortero (ALGORITMO VALIDADO)
    final volumenMuroPorM2 = grosorMuro / 100; // m³ por m²
    final volumenLadrilloUnitario = (largo * ancho * alto) / 1000000; // m³
    final morteroPorM2 = volumenMuroPorM2 - (ladrillosPorM2 * volumenLadrilloUnitario);
    final morteroParaEstaArea = morteroPorM2 * area * (1 + desperdicioMortero);

    // Calcular materiales del mortero según proporción seleccionada
    final proporcionStr = ladrillo.proporcionMortero;
    final factores = factoresMortero[proporcionStr] ?? factoresMortero['4']!; // Default a 1:4

    // Calcular materiales del mortero con factores validados
    cementoTotal += morteroParaEstaArea * factores['cemento']!;
    arenaTotal += morteroParaEstaArea * factores['arena']!;
    aguaTotal += morteroParaEstaArea * factores['agua']!;
  }

  return LadrilloMaterials(
    ladrillos: ladrillosTotal,
    cemento: cementoTotal,
    arena: arenaTotal,
    agua: aguaTotal,
    areaTotal: areaTotal,
  );
}

/// Obtiene el ENUM TipoLadrillo desde el nombre del tipo
enums.TipoLadrillo _obtenerTipoLadrilloEnum(String tipo) {
  // Intentar obtener desde el provider key primero
  final tipoFromKey = enums.TipoLadrillo.fromProviderKey(tipo);
  if (tipoFromKey != null) return tipoFromKey;

  // Intentar normalizar desde el nombre
  final tipoFromNombre = enums.TipoLadrillo.fromNombre(tipo);
  if (tipoFromNombre != null) return tipoFromNombre;

  // Default: Pandereta1
  return enums.TipoLadrillo.pandereta1;
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

  @override
  String toString() {
    return 'LadrilloMaterials(ladrillos: ${ladrillos.toStringAsFixed(0)}, cemento: ${cemento.toStringAsFixed(1)} bls, arena: ${arena.toStringAsFixed(1)} m³, agua: ${agua.toStringAsFixed(1)} m³, areaTotal: ${areaTotal.toStringAsFixed(1)} m²)';
  }

  /// Método para generar texto compartible
  String toShareString(String datosMetrado) {
    return '''
📋 CÁLCULO DE MATERIALES - MURO DE LADRILLOS

🏗️ METRADO:
$datosMetrado

📊 MATERIALES NECESARIOS:
• Ladrillos: ${ladrillos.toStringAsFixed(0)} und
• Cemento: ${cemento.toStringAsFixed(2)} bolsas
• Arena: ${formatResultValue(arena)} m³
• Agua: ${formatResultValue(agua)} m³

📐 ÁREA TOTAL: ${areaTotal.toStringAsFixed(2)} m²

''';
  }

  /// Método para obtener información de configuración
  String getConfigInfo(List<Ladrillo> ladrillos) {
    if (ladrillos.isEmpty) return '';

    final primerLadrillo = ladrillos.first;
    final desperdicioLadrillo = double.tryParse(primerLadrillo.factorDesperdicio) ?? 5.0;
    final desperdicioMortero = double.tryParse(primerLadrillo.factorDesperdicioMortero) ?? 10.0;

    return '''⚙️ CONFIGURACIÓN:
• Tipo de ladrillo: ${primerLadrillo.tipoLadrillo}
• Tipo de asentado: ${primerLadrillo.tipoAsentado}
• Proporción mortero: 1:${primerLadrillo.proporcionMortero}
• Desperdicio ladrillo: ${desperdicioLadrillo.toStringAsFixed(1)}%
• Desperdicio mortero: ${desperdicioMortero.toStringAsFixed(1)}%

📱 Generado con MetraShop
''';
  }
}

// NOTA: _obtenerDimensionesCustom() eliminada
// Ahora las dimensiones custom se obtienen directamente desde el ladrillo guardado
// (ladrillo.brickLength/Width/Height) o desde el ENUM TipoLadrillo