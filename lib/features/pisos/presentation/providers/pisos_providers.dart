
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/features/pisos/domain/services/piso_service.dart';

import 'package:meter_app/core/constants/constant.dart';
import 'package:meter_app/domain/entities/home/piso/piso.dart';

class TipoPiso extends Notifier<String> {
  @override
  String build() => '';

  void selectPiso(String name) {
    state = name;
  }
}

final tipoPisoProvider = NotifierProvider<TipoPiso, String>(TipoPiso.new);

class CantidadArenaPisos extends Notifier<String> {
  @override
  String build() => '';

  void arena(String name) {
    state = name;
  }
}

final cantidadArenaPisosProvider =
    NotifierProvider<CantidadArenaPisos, String>(CantidadArenaPisos.new);

class CantidadCementoPisos extends Notifier<String> {
  @override
  String build() => '';

  void cemento(String name) {
    state = name;
  }
}

final cantidadCementoPisosProvider =
    NotifierProvider<CantidadCementoPisos, String>(CantidadCementoPisos.new);

class CantidadPiedraChancada extends Notifier<String> {
  @override
  String build() => '';

  void piedra(String name) {
    state = name;
  }
}

final cantidadPiedraChancadaProvider =
    NotifierProvider<CantidadPiedraChancada, String>(CantidadPiedraChancada.new);

class PisosResult extends Notifier<List<Piso>> {
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

final pisosResultProvider =
    NotifierProvider<PisosResult, List<Piso>>(PisosResult.new);

final volumenPisoProvider = Provider<List<double>>((ref) {
  final pisoSrevice = PisoService();
  final pisos = ref.watch(pisosResultProvider);

  return pisos.map((piso) => pisoSrevice.calcularArea(piso) ?? 0.0).toList();
  //return pisos.map((e) => double.parse(e.largo) * double.parse(e.altura) * double.parse(e.ancho)).toList();
});

final descriptionPisoProvider = Provider<List<String>>((ref) {
  final pisos = ref.watch(pisosResultProvider);

  return pisos.map((e) => e.description).toList();
});

final datosSharePisosProvider = Provider<String>((ref) {
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
});
