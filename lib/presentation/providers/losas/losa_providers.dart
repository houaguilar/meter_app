import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constant.dart';
import '../../../domain/entities/home/losas/losa.dart';
import '../../../domain/entities/home/losas/tipo_losa.dart';
import '../../../domain/services/losas/losa_service.dart';

part 'losa_providers.g.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE SELECCIÓN Y CONFIGURACIÓN
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para el tipo de losa seleccionado
@riverpod
class TipoLosaSelected extends _$TipoLosaSelected {
  @override
  TipoLosa? build() => null;

  void seleccionar(TipoLosa tipo) {
    state = tipo;
  }

  void limpiar() {
    state = null;
  }
}

/// Provider para la altura seleccionada
@riverpod
class AlturaLosa extends _$AlturaLosa {
  @override
  String build() => '';

  void seleccionarAltura(String altura) {
    state = altura;
  }
}

/// Provider para el material aligerante seleccionado
///
/// Solo aplica para losas aligeradas (tradicional)
/// Para viguetas es fijo: 'Bovedillas'
/// Para maciza es null
@riverpod
class MaterialAligerante extends _$MaterialAligerante {
  @override
  String build() => '';

  void seleccionarMaterial(String material) {
    state = material;
  }
}

/// Provider para la resistencia del concreto seleccionada
@riverpod
class ResistenciaConcreto extends _$ResistenciaConcreto {
  @override
  String build() => '';

  void seleccionarResistencia(String resistencia) {
    state = resistencia;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DE RESULTADOS (LISTA DE LOSAS)
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que mantiene la lista de losas creadas
@Riverpod(keepAlive: true)
class LosaResult extends _$LosaResult {
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
    debugPrint('🏗️ Provider createLosa - Iniciando...');
    debugPrint('   Tipo: ${tipo.displayName}');
    debugPrint('   Descripción: $description');
    debugPrint('   Material aligerante: $materialAligerante');

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

    debugPrint('🔍 Validando losa...');
    // Validar antes de agregar
    final service = LosaService(tipo);
    final error = service.validar(newLosa);
    if (error != null) {
      debugPrint('❌ Error de validación: $error');
      throw Exception(error);
    }

    debugPrint('✅ Losa válida, agregando al estado...');
    state = [...state, newLosa];
    debugPrint('✅ Losa agregada. Total en estado: ${state.length}');
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

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DE SERVICIO
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que proporciona el servicio de losa apropiado según tipo
@riverpod
LosaService losaService(LosaServiceRef ref, TipoLosa tipo) {
  return LosaService(tipo);
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE CÁLCULO DE ÁREAS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que calcula las áreas de todas las losas
@riverpod
List<double> areaLosas(AreaLosasRef ref) {
  final losas = ref.watch(losaResultProvider);

  return losas.map((losa) {
    final service = LosaService(losa.tipoLosa);
    return service.calcularArea(losa);
  }).toList();
}

/// Provider que obtiene las descripciones de todas las losas
@riverpod
List<String> descriptionLosas(DescriptionLosasRef ref) {
  final losas = ref.watch(losaResultProvider);
  return losas.map((e) => e.description).toList();
}

/// Provider que genera texto para compartir con datos de metrado
@riverpod
String datosShareLosa(DatosShareLosaRef ref) {
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
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE MATERIALES DE CONCRETO
// ═══════════════════════════════════════════════════════════════════════════

/// Calcula la cantidad total de cemento en bolsas
@riverpod
double cantidadCementoLosa(CantidadCementoLosaRef ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularCemento(losa);
  }
  return total;
}

/// Calcula la cantidad total de arena gruesa en m³
@riverpod
double cantidadArenaGruesaLosa(CantidadArenaGruesaLosaRef ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularArenaGruesa(losa);
  }
  return total;
}

/// Calcula la cantidad total de piedra chancada en m³
@riverpod
double cantidadPiedraChancadaLosa(CantidadPiedraChancadaLosaRef ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularPiedraChancada(losa);
  }
  return total;
}

/// Calcula la cantidad total de agua en m³
@riverpod
double cantidadAguaLosa(CantidadAguaLosaRef ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularAgua(losa);
  }
  return total;
}

/// Calcula la cantidad total de aditivo plastificante en litros
@riverpod
double cantidadAditivoPlastificanteLosa(CantidadAditivoPlastificanteLosaRef ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularAditivoPlastificante(losa);
  }
  return total;
}

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
@riverpod
Map<String, double> materialesAligerantes(MaterialesAligerantesRef ref) {
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
}

/// Provider para volumen total de concreto (información adicional)
@riverpod
double volumenConcretoLosa(VolumenConcretoLosaRef ref) {
  final losas = ref.watch(losaResultProvider);

  double total = 0.0;
  for (var losa in losas) {
    final service = LosaService(losa.tipoLosa);
    total += service.calcularVolumenConcreto(losa);
  }
  return total;
}
