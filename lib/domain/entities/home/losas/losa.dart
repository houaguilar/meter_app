import 'package:isar/isar.dart';
import '../../entities.dart';
import 'tipo_losa.dart';

part 'losa.g.dart';

/// Entidad unificada para todos los tipos de losas
///
/// Soporta:
/// - Losa aligerada con viguetas prefabricadas (bovedillas)
/// - Losa aligerada tradicional (ladrillos hueco o casetón)
/// - Losa maciza (concreto sólido)
@collection
class Losa {
  Id id = Isar.autoIncrement;

  @Index()
  late final int metradoId;

  final IsarLink<Metrado> metrado = IsarLink<Metrado>();

  /// Identificador único de la losa
  final String idLosa;

  /// Descripción de la losa
  final String description;

  /// Tipo de losa (viguetas, tradicional, maciza)
  ///
  /// Almacenado como String para compatibilidad con Isar
  /// Usar TipoLosa.fromString() y TipoLosa.toStorageString()
  @Index()
  final String tipo;

  /// Altura de la losa
  ///
  /// Viguetas/Tradicional: '17 cm', '20 cm', '25 cm'
  /// Maciza: '15 cm', '20 cm', '25 cm'
  final String altura;

  /// Material aligerante (solo para losas aligeradas)
  ///
  /// Viguetas: 'Bovedillas' (fijo)
  /// Tradicional: 'Ladrillo hueco' o 'Ladrillo casetón'
  /// Maciza: null
  final String? materialAligerante;

  /// Resistencia del concreto
  ///
  /// Valores comunes: '210 kg/cm²', '280 kg/cm²'
  final String resistenciaConcreto;

  /// Desperdicio de material aligerante (%)
  ///
  /// Solo aplica para losas aligeradas
  /// Default: 7%
  final String? desperdicioMaterialAligerante;

  /// Desperdicio de concreto (%)
  ///
  /// Aplica para todos los tipos
  /// Default: 5%
  final String desperdicioConcreto;

  /// Largo de la losa en metros
  ///
  /// Opcional si se proporciona área directa
  final String? largo;

  /// Ancho de la losa en metros
  ///
  /// Opcional si se proporciona área directa
  final String? ancho;

  /// Área directa de la losa en m²
  ///
  /// Opcional si se proporcionan largo y ancho
  final String? area;

  Losa({
    required this.idLosa,
    required this.description,
    required this.tipo,
    required this.altura,
    required this.resistenciaConcreto,
    required this.desperdicioConcreto,
    this.materialAligerante,
    this.desperdicioMaterialAligerante,
    this.largo,
    this.ancho,
    this.area,
  });

  /// Obtiene el tipo de losa como enum
  @ignore
  TipoLosa get tipoLosa => TipoLosa.fromString(tipo);

  /// Copia la losa con modificaciones
  Losa copyWith({
    String? idLosa,
    String? description,
    String? tipo,
    String? altura,
    String? materialAligerante,
    String? resistenciaConcreto,
    String? desperdicioMaterialAligerante,
    String? desperdicioConcreto,
    String? largo,
    String? ancho,
    String? area,
  }) =>
      Losa(
        idLosa: idLosa ?? this.idLosa,
        description: description ?? this.description,
        tipo: tipo ?? this.tipo,
        altura: altura ?? this.altura,
        materialAligerante: materialAligerante ?? this.materialAligerante,
        resistenciaConcreto: resistenciaConcreto ?? this.resistenciaConcreto,
        desperdicioMaterialAligerante:
            desperdicioMaterialAligerante ?? this.desperdicioMaterialAligerante,
        desperdicioConcreto: desperdicioConcreto ?? this.desperdicioConcreto,
        largo: largo ?? this.largo,
        ancho: ancho ?? this.ancho,
        area: area ?? this.area,
      )..id = id;

  /// Crea una losa desde la antigua LosaAligerada
  ///
  /// Usado para migración de datos
  factory Losa.fromLosaAligerada(dynamic losaAligerada) {
    // Determinar tipo según material
    String tipo;
    if (losaAligerada.materialAligerado == 'Poliestireno') {
      // Antiguo poliestireno se mapea a bovedillas (viguetas)
      tipo = TipoLosa.viguetasPrefabricadas.toStorageString();
    } else {
      // Ladrillo hueco se mapea a tradicional
      tipo = TipoLosa.tradicional.toStorageString();
    }

    return Losa(
      idLosa: losaAligerada.idLosaAligerada,
      description: losaAligerada.description,
      tipo: tipo,
      altura: losaAligerada.altura,
      materialAligerante: losaAligerada.materialAligerado,
      resistenciaConcreto: losaAligerada.resistenciaConcreto,
      desperdicioMaterialAligerante: losaAligerada.desperdicioLadrillo,
      desperdicioConcreto: losaAligerada.desperdicioConcreto,
      largo: losaAligerada.largo,
      ancho: losaAligerada.ancho,
      area: losaAligerada.area,
    )..id = losaAligerada.id;
  }

  @override
  String toString() {
    return 'Losa{id: $id, tipo: $tipo, description: $description, altura: $altura, area: ${area ?? "$largo×$ancho"}}';
  }
}
