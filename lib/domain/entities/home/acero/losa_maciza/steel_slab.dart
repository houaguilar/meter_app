import 'package:isar/isar.dart';
import '../../../entities.dart';
import 'mesh_enums.dart';

part 'steel_slab.g.dart';

/// Barra de malla embebida para losas
@embedded
class SteelMeshBarEmbedded {
  String idSteelMeshBar = '';

  @enumerated
  MeshType meshType = MeshType.inferior;

  @enumerated
  MeshDirection direction = MeshDirection.horizontal;

  String diameter = '';
  double separation = 0.0;
}

/// Configuración de malla superior embebida
@embedded
class SuperiorMeshConfigEmbedded {
  String idConfig = '';
  bool enabled = false;
}

@collection
class SteelSlab {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idSteelSlab;
  final String description;
  final double waste; // Porcentaje de desperdicio (0.07 = 7%)
  final int elements; // Elementos similares

  // Dimensiones (SIN apoyo ni recubrimiento, como especificaste)
  final double length; // Largo en metros
  final double width; // Ancho en metros
  final double bendLength; // Doblez en metros

  // ✅ LISTAS EMBEBIDAS
  final List<SteelMeshBarEmbedded> meshBars;
  final SuperiorMeshConfigEmbedded superiorMeshConfig;

  final DateTime createdAt;
  final DateTime updatedAt;

  SteelSlab({
    required this.idSteelSlab,
    required this.description,
    required this.waste,
    required this.elements,
    required this.length,
    required this.width,
    required this.bendLength,
    required this.meshBars,
    required this.superiorMeshConfig,
    required this.createdAt,
    required this.updatedAt,
  });

  SteelSlab copyWith({
    String? idSteelSlab,
    String? description,
    double? waste,
    int? elements,
    double? length,
    double? width,
    double? bendLength,
    List<SteelMeshBarEmbedded>? meshBars,
    SuperiorMeshConfigEmbedded? superiorMeshConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SteelSlab(
    idSteelSlab: idSteelSlab ?? this.idSteelSlab,
    description: description ?? this.description,
    waste: waste ?? this.waste,
    elements: elements ?? this.elements,
    length: length ?? this.length,
    width: width ?? this.width,
    bendLength: bendLength ?? this.bendLength,
    meshBars: meshBars ?? this.meshBars,
    superiorMeshConfig: superiorMeshConfig ?? this.superiorMeshConfig,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  )..id = id;
}

