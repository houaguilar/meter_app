
import 'package:meter_app/domain/services/piso_service.dart';
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
  final PisoService _pisoService = PisoService();
  @override
  List<Piso> build() => [];

  void createPisos(
      String tipo,
      String description,
      String factor,
      String espesor, {
        String? resistencia,
        String? proporcionMortero,
        String? largo,
        String? ancho,
        String? area,
      }){
    final newPiso = Piso(
      idPiso: uuid.v4(),
      description: description,
      tipo: tipo,
      factorDesperdicio: factor,
      espesor: espesor,
      resistencia: resistencia,
      proporcionMortero: proporcionMortero,
      largo: largo,
      ancho: ancho,
      area: area,
    );

    if (!_pisoService.esValido(newPiso)) {
      throw Exception("El ladrillo debe tener largo y altura o área definida.");
    }

    state = [...state, newPiso];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
List<double> volumenPiso(VolumenPisoRef ref) {
  final pisoSrevice = PisoService();
  final pisos = ref.watch( pisosResultProvider );

  return pisos.map((piso) => pisoSrevice.calcularArea(piso) ?? 0.0).toList();
  //return pisos.map((e) => double.parse(e.largo) * double.parse(e.altura) * double.parse(e.ancho)).toList();
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