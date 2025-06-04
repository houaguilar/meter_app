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
List<double> volumenFalsoPiso(VolumenFalsoPisoRef ref) {
  final pisoService = PisoService();
  final falsosPisos = ref.watch(falsoPisoResultProvider);

  return falsosPisos.map((piso) => pisoService.calcularVolumen(piso) ?? 0.0).toList();
}

@riverpod
List<String> descriptionFalsoPiso(DescriptionFalsoPisoRef ref) {
  final falsosPisos = ref.watch(falsoPisoResultProvider);
  return falsosPisos.map((e) => e.description).toList();
}

@riverpod
String datosShareFalsoPiso(DatosShareFalsoPisoRef ref) {
  final description = ref.watch(descriptionFalsoPisoProvider);
  final volumen = ref.watch(volumenFalsoPisoProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(2)} m³\n";
    }
    datos = datos.substring(0, datos.length - 2);
  }
  return datos;
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
  // Factores basados en el Excel (líneas 15-226) - resistencia del concreto
  const Map<String, Map<String, double>> factoresConcreto = {
    '140': {
      'cemento': 7.0,   // bolsas por m³
      'arena': 0.54,    // m³ por m³
      'piedra': 0.55,   // m³ por m³
      'agua': 0.185,    // m³ por m³
    },
    '175': {
      'cemento': 8.43,  // bolsas por m³
      'arena': 0.54,    // m³ por m³
      'piedra': 0.55,   // m³ por m³
      'agua': 0.185,    // m³ por m³
    },
    '210': {
      'cemento': 9.73,  // bolsas por m³
      'arena': 0.52,    // m³ por m³
      'piedra': 0.53,   // m³ por m³
      'agua': 0.186,    // m³ por m³
    },
    '245': {
      'cemento': 11.5,  // bolsas por m³
      'arena': 0.5,     // m³ por m³
      'piedra': 0.51,   // m³ por m³
      'agua': 0.187,    // m³ por m³
    },
  };

  double cementoTotal = 0.0;
  double arenaTotal = 0.0;
  double piedraTotal = 0.0;
  double aguaTotal = 0.0;
  double volumenTotal = 0.0;

  for (var piso in pisos) {
    // Obtener valores del piso
    final resistenciaStr = _extractResistenciaValue(piso.resistencia ?? '175 kg/cm²');
    final espesor = double.tryParse(piso.espesor) ?? 5.0;
    final desperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0;

    // Obtener factores de la resistencia
    final factores = factoresConcreto[resistenciaStr] ?? factoresConcreto['175']!;

    // Calcular área
    final area = _obtenerAreaFalsoPiso(piso);

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
  );
}

/// Extrae el valor numérico de la resistencia del formato "175 kg/cm²"
String _extractResistenciaValue(String resistencia) {
  // Extrae solo los números de la resistencia
  final match = RegExp(r'\d+').firstMatch(resistencia);
  return match?.group(0) ?? '175';
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
  final double volumenTotal;

  const FalsoPisoMaterials({
    this.cemento = 0.0,
    this.arena = 0.0,
    this.piedra = 0.0,
    this.agua = 0.0,
    this.volumenTotal = 0.0,
  });

  FalsoPisoMaterials copyWith({
    double? cemento,
    double? arena,
    double? piedra,
    double? agua,
    double? volumenTotal,
  }) {
    return FalsoPisoMaterials(
      cemento: cemento ?? this.cemento,
      arena: arena ?? this.arena,
      piedra: piedra ?? this.piedra,
      agua: agua ?? this.agua,
      volumenTotal: volumenTotal ?? this.volumenTotal,
    );
  }

  /// Convierte a Map para facilitar el uso
  Map<String, dynamic> toMap() {
    return {
      'cemento': cemento,
      'arena': arena,
      'piedra': piedra,
      'agua': agua,
      'volumenTotal': volumenTotal,
    };
  }

  /// Obtiene materiales como lista de strings formateados
  List<String> toFormattedList() {
    return [
      'Cemento: ${cemento.ceil()} bls',
      'Arena gruesa: ${arena.toStringAsFixed(2)} m³',
      'Piedra chancada: ${piedra.toStringAsFixed(2)} m³',
      'Agua: ${agua.toStringAsFixed(2)} m³',
    ];
  }

  /// Obtiene string para compartir
  String toShareString() {
    return '''LISTA DE MATERIALES
*Cemento: ${cemento.ceil()} bls
*Arena gruesa: ${arena.toStringAsFixed(2)} m³
*Piedra chancada: ${piedra.toStringAsFixed(2)} m³
*Agua: ${agua.toStringAsFixed(2)} m³''';
  }

  @override
  String toString() {
    return 'FalsoPisoMaterials(cemento: $cemento, arena: $arena, piedra: $piedra, agua: $agua, volumen: $volumenTotal)';
  }
}