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
  final String largo;
  final String altura;

  Bloqueta({
    required this.idBloqueta,
    required this.description,
    required this.tipoBloqueta,
    required this.largo,
    required this.altura,
  });

  Bloqueta copyWith({
    String? idBloqueta,
    String? description,
    String? tipoBloqueta,
    String? largo,
    String? altura,
  }) => Bloqueta(
    idBloqueta: idBloqueta ?? this.idBloqueta,
    description: description ?? this.description,
    tipoBloqueta: tipoBloqueta ?? this.tipoBloqueta,
    largo: largo ?? this.largo,
    altura: altura ?? this.altura,
  )..id = id;
}