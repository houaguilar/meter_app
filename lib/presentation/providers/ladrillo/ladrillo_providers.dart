import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../data/models/models.dart';
import '../../../domain/services/ladrillo_service.dart';

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
class LadrilloResult extends _$LadrilloResult {
  final LadrilloService _ladrilloService = LadrilloService();

  @override
  List<Ladrillo> build() => [];

  void createLadrillo(
      String description,
      String tipoLadrillo,
      String factor,
      String factorMortero,                    // NUEVO: Parámetro para desperdicio de mortero
      String proporcionMortero,
      String tipoAsentado, {
        String? largo,
        String? altura,
        String? area,
      }) {
    final newLadrillo = Ladrillo(
      idLadrillo: uuid.v4(),
      description: description,
      tipoLadrillo: tipoLadrillo,
      factorDesperdicio: factor,
      factorDesperdicioMortero: factorMortero,  // NUEVO: Asignar el factor de mortero
      proporcionMortero: proporcionMortero,
      tipoAsentado: tipoAsentado,
      largo: largo,
      altura: altura,
      area: area,
    );

    if (!_ladrilloService.esValido(newLadrillo)) {
      throw Exception("El ladrillo debe tener largo y altura o área definida.");
    }

    state = [...state, newLadrillo];
  }

  void clearList() {
    state = [];
  }
}

@riverpod
List<double> areaLadrillo(AreaLadrilloRef ref) {
  final ladrilloService = LadrilloService();
  final ladrillos = ref.watch(ladrilloResultProvider);

  // Retorna una lista de áreas calculadas
  return ladrillos
      .map((ladrillo) => ladrilloService.calcularArea(ladrillo) ?? 0.0)
      .toList();
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

// Providers para calcular las cantidades de materiales
@riverpod
double cantidadCementoLadrillo(CantidadCementoLadrilloRef ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);
  print("Provider cantidadLadrillos - Número de ladrillos: ${ladrillos.length}");

  final ladrilloService = LadrilloService();
  return ladrilloService.calcularCementoTotal(ladrillos);
}

@riverpod
double cantidadArenaLadrillo(CantidadArenaLadrilloRef ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);
  final ladrilloService = LadrilloService();

  return ladrilloService.calcularArenaTotal(ladrillos);
}

@riverpod
double cantidadAguaLadrillo(CantidadAguaLadrilloRef ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);
  final ladrilloService = LadrilloService();

  return ladrilloService.calcularAguaTotal(ladrillos);
}

@riverpod
double cantidadLadrillos(CantidadLadrillosRef ref) {
  final ladrillos = ref.watch(ladrilloResultProvider);
  final ladrilloService = LadrilloService();

  return ladrilloService.calcularLadrillosTotal(ladrillos);
}