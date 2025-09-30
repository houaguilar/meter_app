import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'solado.g.dart';

@collection
class Solado {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idSolado;
  final String description;
  final String resistencia;
  final String factorDesperdicio;
  final String? largo;
  final String? ancho;
  final String? area; // Específico para solado
  final double espesorFijo; // Siempre 0.1m (10cm)

  Solado({
    required this.idSolado,
    required this.description,
    required this.resistencia,
    required this.factorDesperdicio,
    this.largo,
    this.ancho,
    this.area,
    this.espesorFijo = 0.1, // Valor fijo por defecto
  });

  Solado copyWith({
    String? idSolado,
    String? description,
    String? resistencia,
    String? factorDesperdicio,
    String? largo,
    String? ancho,
    String? area,
    double? espesorFijo,
  }) => Solado(
    idSolado: idSolado ?? this.idSolado,
    description: description ?? this.description,
    resistencia: resistencia ?? this.resistencia,
    factorDesperdicio: factorDesperdicio ?? this.factorDesperdicio,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    area: area ?? this.area,
    espesorFijo: espesorFijo ?? this.espesorFijo,
  )..id = id;
}