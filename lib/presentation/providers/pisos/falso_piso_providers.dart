import 'package:meter_app/domain/services/piso_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../data/models/models.dart';

part 'falso_piso_providers.g.dart';

@riverpod
class FalsoPisoResult extends _$FalsoPisoResult {
  final PisoService _pisoService = PisoService();

  @override
  List<Piso> build() => [];

  void createFalsoPiso(
      String description,
      String factorDesperdicio,
      String espesor, {
        String? resistencia,
        String? largo,
        String? ancho,
        String? area,
      }) {
    final newPiso = Piso(
      idPiso: uuid.v4(),
      description: description,
      tipo: 'falso', // Tipo fijo para falso piso
      factorDesperdicio: factorDesperdicio,
      espesor: espesor,
      resistencia: resistencia,
      largo: largo,
      ancho: ancho,
      area: area,
    );

    if (!_pisoService.esValido(newPiso)) {
      throw Exception("El falso piso debe tener largo y ancho o área definida.");
    }

    state = [...state, newPiso];
  }

  void clearList() {
    state = [];
  }
}

@riverpod
List<double> areaFalsoPiso(AreaFalsoPisoRef ref) {  // ✅ Cambio: volumenFalsoPiso → areaFalsoPiso
  final pisoService = PisoService();
  final falsosPisos = ref.watch(falsoPisoResultProvider);

  return falsosPisos.map((piso) => pisoService.calcularArea(piso) ?? 0.0).toList();  // ✅ Cambio: calcularVolumen → calcularArea
}

@riverpod
List<String> descriptionFalsoPiso(DescriptionFalsoPisoRef ref) {
  final falsosPisos = ref.watch(falsoPisoResultProvider);
  return falsosPisos.map((e) => e.description).toList();
}

@riverpod
String datosShareFalsoPiso(DatosShareFalsoPisoRef ref) {
  final description = ref.watch(descriptionFalsoPisoProvider);
  final areas = ref.watch(areaFalsoPisoProvider);  // ✅ Cambio: volumenFalsoPiso → areaFalsoPiso

  String datos = "";
  if (description.length == areas.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${areas[i].toStringAsFixed(1)} m²\n";  // ✅ Cambio: m³ → m²
    }
    datos = datos.substring(0, datos.length - 2);
  }
  return datos;
}

// 🆕 AGREGAR nuevo provider para área total
@riverpod
double areaTotalFalsoPiso(AreaTotalFalsoPisoRef ref) {
  final areas = ref.watch(areaFalsoPisoProvider);
  return areas.fold(0.0, (sum, area) => sum + area);
}

/// Provider para configuración de falso piso
@riverpod
class FalsoPisoConfig extends _$FalsoPisoConfig {
  @override
  FalsoPisoConfiguration build() => const FalsoPisoConfiguration();

  void updateEspesor(String espesor) {
    state = state.copyWith(espesor: espesor);
  }

  void updateResistencia(String resistencia) {
    state = state.copyWith(resistencia: resistencia);
  }

  void updateDesperdicio(String desperdicio) {
    state = state.copyWith(factorDesperdicio: desperdicio);
  }
}

/// Clase de configuración para falso piso
class FalsoPisoConfiguration {
  final String espesor;
  final String resistencia;
  final String factorDesperdicio;

  const FalsoPisoConfiguration({
    this.espesor = "5",
    this.resistencia = "175",
    this.factorDesperdicio = "5",
  });

  FalsoPisoConfiguration copyWith({
    String? espesor,
    String? resistencia,
    String? factorDesperdicio,
  }) {
    return FalsoPisoConfiguration(
      espesor: espesor ?? this.espesor,
      resistencia: resistencia ?? this.resistencia,
      factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    );
  }
}

/// Provider para cálculos de materiales usando la lógica del Excel (líneas 15-226)
@riverpod
FalsoPisoMaterials falsoPisoMaterials(FalsoPisoMaterialsRef ref) {
  final falsosPisos = ref.watch(falsoPisoResultProvider);

  if (falsosPisos.isEmpty) {
    return const FalsoPisoMaterials();
  }

  return _calcularMaterialesFalsoPiso(falsosPisos);
}

/// Función auxiliar para calcular materiales basada en el Excel
FalsoPisoMaterials _calcularMaterialesFalsoPiso(List<Piso> pisos) {
  // 🔥 FACTORES CORREGIDOS - EXACTOS DEL EXCEL (líneas 15-226)
  const Map<String, Map<String, double>> factoresConcreto = {
    '140': {
      'cemento': 7.01,  // ✅ Era 7.0, ahora 7.01
      'arena': 0.56,    // ✅ Era 0.54, ahora 0.56
      'piedra': 0.64,   // ✅ Era 0.55, ahora 0.64
      'agua': 0.184,    // ✅ Era 0.185, ahora 0.184
    },
    '175': {
      'cemento': 8.43,  // ✅ Correcto
      'arena': 0.54,    // ✅ Correcto
      'piedra': 0.55,   // ✅ Correcto
      'agua': 0.185,    // ✅ Correcto
    },
    '210': {
      'cemento': 9.73,  // ✅ Correcto
      'arena': 0.52,    // ✅ Correcto
      'piedra': 0.53,   // ✅ Correcto
      'agua': 0.186,    // ✅ Correcto
    },
    '245': {
      'cemento': 11.50, // ✅ Era 11.5, ahora 11.50
      'arena': 0.50,    // ✅ Era 0.5, ahora 0.50
      'piedra': 0.51,   // ✅ Correcto
      'agua': 0.187,    // ✅ Correcto
    },
    // 🆕 NUEVA RESISTENCIA - FALTABA EN TU CÓDIGO
    '280': {
      'cemento': 13.34, // 🆕 Nueva
      'arena': 0.45,    // 🆕 Nueva
      'piedra': 0.51,   // 🆕 Nueva
      'agua': 0.189,    // 🆕 Nueva
    },
  };

  double cementoTotal = 0.0;
  double arenaTotal = 0.0;
  double piedraTotal = 0.0;
  double aguaTotal = 0.0;
  double volumenTotal = 0.0;
  double areaTotalCalculada = 0.0;

  for (var piso in pisos) {
    // Obtener valores del piso
    final resistenciaStr = _extractResistenciaValue(piso.resistencia ?? '175 kg/cm²');
    final espesor = double.tryParse(piso.espesor) ?? 5.0;
    final desperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0;

    // Obtener factores de la resistencia
    final factores = factoresConcreto[resistenciaStr] ?? factoresConcreto['175']!;

    // Calcular área
    final area = _obtenerAreaFalsoPiso(piso);
    areaTotalCalculada += area;  // 🆕 SUMA área total

    // Calcular volumen de concreto
    final volumen = area * (espesor / 100); // convertir cm a metros

    // Calcular materiales con desperdicio
    final cemento = factores['cemento']! * volumen * (1 + desperdicio);
    final arena = factores['arena']! * volumen * (1 + desperdicio);
    final piedra = factores['piedra']! * volumen * (1 + desperdicio);
    final agua = factores['agua']! * volumen * (1 + desperdicio);

    // Sumar a totales
    cementoTotal += cemento;
    arenaTotal += arena;
    piedraTotal += piedra;
    aguaTotal += agua;
    volumenTotal += volumen;
  }

  return FalsoPisoMaterials(
    cemento: cementoTotal,
    arena: arenaTotal,
    piedra: piedraTotal,
    agua: aguaTotal,
    volumenTotal: volumenTotal,
    areaTotal: areaTotalCalculada,
  );
}

/// Extrae el valor numérico de la resistencia del formato "175 kg/cm²"
String _extractResistenciaValue(String resistencia) {
  // Extrae solo los números de la resistencia
  final match = RegExp(r'\d+').firstMatch(resistencia);
  final valor = match?.group(0) ?? '175';

  // ✅ Validar que la resistencia exista en la tabla (incluye 280)
  const resistenciasValidas = ['140', '175', '210', '245', '280'];
  if (!resistenciasValidas.contains(valor)) {
    return '175'; // Valor por defecto
  }

  return valor;
}

double _obtenerAreaFalsoPiso(Piso piso) {
  if (piso.area != null && piso.area!.isNotEmpty) {
    return double.tryParse(piso.area!) ?? 0.0;
  } else {
    final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
    final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
    return largo * ancho;
  }
}

/// Clase para almacenar materiales calculados de falso piso
class FalsoPisoMaterials {
  final double cemento;
  final double arena;
  final double piedra;
  final double agua;
  final double volumenTotal;  // Mantener para cálculos internos
  final double areaTotal;     // 🆕 NUEVA propiedad

  const FalsoPisoMaterials({
    this.cemento = 0.0,
    this.arena = 0.0,
    this.piedra = 0.0,
    this.agua = 0.0,
    this.volumenTotal = 0.0,
    this.areaTotal = 0.0,       // 🆕 NUEVA propiedad
  });

  FalsoPisoMaterials copyWith({
    double? cemento,
    double? arena,
    double? piedra,
    double? agua,
    double? volumenTotal,
    double? areaTotal,          // 🆕 NUEVA propiedad
  }) {
    return FalsoPisoMaterials(
      cemento: cemento ?? this.cemento,
      arena: arena ?? this.arena,
      piedra: piedra ?? this.piedra,
      agua: agua ?? this.agua,
      volumenTotal: volumenTotal ?? this.volumenTotal,
      areaTotal: areaTotal ?? this.areaTotal,  // 🆕 NUEVA propiedad
    );
  }

  /// Formatear cemento como entero (bolsas)
  int get cementoBolsas => cemento.ceil();

  /// Formatear materiales con 1 decimal
  String get arenaFormateada => arena.toStringAsFixed(1);
  String get piedraFormateada => piedra.toStringAsFixed(1);
  String get aguaFormateada => agua.toStringAsFixed(1);
  String get volumenFormateado => volumenTotal.toStringAsFixed(1);
  String get areaTotalFormateada => areaTotal.toStringAsFixed(1);  // 🆕 NUEVO método

  @override
  String toString() {
    return 'FalsoPisoMaterials('
        'cemento: $cementoBolsas bolsas, '
        'arena: $arenaFormateada m³, '
        'piedra: $piedraFormateada m³, '
        'agua: $aguaFormateada m³, '
        'volumen: $volumenFormateado m³, '
        'área total: $areaTotalFormateada m²)';  // 🆕 NUEVO en toString
  }
}