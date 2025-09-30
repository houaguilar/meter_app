// lib/domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart
import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'sobrecimiento.g.dart';

@collection
class Sobrecimiento {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idSobrecimiento;
  final String description;
  final String resistencia;
  final String factorDesperdicio;
  final String? largo;
  final String? ancho;
  final String? altura;
  final String? volumen;

  Sobrecimiento({
    required this.idSobrecimiento,
    required this.description,
    required this.resistencia,
    required this.factorDesperdicio,
    this.largo,
    this.ancho,
    this.altura,
    this.volumen,
  });

  Sobrecimiento copyWith({
    String? idSobrecimiento,
    String? description,
    String? resistencia,
    String? factorDesperdicio,
    String? largo,
    String? ancho,
    String? altura,
    String? volumen,
  }) => Sobrecimiento(
    idSobrecimiento: idSobrecimiento ?? this.idSobrecimiento,
    description: description ?? this.description,
    resistencia: resistencia ?? this.resistencia,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    altura: altura ?? this.altura,
    volumen: volumen ?? this.volumen,
  )..id = id;
}