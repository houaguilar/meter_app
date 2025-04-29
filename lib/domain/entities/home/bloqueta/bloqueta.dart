import 'package:isar/isar.dart';

import '../../entities.dart';

part 'bloqueta.g.dart';

@collection
class Bloqueta {

  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();
  
  final String idBloqueta;
  final String description;
  final String tipoBloqueta;
  final String factorDesperdicio;
  final String? largo;
  final String? altura;
  final String? area;

  Bloqueta({
    required this.idBloqueta,
    required this.description,
    required this.tipoBloqueta,
    required this.factorDesperdicio,
    this.largo,
    this.altura,
    this.area,
  });

  Bloqueta copyWith({
    String? idBloqueta,
    String? description,
    String? tipoBloqueta,
    String? factorDesperdicio,
    String? largo,
    String? altura,
    String? area,
  }) => Bloqueta(
    idBloqueta: idBloqueta ?? this.idBloqueta,
    description: description ?? this.description,
    tipoBloqueta: tipoBloqueta ?? this.tipoBloqueta,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    largo: largo ?? this.largo,
    altura: altura ?? this.altura,
    area: area ?? this.area,
  )..id = id;
}