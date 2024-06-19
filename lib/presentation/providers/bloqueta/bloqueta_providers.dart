import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../data/models/models.dart';

part 'bloqueta_providers.g.dart';

@riverpod
class TipoBloqueta extends _$TipoBloqueta {
  @override
  String build() => '';

  void selectBloqueta(String name) {
    state = name;
  }
}

@riverpod
class CantidadArenaBloqueta extends _$CantidadArenaBloqueta {
  @override
  String build() => '';

  void arena(String name) {
    state = name;
  }
}

@riverpod
class CantidadCementoBloqueta extends _$CantidadCementoBloqueta {
  @override
  String build() => '';

  void cemento(String name) {
    state = name;
  }
}

@riverpod
class CantidadBloqueta extends _$CantidadBloqueta {
  @override
  String build() => '';

  void bloqueta(String name) {
    state = name;
  }
}

@riverpod
class BloquetaResult extends _$BloquetaResult {

  @override
  List<Bloqueta> build() => [];

  void createBloqueta(
      String description,
      String tipoBloqueta,
      String largo,
      String altura,
      ) {
    state = [
      ...state, Bloqueta(idBloqueta: uuid.v4(), description: description, tipoBloqueta: tipoBloqueta, largo: largo, altura: altura)
    ];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
List<double> areaBloqueta(AreaBloquetaRef ref) {
  final bloquetas = ref.watch( bloquetaResultProvider );

 // if (bloquetas.isNotEmpty) {
    return bloquetas.map((e) => double.parse(e.largo) * double.parse(e.altura)).toList();
 // }
}

@riverpod
List<String> descriptionBloqueta(DescriptionBloquetaRef ref) {
  final bloqeutas = ref.watch( bloquetaResultProvider );

 // if (bloqeutas.isNotEmpty) {
    return bloqeutas.map((e) => e.description).toList();
 // }
}

@riverpod
String datosShareBloqueta(DatosShareBloquetaRef ref) {
  final description = ref.watch(descriptionBloquetaProvider);
  final area = ref.watch(areaBloquetaProvider);

  String datos = "";
  if (description.length == area.length) {
    for (int i = 0; i < description.length; i++ ) {
      datos += "* ${description[i]}: ${area[i]} m2\n";
    }
    datos = datos.substring(0,datos.length -2);
  }
  return datos;
}

@riverpod
class AddMuroBloqueta1 extends _$AddMuroBloqueta1 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroBloqueta2 extends _$AddMuroBloqueta2 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroBloqueta3 extends _$AddMuroBloqueta3 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroBloqueta4 extends _$AddMuroBloqueta4 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroBloqueta5 extends _$AddMuroBloqueta5 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroBloqueta6 extends _$AddMuroBloqueta6 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroBloqueta7 extends _$AddMuroBloqueta7 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}
