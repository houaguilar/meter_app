// lib/domain/entities/home/structural/columna.dart
import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'columna.g.dart';

@collection
class Columna {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idColumna;
  final String description;
  final String resistencia;
  final String factorDesperdicio;
  final String? largo;
  final String? ancho;
  final String? altura;
  final String? volumen;

  Columna({
    required this.idColumna,
    required this.description,
    required this.resistencia,
    required this.factorDesperdicio,
    this.largo,
    this.ancho,
    this.altura,
    this.volumen,
  });

  Columna copyWith({
    String? idColumna,
    String? description,
    String? resistencia,
    String? factorDesperdicio,
    String? largo,
    String? ancho,
    String? altura,
    String? volumen,
  }) => Columna(
    idColumna: idColumna ?? this.idColumna,
    description: description ?? this.description,
    resistencia: resistencia ?? this.resistencia,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    altura: altura ?? this.altura,
    volumen: volumen ?? this.volumen,
  )..id = id;
}