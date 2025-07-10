// lib/config/utils/validators.dart
import 'package:flutter/material.dart';

class Validators {

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDADORES BÁSICOS (Mantiene compatibilidad con tu código actual)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Validación básica de email (tu método original mejorado)
  static bool validateEmail(String value) {
    if (value.isEmpty) return false;

    // Regex mejorado para email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(value.trim());
  }

  /// Validación básica de texto (tu método original)
  static bool validateText(String value) {
    return value.trim().isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDADORES AVANZADOS CON RESULTADOS DETALLADOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Validación avanzada de email con resultado detallado
  static EmailValidationResult validateEmailAdvanced(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return EmailValidationResult(
        isValid: false,
        message: 'El email es requerido',
        severity: ValidationSeverity.error,
      );
    }

    if (trimmedValue.length > 254) {
      return EmailValidationResult(
        isValid: false,
        message: 'El email es demasiado largo',
        severity: ValidationSeverity.error,
      );
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return EmailValidationResult(
        isValid: false,
        message: 'Formato de email inválido',
        severity: ValidationSeverity.error,
      );
    }

    // Validaciones adicionales
    if (trimmedValue.startsWith('.') || trimmedValue.endsWith('.')) {
      return EmailValidationResult(
        isValid: false,
        message: 'El email no puede empezar o terminar con punto',
        severity: ValidationSeverity.error,
      );
    }

    if (trimmedValue.contains('..')) {
      return EmailValidationResult(
        isValid: false,
        message: 'El email no puede tener puntos consecutivos',
        severity: ValidationSeverity.error,
      );
    }

    // Email válido
    return EmailValidationResult(
      isValid: true,
      message: 'Email válido ✓',
      severity: ValidationSeverity.success,
    );
  }

  /// Validación avanzada de contraseña con análisis de fuerza
  static PasswordValidationResult validatePasswordAdvanced(String value) {
    if (value.isEmpty) {
      return PasswordValidationResult(
        isValid: false,
        message: 'La contraseña es requerida',
        severity: ValidationSeverity.error,
        hasMinLength: false,
        hasMinLengthStrong: false,
        hasUppercase: false,
        hasLowercase: false,
        hasNumber: false,
        hasSpecialChar: false,
        hasCommonPatterns: false,
        hasRepeatedChars: false,
        strength: PasswordStrength.none,
        color: const Color(0xFFE53E3E),
      );
    }

    // Analizar componentes de la contraseña
    final hasMinLength = value.length >= 8;
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLengthStrong = value.length >= 12;

    // Verificar patrones comunes débiles
    final hasCommonPatterns = _hasCommonWeakPatterns(value);
    final hasRepeatedChars = _hasRepeatedCharacters(value);

    // Calcular puntuación de fuerza
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumber) score++;
    if (hasSpecialChar) score++;
    if (hasMinLengthStrong) score++;
    if (!hasCommonPatterns) score++;
    if (!hasRepeatedChars) score++;

    // Determinar fuerza de la contraseña y crear resultado
    if (score < 3) {
      return PasswordValidationResult(
        isValid: false,
        message: 'Contraseña muy débil',
        severity: ValidationSeverity.error,
        hasMinLength: hasMinLength,
        hasMinLengthStrong: hasMinLengthStrong,
        hasUppercase: hasUppercase,
        hasLowercase: hasLowercase,
        hasNumber: hasNumber,
        hasSpecialChar: hasSpecialChar,
        hasCommonPatterns: hasCommonPatterns,
        hasRepeatedChars: hasRepeatedChars,
        strength: PasswordStrength.weak,
        color: const Color(0xFFE53E3E), // Rojo
      );
    } else if (score < 5) {
      return PasswordValidationResult(
        isValid: false,
        message: 'Contraseña débil',
        severity: ValidationSeverity.warning,
        hasMinLength: hasMinLength,
        hasMinLengthStrong: hasMinLengthStrong,
        hasUppercase: hasUppercase,
        hasLowercase: hasLowercase,
        hasNumber: hasNumber,
        hasSpecialChar: hasSpecialChar,
        hasCommonPatterns: hasCommonPatterns,
        hasRepeatedChars: hasRepeatedChars,
        strength: PasswordStrength.medium,
        color: const Color(0xFFFF8C00), // Naranja
      );
    } else if (score < 7) {
      return PasswordValidationResult(
        isValid: true,
        message: 'Contraseña buena',
        severity: ValidationSeverity.success,
        hasMinLength: hasMinLength,
        hasMinLengthStrong: hasMinLengthStrong,
        hasUppercase: hasUppercase,
        hasLowercase: hasLowercase,
        hasNumber: hasNumber,
        hasSpecialChar: hasSpecialChar,
        hasCommonPatterns: hasCommonPatterns,
        hasRepeatedChars: hasRepeatedChars,
        strength: PasswordStrength.strong,
        color: const Color(0xFF38A169), // Verde
      );
    } else {
      return PasswordValidationResult(
        isValid: true,
        message: 'Contraseña excelente ✓',
        severity: ValidationSeverity.success,
        hasMinLength: hasMinLength,
        hasMinLengthStrong: hasMinLengthStrong,
        hasUppercase: hasUppercase,
        hasLowercase: hasLowercase,
        hasNumber: hasNumber,
        hasSpecialChar: hasSpecialChar,
        hasCommonPatterns: hasCommonPatterns,
        hasRepeatedChars: hasRepeatedChars,
        strength: PasswordStrength.veryStrong,
        color: const Color(0xFF2D7D32), // Verde oscuro
      );
    }
  }

  /// Validación de confirmación de contraseña
  static ValidationResult validatePasswordConfirmation(
      String password,
      String confirmation
      ) {
    if (confirmation.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Confirma tu contraseña',
        severity: ValidationSeverity.error,
      );
    }

    if (password != confirmation) {
      return ValidationResult(
        isValid: false,
        message: 'Las contraseñas no coinciden',
        severity: ValidationSeverity.error,
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Las contraseñas coinciden ✓',
      severity: ValidationSeverity.success,
    );
  }

  /// Validación de nombre completo
  static ValidationResult validateName(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'El nombre es requerido',
        severity: ValidationSeverity.error,
      );
    }

    if (trimmedValue.length < 2) {
      return ValidationResult(
        isValid: false,
        message: 'El nombre debe tener al menos 2 caracteres',
        severity: ValidationSeverity.error,
      );
    }

    if (trimmedValue.length > 50) {
      return ValidationResult(
        isValid: false,
        message: 'El nombre es demasiado largo',
        severity: ValidationSeverity.error,
      );
    }

    // Verificar que solo contenga letras, espacios y algunos caracteres especiales
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s'-]+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return ValidationResult(
        isValid: false,
        message: 'El nombre solo puede contener letras',
        severity: ValidationSeverity.error,
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Nombre válido ✓',
      severity: ValidationSeverity.success,
    );
  }

  /// Validación de teléfono
  static ValidationResult validatePhone(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'El teléfono es requerido',
        severity: ValidationSeverity.error,
      );
    }

    // Remover espacios, guiones y paréntesis para validación
    final cleanPhone = trimmedValue.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Verificar que solo contenga números y el símbolo +
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return ValidationResult(
        isValid: false,
        message: 'Formato de teléfono inválido',
        severity: ValidationSeverity.error,
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Teléfono válido ✓',
      severity: ValidationSeverity.success,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS HELPER PRIVADOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verifica patrones comunes débiles en contraseñas
  static bool _hasCommonWeakPatterns(String password) {
    final lowerPassword = password.toLowerCase();

    // Patrones débiles comunes
    final weakPatterns = [
      '123456', 'password', 'qwerty', 'abc123', 'admin',
      '12345678', 'welcome', 'login', 'master', 'monkey',
      'letmein', 'dragon', 'sunshine', 'iloveyou', 'princess',
      'football', 'baseball', 'superman', 'michael', 'shadow'
    ];

    for (final pattern in weakPatterns) {
      if (lowerPassword.contains(pattern)) {
        return true;
      }
    }

    // Verificar secuencias numéricas
    if (RegExp(r'(012|123|234|345|456|567|678|789)').hasMatch(password)) {
      return true;
    }

    // Verificar secuencias de teclado
    if (RegExp(r'(qwe|wer|ert|rty|tyu|yui|uio|iop|asd|sdf|dfg|fgh|ghj|hjk|jkl|zxc|xcv|cvb|vbn|bnm)').hasMatch(lowerPassword)) {
      return true;
    }

    return false;
  }

  /// Verifica caracteres repetidos excesivos
  static bool _hasRepeatedCharacters(String password) {
    // Verificar si hay más de 2 caracteres iguales consecutivos
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS UTILITARIOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Obtiene sugerencias para mejorar la contraseña
  static List<String> getPasswordSuggestions(PasswordValidationResult result) {
    final suggestions = <String>[];

    if (!result.hasMinLength) {
      suggestions.add('Usa al menos 8 caracteres');
    }
    if (!result.hasUppercase) {
      suggestions.add('Incluye al menos una mayúscula (A-Z)');
    }
    if (!result.hasLowercase) {
      suggestions.add('Incluye al menos una minúscula (a-z)');
    }
    if (!result.hasNumber) {
      suggestions.add('Incluye al menos un número (0-9)');
    }
    if (!result.hasSpecialChar) {
      suggestions.add('Incluye un carácter especial (!@#\$%^&*)');
    }
    if (result.hasCommonPatterns) {
      suggestions.add('Evita palabras comunes o patrones obvios');
    }
    if (result.hasRepeatedChars) {
      suggestions.add('Evita caracteres repetidos consecutivos');
    }
    if (!result.hasMinLengthStrong) {
      suggestions.add('Para mayor seguridad, usa 12+ caracteres');
    }

    return suggestions;
  }

  /// Calcula el progreso de fuerza de contraseña (0.0 a 1.0)
  static double getPasswordStrengthProgress(PasswordValidationResult result) {
    switch (result.strength) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES DE RESULTADO
// ═══════════════════════════════════════════════════════════════════════════

/// Resultado básico de validación
class ValidationResult {
  final bool isValid;
  final String message;
  final ValidationSeverity severity;

  ValidationResult({
    required this.isValid,
    required this.message,
    required this.severity,
  });
}

/// Resultado específico para validación de email
class EmailValidationResult extends ValidationResult {
  EmailValidationResult({
    required bool isValid,
    required String message,
    required ValidationSeverity severity,
  }) : super(isValid: isValid, message: message, severity: severity);
}

/// Resultado específico para validación de contraseña
class PasswordValidationResult extends ValidationResult {
  final bool hasMinLength;
  final bool hasMinLengthStrong;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool hasCommonPatterns;
  final bool hasRepeatedChars;
  final PasswordStrength strength;
  final Color color;

  PasswordValidationResult({
    required bool isValid,
    required String message,
    required ValidationSeverity severity,
    required this.hasMinLength,
    required this.hasMinLengthStrong,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.hasCommonPatterns,
    required this.hasRepeatedChars,
    required this.strength,
    required this.color,
  }) : super(isValid: isValid, message: message, severity: severity);
}

// ═══════════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════════

enum ValidationSeverity {
  success,
  warning,
  error
}

enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
  veryStrong
}