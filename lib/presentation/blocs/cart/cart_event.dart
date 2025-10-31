part of 'cart_bloc.dart';

@immutable
sealed class CartEvent {}

/// Agregar producto al carrito
class AddToCart extends CartEvent {
  final Product product;
  final int quantity;
  final String locationId;
  final String locationName;

  AddToCart({
    required this.product,
    required this.locationId,
    required this.locationName,
    this.quantity = 1,
  });
}

/// Eliminar producto del carrito
class RemoveFromCart extends CartEvent {
  final String productId;

  RemoveFromCart(this.productId);
}

/// Actualizar cantidad de un producto
class UpdateQuantity extends CartEvent {
  final String productId;
  final int quantity;

  UpdateQuantity({
    required this.productId,
    required this.quantity,
  });
}

/// Vaciar carrito
class ClearCart extends CartEvent {}

/// Cargar carrito desde almacenamiento
class LoadCart extends CartEvent {}
