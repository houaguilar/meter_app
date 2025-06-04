import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constants.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/services/tarrajeo_service.dart';

part 'tarrajeo_providers.g.dart';

@riverpod
class TipoTarrajeo extends _$TipoTarrajeo {
  @override
  String build() => '';

  void selectTarrajeo(String name) {
    state = name;
  }
}

@riverpod
class TarrajeoResult extends _$TarrajeoResult {
  final TarrajeoService _tarrajeoService = TarrajeoService();

  @override
  List<Tarrajeo> build() => [];

  void createTarrajeo(
      String tipo,
      String description,
      String factor,
      String proporcionMortero,
      String espesor, {
        String? longitud,
        String? ancho,
        String? area,
      }){
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
      throw Exception("El tarrajeo debe tener longitud y ancho o área definida.");
    }

    state = [...state, newTarrajeo];
  }

  void clearList() {
    state = [];
  }
}

// ===== NUEVOS PROVIDERS PARA CÁLCULOS =====

/// Calculadora de materiales para tarrajeo basada en las fórmulas del Excel
class TarrajeoCalculator {
  // Factores de materiales según proporción del mortero (basado en Excel líneas 15-164)
  static const Map<String, Map<String, double>> _factoresMortero = {
    "4": {
      'cemento': 8.9, // bolsas por m³
      'arena': 1.0, // m³ por m³
      'agua': 0.272, // m³ por m³
    },
    "5": {
      'cemento': 7.4, // bolsas por m³
      'arena': 1.05, // m³ por m³
      'agua': 0.268, // m³ por m³
    },
    "6": {
      'cemento': 6.13, // bolsas por m³
      'arena': 1.07, // m³ por m³
      'agua': 0.269, // m³ por m³
    },
  };

  /// Calcula el área de tarrajeo
  static double calcularAreaTarrajeo(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!) ?? 0.0;
    } else {
      double longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
      double ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
      return longitud * ancho;
    }
  }

  /// Calcula el volumen de mortero por m²
  static double calcularVolumenMorteroPorM2(double espesorCm) {
    return espesorCm / 100; // convertir cm a metros
  }

  /// Calcula el volumen total de mortero para un tarrajeo
  static double calcularVolumenMortero(Tarrajeo tarrajeo) {
    double area = calcularAreaTarrajeo(tarrajeo);
    double espesor = double.tryParse(tarrajeo.espesor) ?? 0.0;
    return area * calcularVolumenMorteroPorM2(espesor);
  }

  /// Calcula materiales para un tarrajeo individual
  static Map<String, double> calcularMaterialesIndividual(Tarrajeo tarrajeo) {
    double volumen = calcularVolumenMortero(tarrajeo);
    double factorDesperdicio = (double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0) / 100.0;

    // Obtener factores de la proporción seleccionada
    String proporcionStr = tarrajeo.proporcionMortero;
    Map<String, double> factores = _factoresMortero[proporcionStr] ?? _factoresMortero['4']!;

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

  /// Calcula materiales totales para una lista de tarrajeos
  static Map<String, double> calcularMaterialesTotales(List<Tarrajeo> tarrajeos) {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalAgua = 0.0;
    double totalVolumen = 0.0;

    for (var tarrajeo in tarrajeos) {
      Map<String, double> materiales = calcularMaterialesIndividual(tarrajeo);
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

/// Modelo para resultados de materiales
class TarrajeoMateriales {
  final double cemento;
  final double arena;
  final double agua;
  final double volumenTotal;

  const TarrajeoMateriales({
    required this.cemento,
    required this.arena,
    required this.agua,
    required this.volumenTotal,
  });

  // Getters para valores formateados
  String get cementoFormateado => cemento.ceil().toString();
  String get arenaFormateada => arena.toStringAsFixed(2);
  String get aguaFormateada => agua.toStringAsFixed(2);
  String get volumenFormateado => volumenTotal.toStringAsFixed(3);

  // Para compartir/PDF
  String get resumenTexto => '''
LISTA DE MATERIALES
*Cemento: $cementoFormateado bls
*Arena fina: $arenaFormateada m³
*Agua: $aguaFormateada m³

DATOS DEL METRADO
Volumen total de mortero: $volumenFormateado m³''';

  Map<String, dynamic> toJson() => {
    'cemento': cemento,
    'arena': arena,
    'agua': agua,
    'volumen_total': volumenTotal,
  };
}

/// Modelo para datos de metrado individuales
class TarrajeoMetrado {
  final String descripcion;
  final double volumen;
  final double area;

  const TarrajeoMetrado({
    required this.descripcion,
    required this.volumen,
    required this.area,
  });

  String get volumenFormateado => volumen.toStringAsFixed(3);
  String get areaFormateada => area.toStringAsFixed(2);
}

// ===== PROVIDERS REACTIVOS =====

/// Provider que calcula los materiales totales automáticamente
@riverpod
TarrajeoMateriales tarrajeoMateriales(TarrajeoMaterialesRef ref) {
  final tarrajeos = ref.watch(tarrajeoResultProvider);

  if (tarrajeos.isEmpty) {
    return const TarrajeoMateriales(
      cemento: 0.0,
      arena: 0.0,
      agua: 0.0,
      volumenTotal: 0.0,
    );
  }

  final resultados = TarrajeoCalculator.calcularMaterialesTotales(tarrajeos);

  return TarrajeoMateriales(
    cemento: resultados['cemento']!,
    arena: resultados['arena']!,
    agua: resultados['agua']!,
    volumenTotal: resultados['volumen']!,
  );
}

/// Provider que calcula los datos de metrado individuales
@riverpod
List<TarrajeoMetrado> tarrajeoMetrados(TarrajeoMetradosRef ref) {
  final tarrajeos = ref.watch(tarrajeoResultProvider);

  return tarrajeos.map((tarrajeo) {
    return TarrajeoMetrado(
      descripcion: tarrajeo.description,
      volumen: TarrajeoCalculator.calcularVolumenMortero(tarrajeo),
      area: TarrajeoCalculator.calcularAreaTarrajeo(tarrajeo),
    );
  }).toList();
}

/// Provider para el volumen total (backward compatibility)
@riverpod
List<double> volumenTarrajeo(VolumenTarrajeoRef ref) {
  final tarrajeos = ref.watch(tarrajeoResultProvider);
  return tarrajeos.map((tarrajeo) =>
      TarrajeoCalculator.calcularVolumenMortero(tarrajeo)
  ).toList();
}

/// Provider para las descripciones (backward compatibility)
@riverpod
List<String> descriptionTarrajeo(DescriptionTarrajeoRef ref) {
  final tarrajeo = ref.watch(tarrajeoResultProvider);
  return tarrajeo.map((e) => e.description).toList();
}

/// Provider para datos compartidos/PDF
@riverpod
String datosShareTarrajeo(DatosShareTarrajeoRef ref) {
  final metrados = ref.watch(tarrajeoMetradosProvider);

  if (metrados.isEmpty) return 'No hay datos disponibles.';

  String datos = "";
  for (int i = 0; i < metrados.length; i++) {
    datos += "* ${metrados[i].descripcion}: ${metrados[i].volumenFormateado} m³\n";
  }

  return datos.isNotEmpty ? datos.substring(0, datos.length - 1) : datos;
}

/// Provider para resumen completo (materiales + metrados)
@riverpod
String resumenCompleto(ResumenCompletoRef ref) {
  final materiales = ref.watch(tarrajeoMaterialesProvider);
  final datosShare = ref.watch(datosShareTarrajeoProvider);

  return '''
DATOS METRADO
$datosShare

-------------

${materiales.resumenTexto}''';
}

// ===== PROVIDERS PARA VALIDACIONES =====

/// Provider que verifica si hay datos válidos
@riverpod
bool hayDatosValidos(HayDatosValidosRef ref) {
  final tarrajeos = ref.watch(tarrajeoResultProvider);
  return tarrajeos.isNotEmpty && tarrajeos.every((t) =>
  t.description.isNotEmpty &&
      t.espesor.isNotEmpty &&
      t.proporcionMortero.isNotEmpty
  );
}

/// Provider que calcula estadísticas adicionales
@riverpod
Map<String, dynamic> estadisticasTarrajeo(EstadisticasTarrajeoRef ref) {
  final tarrajeos = ref.watch(tarrajeoResultProvider);
  final materiales = ref.watch(tarrajeoMaterialesProvider);

  if (tarrajeos.isEmpty) {
    return {
      'cantidad_medidas': 0,
      'area_total': 0.0,
      'espesor_promedio': 0.0,
      'proporcion_mas_usada': '',
    };
  }

  double areaTotal = tarrajeos.fold(0.0, (sum, t) =>
  sum + TarrajeoCalculator.calcularAreaTarrajeo(t)
  );

  double espesorPromedio = tarrajeos.fold(0.0, (sum, t) =>
  sum + (double.tryParse(t.espesor) ?? 0.0)
  ) / tarrajeos.length;

  // Encontrar proporción más usada
  Map<String, int> conteoProporcion = {};
  for (var t in tarrajeos) {
    conteoProporcion[t.proporcionMortero] =
        (conteoProporcion[t.proporcionMortero] ?? 0) + 1;
  }

  String proporcionMasUsada = conteoProporcion.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;

  return {
    'cantidad_medidas': tarrajeos.length,
    'area_total': areaTotal,
    'espesor_promedio': espesorPromedio,
    'proporcion_mas_usada': proporcionMasUsada,
    'volumen_total': materiales.volumenTotal,
  };
}