import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/constants/constants.dart';
import '../../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../../domain/services/structural_element_service.dart';

part 'structural_providers.g.dart';

// Providers for Columna
@riverpod
class ColumnaResult extends _$ColumnaResult {
  final StructuralElementService _structuralElementService = StructuralElementService();

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

    if (!_structuralElementService.esValido(newColumna)) {
      throw Exception("La columna debe tener largo, ancho y altura o volumen definidos.");
    }

    state = [...state, newColumna];
  }

  void clearList() {
    state = [];
  }
}

@riverpod
List<double> volumenColumna(VolumenColumnaRef ref) {
  final structuralElementService = StructuralElementService();
  final columnas = ref.watch(columnaResultProvider);

  return columnas.map((columna) => structuralElementService.calcularVolumen(columna) ?? 0.0).toList();
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
      datos += "* ${description[i]}: ${volumen[i]} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

@riverpod
double cantidadCementoColumna(CantidadCementoColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularCementoColumna(columnas);
}

@riverpod
double cantidadArenaColumna(CantidadArenaColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularArenaColumna(columnas);
}

@riverpod
double cantidadPiedraColumna(CantidadPiedraColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularPiedraColumna(columnas);
}

@riverpod
double cantidadAguaColumna(CantidadAguaColumnaRef ref) {
  final columnas = ref.watch(columnaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularAguaColumna(columnas);
}

// Providers for Viga
@riverpod
class VigaResult extends _$VigaResult {
  final StructuralElementService _structuralElementService = StructuralElementService();

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

    if (!_structuralElementService.esValido(newViga)) {
      throw Exception("La viga debe tener largo, ancho y altura o volumen definidos.");
    }

    state = [...state, newViga];
  }

  void clearList() {
    state = [];
  }
}

@riverpod
List<double> volumenViga(VolumenVigaRef ref) {
  final structuralElementService = StructuralElementService();
  final vigas = ref.watch(vigaResultProvider);

  return vigas.map((viga) => structuralElementService.calcularVolumen(viga) ?? 0.0).toList();
}

@riverpod
List<String> descriptionViga(DescriptionVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  return vigas.map((e) => e.description).toList();
}

// lib/presentation/providers/structural/structural_providers.dart (continued)
@riverpod
String datosShareViga(DatosShareVigaRef ref) {
  final description = ref.watch(descriptionVigaProvider);
  final volumen = ref.watch(volumenVigaProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i]} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

@riverpod
double cantidadCementoViga(CantidadCementoVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularCementoViga(vigas);
}

@riverpod
double cantidadArenaViga(CantidadArenaVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularArenaViga(vigas);
}

@riverpod
double cantidadPiedraViga(CantidadPiedraVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularPiedraViga(vigas);
}

@riverpod
double cantidadAguaViga(CantidadAguaVigaRef ref) {
  final vigas = ref.watch(vigaResultProvider);
  final structuralElementService = StructuralElementService();
  return structuralElementService.calcularAguaViga(vigas);
}