// lib/domain/services/validation/result_validation_service.dart

import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';

/// Servicio de validación para resultados de cálculos
class ResultValidationService {

  /// Valida una lista de resultados
  static ValidationResult validateResults(List<dynamic> results) {
    try {
      if (results.isEmpty) {
        return ValidationResult.error('La lista de resultados está vacía');
      }

      // Validar que todos los elementos sean del mismo tipo
      final firstType = results.first.runtimeType;
      if (!results.every((result) => result.runtimeType == firstType)) {
        return ValidationResult.error('Los resultados contienen tipos mixtos');
      }

      // Validar según el tipo específico
      final firstResult = results.first;

      if (firstResult is Ladrillo) {
        return _validateLadrillos(results.cast<Ladrillo>());
      } else if (firstResult is Piso) {
        return _validatePisos(results.cast<Piso>());
      } else if (firstResult is LosaAligerada) {
        return _validateLosas(results.cast<LosaAligerada>());
      } else if (firstResult is Tarrajeo) {
        return _validateTarrajeos(results.cast<Tarrajeo>());
      } else if (firstResult is Columna) {
        return _validateColumnas(results.cast<Columna>());
      } else if (firstResult is Viga) {
        return _validateVigas(results.cast<Viga>());
      }

      return ValidationResult.error('Tipo de resultado no soportado: ${firstResult.runtimeType}');
    } catch (e) {
      return ValidationResult.error('Error durante la validación: $e');
    }
  }

  /// Valida ladrillos
  static ValidationResult _validateLadrillos(List<Ladrillo> ladrillos) {
    final errors = <String>[];
    final warnings = <String>[];

    for (int i = 0; i < ladrillos.length; i++) {
      final ladrillo = ladrillos[i];
      final prefix = 'Ladrillo ${i + 1}';

      // Validaciones críticas
      if (ladrillo.description.trim().isEmpty) {
        errors.add('$prefix: La descripción es requerida');
      }

      if (ladrillo.tipoLadrillo.trim().isEmpty) {
        errors.add('$prefix: El tipo de ladrillo es requerido');
      }

      if (ladrillo.tipoAsentado.trim().isEmpty) {
        errors.add('$prefix: El tipo de asentado es requerido');
      }

      // Validar área o dimensiones
      final hasArea = ladrillo.area != null && ladrillo.area!.isNotEmpty;
      final hasDimensions = ladrillo.largo != null &&
          ladrillo.altura != null &&
          ladrillo.largo!.isNotEmpty &&
          ladrillo.altura!.isNotEmpty;

      if (!hasArea && !hasDimensions) {
        errors.add('$prefix: Debe tener área o dimensiones (largo y altura)');
      }

      // Validar valores numéricos
      if (hasArea) {
        final area = double.tryParse(ladrillo.area!);
        if (area == null || area <= 0) {
          errors.add('$prefix: El área debe ser un número positivo');
        } else if (area > 10000) { // 10,000 m² es excesivo
          warnings.add('$prefix: El área parece excesivamente grande (${area.toStringAsFixed(2)} m²)');
        }
      }

      if (hasDimensions) {
        final largo = double.tryParse(ladrillo.largo!);
        final altura = double.tryParse(ladrillo.altura!);

        if (largo == null || largo <= 0) {
          errors.add('$prefix: El largo debe ser un número positivo');
        } else if (largo > 1000) { // 1000m es excesivo
          warnings.add('$prefix: El largo parece excesivamente grande (${largo.toStringAsFixed(2)} m)');
        }

        if (altura == null || altura <= 0) {
          errors.add('$prefix: La altura debe ser un número positivo');
        } else if (altura > 100) { // 100m es excesivo
          warnings.add('$prefix: La altura parece excesivamente grande (${altura.toStringAsFixed(2)} m)');
        }
      }

      // Validar factores de desperdicio
      final factorLadrillo = double.tryParse(ladrillo.factorDesperdicio);
      if (factorLadrillo == null || factorLadrillo < 0 || factorLadrillo > 100) {
        errors.add('$prefix: El factor de desperdicio de ladrillo debe estar entre 0% y 100%');
      }

      final factorMortero = double.tryParse(ladrillo.factorDesperdicioMortero);
      if (factorMortero == null || factorMortero < 0 || factorMortero > 100) {
        errors.add('$prefix: El factor de desperdicio de mortero debe estar entre 0% y 100%');
      }

      // Validar proporción de mortero
      if (!_isValidProporcionMortero(ladrillo.proporcionMortero)) {
        errors.add('$prefix: Proporción de mortero inválida (${ladrillo.proporcionMortero})');
      }

      // Validar tipo de asentado
      if (!_isValidTipoAsentado(ladrillo.tipoAsentado)) {
        errors.add('$prefix: Tipo de asentado inválido (${ladrillo.tipoAsentado})');
      }

      // Validaciones de seguridad
      if (_containsSuspiciousContent(ladrillo.description)) {
        errors.add('$prefix: La descripción contiene caracteres no permitidos');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida pisos
  static ValidationResult _validatePisos(List<Piso> pisos) {
    final errors = <String>[];
    final warnings = <String>[];

    for (int i = 0; i < pisos.length; i++) {
      final piso = pisos[i];
      final prefix = 'Piso ${i + 1}';

      // Validaciones básicas
      if (piso.description.trim().isEmpty) {
        errors.add('$prefix: La descripción es requerida');
      }

      if (piso.tipo.trim().isEmpty) {
        errors.add('$prefix: El tipo de piso es requerido');
      }

      // Validar espesor
      final espesor = double.tryParse(piso.espesor);
      if (espesor == null || espesor <= 0) {
        errors.add('$prefix: El espesor debe ser un número positivo');
      } else if (espesor > 100) { // 100 cm es excesivo
        warnings.add('$prefix: El espesor parece excesivo (${espesor.toStringAsFixed(1)} cm)');
      }

      // Validar área o dimensiones
      final hasArea = piso.area != null && piso.area!.isNotEmpty;
      final hasDimensions = piso.largo != null &&
          piso.ancho != null &&
          piso.largo!.isNotEmpty &&
          piso.ancho!.isNotEmpty;

      if (!hasArea && !hasDimensions) {
        errors.add('$prefix: Debe tener área o dimensiones (largo y ancho)');
      }

      // Validaciones de seguridad
      if (_containsSuspiciousContent(piso.description)) {
        errors.add('$prefix: La descripción contiene caracteres no permitidos');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida losas aligeradas
  static ValidationResult _validateLosas(List<LosaAligerada> losas) {
    final errors = <String>[];
    final warnings = <String>[];

    for (int i = 0; i < losas.length; i++) {
      final losa = losas[i];
      final prefix = 'Losa ${i + 1}';

      // Validaciones básicas
      if (losa.description.trim().isEmpty) {
        errors.add('$prefix: La descripción es requerida');
      }

      // Validar altura
      final altura = losa.altura.replaceAll(RegExp(r'[^0-9.]'), '');
      final alturaNum = double.tryParse(altura);
      if (alturaNum == null || alturaNum <= 0) {
        errors.add('$prefix: La altura debe ser un número positivo');
      }

      // Validar resistencia
      final resistencia = losa.resistenciaConcreto.replaceAll(RegExp(r'[^0-9.]'), '');
      final resistenciaNum = double.tryParse(resistencia);
      if (resistenciaNum == null || resistenciaNum <= 0) {
        errors.add('$prefix: La resistencia debe ser un número positivo');
      }

      // Validaciones de seguridad
      if (_containsSuspiciousContent(losa.description)) {
        errors.add('$prefix: La descripción contiene caracteres no permitidos');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida tarrajeos
  static ValidationResult _validateTarrajeos(List<Tarrajeo> tarrajeos) {
    final errors = <String>[];
    final warnings = <String>[];

    for (int i = 0; i < tarrajeos.length; i++) {
      final tarrajeo = tarrajeos[i];
      final prefix = 'Tarrajeo ${i + 1}';

      // Validaciones básicas
      if (tarrajeo.description.trim().isEmpty) {
        errors.add('$prefix: La descripción es requerida');
      }

      // Validar espesor
      final espesor = double.tryParse(tarrajeo.espesor);
      if (espesor == null || espesor <= 0) {
        errors.add('$prefix: El espesor debe ser un número positivo');
      } else if (espesor > 10) { // 10 cm es excesivo para tarrajeo
        warnings.add('$prefix: El espesor parece excesivo para tarrajeo (${espesor.toStringAsFixed(1)} cm)');
      }

      // Validaciones de seguridad
      if (_containsSuspiciousContent(tarrajeo.description)) {
        errors.add('$prefix: La descripción contiene caracteres no permitidos');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida columnas
  static ValidationResult _validateColumnas(List<Columna> columnas) {
    final errors = <String>[];
    final warnings = <String>[];

    for (int i = 0; i < columnas.length; i++) {
      final columna = columnas[i];
      final prefix = 'Columna ${i + 1}';

      // Validaciones básicas
      if (columna.description.trim().isEmpty) {
        errors.add('$prefix: La descripción es requerida');
      }

      if (columna.resistencia.trim().isEmpty) {
        errors.add('$prefix: La resistencia es requerida');
      }

      // Validaciones de seguridad
      if (_containsSuspiciousContent(columna.description)) {
        errors.add('$prefix: La descripción contiene caracteres no permitidos');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida vigas
  static ValidationResult _validateVigas(List<Viga> vigas) {
    final errors = <String>[];
    final warnings = <String>[];

    for (int i = 0; i < vigas.length; i++) {
      final viga = vigas[i];
      final prefix = 'Viga ${i + 1}';

      // Validaciones básicas
      if (viga.description.trim().isEmpty) {
        errors.add('$prefix: La descripción es requerida');
      }

      if (viga.resistencia.trim().isEmpty) {
        errors.add('$prefix: La resistencia es requerida');
      }

      // Validaciones de seguridad
      if (_containsSuspiciousContent(viga.description)) {
        errors.add('$prefix: La descripción contiene caracteres no permitidos');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Métodos auxiliares de validación

  /// Valida proporción de mortero
  static bool _isValidProporcionMortero(String proporcion) {
    const validProporciones = ['3', '4', '5', '6'];
    return validProporciones.contains(proporcion.trim());
  }

  /// Valida tipo de asentado
  static bool _isValidTipoAsentado(String tipo) {
    const validTipos = ['soga', 'cabeza', 'canto'];
    return validTipos.contains(tipo.trim().toLowerCase());
  }

  /// Detecta contenido sospechoso
  static bool _containsSuspiciousContent(String content) {
    if (content.length > 200) return true; // Muy largo

    const suspiciousPatterns = [
      '<script',
      'javascript:',
      'onload=',
      'onerror=',
      '<iframe',
      'eval(',
      'document.',
      'window.',
      'alert(',
      'confirm(',
      'prompt(',
    ];

    final lowerContent = content.toLowerCase();
    return suspiciousPatterns.any((pattern) => lowerContent.contains(pattern));
  }

  /// Sanitiza texto de entrada
  static String sanitizeText(String input) {
    if (input.isEmpty) return input;

    // Remover caracteres peligrosos
    String cleaned = input
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('`', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .trim();

    // Limitar longitud
    if (cleaned.length > 200) {
      cleaned = cleaned.substring(0, 200);
    }

    return cleaned;
  }

  /// Valida ID de metrado
  static bool isValidMetradoId(String metradoId) {
    final trimmed = metradoId.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length > 50) return false; // Muy largo

    // Solo permitir caracteres alfanuméricos, guiones y guiones bajos
    final validPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    return validPattern.hasMatch(trimmed);
  }

  /// Valida límites de datos para prevenir ataques DoS
  static ValidationResult validateDataLimits(List<dynamic> results) {
    const maxResults = 100; // Máximo 100 elementos
    const maxTotalSize = 1000000; // 1MB aproximado en caracteres

    if (results.length > maxResults) {
      return ValidationResult.error(
          'Demasiados elementos: ${results.length}. Máximo permitido: $maxResults'
      );
    }

    // Calcular tamaño aproximado
    int totalSize = 0;
    for (var result in results) {
      totalSize += result.toString().length;
      if (totalSize > maxTotalSize) {
        return ValidationResult.error(
            'Los datos son demasiado grandes. Tamaño máximo: ${maxTotalSize ~/ 1000}KB'
        );
      }
    }

    return ValidationResult.success();
  }
}

/// Resultado de validación
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final String? successMessage;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.successMessage,
  });

  factory ValidationResult.success([String? message]) {
    return ValidationResult(
      isValid: true,
      successMessage: message,
    );
  }

  factory ValidationResult.error(String error) {
    return ValidationResult(
      isValid: false,
      errors: [error],
    );
  }

  factory ValidationResult.errors(List<String> errors) {
    return ValidationResult(
      isValid: false,
      errors: errors,
    );
  }

  /// Tiene errores
  bool get hasErrors => errors.isNotEmpty;

  /// Tiene advertencias
  bool get hasWarnings => warnings.isNotEmpty;

  /// Mensaje de error combinado
  String get errorMessage => errors.join(', ');

  /// Mensaje de advertencia combinado
  String get warningMessage => warnings.join(', ');

  /// Todos los mensajes combinados
  String get allMessages {
    final all = <String>[];
    if (hasErrors) all.addAll(errors);
    if (hasWarnings) all.addAll(warnings.map((w) => 'Advertencia: $w'));
    if (successMessage != null) all.add(successMessage!);
    return all.join('\n');
  }

  /// Convierte a JSON para logging
  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'errors': errors,
      'warnings': warnings,
      'successMessage': successMessage,
      'hasErrors': hasErrors,
      'hasWarnings': hasWarnings,
    };
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
  }
}