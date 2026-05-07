import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meter_app/core/constants/constant.dart';
import 'package:meter_app/domain/entities/home/losas/losa.dart';
import 'package:meter_app/domain/entities/home/losas/tipo_losa.dart';
import 'package:meter_app/features/losas/domain/services/losa_service.dart';

/// Provider para el tipo de losa seleccionado
class TipoLosaSelected extends Notifier<TipoLosa?> {
  @override
  TipoLosa? build() => null;

  void seleccionar(TipoLosa tipo) {
    state = tipo;
  }

  void limpiar() {
    state = null;
  }
}

final tipoLosaSelectedProvider =
    NotifierProvider<TipoLosaSelected, TipoLosa?>(TipoLosaSelected.new);

/// Provider para la altura seleccionada
class AlturaLosa extends Notifier<String> {
  @override
  String build() => '';

  void seleccionarAltura(String altura) {
    state = altura;
  }
}

final alturaLosaProvider = NotifierProvider<AlturaLosa, String>(AlturaLosa.new);

/// Provider para el material aligerante seleccionado
///
/// Solo aplica para losas aligeradas (tradicional)
/// Para viguetas es fijo: 'Bovedillas'
/// Para maciza es null
class MaterialAligerante extends Notifier<String> {
  @override
  String build() => '';

  void seleccionarMaterial(String material) {
    state = material;
  }
}

final materialAligeranteProvider =
    NotifierProvider<MaterialAligerante, String>(MaterialAligerante.new);

/// Provider para la resistencia del concreto seleccionada
class ResistenciaConcreto extends Notifier<String> {
  @override
  String build() => '';

  void seleccionarResistencia(String resistencia) {
    state = resistencia;
  }
}

final resistenciaConcretoProvider =
    NotifierProvider<ResistenciaConcreto, String>(ResistenciaConcreto.new);

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DE RESULTADOS (LISTA DE LOSAS)
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que mantiene la lista de losas creadas
class LosaResult extends Notifier<List<Losa>> {
  @override
  List<Losa> build() => [];

  /// Crea y agrega una nueva losa a la lista
  void createLosa({
    required TipoLosa tipo,
    required String description,
    required String altura,
    required String resistenciaConcreto,
    required String desperdicioConcreto,
    String? materialAligerante,
    String? desperdicioMaterialAligerante,
    String? largo,
    String? ancho,
    String? area,
  }) {

    final newLosa = Losa(
      idLosa: uuid.v4(),
      description: description,
      tipo: tipo.toStorageString(),
      altura: altura,
      resistenciaConcreto: resistenciaConcreto,
      desperdicioConcreto: desperdicioConcreto,
      materialAligerante: materialAligerante,
      desperdicioMaterialAligerante: desperdicioMaterialAligerante,
      largo: largo,
      ancho: ancho,
      area: area,
    );

    // Validar antes de agregar
    final service = LosaService(tipo);
    final error = service.validar(newLosa);
    if (error != null) {
      throw Exception(error);
    }

    state = [...state, newLosa];
  }

  /// Limpia la lista de losas
  void clearList() {
    state = [];
  }

  /// Elimina una losa específica
  void removeLosa(String idLosa) {
    state = state.where((losa) => losa.idLosa != idLosa).toList();
  }
}

final losaResultProvider =
    NotifierProvider<LosaResult, List<Losa>>(LosaResult.new);

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DE SERVICIO
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que proporciona el servicio de losa apropiado según tipo
final losaServiceProvider =
    Provider.family<LosaService, TipoLosa>((ref, tipo) {
  return LosaService(tipo);
});

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE CÁLCULO DE ÁREAS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que calcula las áreas de todas las losas
final areaLosasProvider = Provider<List<double>>((ref) {
  final losas = ref.watch(losaResultProvider);

  return losas.map((losa) {
    final service = LosaService(losa.tipoLosa);
    return service.calcularArea(losa);
  }).toList();
});

/// Provider que obtiene las descripciones de todas las losas
final descriptionLosasProvider = Provider<List<String>>((ref) {
  final losas = ref.watch(losaResultProvider);
  return losas.map((e) => e.description).toList();
});

/// Provider que genera texto para compartir con datos de metrado
final datosShareLosaProvider = Provider<String>((ref) {
  final descriptions = ref.watch(descriptionLosasProvider);
  final areas = ref.watch(areaLosasProvider);

  String datos = "";
  if (descriptions.length == areas.length) {
    for (int i = 0; i < descriptions.length; i++) {
      datos += "* ${descriptions[i]}: ${areas[i].toStringAsFixed(1)} m²\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
});

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE MATERIALES DE CONCRETO
// ═══════════════════════════════════════════════════════════════════════════

/// Calcula la cantidad total de cemento en bolsas
final cantidadCementoLosaProvider = Provider<double>((ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    final cemento = service.calcularCemento(losa);
    total += cemento;
  }
  return total;
});

/// Calcula la cantidad total de arena gruesa en m³
final cantidadArenaGruesaLosaProvider = Provider<double>((ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularArenaGruesa(losa);
  }
  return total;
});

/// Calcula la cantidad total de piedra chancada en m³
final cantidadPiedraChancadaLosaProvider = Provider<double>((ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularPiedraChancada(losa);
  }
  return total;
});

/// Calcula la cantidad total de agua en m³
final cantidadAguaLosaProvider = Provider<double>((ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularAgua(losa);
  }
  return total;
});

/// Calcula la cantidad total de aditivo plastificante en litros
final cantidadAditivoPlastificanteLosaProvider = Provider<double>((ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularAditivoPlastificante(losa);
  }
  return total;
});

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE MATERIALES ALIGERANTES
// ═══════════════════════════════════════════════════════════════════════════

/// Calcula los materiales aligerantes agrupados por tipo
///
/// Retorna un Map con:
/// - Key: Descripción del material (ej: "Bovedillas", "Ladrillo hueco 30×30×15 cm")
/// - Value: Cantidad total en unidades
///
/// Las losas macizas no aportan materiales aligerantes
final materialesAligerantesProvider = Provider<Map<String, double>>((ref) {
  final losas = ref.watch(losaResultProvider);
  final Map<String, double> totales = {};

  for (var losa in losas) {
    // Skip losas macizas
    if (losa.tipoLosa == TipoLosa.maciza) continue;

    final service = LosaService(losa.tipoLosa);
    final cantidad = service.calcularMaterialAligerante(losa);

    if (cantidad != null && cantidad > 0) {
      final descripcion = service.obtenerDescripcionMaterialAligerante(losa);
      totales[descripcion] = (totales[descripcion] ?? 0.0) + cantidad;
    }
  }

  return totales;
});

/// Provider para volumen total de concreto (información adicional)
final volumenConcretoLosaProvider = Provider<double>((ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    final volumen = service.calcularVolumenConcreto(losa);
    total += volumen;
  }
  return total;
});
