import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'cimiento_corrido.g.dart';

@collection
class CimientoCorrido {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idCimientoCorrido;
  final String description;
  final String resistencia;
  final String factorDesperdicio;
  final String? largo;
  final String? ancho;
  final String? altura;
  final String? volumen;

  CimientoCorrido({
    required this.idCimientoCorrido,
    required this.description,
    required this.resistencia,
    required this.factorDesperdicio,
    this.largo,
    this.ancho,
    this.altura,
    this.volumen,
  });

  CimientoCorrido copyWith({
    String? idCimientoCorrido,
    String? description,
    String? resistencia,
    String? factorDesperdicio,
    String? largo,
    String? ancho,
    String? altura,
    String? volumen,
  }) => CimientoCorrido(
    idCimientoCorrido: idCimientoCorrido ?? this.idCimientoCorrido,
    description: description ?? this.description,
    resistencia: resistencia ?? this.resistencia,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    altura: altura ?? this.altura,
    volumen: volumen ?? this.volumen,
  )..id = id;
}