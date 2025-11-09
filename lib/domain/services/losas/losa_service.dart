import '../../entities/home/losas/losa.dart';
import '../../entities/home/losas/tipo_losa.dart';
import 'concreto_materials_calculator.dart';
import 'losa_calculation_strategy.dart';
import 'strategies/maciza_strategy.dart';
import 'strategies/tradicional_strategy.dart';
import 'strategies/viguetas_strategy.dart';

/// Servicio unificado para cálculos de losas
///
/// Utiliza Strategy Pattern para delegar cálculos específicos según tipo de losa
class LosaService {
  final LosaCalculationStrategy _strategy;
  final ConcretoMaterialsCalculator _concretoCalculator;

  LosaService._(this._strategy) : _concretoCalculator = ConcretoMaterialsCalculator();

  /// Factory constructor que crea el servicio apropiado según tipo de losa
  factory LosaService(TipoLosa tipo) {
    final strategy = _getStrategy(tipo);
    return LosaService._(strategy);
  }

  /// Obtiene la strategy apropiada según tipo de losa
  static LosaCalculationStrategy _getStrategy(TipoLosa tipo) {
    switch (tipo) {
      case TipoLosa.viguetasPrefabricadas:
        return ViguetasStrategy();
      case TipoLosa.tradicional:
        return TradicionalStrategy();
      case TipoLosa.maciza:
        return MacizaStrategy();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS DE ÁREA Y VOLUMEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calcula el área de la losa en m²
  double calcularArea(Losa losa) {
    return _strategy.calcularArea(losa);
  }

  /// Calcula el volumen de concreto necesario en m³
  ///
  /// Ya incluye desperdicio de concreto
  double calcularVolumenConcreto(Losa losa) {
    return _strategy.calcularVolumenConcreto(losa);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS DE MATERIALES DE CONCRETO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calcula la cantidad de cemento en bolsas
  double calcularCemento(Losa losa) {
    final volumen = calcularVolumenConcreto(losa);
    return _concretoCalculator.calcularCemento(volumen, losa.resistenciaConcreto);
  }

  /// Calcula la cantidad de arena gruesa en m³
  double calcularArenaGruesa(Losa losa) {
    final volumen = calcularVolumenConcreto(losa);
    return _concretoCalculator.calcularArenaGruesa(volumen, losa.resistenciaConcreto);
  }

  /// Calcula la cantidad de piedra chancada en m³
  double calcularPiedraChancada(Losa losa) {
    final volumen = calcularVolumenConcreto(losa);
    return _concretoCalculator.calcularPiedraChancada(volumen, losa.resistenciaConcreto);
  }

  /// Calcula la cantidad de agua en m³
  double calcularAgua(Losa losa) {
    final volumen = calcularVolumenConcreto(losa);
    return _concretoCalculator.calcularAgua(volumen, losa.resistenciaConcreto);
  }

  /// Calcula la cantidad de aditivo plastificante en litros
  double calcularAditivoPlastificante(Losa losa) {
    final volumen = calcularVolumenConcreto(losa);
    return _concretoCalculator.calcularAditivoPlastificante(volumen, losa.resistenciaConcreto);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÁLCULOS DE MATERIAL ALIGERANTE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calcula la cantidad de material aligerante
  ///
  /// Retorna null si el tipo de losa no usa material aligerante (maciza)
  /// Ya incluye desperdicio de material
  double? calcularMaterialAligerante(Losa losa) {
    return _strategy.calcularMaterialAligerante(losa);
  }

  /// Obtiene la unidad del material aligerante
  ///
  /// Retorna 'und' para bovedillas/ladrillos, '' para maciza
  String obtenerUnidadMaterialAligerante() {
    return _strategy.obtenerUnidadMaterialAligerante();
  }

  /// Obtiene la descripción del material aligerante
  ///
  /// Ejemplos:
  /// - "Bovedillas"
  /// - "Ladrillo hueco 30×30×15 cm"
  /// - "" (para maciza)
  String obtenerDescripcionMaterialAligerante(Losa losa) {
    return _strategy.obtenerDescripcionMaterialAligerante(losa);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Valida que los datos de la losa sean correctos
  ///
  /// Retorna null si es válido, mensaje de error si no
  String? validar(Losa losa) {
    return _strategy.validar(losa);
  }

  /// Verifica si los datos de la losa son válidos
  bool esValido(Losa losa) {
    return validar(losa) == null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INFORMACIÓN DE CONFIGURACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Obtiene las alturas válidas para el tipo de losa
  static List<String> getAlturasValidas(TipoLosa tipo) {
    switch (tipo) {
      case TipoLosa.viguetasPrefabricadas:
        return ViguetasStrategy.alturasValidas;
      case TipoLosa.tradicional:
        return TradicionalStrategy.alturasValidas;
      case TipoLosa.maciza:
        return MacizaStrategy.alturasValidas;
    }
  }

  /// Obtiene las resistencias válidas para el tipo de losa
  static List<String> getResistenciasValidas(TipoLosa tipo) {
    switch (tipo) {
      case TipoLosa.viguetasPrefabricadas:
        return ViguetasStrategy.resistenciasValidas;
      case TipoLosa.tradicional:
        return TradicionalStrategy.resistenciasValidas;
      case TipoLosa.maciza:
        return MacizaStrategy.resistenciasValidas;
    }
  }

  /// Obtiene los tipos de ladrillo válidos (solo para tradicional)
  static List<String>? getTiposLadrilloValidos(TipoLosa tipo) {
    if (tipo == TipoLosa.tradicional) {
      return TradicionalStrategy.tiposLadrilloValidos;
    }
    return null;
  }

  /// Obtiene el material fijo para viguetas
  static String? getMaterialFijo(TipoLosa tipo) {
    if (tipo == TipoLosa.viguetasPrefabricadas) {
      return ViguetasStrategy.MATERIAL_FIJO;
    }
    return null;
  }
}
