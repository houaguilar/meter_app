// lib/domain/entities/home/acero/losa/steel_mesh_bar.dart
import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/home/acero/losa_maciza/steel_slab.dart';
import 'mesh_enums.dart';

part 'steel_mesh_bar.g.dart';

@collection
class SteelMeshBar {
  Id id = Isar.autoIncrement;

  @Index()
  late final int steelSlabId;

  final IsarLink<SteelSlab> steelSlab = IsarLink<SteelSlab>();

  final String idSteelMeshBar;

  @enumerated
  final MeshType meshType; // inferior o superior

  @enumerated
  final MeshDirection direction; // horizontal o vertical

  final String diameter; // Diámetro como string (ej: "3/8", "1/2")
  final double separation; // Separación en metros

  SteelMeshBar({
    required this.idSteelMeshBar,
    required this.meshType,
    required this.direction,
    required this.diameter,
    required this.separation,
  });

  SteelMeshBar copyWith({
    String? idSteelMeshBar,
    MeshType? meshType,
    MeshDirection? direction,
    String? diameter,
    double? separation,
  }) => SteelMeshBar(
    idSteelMeshBar: idSteelMeshBar ?? this.idSteelMeshBar,
    meshType: meshType ?? this.meshType,
    direction: direction ?? this.direction,
    diameter: diameter ?? this.diameter,
    separation: separation ?? this.separation,
  )..id = id;
}
