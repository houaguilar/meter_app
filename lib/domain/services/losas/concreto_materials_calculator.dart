/// Calculadora de materiales de concreto compartida por todos los tipos de losas
///
/// Centraliza los factores y cálculos de cemento, arena, piedra, agua y aditivo
/// según la resistencia del concreto especificada.
class ConcretoMaterialsCalculator {
  /// Factores de materiales por resistencia de concreto
  ///
  /// Valores actualizados según especificaciones:
  /// - cemento: bolsas por m³
  /// - arena: m³ por m³ de concreto
  /// - piedra: m³ por m³ de concreto
  /// - agua: m³ por m³ de concreto
  /// - aditivo: litros por m³ de concreto
  static const Map<String, Map<String, double>> FACTORES_MATERIALES = {
    '140 kg/cm²': {
      'cemento': 7.01,
      'arena': 0.56,
      'piedra': 0.64,
      'agua': 0.184,
      'aditivo': 2.5,
    },
    '175 kg/cm²': {
      'cemento': 8.43,
      'arena': 0.54,
      'piedra': 0.55,
      'agua': 0.185,
      'aditivo': 2.5,
    },
    '210 kg/cm²': {
      'cemento': 9.73,
      'arena': 0.52,
      'piedra': 0.53,
      'agua': 0.186,
      'aditivo': 2.5,
    },
    '245 kg/cm²': {
      'cemento': 11.50,
      'arena': 0.50,
      'piedra': 0.51,
      'agua': 0.187,
      'aditivo': 2.5,
    },
    '280 kg/cm²': {
      'cemento': 13.34,
      'arena': 0.45,
      'piedra': 0.51,
      'agua': 0.189,
      'aditivo': 2.5,
    },
  };

  /// Resistencia por defecto si no se encuentra la especificada
  static const String RESISTENCIA_DEFAULT = '210 kg/cm²';

  /// Obtiene los factores para una resistencia específica
  Map<String, double> _getFactores(String resistencia) {
    return FACTORES_MATERIALES[resistencia] ??
           FACTORES_MATERIALES[RESISTENCIA_DEFAULT]!;
  }

  /// Calcula la cantidad de cemento en bolsas
  ///
  /// [volumen] Volumen de concreto en m³
  /// [resistencia] Resistencia del concreto (ej: '210 kg/cm²')
  ///
  /// Returns: Cantidad de cemento en bolsas
  double calcularCemento(double volumen, String resistencia) {
    final factores = _getFactores(resistencia);
    return volumen * factores['cemento']!;
  }

  /// Calcula la cantidad de arena gruesa en m³
  ///
  /// [volumen] Volumen de concreto en m³
  /// [resistencia] Resistencia del concreto
  ///
  /// Returns: Cantidad de arena gruesa en m³
  double calcularArenaGruesa(double volumen, String resistencia) {
    final factores = _getFactores(resistencia);
    return volumen * factores['arena']!;
  }

  /// Calcula la cantidad de piedra chancada en m³
  ///
  /// [volumen] Volumen de concreto en m³
  /// [resistencia] Resistencia del concreto
  ///
  /// Returns: Cantidad de piedra chancada en m³
  double calcularPiedraChancada(double volumen, String resistencia) {
    final factores = _getFactores(resistencia);
    return volumen * factores['piedra']!;
  }

  /// Calcula la cantidad de agua en m³
  ///
  /// [volumen] Volumen de concreto en m³
  /// [resistencia] Resistencia del concreto
  ///
  /// Returns: Cantidad de agua en m³
  double calcularAgua(double volumen, String resistencia) {
    final factores = _getFactores(resistencia);
    return volumen * factores['agua']!;
  }

  /// Calcula la cantidad de aditivo plastificante en litros
  ///
  /// [volumen] Volumen de concreto en m³
  /// [resistencia] Resistencia del concreto
  ///
  /// Returns: Cantidad de aditivo plastificante en litros
  double calcularAditivoPlastificante(double volumen, String resistencia) {
    final factores = _getFactores(resistencia);
    return volumen * factores['aditivo']!;
  }

  /// Obtiene todas las resistencias disponibles
  static List<String> get resistenciasDisponibles {
    return FACTORES_MATERIALES.keys.toList();
  }

  /// Verifica si una resistencia es válida
  static bool esResistenciaValida(String resistencia) {
    return FACTORES_MATERIALES.containsKey(resistencia);
  }
}
