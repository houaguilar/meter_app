import 'dart:convert';
import 'dart:math'; // Añadido para Random.secure
import 'package:crypto/crypto.dart';

/// Servicio centralizado de seguridad para la aplicación
class SecurityService {

  // Configuraciones de seguridad
  static const int _maxStringLength = 200;
  static const int _maxListSize = 100;
  static const int _maxTotalDataSize = 1000000; // 1MB

  // Patrones de contenido malicioso
  static final List<RegExp> _maliciousPatterns = [
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false),
    RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true),
    RegExp(r'eval\s*\(', caseSensitive: false),
    RegExp(r'document\.\w+', caseSensitive: false),
    RegExp(r'window\.\w+', caseSensitive: false),
    RegExp(r'alert\s*\(', caseSensitive: false),
    RegExp(r'confirm\s*\(', caseSensitive: false),
    RegExp(r'prompt\s*\(', caseSensitive: false),
    RegExp(r'setTimeout\s*\(', caseSensitive: false),
    RegExp(r'setInterval\s*\(', caseSensitive: false),
  ];

  /// Sanitiza texto de entrada removiendo caracteres peligrosos
  static String sanitizeText(String input) {
    if (input.isEmpty) return input;

    String cleaned = input
    // Remover caracteres HTML peligrosos
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('`', '&#x60;')
    // Remover caracteres de control
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
    // Normalizar espacios
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Limitar longitud
    if (cleaned.length > _maxStringLength) {
      cleaned = cleaned.substring(0, _maxStringLength).trim();
    }

    return cleaned;
  }

  /// Valida que el texto no contenga contenido malicioso
  static ValidationResult validateTextSecurity(String text) {
    if (text.isEmpty) {
      return ValidationResult.success();
    }

    // Verificar longitud
    if (text.length > _maxStringLength) {
      return ValidationResult.error(
          'El texto es demasiado largo. Máximo $_maxStringLength caracteres.'
      );
    }

    // Verificar patrones maliciosos
    final lowerText = text.toLowerCase();
    for (final pattern in _maliciousPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return ValidationResult.error(
            'El texto contiene contenido no permitido'
        );
      }
    }

    // Verificar caracteres de control sospechosos
    if (text.contains(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'))) {
      return ValidationResult.error(
          'El texto contiene caracteres no válidos'
      );
    }

    return ValidationResult.success();
  }

  /// Valida números en rangos seguros
  static ValidationResult validateNumericInput(
      String input,
      String fieldName, {
        double? min,
        double? max,
      }) {
    if (input.trim().isEmpty) {
      return ValidationResult.error('$fieldName es requerido');
    }

    final value = double.tryParse(input.trim());

    if (value == null) {
      return ValidationResult.error('$fieldName debe ser un número válido');
    }

    if (value.isNaN || value.isInfinite) {
      return ValidationResult.error('$fieldName tiene un valor no válido');
    }

    if (min != null && value < min) {
      return ValidationResult.error('$fieldName debe ser mayor o igual a $min');
    }

    if (max != null && value > max) {
      return ValidationResult.error('$fieldName debe ser menor o igual a $max');
    }

    return ValidationResult.success();
  }

  /// Valida que una lista no sea demasiado grande (previene ataques DoS)
  static ValidationResult validateListSize<T>(List<T> list, String listName) {
    if (list.length > _maxListSize) {
      return ValidationResult.error(
          '$listName contiene demasiados elementos. Máximo $_maxListSize elementos.'
      );
    }

    // Calcular tamaño total
    final totalSize = list.fold<int>(0, (sum, item) => sum + item.toString().length);
    if (totalSize > _maxTotalDataSize) {
      return ValidationResult.error(
          '$listName es demasiado grande. Tamaño máximo permitido: ${_maxTotalDataSize ~/ 1000}KB'
      );
    }

    return ValidationResult.success();
  }

  /// Valida ID de metrado/proyecto para prevenir inyecciones
  static ValidationResult validateId(String id, String fieldName) {
    if (id.trim().isEmpty) {
      return ValidationResult.error('$fieldName es requerido');
    }

    if (id.length > 50) {
      return ValidationResult.error('$fieldName es demasiado largo');
    }

    // Solo permitir caracteres alfanuméricos, guiones y guiones bajos
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id.trim())) {
      return ValidationResult.error('$fieldName contiene caracteres no válidos');
    }

    return ValidationResult.success();
  }

  /// Genera un hash seguro para comparaciones
  static String generateSecureHash(String input, String salt) {
    final bytes = utf8.encode(input + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Valida que un archivo tenga una extensión permitida
  static ValidationResult validateFileExtension(String fileName, List<String> allowedExtensions) {
    if (fileName.trim().isEmpty) {
      return ValidationResult.error('Nombre de archivo requerido');
    }

    final parts = fileName.split('.');
    if (parts.length < 2) {
      return ValidationResult.error('El archivo no tiene extensión');
    }
    final extension = parts.last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return ValidationResult.error(
          'Tipo de archivo no permitido. Extensiones permitidas: ${allowedExtensions.join(', ')}'
      );
    }

    return ValidationResult.success();
  }

  /// Limpia y valida datos de entrada para entidades
  static Map<String, dynamic> sanitizeEntityData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        // Sanitizar strings
        final cleanValue = sanitizeText(value);
        if (validateTextSecurity(cleanValue).isValid) {
          sanitized[key] = cleanValue;
        }
      } else if (value is num) {
        // Validar números
        if (!value.isNaN && !value.isInfinite && value.abs() < 1e15) {
          sanitized[key] = value;
        }
      } else if (value is bool) {
        sanitized[key] = value;
      } else if (value is List) {
        // Validar listas
        if (validateListSize(value, key).isValid) {
          sanitized[key] = value;
        }
      } else if (value == null) {
        sanitized[key] = null;
      }
    }

    return sanitized;
  }

  /// Valida credenciales de usuario
  static ValidationResult validateUserCredentials(String email, String password) {
    final errors = <String>[];

    // Validar email
    if (email.trim().isEmpty) {
      errors.add('El email es requerido');
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim())) {
      errors.add('El email no tiene un formato válido');
    } else if (email.length > 100) {
      errors.add('El email es demasiado largo');
    }

    // Validar password
    if (password.isEmpty) {
      errors.add('La contraseña es requerida');
    } else if (password.length < 8) {
      errors.add('La contraseña debe tener al menos 8 caracteres');
    } else if (password.length > 128) {
      errors.add('La contraseña es demasiado larga');
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$').hasMatch(password)) {
      errors.add('La contraseña debe contener al menos una mayúscula, una minúscula y un número');
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.errors(errors);
  }

  /// Genera un token de sesión seguro
  static String generateSessionToken() {
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final token = List.generate(32, (i) => chars[random.nextInt(chars.length)]).join();
    return generateSecureHash(token, DateTime.now().millisecondsSinceEpoch.toString());
  }

  /// Valida datos específicos de construcción
  static ValidationResult validateConstructionData(Map<String, dynamic> data) {
    final errors = <String>[];

    // Validar área (0.1 - 10,000 m²)
    if (data.containsKey('area')) {
      final areaResult = validateNumericInput(
          data['area'].toString(),
          'Área',
          min: 0.1,
          max: 10000
      );
      if (!areaResult.isValid) {
        errors.add(areaResult.errorMessage);
      }
    }

    // Validar dimensiones (0.1 - 1,000 m)
    for (final dimension in ['largo', 'ancho', 'altura', 'longitud']) {
      if (data.containsKey(dimension)) {
        final result = validateNumericInput(
            data[dimension].toString(),
            dimension,
            min: 0.1,
            max: 1000
        );
        if (!result.isValid) {
          errors.add(result.errorMessage);
        }
      }
    }

    // Validar espesores (0.1 - 100 cm)
    if (data.containsKey('espesor')) {
      final result = validateNumericInput(
          data['espesor'].toString(),
          'Espesor',
          min: 0.1,
          max: 100
      );
      if (!result.isValid) {
        errors.add(result.errorMessage);
      }
    }

    // Validar factores de desperdicio (0 - 100%)
    for (final factor in ['factorDesperdicio', 'factorDesperdicioMortero']) {
      if (data.containsKey(factor)) {
        final result = validateNumericInput(
            data[factor].toString(),
            'Factor de desperdicio',
            min: 0,
            max: 100
        );
        if (!result.isValid) {
          errors.add(result.errorMessage);
        }
      }
    }

    // Validar volumen (0.001 - 100,000 m³)
    if (data.containsKey('volumen')) {
      final result = validateNumericInput(
          data['volumen'].toString(),
          'Volumen',
          min: 0.001,
          max: 100000
      );
      if (!result.isValid) {
        errors.add(result.errorMessage);
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.errors(errors);
  }

  /// Registra actividad sospechosa para auditoría
  static void logSuspiciousActivity(String activity, Map<String, dynamic> context) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'activity': activity,
      'context': context,
      'severity': 'WARNING',
    };

    // En un entorno de producción, esto se enviaría a un servicio de logging
    print('🚨 ACTIVIDAD SOSPECHOSA: $logEntry');
  }

  /// Limpia caché y datos temporales por seguridad
  static void clearSecurityCache() {
    // Implementar limpieza de datos sensibles en memoria
    // En un entorno de producción, esto limpiaría caches, tokens temporales, etc.
  }

  /// Verifica integridad de datos
  static bool verifyDataIntegrity(Map<String, dynamic> data, String expectedHash) {
    final currentHash = generateSecureHash(
        data.toString(),
        'integrity_salt_${DateTime.now().day}'
    );
    return currentHash == expectedHash;
  }
}

/// Resultado de validación de seguridad
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

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  String get errorMessage => errors.join(', ');
  String get warningMessage => warnings.join(', ');

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
  }
}