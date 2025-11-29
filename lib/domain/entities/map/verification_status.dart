/// Estados de verificación de un proveedor en el marketplace
enum VerificationStatus {
  /// Esperando aprobación
  pending,

  /// Aprobado, puede operar y estar visible
  approved,

  /// Rechazado, no puede continuar
  rejected;

  /// Convierte el enum a string para BD (snake_case)
  String toDbString() {
    switch (this) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }

  /// Crea el enum desde string de BD
  static VerificationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'scheduled': // Compatibilidad con datos antiguos
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pendiente';
      case VerificationStatus.approved:
        return 'Aprobado';
      case VerificationStatus.rejected:
        return 'Rechazado';
    }
  }

  /// Emoji representativo
  String get emoji {
    switch (this) {
      case VerificationStatus.pending:
        return '⏳';
      case VerificationStatus.approved:
        return '✅';
      case VerificationStatus.rejected:
        return '❌';
    }
  }

  /// Color asociado (hex string)
  String get colorHex {
    switch (this) {
      case VerificationStatus.pending:
        return '#FF9800'; // Orange
      case VerificationStatus.approved:
        return '#4CAF50'; // Green
      case VerificationStatus.rejected:
        return '#F44336'; // Red
    }
  }

  /// Si puede configurar productos
  bool get canConfigureProducts {
    return this == VerificationStatus.approved;
  }

  /// Si es visible en el mapa para clientes
  bool get isVisibleInMap {
    return this == VerificationStatus.approved;
  }

  // ============================================================
  // GETTERS DE CONVENIENCIA
  // ============================================================

  /// Si está aprobado (puede operar en la plataforma)
  bool get isApproved {
    return this == VerificationStatus.approved;
  }

  /// Si está esperando aprobación
  bool get isPending {
    return this == VerificationStatus.pending;
  }

  /// Si fue rechazado
  bool get isRejected {
    return this == VerificationStatus.rejected;
  }
}
