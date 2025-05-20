// lib/domain/entities/home/structural/viga.dart
import 'package:isar/isar.dart';

import '../../../entities.dart';

part 'viga.g.dart';

@collection
class Viga {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idViga;
  final String description;
  final String resistencia;
  final String factorDesperdicio;
  final String? largo;
  final String? ancho;
  final String? altura;
  final String? volumen;

  Viga({
    required this.idViga,
    required this.description,
    required this.resistencia,
    required this.factorDesperdicio,
    this.largo,
    this.ancho,
    this.altura,
    this.volumen,
  });

  Viga copyWith({
    String? idViga,
    String? description,
    String? resistencia,
    String? factorDesperdicio,
    String? largo,
    String? ancho,
    String? altura,
    String? volumen,
  }) => Viga(
    idViga: idViga ?? this.idViga,
    description: description ?? this.description,
    resistencia: resistencia ?? this.resistencia,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    altura: altura ?? this.altura,
    volumen: volumen ?? this.volumen,
  )..id = id;
}