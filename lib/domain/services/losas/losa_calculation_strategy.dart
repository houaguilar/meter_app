import '../../entities/home/losas/losa.dart';

/// Strategy Pattern para cálculos específicos de cada tipo de losa
///
/// Cada tipo de losa (viguetas, tradicional, maciza) implementa esta interfaz
/// con su lógica específica de cálculo.
abstract class LosaCalculationStrategy {
  /// Calcula el volumen de concreto necesario en m³
  ///
  /// Incluye desperdicio de concreto ya aplicado
  ///
  /// [losa] Datos de la losa
  /// Returns: Volumen de concreto en m³
  double calcularVolumenConcreto(Losa losa);

  /// Calcula la cantidad de material aligerante (bovedillas o ladrillos)
  ///
  /// Incluye desperdicio de material aligerante ya aplicado
  /// Retorna null si el tipo de losa no usa material aligerante
  ///
  /// [losa] Datos de la losa
  /// Returns: Cantidad en unidades o null
  double? calcularMaterialAligerante(Losa losa);

  /// Obtiene la unidad del material aligerante
  ///
  /// Returns: 'und' para unidades, '' si no aplica
  String obtenerUnidadMaterialAligerante();

  /// Obtiene la descripción del material aligerante
  ///
  /// Para tradicional incluye dimensiones (ej: "Ladrillo hueco 30×30×15 cm")
  ///
  /// [losa] Datos de la losa
  /// Returns: Descripción del material
  String obtenerDescripcionMaterialAligerante(Losa losa);

  /// Valida que los datos de la losa sean correctos para este tipo
  ///
  /// [losa] Datos de la losa a validar
  /// Returns: null si es válido, mensaje de error si no
  String? validar(Losa losa);

  /// Calcula el área de la losa
  ///
  /// Usa área directa o calcula desde largo × ancho
  ///
  /// [losa] Datos de la losa
  /// Returns: Área en m²
  double calcularArea(Losa losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    }

    if (losa.largo != null && losa.ancho != null) {
      final largo = double.tryParse(losa.largo!) ?? 0.0;
      final ancho = double.tryParse(losa.ancho!) ?? 0.0;
      return largo * ancho;
    }

    return 0.0;
  }
}
