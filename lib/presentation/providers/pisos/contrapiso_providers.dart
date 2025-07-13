import 'package:meter_app/domain/services/piso_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../data/models/models.dart';

part 'contrapiso_providers.g.dart';

@riverpod
class ContrapisoResult extends _$ContrapisoResult {
  final PisoService _pisoService = PisoService();

  @override
  List<Piso> build() => [];

  void createContrapiso(
      String description,
      String factorDesperdicio,
      String espesor, {
        String? proporcionMortero,
        String? largo,
        String? ancho,
        String? area,
      }) {
    final newPiso = Piso(
      idPiso: uuid.v4(),
      description: description,
      tipo: 'contrapiso',
      factorDesperdicio: factorDesperdicio,
      espesor: espesor,
      proporcionMortero: proporcionMortero,
      largo: largo,
      ancho: ancho,
      area: area,
    );

    if (!_pisoService.esValido(newPiso)) {
      throw Exception("El contrapiso debe tener largo y ancho o área definida.");
    }

    state = [...state, newPiso];
  }

  void clearList() {
    state = [];
  }
}

// 🔄 CAMBIAR: De volumenContrapiso a areaContrapiso
@riverpod
List<double> areaContrapiso(AreaContrapisoRef ref) {
  final pisoService = PisoService();
  final contrapisos = ref.watch(contrapisoResultProvider);

  return contrapisos.map((piso) => pisoService.calcularArea(piso) ?? 0.0).toList();
}

@riverpod
List<String> descriptionContrapiso(DescriptionContrapisoRef ref) {
  final contrapisos = ref.watch(contrapisoResultProvider);
  return contrapisos.map((e) => e.description).toList();
}

// 🔄 ACTUALIZAR: datosShareContrapiso para usar áreas
@riverpod
String datosShareContrapiso(DatosShareContrapisoRef ref) {
  final description = ref.watch(descriptionContrapisoProvider);
  final areas = ref.watch(areaContrapisoProvider);  // ✅ Cambio aquí

  String datos = "";
  if (description.length == areas.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${areas[i].toStringAsFixed(2)} m²\n";  // ✅ m² en lugar de m³
    }
    datos = datos.substring(0, datos.length - 2);
  }
  return datos;
}

// 🆕 NUEVO: Provider para área total
@riverpod
double areaTotalContrapiso(AreaTotalContrapisoRef ref) {
  final areas = ref.watch(areaContrapisoProvider);
  return areas.fold(0.0, (sum, area) => sum + area);
}

/// Provider para configuración de contrapiso
@riverpod
class ContrapisoConfig extends _$ContrapisoConfig {
  @override
  ContrapisoConfiguration build() => const ContrapisoConfiguration();

  void updateEspesor(String espesor) {
    state = state.copyWith(espesor: espesor);
  }

  void updateProporcion(String proporcion) {
    state = state.copyWith(proporcionMortero: proporcion);
  }

  void updateDesperdicio(String desperdicio) {
    state = state.copyWith(factorDesperdicio: desperdicio);
  }
}

/// Clase de configuración para contrapiso
class ContrapisoConfiguration {
  final String espesor;
  final String proporcionMortero;
  final String factorDesperdicio;

  const ContrapisoConfiguration({
    this.espesor = "5",
    this.proporcionMortero = "5",
    this.factorDesperdicio = "5",
  });

  ContrapisoConfiguration copyWith({
    String? espesor,
    String? proporcionMortero,
    String? factorDesperdicio,
  }) {
    return ContrapisoConfiguration(
      espesor: espesor ?? this.espesor,
      proporcionMortero: proporcionMortero ?? this.proporcionMortero,
      factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    );
  }
}

// 🔄 ACTUALIZAR: Provider para materiales con área total
@riverpod
ContrapisoMaterials contrapisoMaterials(ContrapisoMaterialsRef ref) {
  final contrapisos = ref.watch(contrapisoResultProvider);

  if (contrapisos.isEmpty) {
    return const ContrapisoMaterials();
  }

  return _calcularMaterialesContrapiso(contrapisos);
}

/// Función auxiliar para calcular materiales
ContrapisoMaterials _calcularMaterialesContrapiso(List<Piso> pisos) {
  // Factores basados en el Excel (líneas 15-164)
  const Map<String, Map<String, double>> factoresMortero = {
    '3': {
      'cemento': 10.5, // bolsas por m³
      'arena': 0.95,   // m³ por m³
      'agua': 0.285,   // m³ por m³
    },
    '4': {
      'cemento': 8.9,  // bolsas por m³
      'arena': 1.0,    // m³ por m³
      'agua': 0.272,   // m³ por m³
    },
    '5': {
      'cemento': 7.4,  // bolsas por m³
      'arena': 1.05,   // m³ por m³
      'agua': 0.268,   // m³ por m³
    },
    '6': {
      'cemento': 6.3,  // bolsas por m³
      'arena': 1.08,   // m³ por m³
      'agua': 0.265,   // m³ por m³
    },
  };

  double cementoTotal = 0.0;
  double arenaTotal = 0.0;
  double aguaTotal = 0.0;
  double volumenTotal = 0.0;
  double areaTotalCalculada = 0.0;  // 🆕 NUEVO

  for (var piso in pisos) {
    final proporcion = piso.proporcionMortero ?? '5';
    final espesor = double.tryParse(piso.espesor) ?? 5.0;
    final desperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0;

    final factores = factoresMortero[proporcion] ?? factoresMortero['5']!;

    // Calcular área
    final area = _obtenerArea(piso);
    areaTotalCalculada += area;  // 🆕 Sumar área

    // Calcular volumen de mortero (para materiales)
    final volumen = area * (espesor / 100);

    // Calcular materiales con desperdicio
    final cemento = factores['cemento']! * volumen * (1 + desperdicio);
    final arena = factores['arena']! * volumen * (1 + desperdicio);
    final agua = factores['agua']! * volumen * (1 + desperdicio);

    // Sumar a totales
    cementoTotal += cemento;
    arenaTotal += arena;
    aguaTotal += agua;
    volumenTotal += volumen;
  }

  return ContrapisoMaterials(
    cemento: cementoTotal,
    arena: arenaTotal,
    agua: aguaTotal,
    volumenTotal: volumenTotal,
    areaTotal: areaTotalCalculada,  // 🆕 NUEVO
  );
}

double _obtenerArea(Piso piso) {
  if (piso.area != null && piso.area!.isNotEmpty) {
    return double.tryParse(piso.area!) ?? 0.0;
  } else {
    final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
    final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
    return largo * ancho;
  }
}

/// Clase para almacenar materiales calculados
class ContrapisoMaterials {
  final double cemento;
  final double arena;
  final double agua;
  final double volumenTotal;
  final double areaTotal;  // 🆕 NUEVO

  const ContrapisoMaterials({
    this.cemento = 0.0,
    this.arena = 0.0,
    this.agua = 0.0,
    this.volumenTotal = 0.0,
    this.areaTotal = 0.0,  // 🆕 NUEVO
  });

  ContrapisoMaterials copyWith({
    double? cemento,
    double? arena,
    double? agua,
    double? volumenTotal,
    double? areaTotal,  // 🆕 NUEVO
  }) {
    return ContrapisoMaterials(
      cemento: cemento ?? this.cemento,
      arena: arena ?? this.arena,
      agua: agua ?? this.agua,
      volumenTotal: volumenTotal ?? this.volumenTotal,
      areaTotal: areaTotal ?? this.areaTotal,  // 🆕 NUEVO
    );
  }

  // 🆕 MÉTODOS DE FORMATO (como en FalsoPisoMaterials)
  int get cementoBolsas => cemento.ceil();
  String get arenaFormateada => arena.toStringAsFixed(2);
  String get aguaFormateada => agua.toStringAsFixed(2);
  String get volumenFormateado => volumenTotal.toStringAsFixed(2);
  String get areaTotalFormateada => areaTotal.toStringAsFixed(2);  // 🆕 ESTE ERA EL MÉTODO FALTANTE

  // Métodos existentes mantenidos para compatibilidad
  Map<String, dynamic> toMap() {
    return {
      'cemento': cemento,
      'arena': arena,
      'agua': agua,
      'volumenTotal': volumenTotal,
      'areaTotal': areaTotal,  // 🆕 NUEVO
    };
  }

  List<String> toFormattedList() {
    return [
      'Cemento: ${cementoBolsas} bls',
      'Arena gruesa: ${arenaFormateada} m³',
      'Agua: ${aguaFormateada} m³',
    ];
  }

  @override
  String toString() {
    return 'ContrapisoMaterials(cemento: $cemento, arena: $arena, agua: $agua, volumen: $volumenTotal, area: $areaTotal)';
  }
}