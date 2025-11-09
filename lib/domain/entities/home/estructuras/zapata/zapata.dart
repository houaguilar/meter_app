// lib/domain/entities/home/structural/zapata.dart
import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'zapata.g.dart';

@collection
class Zapata {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idZapata;
  final String description;
  final String resistencia;
  final String factorDesperdicio;
  final String? largo;
  final String? ancho;
  final String? altura;
  final String? volumen;

  Zapata({
    required this.idZapata,
    required this.description,
    required this.resistencia,
    required this.factorDesperdicio,
    this.largo,
    this.ancho,
    this.altura,
    this.volumen,
  });

  Zapata copyWith({
    String? idZapata,
    String? description,
    String? resistencia,
    String? factorDesperdicio,
    String? largo,
    String? ancho,
    String? altura,
    String? volumen,
  }) => Zapata(
    idZapata: idZapata ?? this.idZapata,
    description: description ?? this.description,
    resistencia: resistencia ?? this.resistencia,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    altura: altura ?? this.altura,
    volumen: volumen ?? this.volumen,
  )..id = id;
}
