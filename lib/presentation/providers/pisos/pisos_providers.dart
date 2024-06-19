
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../data/models/models.dart';

part 'pisos_providers.g.dart';

@riverpod
class TipoPiso extends _$TipoPiso {
  @override
  String build() => '';

  void selectPiso(String name) {
    state = name;
  }
}

@riverpod
class CantidadArenaPisos extends _$CantidadArenaPisos {
  @override
  String build() => '';

  void arena(String name) {
    state = name;
  }
}

@riverpod
class CantidadCementoPisos extends _$CantidadCementoPisos {
  @override
  String build() => '';

  void cemento(String name) {
    state = name;
  }
}

@riverpod
class CantidadPiedraChancada extends _$CantidadPiedraChancada {
  @override
  String build() => '';

  void piedra(String name) {
    state = name;
  }
}

@riverpod
class PisosResult extends _$PisosResult {
  @override
  List<Piso> build() => [];

  void createPisos(
      String tipo,
      String description,
      String largo,
      String ancho,
      String altura,
      ) {
    state = [
      ...state, Piso(idPiso: uuid.v4(), tipo: tipo, description: description, largo: largo, ancho: ancho, altura: altura)
    ];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
List<double> volumenPiso(VolumenPisoRef ref) {
  final pisos = ref.watch( pisosResultProvider );

  return pisos.map((e) => double.parse(e.largo) * double.parse(e.altura) * double.parse(e.ancho)).toList();
}

@riverpod
List<String> descriptionPiso(DescriptionPisoRef ref) {
  final pisos = ref.watch( pisosResultProvider );

  return pisos.map((e) => e.description).toList();
}

@riverpod
String datosSharePisos(DatosSharePisosRef ref) {
  final description = ref.watch(descriptionPisoProvider);
  final volumen = ref.watch(volumenPisoProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++ ) {
      datos += "* ${description[i]}: ${volumen[i]} m3\n";
    }
    datos = datos.substring(0,datos.length -2);
  }
  return datos;
}

@riverpod
class AddPiso1 extends _$AddPiso1 {
  @override
  bool build() => true;

  void toggleAddPiso() {
    state = !state;
  }
}

@riverpod
class AddPiso2 extends _$AddPiso2 {
  @override
  bool build() => true;

  void toggleAddPiso() {
    state = !state;
  }
}

@riverpod
class AddPiso3 extends _$AddPiso3 {
  @override
  bool build() => true;

  void toggleAddPiso() {
    state = !state;
  }
}

@riverpod
class AddPiso4 extends _$AddPiso4 {
  @override
  bool build() => true;

  void toggleAddPiso() {
    state = !state;
  }
}

@riverpod
class AddPiso5 extends _$AddPiso5 {
  @override
  bool build() => true;

  void toggleAddPiso() {
    state = !state;
  }
}

@riverpod
class AddPiso6 extends _$AddPiso6 {
  @override
  bool build() => true;

  void toggleAddPiso() {
    state = !state;
  }
}

@riverpod
class AddPiso7 extends _$AddPiso7 {
  @override
  bool build() => true;

  void toggleAddPiso() {
    state = !state;
  }
}