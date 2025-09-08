import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/home/acero/viga/steel_beam.dart';

part 'stirrup_distribution.g.dart';

@collection
class StirrupDistribution {
  Id id = Isar.autoIncrement;

  @Index()
  late final int steelBeamId;

  final IsarLink<SteelBeam> steelBeam = IsarLink<SteelBeam>();

  final String idStirrupDistribution;
  final int quantity; // Cantidad de estribos
  final double separation; // Separación en metros

  StirrupDistribution({
    required this.idStirrupDistribution,
    required this.quantity,
    required this.separation,
  });

  StirrupDistribution copyWith({
    String? idStirrupDistribution,
    int? quantity,
    double? separation,
  }) => StirrupDistribution(
    idStirrupDistribution: idStirrupDistribution ?? this.idStirrupDistribution,
    quantity: quantity ?? this.quantity,
    separation: separation ?? this.separation,
  )..id = id;
}