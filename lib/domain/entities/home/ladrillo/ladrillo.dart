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
  final String tipoAsentado;
  final String largo;
  final String altura;

  Ladrillo({
    required this.idLadrillo,
    required this.description,
    required this.tipoLadrillo,
    required this.tipoAsentado,
    required this.largo,
    required this.altura,
  });

  Ladrillo copyWith({
    String? idLadrillo,
    String? description,
    String? tipoLadrillo,
    String? tipoAsentado,
    String? largo,
    String? altura,
  }) => Ladrillo(
    idLadrillo: idLadrillo ?? this.idLadrillo,
    description: description ?? this.description,
    tipoLadrillo: tipoLadrillo ?? this.tipoLadrillo,
    tipoAsentado: tipoAsentado ?? this.tipoAsentado,
    largo: largo ?? this.largo,
    altura: altura ?? this.altura,
  )..id = id;
}