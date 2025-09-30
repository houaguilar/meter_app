
import 'package:isar/isar.dart';
import '../../../entities.dart';

part 'steel_column.g.dart';

@collection
class SteelColumn {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  final String idSteelColumn;
  final String description;
  final double waste; // Porcentaje de desperdicio (0.07 = 7%)
  final int elements; // Elementos similares
  final double cover; // Recubrimiento en metros

  // Dimensiones básicas
  final double height; // Alto de columna en metros
  final double length; // Largo en metros  
  final double width; // Ancho en metros

  // Datos específicos de zapata (solo si hasFooting = true)
  final bool hasFooting; // Si tiene zapata
  final double footingHeight; // Altura de zapata en metros
  final double footingBend; // Doblez de zapata en metros

  // Acero longitudinal (NO tiene doblez como las vigas)
  final bool useSplice; // Usar empalme

  // Estribos
  final String stirrupDiameter; // Diámetro del estribo
  final double stirrupBendLength; // Doblez en metros
  final double restSeparation; // Resto @ en metros

  final DateTime createdAt;
  final DateTime updatedAt;

  SteelColumn({
    required this.idSteelColumn,
    required this.description,
    required this.waste,
    required this.elements,
    required this.cover,
    required this.height,
    required this.length,
    required this.width,
    required this.hasFooting,
    required this.footingHeight,
    required this.footingBend,
    required this.useSplice,
    required this.stirrupDiameter,
    required this.stirrupBendLength,
    required this.restSeparation,
    required this.createdAt,
    required this.updatedAt,
  });

  SteelColumn copyWith({
    String? idSteelColumn,
    String? description,
    double? waste,
    int? elements,
    double? cover,
    double? height,
    double? length,
    double? width,
    bool? hasFooting,
    double? footingHeight,
    double? footingBend,
    bool? useSplice,
    String? stirrupDiameter,
    double? stirrupBendLength,
    double? restSeparation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SteelColumn(
    idSteelColumn: idSteelColumn ?? this.idSteelColumn,
    description: description ?? this.description,
    waste: waste ?? this.waste,
    elements: elements ?? this.elements,
    cover: cover ?? this.cover,
    height: height ?? this.height,
    length: length ?? this.length,
    width: width ?? this.width,
    hasFooting: hasFooting ?? this.hasFooting,
    footingHeight: footingHeight ?? this.footingHeight,
    footingBend: footingBend ?? this.footingBend,
    useSplice: useSplice ?? this.useSplice,
    stirrupDiameter: stirrupDiameter ?? this.stirrupDiameter,
    stirrupBendLength: stirrupBendLength ?? this.stirrupBendLength,
    restSeparation: restSeparation ?? this.restSeparation,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  )..id = id;
}
