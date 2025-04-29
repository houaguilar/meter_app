import 'package:isar/isar.dart';

import '../../entities.dart';

part 'piso.g.dart';

@collection
class Piso {

  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idPiso;
  final String tipo;
  final String description;
  final String factorDesperdicio;
  final String espesor;
  final String? largo;
  final String? ancho;
  final String? area;

  Piso({
    required this.idPiso,
    required this.tipo,
    required this.description,
    required this.factorDesperdicio,
    required this.espesor,
    this.largo,
    this.ancho,
    this.area
  });

  Piso copyWith({
    String? idPiso,
    String? tipo,
    String? description,
    String? factorDesperdicio,
    String? espesor,
    String? largo,
    String? ancho,
    String? area,
  }) => Piso(
    idPiso: idPiso ?? this.idPiso,
    tipo: tipo ?? this.tipo,
    description: description ?? this.description,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    espesor: espesor ?? this.espesor,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    area: area ?? this.area,
  )..id = id;
}