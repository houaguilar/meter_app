// lib/domain/entities/home/acero/zapata/steel_foundation.dart
import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'steel_footing.g.dart';

@collection
class SteelFooting {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idSteelFooting;
  final String description;
  final double waste; // Porcentaje de desperdicio (0.07 = 7%)
  final int elements; // Elementos similares
  final double cover; // Recubrimiento en metros

  // Dimensiones de la zapata
  final double length; // Largo en metros
  final double width; // Ancho en metros

  // Configuración de malla inferior (siempre habilitada)
  final String inferiorHorizontalDiameter;
  final double inferiorHorizontalSeparation;
  final String inferiorVerticalDiameter;
  final double inferiorVerticalSeparation;
  final double inferiorBendLength; // Doblez en metros

  // Configuración de malla superior (opcional)
  final bool hasSuperiorMesh; // Si tiene malla superior
  final String? superiorHorizontalDiameter;
  final double? superiorHorizontalSeparation;
  final String? superiorVerticalDiameter;
  final double? superiorVerticalSeparation;

  final DateTime createdAt;
  final DateTime updatedAt;

  SteelFooting({
    required this.idSteelFooting,
    required this.description,
    required this.waste,
    required this.elements,
    required this.cover,
    required this.length,
    required this.width,
    required this.inferiorHorizontalDiameter,
    required this.inferiorHorizontalSeparation,
    required this.inferiorVerticalDiameter,
    required this.inferiorVerticalSeparation,
    required this.inferiorBendLength,
    required this.hasSuperiorMesh,
    this.superiorHorizontalDiameter,
    this.superiorHorizontalSeparation,
    this.superiorVerticalDiameter,
    this.superiorVerticalSeparation,
    required this.createdAt,
    required this.updatedAt,
  });

  SteelFooting copyWith({
    String? idSteelFooting,
    String? description,
    double? waste,
    int? elements,
    double? cover,
    double? length,
    double? width,
    String? inferiorHorizontalDiameter,
    double? inferiorHorizontalSeparation,
    String? inferiorVerticalDiameter,
    double? inferiorVerticalSeparation,
    double? inferiorBendLength,
    bool? hasSuperiorMesh,
    String? superiorHorizontalDiameter,
    double? superiorHorizontalSeparation,
    String? superiorVerticalDiameter,
    double? superiorVerticalSeparation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SteelFooting(
    idSteelFooting: idSteelFooting ?? this.idSteelFooting,
    description: description ?? this.description,
    waste: waste ?? this.waste,
    elements: elements ?? this.elements,
    cover: cover ?? this.cover,
    length: length ?? this.length,
    width: width ?? this.width,
    inferiorHorizontalDiameter: inferiorHorizontalDiameter ?? this.inferiorHorizontalDiameter,
    inferiorHorizontalSeparation: inferiorHorizontalSeparation ?? this.inferiorHorizontalSeparation,
    inferiorVerticalDiameter: inferiorVerticalDiameter ?? this.inferiorVerticalDiameter,
    inferiorVerticalSeparation: inferiorVerticalSeparation ?? this.inferiorVerticalSeparation,
    inferiorBendLength: inferiorBendLength ?? this.inferiorBendLength,
    hasSuperiorMesh: hasSuperiorMesh ?? this.hasSuperiorMesh,
    superiorHorizontalDiameter: superiorHorizontalDiameter ?? this.superiorHorizontalDiameter,
    superiorHorizontalSeparation: superiorHorizontalSeparation ?? this.superiorHorizontalSeparation,
    superiorVerticalDiameter: superiorVerticalDiameter ?? this.superiorVerticalDiameter,
    superiorVerticalSeparation: superiorVerticalSeparation ?? this.superiorVerticalSeparation,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  )..id = id;
}

