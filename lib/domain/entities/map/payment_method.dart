/// Métodos de pago aceptados por un proveedor
enum PaymentMethod {
  /// Efectivo
  cash,

  /// Tarjeta de crédito/débito
  card,

  /// Yape (Billetera digital Perú)
  yape,

  /// Plin (Billetera digital Perú)
  plin,

  /// Transferencia bancaria
  transfer;

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.yape:
        return 'Yape';
      case PaymentMethod.plin:
        return 'Plin';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }

  /// Icono emoji
  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.yape:
        return '📱';
      case PaymentMethod.plin:
        return '📲';
      case PaymentMethod.transfer:
        return '🏦';
    }
  }

  /// Descripción corta
  String get description {
    switch (this) {
      case PaymentMethod.cash:
        return 'Pago en efectivo';
      case PaymentMethod.card:
        return 'Visa, Mastercard';
      case PaymentMethod.yape:
        return 'Yape BCP';
      case PaymentMethod.plin:
        return 'Plin Interbank';
      case PaymentMethod.transfer:
        return 'Transferencia bancaria';
    }
  }

  /// Convierte el enum a string para BD
  String toDbString() {
    return name; // 'cash', 'card', 'yape', 'plin', 'transfer'
  }

  /// Crea el enum desde string de BD
  static PaymentMethod fromString(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'yape':
        return PaymentMethod.yape;
      case 'plin':
        return PaymentMethod.plin;
      case 'transfer':
        return PaymentMethod.transfer;
      default:
        return PaymentMethod.cash;
    }
  }

  /// Convierte una lista de strings a lista de enums
  static List<PaymentMethod> fromStringList(List<String>? stringList) {
    if (stringList == null || stringList.isEmpty) return [];
    return stringList.map((str) => fromString(str)).toList();
  }

  /// Convierte una lista de enums a lista de strings
  static List<String> toStringList(List<PaymentMethod> methods) {
    return methods.map((method) => method.toDbString()).toList();
  }

  /// Si es un método digital/electrónico
  bool get isDigital {
    return this == PaymentMethod.card ||
        this == PaymentMethod.yape ||
        this == PaymentMethod.plin ||
        this == PaymentMethod.transfer;
  }

  /// Si requiere contacto directo
  bool get requiresContact {
    return this == PaymentMethod.yape ||
        this == PaymentMethod.plin ||
        this == PaymentMethod.transfer;
  }
}

/// Helper para formatear métodos de pago en texto
class PaymentMethodFormatter {
  /// Convierte lista de métodos a texto legible
  /// Ejemplo: "Efectivo, Yape, Plin"
  static String toReadableString(List<PaymentMethod> methods) {
    if (methods.isEmpty) return 'No especificado';
    return methods.map((m) => m.displayName).join(', ');
  }

  /// Convierte lista de métodos a texto con iconos
  /// Ejemplo: "💵 Efectivo, 📱 Yape, 📲 Plin"
  static String toReadableStringWithIcons(List<PaymentMethod> methods) {
    if (methods.isEmpty) return 'No especificado';
    return methods.map((m) => '${m.icon} ${m.displayName}').join(', ');
  }

  /// Agrupa por tipo (físico vs digital)
  static Map<String, List<PaymentMethod>> groupByType(List<PaymentMethod> methods) {
    final physical = methods.where((m) => !m.isDigital).toList();
    final digital = methods.where((m) => m.isDigital).toList();

    return {
      'physical': physical,
      'digital': digital,
    };
  }

  /// Devuelve los métodos más comunes en Perú
  static List<PaymentMethod> get commonInPeru {
    return [
      PaymentMethod.cash,
      PaymentMethod.yape,
      PaymentMethod.plin,
      PaymentMethod.card,
    ];
  }
}
