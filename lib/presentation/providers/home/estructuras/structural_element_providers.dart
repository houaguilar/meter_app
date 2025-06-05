// lib/presentation/providers/home/estructuras/structural_element_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/constants/constant.dart';
import '../../../../domain/entities/home/estructuras/columna/columna.dart';
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