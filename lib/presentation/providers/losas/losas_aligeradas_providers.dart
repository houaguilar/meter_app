// lib/presentation/providers/losas/losas_aligeradas_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/losas/losas.dart';
import '../../../domain/services/losa_aligerada_service.dart';

part 'losas_aligeradas_providers.g.dart';

@riverpod
class AlturaLosaAligerada extends _$AlturaLosaAligerada {
  @override
  String build() => '';

  void seleccionarAltura(String altura) {
    state = altura;
  }
}

@riverpod
class MaterialAligerado extends _$MaterialAligerado {
  @override
  String build() => '';

  void seleccionarMaterial(String material) {
    state = material;
  }
}

@riverpod
class ResistenciaConcreto extends _$ResistenciaConcreto {
  @override
  String build() => '';

  void seleccionarResistencia(String resistencia) {
    state = resistencia;
  }
}

@riverpod
class LosaAligeradaResult extends _$LosaAligeradaResult {
  final LosaAligeradaService _losaAligeradaService = LosaAligeradaService();

  @override
  List<LosaAligerada> build() => [];

  void createLosaAligerada(
      String description,
      String altura,
      String materialAligerado,
      String resistenciaConcreto,
      String desperdicioLadrillo,
      String desperdicioConcreto, {
        String? largo,
        String? ancho,
        String? area,
      }) {
    final newLosaAligerada = LosaAligerada(
      idLosaAligerada: uuid.v4(),
      description: description,
      altura: altura,
      materialAligerado: materialAligerado,
      resistenciaConcreto: resistenciaConcreto,
      desperdicioLadrillo: desperdicioLadrillo,
      desperdicioConcreto: desperdicioConcreto,
      largo: largo,
      ancho: ancho,
      area: area,
    );

    if (!_losaAligeradaService.esValido(newLosaAligerada)) {
      throw Exception("La losa aligerada debe tener largo y ancho o área definida.");
    }

    state = [...state, newLosaAligerada];
  }

  void clearList() {
    state = [];
  }
}

@riverpod
List<double> areaLosaAligerada(AreaLosaAligeradaRef ref) {
  final losaAligeradaService = LosaAligeradaService();
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);

  return losasAligeradas
      .map((losa) => losaAligeradaService.calcularArea(losa) ?? 0.0)
      .toList();
}

@riverpod
List<String> descriptionLosaAligerada(DescriptionLosaAligeradaRef ref) {
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);
  return losasAligeradas.map((e) => e.description).toList();
}

@riverpod
String datosShareLosaAligerada(DatosShareLosaAligeradaRef ref) {
  final description = ref.watch(descriptionLosaAligeradaProvider);
  final area = ref.watch(areaLosaAligeradaProvider);

  String datos = "";
  if (description.length == area.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${area[i].toStringAsFixed(2)} m2\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
}

// PROVIDERS PARA LOS 4 MATERIALES PRINCIPALES

@riverpod
double cantidadCementoLosaAligerada(CantidadCementoLosaAligeradaRef ref) {
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);
  final losaAligeradaService = LosaAligeradaService();

  double total = 0.0;
  for (var losa in losasAligeradas) {
    total += losaAligeradaService.calcularCemento(losa);
  }
  return total;
}

@riverpod
double cantidadArenaGruesaLosaAligerada(CantidadArenaGruesaLosaAligeradaRef ref) {
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);
  final losaAligeradaService = LosaAligeradaService();

  double total = 0.0;
  for (var losa in losasAligeradas) {
    total += losaAligeradaService.calcularArenaGruesa(losa);
  }
  return total;
}

@riverpod
double cantidadPiedraChancadaLosaAligerada(CantidadPiedraChancadaLosaAligeradaRef ref) {
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);
  final losaAligeradaService = LosaAligeradaService();

  double total = 0.0;
  for (var losa in losasAligeradas) {
    total += losaAligeradaService.calcularPiedraChancada(losa);
  }
  return total;
}

@riverpod
double cantidadAguaLosaAligerada(CantidadAguaLosaAligeradaRef ref) {
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);
  final losaAligeradaService = LosaAligeradaService();

  double total = 0.0;
  for (var losa in losasAligeradas) {
    total += losaAligeradaService.calcularAgua(losa);
  }
  return total;
}

// Provider para volumen de concreto (información adicional)
@riverpod
double volumenConcretoLosaAligerada(VolumenConcretoLosaAligeradaRef ref) {
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);
  final losaAligeradaService = LosaAligeradaService();

  double total = 0.0;
  for (var losa in losasAligeradas) {
    total += losaAligeradaService.calcularVolumenConcreto(losa);
  }
  return total;
}