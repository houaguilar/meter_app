
import 'package:isar/isar.dart';

import '../../entities.dart';

part 'ladrillo.g.dart';

@collection
class Ladrillo {

  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idLadrillo;
  final String description;
  final String tipoLadrillo;
  final String factorDesperdicio;
  final String factorDesperdicioMortero;
  final String proporcionMortero;
  final String tipoAsentado;
  final String? largo;
  final String? altura;
  final String? area;

  Ladrillo({
    required this.idLadrillo,
    required this.description,
    required this.tipoLadrillo,
    required this.factorDesperdicio,
    required this.factorDesperdicioMortero, // NUEVO: Parámetro requerido
    required this.proporcionMortero,
    required this.tipoAsentado,
    this.largo,
    this.altura,
    this.area,
  });

  Ladrillo copyWith({
    String? idLadrillo,
    String? description,
    String? tipoLadrillo,
    String? factorDesperdicio,
    String? factorDesperdicioMortero, // NUEVO: En copyWith
    String? proporcionMortero,
    String? tipoAsentado,
    String? largo,
    String? altura,
    String? area,
  }) =>
      Ladrillo(
        idLadrillo: idLadrillo ?? this.idLadrillo,
        description: description ?? this.description,
        tipoLadrillo: tipoLadrillo ?? this.tipoLadrillo,
        factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
        factorDesperdicioMortero: factorDesperdicioMortero ??
            this.factorDesperdicioMortero,
        // NUEVO
        proporcionMortero: proporcionMortero ?? this.proporcionMortero,
        tipoAsentado: tipoAsentado ?? this.tipoAsentado,
        largo: largo ?? this.largo,
        altura: altura ?? this.altura,
        area: area ?? this.area,
      )
        ..id = id;
}