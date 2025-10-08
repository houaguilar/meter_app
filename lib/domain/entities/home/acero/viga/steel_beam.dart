// lib/domain/entities/home/acero/viga/steel_beam.dart
import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'steel_beam.g.dart';

/// Barra de acero embebida para vigas
@embedded
class SteelBeamBarEmbedded {
  String idSteelBar = '';
  int quantity = 0;
  String diameter = '';
}

/// Distribución de estribos embebida para vigas
@embedded
class SteelBeamStirrupDistributionEmbedded {
  String idStirrupDistribution = '';
  int quantity = 0;
  double separation = 0.0;
}

@collection
class SteelBeam {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idSteelBeam;
  final String description;
  final double waste; // Porcentaje de desperdicio (0.07 = 7%)
  final int elements; // Elementos similares
  final double cover; // Recubrimiento en metros

  // Dimensiones
  final double height; // Alto en metros
  final double length; // Largo en metros
  final double width; // Ancho en metros
  final double supportA1; // Apoyo A1 en metros
  final double supportA2; // Apoyo A2 en metros

  // Acero longitudinal
  final double bendLength; // Doblez en metros
  final bool useSplice; // Usar empalme

  // Estribos
  final String stirrupDiameter; // Diámetro del estribo (guardado como string)
  final double stirrupBendLength; // Doblez en metros
  final double restSeparation; // Resto @ en metros

  // ✅ LISTAS EMBEBIDAS
  final List<SteelBeamBarEmbedded> steelBars;
  final List<SteelBeamStirrupDistributionEmbedded> stirrupDistributions;

  final DateTime createdAt;
  final DateTime updatedAt;

  SteelBeam({
    required this.idSteelBeam,
    required this.description,
    required this.waste,
    required this.elements,
    required this.cover,
    required this.height,
    required this.length,
    required this.width,
    required this.supportA1,
    required this.supportA2,
    required this.bendLength,
    required this.useSplice,
    required this.stirrupDiameter,
    required this.stirrupBendLength,
    required this.restSeparation,
    required this.steelBars,
    required this.stirrupDistributions,
    required this.createdAt,
    required this.updatedAt,
  });

  SteelBeam copyWith({
    String? idSteelBeam,
    String? description,
    double? waste,
    int? elements,
    double? cover,
    double? height,
    double? length,
    double? width,
    double? supportA1,
    double? supportA2,
    double? bendLength,
    bool? useSplice,
    String? stirrupDiameter,
    double? stirrupBendLength,
    double? restSeparation,
    List<SteelBeamBarEmbedded>? steelBars,
    List<SteelBeamStirrupDistributionEmbedded>? stirrupDistributions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SteelBeam(
    idSteelBeam: idSteelBeam ?? this.idSteelBeam,
    description: description ?? this.description,
    waste: waste ?? this.waste,
    elements: elements ?? this.elements,
    cover: cover ?? this.cover,
    height: height ?? this.height,
    length: length ?? this.length,
    width: width ?? this.width,
    supportA1: supportA1 ?? this.supportA1,
    supportA2: supportA2 ?? this.supportA2,
    bendLength: bendLength ?? this.bendLength,
    useSplice: useSplice ?? this.useSplice,
    stirrupDiameter: stirrupDiameter ?? this.stirrupDiameter,
    stirrupBendLength: stirrupBendLength ?? this.stirrupBendLength,
    restSeparation: restSeparation ?? this.restSeparation,
    steelBars: steelBars ?? this.steelBars,
    stirrupDistributions: stirrupDistributions ?? this.stirrupDistributions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  )..id = id;
}
