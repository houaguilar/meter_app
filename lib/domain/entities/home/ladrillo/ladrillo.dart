
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
  final String factorDesperdicio;
  final String factorDesperdicioMortero;
  final String proporcionMortero;
  final String tipoAsentado;
  final String? largo;    // Largo del MURO en metros
  final String? altura;   // Altura del MURO en metros
  final String? area;     // Área del MURO en m²

  // ✅ NUEVO: Dimensiones del LADRILLO en cm (para custom bricks)
  final double? brickLength;  // Largo del ladrillo en cm
  final double? brickWidth;   // Ancho del ladrillo en cm
  final double? brickHeight;  // Alto del ladrillo en cm

  Ladrillo({
    required this.idLadrillo,
    required this.description,
    required this.tipoLadrillo,
    required this.factorDesperdicio,
    required this.factorDesperdicioMortero,
    required this.proporcionMortero,
    required this.tipoAsentado,
    this.largo,
    this.altura,
    this.area,
    this.brickLength,   // ✅ NUEVO
    this.brickWidth,    // ✅ NUEVO
    this.brickHeight,   // ✅ NUEVO
  });

  Ladrillo copyWith({
    String? idLadrillo,
    String? description,
    String? tipoLadrillo,
    String? factorDesperdicio,
    String? factorDesperdicioMortero,
    String? proporcionMortero,
    String? tipoAsentado,
    String? largo,
    String? altura,
    String? area,
    double? brickLength,   // ✅ NUEVO
    double? brickWidth,    // ✅ NUEVO
    double? brickHeight,   // ✅ NUEVO
  }) =>
      Ladrillo(
        idLadrillo: idLadrillo ?? this.idLadrillo,
        description: description ?? this.description,
        tipoLadrillo: tipoLadrillo ?? this.tipoLadrillo,
        factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
        factorDesperdicioMortero: factorDesperdicioMortero ?? this.factorDesperdicioMortero,
        proporcionMortero: proporcionMortero ?? this.proporcionMortero,
        tipoAsentado: tipoAsentado ?? this.tipoAsentado,
        largo: largo ?? this.largo,
        altura: altura ?? this.altura,
        area: area ?? this.area,
        brickLength: brickLength ?? this.brickLength,     // ✅ NUEVO
        brickWidth: brickWidth ?? this.brickWidth,        // ✅ NUEVO
        brickHeight: brickHeight ?? this.brickHeight,     // ✅ NUEVO
      )
        ..id = id;
}