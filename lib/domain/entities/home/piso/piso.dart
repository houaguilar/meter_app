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
  final String largo;
  final String ancho;
  final String altura;

  Piso({
    required this.idPiso,
    required this.tipo,
    required this.description,
    required this.largo,
    required this.ancho,
    required this.altura,
  });

  Piso copyWith({
    String? idPiso,
    String? tipo,
    String? description,
    String? largo,
    String? ancho,
    String? altura,
  }) => Piso(
    idPiso: idPiso ?? this.idPiso,
    tipo: tipo ?? this.tipo,
    description: description ?? this.description,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    altura: altura ?? this.altura,
  )..id = id;
}