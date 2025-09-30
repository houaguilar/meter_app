import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/constants/constant.dart';
import '../../../../domain/entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import '../../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../../domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import '../../../../domain/entities/home/estructuras/solado/solado.dart';
import '../../../../domain/entities/home/estructuras/structural_element.dart';
import '../../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../../presentation/assets/images.dart';

part 'structural_element_providers.g.dart';

final List<StructuralElement> _structuralElements = [
  StructuralElement(
    id: '1',
    name: 'Columna',
    image: AppImages.concretoImg,
    details: 'Las columnas son elementos estructurales verticales que transmiten cargas de compresión a la cimentación.',
  ),
  StructuralElement(
    id: '2',
    name: 'Viga',
    image: AppImages.concretoImg,
    details: 'Las vigas son elementos estructurales horizontales que soportan cargas transversales.',
  ),
  StructuralElement(
    id: '3',
    name: 'Zapata',
    image: AppImages.concretoImg,
    details: 'Las vigas son elementos estructurales horizontales que soportan cargas transversales.',
  ),
  StructuralElement(
    id: '4',
    name: 'Cimiento corrido',
    image: AppImages.concretoImg,
    details: 'Las vigas son elementos estructurales horizontales que soportan cargas transversales.',
  ),
  StructuralElement(
    id: '5',
    name: 'Sobrecimiento',
    image: AppImages.concretoImg,
    details: 'Elementos de concreto simple que conectan la cimentación con los muros.',
  ),
  StructuralElement(
    id: '6',
    name: 'Solado',
    image: AppImages.concretoImg,
    details: 'Capa de concreto simple que se coloca sobre el terreno como base.',
  ),
];

@riverpod
List<StructuralElement> structuralElements(StructuralElementsRef ref) {
  return _structuralElements;
}

@riverpod
class SelectedStructuralElement extends _$SelectedStructuralElement {
  @override
  StructuralElement? build() => null;

  void selectElement(StructuralElement element) {
    print('🏗️ Seleccionando elemento: ${element.name} (ID: ${element.id})');
    state = element;
  }

  void clearSelection() {
    print('🧹 Limpiando selección de elemento');
    state = null;
  }
}

// FIX: Cambiamos a StateProvider para mejor manejo del estado
final tipoStructuralElementProvider = StateProvider<String>((ref) {
  print('🔄 Inicializando TipoStructuralElement con valor vacío');
  return '';
});

// FIX: Agregamos un provider helper para debug
@riverpod
String currentStructuralElementType(CurrentStructuralElementTypeRef ref) {
  final tipo = ref.watch(tipoStructuralElementProvider);
  print('📋 Tipo actual observado: $tipo');
  return tipo;
}

// Factores de materiales según resistencia del concreto (líneas 15-80 del Excel)
const Map<String, Map<String, double>> factoresConcreto = {
  "175 kg/cm²": {
    "cemento": 8.43, // bolsas por m³
    "arenaGruesa": 0.54, // m³ por m³
    "piedraConcreto": 0.55, // m³ por m³
    "agua": 0.185, // m³ por m³
  },
  "210 kg/cm²": {
    "cemento": 9.73, // bolsas por m³
    "arenaGruesa": 0.52, // m³ por m³
    "piedraConcreto": 0.53, // m³ por m³
    "agua": 0.186, // m³ por m³
  },
  "245 kg/cm²": {
    "cemento": 11.5, // bolsas por m³
    "arenaGruesa": 0.5, // m³ por m³
    "piedraConcreto": 0.51, // m³ por m³
    "agua": 0.187, // m³ por m³
  },
};

// Helper function para calcular volumen de elementos estructurales
double calcularVolumenElemento(dynamic elemento) {
  // Caso especial para Solado
  if (elemento is Solado) {
    return calcularVolumenSolado(elemento);
  }

  // Lógica existente para otros elementos
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

// Helper function para aplicar desperdicio
double aplicarDesperdicio(double valor, String factorDesperdicio) {
  final desperdicio = double.tryParse(factorDesperdicio) ?? 5.0;
  return valor * (1 + (desperdicio / 100));
}

// Providers for Columna
@riverpod
class ColumnaResult extends _$ColumnaResult {
  @override
  List<Columna> build() => [];

  void createColumna(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newColumna = Columna(
      idColumna: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que la columna tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newColumna);
    if (volumenCalculado <= 0) {
      throw Exception("La columna debe tener largo, ancho y altura o volumen definidos.");
    }

    print('✅ Nueva columna creada: ${newColumna.description}, volumen: $volumenCalculado m³');
    state = [...state, newColumna];
  }

  void clearList() {
    print('🧹 Limpiando lista de columnas');
    state = [];
  }
}

@riverpod
List<double> volumenColumna(VolumenColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  final volumenes = columnas.map((columna) => calcularVolumenElemento(columna)).toList();
  print('📊 Volúmenes de columnas calculados: $volumenes');
  return volumenes;
}

@riverpod
List<String> descriptionColumna(DescriptionColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  return columnas.map((e) => e.description).toList();
}

@riverpod
String datosShareColumna(DatosShareColumnaRef ref) {
  final description = ref.watch(descriptionColumnaProvider);
  final volumen = ref.watch(volumenColumnaProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(2)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

// Providers para cálculos de materiales de Columna
@riverpod
double cantidadCementoColumna(CantidadCementoColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, columna.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  print('🧱 Cemento total para columnas: $cementoTotal');
  return cementoTotal;
}

@riverpod
double cantidadArenaColumna(CantidadArenaColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, columna.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
}

@riverpod
double cantidadPiedraColumna(CantidadPiedraColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraConcreto']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, columna.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
}

@riverpod
double cantidadAguaColumna(CantidadAguaColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, columna.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
}

// Providers for Viga
@riverpod
class VigaResult extends _$VigaResult {
  @override
  List<Viga> build() => [];

  void createViga(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newViga = Viga(
      idViga: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que la viga tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newViga);
    if (volumenCalculado <= 0) {
      throw Exception("La viga debe tener largo, ancho y altura o volumen definidos.");
    }

    print('✅ Nueva viga creada: ${newViga.description}, volumen: $volumenCalculado m³');
    state = [...state, newViga];
  }

  void clearList() {
    print('🧹 Limpiando lista de vigas');
    state = [];
  }
}

@riverpod
List<double> volumenViga(VolumenVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  final volumenes = vigas.map((viga) => calcularVolumenElemento(viga)).toList();
  print('📊 Volúmenes de vigas calculados: $volumenes');
  return volumenes;
}

@riverpod
List<String> descriptionViga(DescriptionVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  return vigas.map((e) => e.description).toList();
}

@riverpod
String datosShareViga(DatosShareVigaRef ref) {
  final description = ref.watch(descriptionVigaProvider);
  final volumen = ref.watch(volumenVigaProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(2)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

// Providers para cálculos de materiales de Viga
@riverpod
double cantidadCementoViga(CantidadCementoVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, viga.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  print('🧱 Cemento total para vigas: $cementoTotal');
  return cementoTotal;
}

@riverpod
double cantidadArenaViga(CantidadArenaVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, viga.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
}

@riverpod
double cantidadPiedraViga(CantidadPiedraVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraConcreto']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, viga.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
}

@riverpod
double cantidadAguaViga(CantidadAguaVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, viga.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
}


// Agregar al final de structural_element_providers.dart:

// Constantes específicas para Sobrecimiento (basadas en el Excel)
const Map<String, Map<String, double>> factoresSobrecimiento = {
  "175 kg/cm²": {
    "cemento": 8.43, // bolsas por m³
    "arenaGruesa": 0.45, // m³ por m³
    "piedraChancada": 0.40, // m³ por m³
    "piedraGrande": 0.25, // m³ por m³
    "agua": 0.139, // m³ por m³
  },
  "140 kg/cm²": {
    "cemento": 7.50,
    "arenaGruesa": 0.50,
    "piedraChancada": 0.45,
    "piedraGrande": 0.30,
    "agua": 0.145,
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

// Providers for Sobrecimiento
@riverpod
class SobrecimientoResult extends _$SobrecimientoResult {
  @override
  List<Sobrecimiento> build() => [];

  void createSobrecimiento(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newSobrecimiento = Sobrecimiento(
      idSobrecimiento: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que el sobrecimiento tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newSobrecimiento);
    if (volumenCalculado <= 0) {
      throw Exception("El sobrecimiento debe tener largo, ancho y altura o volumen definidos.");
    }

    print('✅ Nuevo sobrecimiento creado: ${newSobrecimiento.description}, volumen: $volumenCalculado m³');
    state = [...state, newSobrecimiento];
  }

  void clearList() {
    print('🧹 Limpiando lista de sobrecimientos');
    state = [];
  }
}

@riverpod
List<double> volumenSobrecimiento(VolumenSobrecimientoRef ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  final volumenes = sobrecimientos.map((sobrecimiento) => calcularVolumenElemento(sobrecimiento)).toList();
  print('📊 Volúmenes de sobrecimientos calculados: $volumenes');
  return volumenes;
}

@riverpod
List<String> descriptionSobrecimiento(DescriptionSobrecimientoRef ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  return sobrecimientos.map((e) => e.description).toList();
}

@riverpod
String datosShareSobrecimiento(DatosShareSobrecimientoRef ref) {
  final description = ref.watch(descriptionSobrecimientoProvider);
  final volumen = ref.watch(volumenSobrecimientoProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(2)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

// Providers para cálculos de materiales específicos del Sobrecimiento
@riverpod
double cantidadCementoSobrecimiento(CantidadCementoSobrecimientoRef ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, sobrecimiento.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  print('🧱 Cemento total para sobrecimientos: $cementoTotal');
  return cementoTotal;
}

@riverpod
double cantidadArenaSobrecimiento(CantidadArenaSobrecimientoRef ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, sobrecimiento.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
}

@riverpod
double cantidadPiedraChancadaSobrecimiento(CantidadPiedraChancadaSobrecimientoRef ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraChancada']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, sobrecimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
}

@riverpod
double cantidadPiedraGrandeSobrecimiento(CantidadPiedraGrandeSobrecimientoRef ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraGrande']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, sobrecimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
}

@riverpod
double cantidadAguaSobrecimiento(CantidadAguaSobrecimientoRef ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, sobrecimiento.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
}

// Agregar en structural_element_providers.dart:

// Constantes específicas para Cimiento Corrido (basadas en el Excel)
const Map<String, Map<String, double>> factoresCimientoCorrido = {
  "175 kg/cm²": {
    "cemento": 8.43,
    "arenaGruesa": 0.45,
    "piedraChancada": 0.35,
    "piedraZanja": 0.30,
    "agua": 0.139,
  },
  "140 kg/cm²": {
    "cemento": 7.50,
    "arenaGruesa": 0.50,
    "piedraChancada": 0.40,
    "piedraZanja": 0.35,
    "agua": 0.145,
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

// Providers for Cimiento Corrido
@riverpod
class CimientoCorridoResult extends _$CimientoCorridoResult {
  @override
  List<CimientoCorrido> build() => [];

  void createCimientoCorrido(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newCimientoCorrido = CimientoCorrido(
      idCimientoCorrido: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que el cimiento tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newCimientoCorrido);
    if (volumenCalculado <= 0) {
      throw Exception("El cimiento corrido debe tener largo, ancho y altura o volumen definidos.");
    }

    print('✅ Nuevo cimiento corrido creado: ${newCimientoCorrido.description}, volumen: $volumenCalculado m³');
    state = [...state, newCimientoCorrido];
  }

  void clearList() {
    print('🧹 Limpiando lista de cimientos corridos');
    state = [];
  }
}

@riverpod
List<double> volumenCimientoCorrido(VolumenCimientoCorridoRef ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  final volumenes = cimientos.map((cimiento) => calcularVolumenElemento(cimiento)).toList();
  print('📊 Volúmenes de cimientos corridos calculados: $volumenes');
  return volumenes;
}

@riverpod
List<String> descriptionCimientoCorrido(DescriptionCimientoCorridoRef ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  return cimientos.map((e) => e.description).toList();
}

@riverpod
String datosShareCimientoCorrido(DatosShareCimientoCorridoRef ref) {
  final description = ref.watch(descriptionCimientoCorridoProvider);
  final volumen = ref.watch(volumenCimientoCorridoProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(2)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

// Providers para cálculos de materiales específicos del Cimiento Corrido
@riverpod
double cantidadCementoCimientoCorrido(CantidadCementoCimientoCorridoRef ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, cimiento.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  print('🧱 Cemento total para cimientos corridos: $cementoTotal');
  return cementoTotal;
}

@riverpod
double cantidadArenaCimientoCorrido(CantidadArenaCimientoCorridoRef ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, cimiento.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
}

@riverpod
double cantidadPiedraChancadaCimientoCorrido(CantidadPiedraChancadaCimientoCorridoRef ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraChancada']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, cimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
}

@riverpod
double cantidadPiedraZanjaCimientoCorrido(CantidadPiedraZanjaCimientoCorridoRef ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraZanja']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, cimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
}

@riverpod
double cantidadAguaCimientoCorrido(CantidadAguaCimientoCorridoRef ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, cimiento.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
}


// Constantes específicas para Solado (basadas en el Excel)
const Map<String, Map<String, double>> factoresSolado = {
  "175 kg/cm²": {
    "cemento": 8.43,
    "arenaGruesa": 0.54,
    "piedraChancada": 0.55,
    "agua": 0.185,
  },
  "140 kg/cm²": {
    "cemento": 7.50,
    "arenaGruesa": 0.59,
    "piedraChancada": 0.60,
    "agua": 0.190,
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

// Helper function para calcular volumen de Solado
double calcularVolumenSolado(Solado solado) {
  // Para solado, el volumen siempre se calcula como: área × espesor_fijo
  if (solado.area != null && solado.area!.isNotEmpty) {
    final area = double.tryParse(solado.area!) ?? 0.0;
    return area * solado.espesorFijo;
  }

  if (solado.largo != null && solado.largo!.isNotEmpty &&
      solado.ancho != null && solado.ancho!.isNotEmpty) {
    final largo = double.tryParse(solado.largo!) ?? 0.0;
    final ancho = double.tryParse(solado.ancho!) ?? 0.0;
    final area = largo * ancho;
    return area * solado.espesorFijo;
  }

  return 0.0;
}

// Providers for Solado
@riverpod
class SoladoResult extends _$SoladoResult {
  @override
  List<Solado> build() => [];

  void createSolado(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? area,
      }) {
    final newSolado = Solado(
      idSolado: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      area: area,
      espesorFijo: 0.1, // Siempre 10 cm
    );

    // Validar que el solado tenga datos suficientes
    final volumenCalculado = calcularVolumenSolado(newSolado);
    if (volumenCalculado <= 0) {
      throw Exception("El solado debe tener área o largo y ancho definidos.");
    }

    print('✅ Nuevo solado creado: ${newSolado.description}, volumen: $volumenCalculado m³');
    state = [...state, newSolado];
  }

  void clearList() {
    print('🧹 Limpiando lista de solados');
    state = [];
  }
}

@riverpod
List<double> volumenSolado(VolumenSoladoRef ref) {
  final solados = ref.watch(soladoResultProvider);
  final volumenes = solados.map((solado) => calcularVolumenSolado(solado)).toList();
  print('📊 Volúmenes de solados calculados: $volumenes');
  return volumenes;
}

@riverpod
List<double> areaSolado(AreaSoladoRef ref) {
  final solados = ref.watch(soladoResultProvider);
  final areas = solados.map((solado) {
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
  }).toList();
  return areas;
}

@riverpod
List<String> descriptionSolado(DescriptionSoladoRef ref) {
  final solados = ref.watch(soladoResultProvider);
  return solados.map((e) => e.description).toList();
}

@riverpod
String datosShareSolado(DatosShareSoladoRef ref) {
  final description = ref.watch(descriptionSoladoProvider);
  final areas = ref.watch(areaSoladoProvider);

  String datos = "";
  if (description.length == areas.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${areas[i].toStringAsFixed(2)} m2\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

// Providers para cálculos de materiales específicos del Solado
@riverpod
double cantidadCementoSolado(CantidadCementoSoladoRef ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, solado.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  print('🧱 Cemento total para solados: $cementoTotal');
  return cementoTotal;
}

@riverpod
double cantidadArenaSolado(CantidadArenaSoladoRef ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, solado.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
}

@riverpod
double cantidadPiedraChancadaSolado(CantidadPiedraChancadaSoladoRef ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraChancada']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, solado.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
}

@riverpod
double cantidadAguaSolado(CantidadAguaSoladoRef ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, solado.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
}