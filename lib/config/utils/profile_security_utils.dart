import 'package:flutter/material.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';

class ProfileSecurityUtils {

  /// Constructor privado para evitar instanciación
  ProfileSecurityUtils._();

  /// Valida un perfil de usuario completo
  static ProfileValidationResult validateProfile(UserProfile profile) {
    final errors = <String, String>{};
    final warnings = <String, String>{};

    // Validar campos obligatorios
    if (!isValidName(profile.name)) {
      errors['name'] = 'El nombre es requerido y debe tener al menos 2 caracteres';
    }

    if (!isValidEmail(profile.email)) {
      errors['email'] = 'El email no tiene un formato válido';
    }

    // Validar campos opcionales si están presentes
    if (profile.phone.isNotEmpty && !isValidPhone(profile.phone)) {
      warnings['phone'] = 'El número de teléfono no tiene un formato válido';
    }

    if (profile.name.isNotEmpty && !isSecureName(profile.name)) {
      warnings['name'] = 'El nombre contiene caracteres no permitidos';
    }

    // Validar URL de imagen si está presente
    if (profile.profileImageUrl != null &&
        profile.profileImageUrl!.isNotEmpty &&
        !isValidImageUrl(profile.profileImageUrl!)) {
      warnings['profileImage'] = 'La URL de la imagen no es válida';
    }

    return ProfileValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida un nombre
  static bool isValidName(String name) {
    if (name.isEmpty || name.length < 2) return false;
    if (name.length > 100) return false;

    // Permitir solo letras, espacios, guiones y apostrofes
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s\-'\.]+$");
    return nameRegex.hasMatch(name.trim());
  }

  /// Valida que un nombre sea seguro (sin caracteres maliciosos)
  static bool isSecureName(String name) {
    final sanitized = sanitizeInput(name);
    return sanitized == name.trim();
  }

  /// Valida un email
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );

    return emailRegex.hasMatch(email.trim()) && email.length <= 254;
  }

  /// Valida un número de teléfono
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return true; // Campo opcional

    // Remover espacios, guiones y paréntesis
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Validar que solo contenga dígitos y el signo +
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  /// Valida una URL de imagen
  static bool isValidImageUrl(String url) {
    if (url.isEmpty) return true; // Campo opcional

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }

      // Verificar que termine en una extensión de imagen válida
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      final lowerUrl = url.toLowerCase();

      return validExtensions.any((ext) => lowerUrl.contains(ext)) ||
          lowerUrl.contains('supabase') || // Permitir URLs de Supabase
          lowerUrl.contains('storage'); // Permitir URLs de storage genérico
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SANITIZACIÓN DE DATOS - VERSIÓN SIMPLE Y SEGURA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lista de caracteres peligrosos a remover
  static const List<String> _dangerousChars = ['<', '>', '"', "'", '`', '{', '}'];

  /// Sanitiza un input general removiendo caracteres peligrosos
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    String cleaned = input.trim();

    // Remover caracteres peligrosos uno por uno
    for (String char in _dangerousChars) {
      cleaned = cleaned.replaceAll(char, '');
    }

    // Remover HTML tags básicos
    cleaned = cleaned.replaceAll('<script>', '');
    cleaned = cleaned.replaceAll('</script>', '');
    cleaned = cleaned.replaceAll('<iframe>', '');
    cleaned = cleaned.replaceAll('</iframe>', '');

    // Normalizar espacios múltiples a uno solo
    while (cleaned.contains('  ')) {
      cleaned = cleaned.replaceAll('  ', ' ');
    }

    return cleaned.trim();
  }

  /// Sanitiza un nombre
  static String sanitizeName(String name) {
    if (name.isEmpty) return name;

    String cleaned = name.trim();

    // Remover caracteres peligrosos
    for (String char in _dangerousChars) {
      cleaned = cleaned.replaceAll(char, '');
    }

    // Normalizar espacios
    while (cleaned.contains('  ')) {
      cleaned = cleaned.replaceAll('  ', ' ');
    }

    // Capitalizar cada palabra
    List<String> words = cleaned.split(' ');
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isNotEmpty) {
        String capitalizedWord = word[0].toUpperCase() +
            (word.length > 1 ? word.substring(1).toLowerCase() : '');
        capitalizedWords.add(capitalizedWord);
      }
    }

    return capitalizedWords.join(' ');
  }

  /// Sanitiza un email
  static String sanitizeEmail(String email) {
    if (email.isEmpty) return email;

    String cleaned = email.trim().toLowerCase();

    // Remover caracteres peligrosos excepto @ y .
    for (String char in _dangerousChars) {
      cleaned = cleaned.replaceAll(char, '');
    }

    return cleaned;
  }

  /// Sanitiza un teléfono
  static String sanitizePhone(String phone) {
    if (phone.isEmpty) return phone;

    String cleaned = '';

    // Mantener solo dígitos, + y espacios
    for (int i = 0; i < phone.length; i++) {
      String char = phone[i];
      if (char.contains(RegExp(r'[\d\+\s\-\(\)]'))) {
        cleaned += char;
      }
    }

    return cleaned.trim();
  }

  /// Sanitiza un input de ubicación (ciudad, provincia, distrito)
  static String sanitizeLocation(String location) {
    if (location.isEmpty) return location;

    String cleaned = location.trim();

    // Remover caracteres peligrosos
    for (String char in _dangerousChars) {
      cleaned = cleaned.replaceAll(char, '');
    }

    // Permitir solo letras, espacios, guiones y puntos
    String result = '';
    for (int i = 0; i < cleaned.length; i++) {
      String char = cleaned[i];
      if (char.contains(RegExp(r'[a-zA-ZÀ-ÿ\u00f1\u00d1\s\-\.]'))) {
        result += char;
      }
    }

    // Normalizar espacios
    while (result.contains('  ')) {
      result = result.replaceAll('  ', ' ');
    }

    return result.trim();
  }

  /// Sanitiza un perfil completo
  static UserProfile sanitizeProfile(UserProfile profile) {
    return profile.copyWith(
      name: sanitizeName(profile.name),
      email: sanitizeEmail(profile.email),
      phone: sanitizePhone(profile.phone),
      employment: sanitizeInput(profile.employment),
      nationality: sanitizeLocation(profile.nationality),
      city: sanitizeLocation(profile.city),
      province: sanitizeLocation(profile.province),
      district: sanitizeLocation(profile.district),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VERIFICACIÓN DE SEGURIDAD
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verifica si un input contiene contenido potencialmente malicioso
  static bool containsMaliciousContent(String input) {
    if (input.isEmpty) return false;

    final maliciousPatterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe[^>]*>', caseSensitive: false),
      RegExp(r'<object[^>]*>', caseSensitive: false),
      RegExp(r'<embed[^>]*>', caseSensitive: false),
    ];

    return maliciousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Verifica si un perfil es seguro
  static bool isProfileSecure(UserProfile profile) {
    final fields = [
      profile.name,
      profile.email,
      profile.phone,
      profile.employment,
      profile.nationality,
      profile.city,
      profile.province,
      profile.district,
      profile.profileImageUrl ?? '',
    ];

    return !fields.any((field) => containsMaliciousContent(field));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILIDADES DE PRIVACIDAD
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ofusca información sensible para logs
  static String obfuscateEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;

    final visibleChars = username.length > 4 ? 2 : 1;
    final obfuscated = username.substring(0, visibleChars) +
        '*' * (username.length - visibleChars);

    return '$obfuscated@$domain';
  }

  /// Ofusca un número de teléfono
  static String obfuscatePhone(String phone) {
    if (phone.length <= 4) return phone;

    final visibleDigits = 2;
    final start = phone.substring(0, visibleDigits);
    final end = phone.substring(phone.length - visibleDigits);
    final middle = '*' * (phone.length - (visibleDigits * 2));

    return '$start$middle$end';
  }

  /// Ofusca información sensible en un perfil para logs
  static Map<String, dynamic> obfuscateProfileForLogs(UserProfile profile) {
    return {
      'id': profile.id.length > 8 ? '${profile.id.substring(0, 8)}...' : profile.id,
      'name': profile.name.isNotEmpty ? '${profile.name[0]}***' : 'empty',
      'email': obfuscateEmail(profile.email),
      'phone': profile.phone.isNotEmpty ? obfuscatePhone(profile.phone) : 'empty',
      'employment': profile.employment.isNotEmpty ? 'set' : 'empty',
      'city': profile.city.isNotEmpty ? 'set' : 'empty',
      'hasProfileImage': profile.profileImageUrl?.isNotEmpty == true,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILIDADES DE COMPLETITUD
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calcula la completitud del perfil
  static ProfileCompleteness calculateCompleteness(UserProfile profile) {
    final fields = <String, bool>{
      'name': profile.name.isNotEmpty,
      'phone': profile.phone.isNotEmpty,
      'employment': profile.employment.isNotEmpty,
      'city': profile.city.isNotEmpty,
      'district': profile.district.isNotEmpty,
      'profileImage': profile.profileImageUrl?.isNotEmpty == true,
    };

    final completedCount = fields.values.where((completed) => completed).length;
    final totalCount = fields.length;
    final percentage = (completedCount / totalCount) * 100;

    return ProfileCompleteness(
      completedFields: completedCount,
      totalFields: totalCount,
      percentage: percentage,
      missingFields: fields.entries
          .where((entry) => !entry.value)
          .map((entry) => entry.key)
          .toList(),
    );
  }

  /// Obtiene recomendaciones para mejorar el perfil
  static List<String> getProfileRecommendations(UserProfile profile) {
    final recommendations = <String>[];

    if (profile.name.isEmpty) {
      recommendations.add('Agrega tu nombre completo para personalizar tu experiencia');
    }

    if (profile.phone.isEmpty) {
      recommendations.add('Agrega tu número de teléfono para facilitar el contacto');
    }

    if (profile.employment.isEmpty) {
      recommendations.add('Especifica tu ocupación para recibir contenido relevante');
    }

    if (profile.city.isEmpty || profile.district.isEmpty) {
      recommendations.add('Completa tu ubicación para encontrar proveedores cerca de ti');
    }

    if (profile.profileImageUrl?.isEmpty != false) {
      recommendations.add('Sube una foto de perfil para personalizar tu cuenta');
    }

    if (recommendations.isEmpty) {
      recommendations.add('¡Excelente! Tu perfil está completo');
    }

    return recommendations;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGGING SEGURO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Log seguro de operaciones de perfil
  static void logProfileOperation(
      String operation,
      UserProfile profile, {
        String? additionalInfo,
        bool isError = false,
      }) {
    final obfuscatedProfile = obfuscateProfileForLogs(profile);
    final logData = {
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
      'profile': obfuscatedProfile,
      'additional_info': additionalInfo,
      'is_error': isError,
    };

    // En un entorno de producción, esto se enviaría a un servicio de logging
    debugPrint('PROFILE_OPERATION: ${logData.toString()}');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDACIONES ESPECÍFICAS DE CAMPOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Valida un campo de empleo/ocupación
  static bool isValidEmployment(String employment) {
    if (employment.isEmpty) return true; // Campo opcional
    if (employment.length > 100) return false;

    // Permitir letras, números, espacios y algunos caracteres especiales
    final employmentRegex = RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s\-\.\,\(\)0-9]+$");
    return employmentRegex.hasMatch(employment.trim());
  }

  /// Valida un campo de ubicación (ciudad, provincia, distrito)
  static bool isValidLocation(String location) {
    if (location.isEmpty) return true; // Campo opcional
    if (location.length > 50) return false;

    // Permitir solo letras, espacios y algunos caracteres especiales
    final locationRegex = RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s\-\.]+$");
    return locationRegex.hasMatch(location.trim());
  }

  /// Valida nacionalidad
  static bool isValidNationality(String nationality) {
    if (nationality.isEmpty) return true; // Campo opcional
    if (nationality.length > 50) return false;

    // Permitir solo letras y espacios
    final nationalityRegex = RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s]+$");
    return nationalityRegex.hasMatch(nationality.trim());
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES DE RESULTADO
// ═══════════════════════════════════════════════════════════════════════════

/// Resultado de validación de perfil
class ProfileValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;

  const ProfileValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  /// Verifica si hay errores en un campo específico
  bool hasErrorForField(String field) => errors.containsKey(field);

  /// Obtiene el error de un campo específico
  String? getErrorForField(String field) => errors[field];

  /// Verifica si hay advertencias en un campo específico
  bool hasWarningForField(String field) => warnings.containsKey(field);

  /// Obtiene la advertencia de un campo específico
  String? getWarningForField(String field) => warnings[field];

  /// Obtiene todos los mensajes (errores y advertencias)
  List<String> getAllMessages() {
    return [...errors.values, ...warnings.values];
  }
}

/// Información de completitud del perfil
class ProfileCompleteness {
  final int completedFields;
  final int totalFields;
  final double percentage;
  final List<String> missingFields;

  const ProfileCompleteness({
    required this.completedFields,
    required this.totalFields,
    required this.percentage,
    required this.missingFields,
  });

  /// Determina el nivel de completitud
  ProfileCompletenessLevel get level {
    if (percentage >= 90) return ProfileCompletenessLevel.excellent;
    if (percentage >= 70) return ProfileCompletenessLevel.good;
    if (percentage >= 50) return ProfileCompletenessLevel.fair;
    return ProfileCompletenessLevel.poor;
  }

  /// Obtiene un mensaje descriptivo del nivel
  String get levelMessage {
    switch (level) {
      case ProfileCompletenessLevel.excellent:
        return '¡Excelente! Tu perfil está casi completo';
      case ProfileCompletenessLevel.good:
        return 'Buen trabajo. Tu perfil está bien completado';
      case ProfileCompletenessLevel.fair:
        return 'Tu perfil está parcialmente completo';
      case ProfileCompletenessLevel.poor:
        return 'Tu perfil necesita más información';
    }
  }

  /// Obtiene el color asociado al nivel
  Color get levelColor {
    switch (level) {
      case ProfileCompletenessLevel.excellent:
        return Colors.green;
      case ProfileCompletenessLevel.good:
        return Colors.lightGreen;
      case ProfileCompletenessLevel.fair:
        return Colors.orange;
      case ProfileCompletenessLevel.poor:
        return Colors.red;
    }
  }

  /// Obtiene el icono asociado al nivel
  IconData get levelIcon {
    switch (level) {
      case ProfileCompletenessLevel.excellent:
        return Icons.check_circle;
      case ProfileCompletenessLevel.good:
        return Icons.thumb_up;
      case ProfileCompletenessLevel.fair:
        return Icons.info;
      case ProfileCompletenessLevel.poor:
        return Icons.warning;
    }
  }
}

/// Niveles de completitud del perfil
enum ProfileCompletenessLevel {
  poor,
  fair,
  good,
  excellent,
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSIONES PARA MEJORAR LA USABILIDAD
// ═══════════════════════════════════════════════════════════════════════════

/// Extensión para UserProfile con métodos de seguridad
extension UserProfileSecurity on UserProfile {
  /// Valida este perfil
  ProfileValidationResult validate() => ProfileSecurityUtils.validateProfile(this);

  /// Sanitiza este perfil
  UserProfile sanitize() => ProfileSecurityUtils.sanitizeProfile(this);

  /// Verifica si este perfil es seguro
  bool get isSecure => ProfileSecurityUtils.isProfileSecure(this);

  /// Calcula la completitud de este perfil
  ProfileCompleteness get completeness => ProfileSecurityUtils.calculateCompleteness(this);

  /// Obtiene recomendaciones para este perfil
  List<String> get recommendations => ProfileSecurityUtils.getProfileRecommendations(this);

  /// Crea una versión ofuscada para logs
  Map<String, dynamic> get obfuscatedForLogs => ProfileSecurityUtils.obfuscateProfileForLogs(this);

  /// Verifica si un campo específico es válido
  bool isFieldValid(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'name':
        return ProfileSecurityUtils.isValidName(name);
      case 'email':
        return ProfileSecurityUtils.isValidEmail(email);
      case 'phone':
        return ProfileSecurityUtils.isValidPhone(phone);
      case 'employment':
        return ProfileSecurityUtils.isValidEmployment(employment);
      case 'nationality':
        return ProfileSecurityUtils.isValidNationality(nationality);
      case 'city':
      case 'province':
      case 'district':
        final value = fieldName == 'city' ? city :
        fieldName == 'province' ? province : district;
        return ProfileSecurityUtils.isValidLocation(value);
      case 'profileimage':
        return ProfileSecurityUtils.isValidImageUrl(profileImageUrl ?? '');
      default:
        return true;
    }
  }

  /// Obtiene el mensaje de error para un campo específico
  String? getFieldError(String fieldName) {
    if (isFieldValid(fieldName)) return null;

    switch (fieldName.toLowerCase()) {
      case 'name':
        return 'El nombre debe tener entre 2 y 100 caracteres válidos';
      case 'email':
        return 'El email no tiene un formato válido';
      case 'phone':
        return 'El teléfono no tiene un formato válido';
      case 'employment':
        return 'La ocupación contiene caracteres no válidos';
      case 'nationality':
        return 'La nacionalidad contiene caracteres no válidos';
      case 'city':
      case 'province':
      case 'district':
        return 'La ubicación contiene caracteres no válidos';
      case 'profileimage':
        return 'La URL de la imagen no es válida';
      default:
        return 'Campo no válido';
    }
  }
}