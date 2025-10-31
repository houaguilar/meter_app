import 'package:url_launcher/url_launcher.dart';
import 'product.dart';
import 'location.dart';

/// Item individual en el carrito de compras
class CartItem {
  /// Producto
  final Product product;

  /// Cantidad solicitada
  final int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Subtotal del item (precio × cantidad)
  double get subtotal {
    final price = product.price ?? 0.0;
    return price * quantity;
  }

  /// Subtotal formateado
  String get formattedSubtotal {
    return '${product.currency.symbol} ${subtotal.toStringAsFixed(2)}';
  }

  /// Descripción del item para compartir
  String get description {
    final name = product.name ?? 'Producto';
    final unit = product.unit?.displayName ?? '';
    return unit.isNotEmpty ? '$name ($unit)' : name;
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItem(product: ${product.name}, quantity: $quantity, subtotal: $formattedSubtotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.product.id == product.id &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(product.id, quantity);
}

/// Carrito de compras para un proveedor específico
/// Solo existe en memoria, no se persiste en Isar
class Cart {
  /// ID del proveedor/ubicación
  final String locationId;

  /// Items en el carrito
  final List<CartItem> items;

  /// Notas adicionales del cliente
  String? notes;

  /// Dirección de entrega
  String? deliveryAddress;

  Cart({
    required this.locationId,
    this.items = const [],
    this.notes,
    this.deliveryAddress,
  });

  /// Constructor vacío
  Cart.empty(String locationId)
      : locationId = locationId,
        items = [],
        notes = null,
        deliveryAddress = null;

  /// Total de items (sumando cantidades)
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Total de productos diferentes
  int get totalProducts {
    return items.length;
  }

  /// Total a pagar (suma de subtotales)
  double get total {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Total formateado (asume todos en la misma moneda)
  String get formattedTotal {
    if (items.isEmpty) return 'S/ 0.00';
    final currency = items.first.product.currency;
    return '${currency.symbol} ${total.toStringAsFixed(2)}';
  }

  /// Si el carrito está vacío
  bool get isEmpty {
    return items.isEmpty;
  }

  /// Si el carrito tiene items
  bool get isNotEmpty {
    return items.isNotEmpty;
  }

  /// Agrega un producto al carrito
  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Incrementar cantidad del existente
      final existing = items[existingIndex];
      items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      // Agregar nuevo item
      items.add(CartItem(product: product, quantity: quantity));
    }
  }

  /// Remueve un producto del carrito
  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id.toString() == productId);
  }

  /// Actualiza la cantidad de un producto
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = items.indexWhere(
      (item) => item.product.id.toString() == productId,
    );

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
    }
  }

  /// Limpia el carrito
  void clear() {
    items.clear();
    notes = null;
    deliveryAddress = null;
  }

  /// Genera el mensaje para WhatsApp
  String generateWhatsAppMessage(LocationMap location) {
    final buffer = StringBuffer();

    // Saludo
    buffer.writeln('Hola, me gustaría hacer un pedido desde MetraShop:');
    buffer.writeln();

    // Nombre del negocio
    buffer.writeln('🏪 ${location.title}');
    buffer.writeln();

    // Items
    buffer.writeln('📦 MI PEDIDO:');
    for (var item in items) {
      final name = item.product.name ?? 'Producto';
      final unit = item.product.unit?.displayName ?? '';
      final unitText = unit.isNotEmpty ? ' ($unit)' : '';
      buffer.writeln('• $name$unitText - Cantidad: ${item.quantity}');
    }
    buffer.writeln();

    // Notas
    if (notes != null && notes!.isNotEmpty) {
      buffer.writeln('📝 Notas: $notes');
      buffer.writeln();
    }

    // Dirección
    if (deliveryAddress != null && deliveryAddress!.isNotEmpty) {
      buffer.writeln('📍 Dirección: $deliveryAddress');
      buffer.writeln();
    }

    // Pregunta final
    buffer.writeln('¿Podrías confirmar disponibilidad y precio total?');

    return buffer.toString();
  }

  /// Abre WhatsApp con el mensaje del pedido
  Future<bool> sendToWhatsApp(LocationMap location, String whatsappNumber) async {
    final message = generateWhatsAppMessage(location);
    final encodedMessage = Uri.encodeComponent(message);

    // Limpiar número (remover espacios, guiones, etc.)
    final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // URL de WhatsApp
    final url = 'https://wa.me/$cleanNumber?text=$encodedMessage';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    return false;
  }

  /// Resumen corto del carrito
  /// Ejemplo: "3 productos (5 items)"
  String get summary {
    return '$totalProducts producto${totalProducts != 1 ? 's' : ''} ($totalItems item${totalItems != 1 ? 's' : ''})';
  }

  Cart copyWith({
    String? locationId,
    List<CartItem>? items,
    String? notes,
    String? deliveryAddress,
  }) {
    return Cart(
      locationId: locationId ?? this.locationId,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }

  @override
  String toString() {
    return 'Cart(locationId: $locationId, items: ${items.length}, total: $formattedTotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && other.locationId == locationId;
  }

  @override
  int get hashCode => locationId.hashCode;
}
