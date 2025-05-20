import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/entities.dart';

part 'tarrajeo.g.dart';

@collection
class Tarrajeo {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idCoating;
  final String description;
  final String tipo;
  final String factorDesperdicio;
  final String proporcionMortero; // "4" o "5" (para 1:4 o 1:5)
  final String espesor;
  final String? longitud;
  final String? ancho;
  final String? area;

  Tarrajeo({
    required this.idCoating,
    required this.description,
    required this.tipo,
    required this.factorDesperdicio,
    required this.proporcionMortero,
    required this.espesor,
    this.longitud,
    this.ancho,
    this.area,
  });

  Tarrajeo copyWith({
    String? idCoating,
    String? description,
    String? tipo,
    String? factorDesperdicio,
    String? proporcionMortero,
    String? espesor,
    String? longitud,
    String? ancho,
    String? area,
  }) => Tarrajeo(
    idCoating: idCoating ?? this.idCoating,
    description: description ?? this.description,
    tipo: tipo ?? this.tipo,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    proporcionMortero: proporcionMortero ?? this.proporcionMortero,
    espesor: espesor ?? this.espesor,
    longitud: longitud ?? this.longitud,
    ancho: ancho ?? this.ancho,
    area: area ?? this.area,
  )..id = id;
}