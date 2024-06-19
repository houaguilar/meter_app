import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../data/models/models.dart';

part 'ladrillo_providers.g.dart';

@riverpod
class TipoLadrillo extends _$TipoLadrillo {
  @override
  String build() => '';

  void selectLadrillo(String name) {
    state = name;
  }
}

@riverpod
class CantidadArenaLadrillo extends _$CantidadArenaLadrillo {
  @override
  String build() => '';

  void arena(String name) {
    state = name;
  }
}

@riverpod
class CantidadCementoLadrillo extends _$CantidadCementoLadrillo {
  @override
  String build() => '';

  void cemento(String name) {
    state = name;
  }
}

@riverpod
class CantidadLadrillo extends _$CantidadLadrillo {
  @override
  String build() => '';

  void ladrillo(String name) {
    state = name;
  }
}

@riverpod
class LadrilloResult extends _$LadrilloResult {

  @override
  List<Ladrillo> build() => [];

  void createLadrillo(
      String description,
      String tipoLadrillo,
      String tipoAsentado,
      String largo,
      String altura,
      ) {
    state = [
      ...state, Ladrillo(
          idLadrillo: uuid.v4(),
          description: description,
          tipoLadrillo: tipoLadrillo,
          tipoAsentado: tipoAsentado,
          largo: largo,
          altura: altura
      )
    ];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
List<double> areaLadrillo(AreaLadrilloRef ref) {
  final ladrillos = ref.watch( ladrilloResultProvider );

  return ladrillos.map((e) => double.parse(e.largo) * double.parse(e.altura)).toList();
}

@riverpod
List<String> descriptionLadrillo(DescriptionLadrilloRef ref) {
  final ladrillos = ref.watch( ladrilloResultProvider );

  return ladrillos.map((e) => e.description).toList();
}

@riverpod
String datosShareLadrillo(DatosShareLadrilloRef ref) {
  final description = ref.watch(descriptionLadrilloProvider);
  final area = ref.watch(areaLadrilloProvider);

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
class AddMuroLadrillo1 extends _$AddMuroLadrillo1 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroLadrillo2 extends _$AddMuroLadrillo2 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroLadrillo3 extends _$AddMuroLadrillo3 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroLadrillo4 extends _$AddMuroLadrillo4 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroLadrillo5 extends _$AddMuroLadrillo5 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroLadrillo6 extends _$AddMuroLadrillo6 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}

@riverpod
class AddMuroLadrillo7 extends _$AddMuroLadrillo7 {
  @override
  bool build() => true;

  void toggleAddMuro() {
    state = !state;
  }
}