/// Estados de verificación de un proveedor en el marketplace
enum VerificationStatus {
  /// Esperando reunión/videollamada con encargada
  pendingApproval,

  /// Aprobado por encargada, puede configurar productos
  approved,

  /// Rechazado, no puede continuar
  rejected,

  /// Activo con productos configurados, visible en el mapa
  active;

  /// Convierte el enum a string para BD (snake_case)
  String toDbString() {
    switch (this) {
      case VerificationStatus.pendingApproval:
        return 'pending_approval';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
      case VerificationStatus.active:
        return 'active';
    }
  }

  /// Crea el enum desde string de BD
  static VerificationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return VerificationStatus.pendingApproval;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'active':
        return VerificationStatus.active;
      default:
        return VerificationStatus.pendingApproval;
    }
  }

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case VerificationStatus.pendingApproval:
        return 'Verificación Pendiente';
      case VerificationStatus.approved:
        return 'Aprobado';
      case VerificationStatus.rejected:
        return 'Rechazado';
      case VerificationStatus.active:
        return 'Activo';
    }
  }

  /// Emoji representativo
  String get emoji {
    switch (this) {
      case VerificationStatus.pendingApproval:
        return '⏳';
      case VerificationStatus.approved:
        return '✅';
      case VerificationStatus.rejected:
        return '❌';
      case VerificationStatus.active:
        return '🟢';
    }
  }

  /// Color asociado (hex string)
  String get colorHex {
    switch (this) {
      case VerificationStatus.pendingApproval:
        return '#FF9800'; // Orange
      case VerificationStatus.approved:
        return '#4CAF50'; // Green
      case VerificationStatus.rejected:
        return '#F44336'; // Red
      case VerificationStatus.active:
        return '#2196F3'; // Blue
    }
  }

  /// Si puede configurar productos
  bool get canConfigureProducts {
    return this == VerificationStatus.approved || this == VerificationStatus.active;
  }

  /// Si es visible en el mapa para clientes
  bool get isVisibleInMap {
    return this == VerificationStatus.active;
  }

  // ============================================================
  // GETTERS DE CONVENIENCIA PARA COMPATIBILIDAD
  // ============================================================

  /// Si está aprobado o activo (puede operar en la plataforma)
  bool get isApproved {
    return this == VerificationStatus.approved || this == VerificationStatus.active;
  }

  /// Si está esperando aprobación
  bool get isPendingApproval {
    return this == VerificationStatus.pendingApproval;
  }

  /// Si fue rechazado
  bool get isRejected {
    return this == VerificationStatus.rejected;
  }

  /// Si está activo (con productos configurados y visible en mapa)
  bool get isActive {
    return this == VerificationStatus.active;
  }
}
