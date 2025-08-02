import '../entities/entities.dart';

/// Servicio simplificado para operaciones básicas de ladrillo
class LadrilloService {

  /// Calcula el área de un ladrillo
  double? calcularArea(Ladrillo ladrillo) {
    if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
      return double.tryParse(ladrillo.area!);
    }
    if (ladrillo.largo != null && ladrillo.altura != null) {
      final largo = double.tryParse(ladrillo.largo!);
      final altura = double.tryParse(ladrillo.altura!);
      if (largo != null && altura != null) {
        return largo * altura;
      }
    }
    return null;
  }

  /// Valida que un ladrillo tenga los datos mínimos necesarios
  bool esValido(Ladrillo ladrillo) {
    return (ladrillo.largo != null && ladrillo.altura != null) ||
        (ladrillo.area != null && ladrillo.area!.isNotEmpty);
  }

  /// Obtiene información descriptiva del ladrillo
  String getDescripcionCompleta(Ladrillo ladrillo) {
    final area = calcularArea(ladrillo);
    final areaStr = area != null ? area.toStringAsFixed(2) : 'N/A';

    return '''
Descripción: ${ladrillo.description}
Tipo: ${ladrillo.tipoLadrillo}
Asentado: ${ladrillo.tipoAsentado}
Área: $areaStr m²
Proporción mortero: 1:${ladrillo.proporcionMortero}
''';
  }

  /// Valida los datos de entrada antes de crear un ladrillo
  ValidationResult validarDatos({
    required String description,
    required String tipoLadrillo,
    required String factorDesperdicio,
    required String factorMortero,
    required String proporcionMortero,
    required String tipoAsentado,
    String? largo,
    String? altura,
    String? area,
  }) {
    final errores = <String>[];

    // Validar descripción
    if (description.trim().isEmpty) {
      errores.add('La descripción es obligatoria');
    }

    // Validar que tenga área o medidas
    final tieneArea = area != null && area.isNotEmpty;
    final tieneMedidas = largo != null && largo.isNotEmpty &&
        altura != null && altura.isNotEmpty;

    if (!tieneArea && !tieneMedidas) {
      errores.add('Debe proporcionar área o largo y altura');
    }

    // Validar factores numéricos
    if (double.tryParse(factorDesperdicio) == null) {
      errores.add('Factor de desperdicio de ladrillo inválido');
    }

    if (double.tryParse(factorMortero) == null) {
      errores.add('Factor de desperdicio de mortero inválido');
    }

    // Validar área si se proporciona
    if (tieneArea) {
      final areaNum = double.tryParse(area);
      if (areaNum == null || areaNum <= 0) {
        errores.add('El área debe ser un número mayor a 0');
      }
    }

    // Validar medidas si se proporcionan
    if (tieneMedidas) {
      final largoNum = double.tryParse(largo);
      final alturaNum = double.tryParse(altura);

      if (largoNum == null || largoNum <= 0) {
        errores.add('El largo debe ser un número mayor a 0');
      }

      if (alturaNum == null || alturaNum <= 0) {
        errores.add('La altura debe ser un número mayor a 0');
      }
    }

    return ValidationResult(
      esValido: errores.isEmpty,
      errores: errores,
    );
  }

  /// Obtiene las dimensiones estándar de un tipo de ladrillo
  Map<String, double>? getDimensionesEstandar(String tipoLadrillo) {
    const dimensiones = {
      'Pandereta': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
      'Pandereta1': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
      'Pandereta2': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
      'Kingkong': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
      'Kingkong1': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
      'Kingkong2': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
      'Común': {'largo': 24.0, 'ancho': 12.0, 'alto': 8.0},
    };

    final tipoNormalizado = _normalizarTipoLadrillo(tipoLadrillo);
    return dimensiones[tipoNormalizado];
  }

  /// Normaliza el tipo de ladrillo
  String _normalizarTipoLadrillo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'pandereta':
      case 'pandereta1':
      case 'pandereta2':
        return 'Pandereta';
      case 'kingkong':
      case 'kingkong1':
      case 'kingkong2':
      case 'king kong':
        return 'Kingkong';
      case 'común':
      case 'comun':
        return 'Común';
      default:
        return 'Pandereta';
    }
  }
}

/// Clase para resultado de validación
class ValidationResult {
  final bool esValido;
  final List<String> errores;

  const ValidationResult({
    required this.esValido,
    required this.errores,
  });

  String get mensajeError => errores.join(', ');
  bool get tieneErrores => errores.isNotEmpty;
}