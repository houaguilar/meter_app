/// Tipos de documento de identidad válidos en Perú
enum DocumentType {
  /// DNI - Documento Nacional de Identidad (8 dígitos, peruanos)
  dni,

  /// Carnet de Extranjería (9 dígitos, extranjeros residentes)
  ce;

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case DocumentType.dni:
        return 'DNI';
      case DocumentType.ce:
        return 'Carnet de Extranjería';
    }
  }

  /// Descripción completa
  String get fullDescription {
    switch (this) {
      case DocumentType.dni:
        return 'DNI (8 dígitos)';
      case DocumentType.ce:
        return 'Carnet de Extranjería (9 dígitos)';
    }
  }

  /// Longitud esperada del documento
  int get expectedLength {
    switch (this) {
      case DocumentType.dni:
        return 8;
      case DocumentType.ce:
        return 9;
    }
  }

  /// Convierte el enum a string para BD
  String toDbString() {
    return name; // 'dni' o 'ce'
  }

  /// Crea el enum desde string de BD
  static DocumentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'dni':
        return DocumentType.dni;
      case 'ce':
        return DocumentType.ce;
      default:
        return DocumentType.dni;
    }
  }
}

/// Validadores para documentos de identidad
class DocumentValidator {
  /// Valida DNI (8 dígitos)
  static bool isValidDNI(String dni) {
    return RegExp(r'^\d{8}$').hasMatch(dni);
  }

  /// Valida Carnet de Extranjería (9 dígitos)
  static bool isValidCE(String ce) {
    return RegExp(r'^\d{9}$').hasMatch(ce);
  }

  /// Valida cualquier documento según su tipo
  static bool isValid(String document, DocumentType type) {
    switch (type) {
      case DocumentType.dni:
        return isValidDNI(document);
      case DocumentType.ce:
        return isValidCE(document);
    }
  }

  /// Valida cualquier documento (DNI o CE)
  static bool isValidDocument(String document) {
    return isValidDNI(document) || isValidCE(document);
  }

  /// Determina el tipo de documento basado en la longitud
  static DocumentType? detectType(String document) {
    if (isValidDNI(document)) return DocumentType.dni;
    if (isValidCE(document)) return DocumentType.ce;
    return null;
  }

  /// Mensaje de error para validación de formulario
  static String? validateField(String? value, DocumentType type) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu ${type.displayName}';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Solo números';
    }

    if (value.length != type.expectedLength) {
      return 'Debe tener ${type.expectedLength} dígitos';
    }

    if (!isValid(value, type)) {
      return '${type.displayName} inválido';
    }

    return null; // Sin error
  }
}
