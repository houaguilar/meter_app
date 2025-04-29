
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
class CantidadArenaTarrajeo extends _$CantidadArenaTarrajeo {
  @override
  String build() => '';

  void arena(String name) {
    state = name;
  }
}

@riverpod
class CantidadCementoTarrajeo extends _$CantidadCementoTarrajeo {
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
class TarrajeoResult extends _$TarrajeoResult {
  final TarrajeoService _tarrajeoService = TarrajeoService();

  @override
  List<Tarrajeo> build() => [];

  void createTarrajeo(
      String tipo,
      String description,
      String factor,
      String cementoDosage,
      String arenaDosage,
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
      cementoDosage: cementoDosage,
      arenaDosage: arenaDosage,
      espesor: espesor,
      longitud: longitud,
      ancho: ancho,
      area: area,
    );

    if (!_tarrajeoService.esValido(newTarrajeo)) {
      throw Exception("El ladrillo debe tener largo y altura o área definida.");
    }

    state = [...state, newTarrajeo];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
List<double> volumenTarrajeo(VolumenTarrajeoRef ref) {
  final tarrajeoSrevice = TarrajeoService();
  final tarrajeos = ref.watch( tarrajeoResultProvider );

  return tarrajeos.map((tarrajeo) => tarrajeoSrevice.calcularArea(tarrajeo) ?? 0.0).toList();
  //return pisos.map((e) => double.parse(e.largo) * double.parse(e.altura) * double.parse(e.ancho)).toList();
}

@riverpod
List<String> descriptionTarrajeo(DescriptionTarrajeoRef ref) {
  final tarrajeo = ref.watch( tarrajeoResultProvider );

  return tarrajeo.map((e) => e.description).toList();
}

@riverpod
String datosShareTarrajeo(DatosShareTarrajeoRef ref) {
  final description = ref.watch(descriptionTarrajeoProvider);
  final volumen = ref.watch(volumenTarrajeoProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++ ) {
      datos += "* ${description[i]}: ${volumen[i]} m3\n";
    }
    datos = datos.substring(0,datos.length -2);
  }
  return datos;
}
