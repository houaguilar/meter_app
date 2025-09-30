// lib/domain/entities/home/acero/losa/superior_mesh_config.dart
import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/home/acero/losa_maciza/steel_slab.dart';

part 'superior_mesh_config.g.dart';

@collection
class SuperiorMeshConfig {
  Id id = Isar.autoIncrement;

  @Index()
  late final int steelSlabId;

  final IsarLink<SteelSlab> steelSlab = IsarLink<SteelSlab>();

  final String idConfig;
  final bool enabled; // Si la malla superior está habilitada

  SuperiorMeshConfig({
    required this.idConfig,
    required this.enabled,
  });

  SuperiorMeshConfig copyWith({
    String? idConfig,
    bool? enabled,
  }) => SuperiorMeshConfig(
    idConfig: idConfig ?? this.idConfig,
    enabled: enabled ?? this.enabled,
  )..id = id;
}

