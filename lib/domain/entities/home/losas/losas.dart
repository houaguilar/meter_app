// lib/domain/entities/home/losa/losa_aligerada.dart
import 'package:isar/isar.dart';
import '../../entities.dart';

part 'losas.g.dart';

@collection
class LosaAligerada {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idLosaAligerada;
  final String description;
  final String altura; // Altura de losa
  final String materialAligerado; // Material de aligerado
  final String resistenciaConcreto; // Resistencia del concreto
  final String desperdicioLadrillo; // Desperdicio de ladrillo
  final String desperdicioConcreto; // Desperdicio de concreto
  final String? largo;
  final String? ancho;
  final String? area;

  LosaAligerada({
    required this.idLosaAligerada,
    required this.description,
    required this.altura,
    required this.materialAligerado,
    required this.resistenciaConcreto,
    required this.desperdicioLadrillo,
    required this.desperdicioConcreto,
    this.largo,
    this.ancho,
    this.area,
  });

  LosaAligerada copyWith({
    String? idLosaAligerada,
    String? description,
    String? altura,
    String? materialAligerado,
    String? resistenciaConcreto,
    String? desperdicioLadrillo,
    String? desperdicioConcreto,
    String? largo,
    String? ancho,
    String? area,
  }) => LosaAligerada(
    idLosaAligerada: idLosaAligerada ?? this.idLosaAligerada,
    description: description ?? this.description,
    altura: altura ?? this.altura,
    materialAligerado: materialAligerado ?? this.materialAligerado,
    resistenciaConcreto: resistenciaConcreto ?? this.resistenciaConcreto,
    desperdicioLadrillo: desperdicioLadrillo ?? this.desperdicioLadrillo,
    desperdicioConcreto: desperdicioConcreto ?? this.desperdicioConcreto,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    area: area ?? this.area,
  )..id = id;
}