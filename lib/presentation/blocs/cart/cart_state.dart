part of 'cart_bloc.dart';

@immutable
sealed class CartState {}

/// Estado inicial del carrito
final class CartInitial extends CartState {}

/// Carrito vacío
class CartEmpty extends CartState {}

/// Carrito con items
class CartLoaded extends CartState {
  final List<CartItem> items;

  CartLoaded(this.items);

  /// Total de items en el carrito
  int get totalItems {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Total de precio del carrito
  double get totalPrice {
    return items.fold<double>(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Total formateado (asumiendo PEN)
  String get formattedTotal {
    return 'S/ ${totalPrice.toStringAsFixed(2)}';
  }

  /// Items agrupados por ubicación
  Map<String, List<CartItem>> get itemsByLocation {
    final grouped = <String, List<CartItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.locationId, () => []).add(item);
    }
    return grouped;
  }
}

/// Item agregado al carrito exitosamente
class CartItemAdded extends CartState {
  final String productName;

  CartItemAdded(this.productName);
}

/// Item removido del carrito
class CartItemRemoved extends CartState {
  final String productName;

  CartItemRemoved(this.productName);
}

/// Cantidad actualizada
class CartItemUpdated extends CartState {}

/// Carrito vaciado
class CartCleared extends CartState {}

/// Error en operación del carrito
class CartError extends CartState {
  final String message;

  CartError(this.message);
}
