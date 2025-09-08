import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/home/acero/viga/steel_beam.dart';

part 'steel_bar.g.dart';

@collection
class SteelBar {
  Id id = Isar.autoIncrement;

  @Index()
  late final int steelBeamId;

  final IsarLink<SteelBeam> steelBeam = IsarLink<SteelBeam>();

  final String idSteelBar;
  final int quantity; // Cantidad de barras
  final String diameter; // Diámetro como string (ej: "3/4", "1/2")

  SteelBar({
    required this.idSteelBar,
    required this.quantity,
    required this.diameter,
  });

  SteelBar copyWith({
    String? idSteelBar,
    int? quantity,
    String? diameter,
  }) => SteelBar(
    idSteelBar: idSteelBar ?? this.idSteelBar,
    quantity: quantity ?? this.quantity,
    diameter: diameter ?? this.diameter,
  )..id = id;
}
