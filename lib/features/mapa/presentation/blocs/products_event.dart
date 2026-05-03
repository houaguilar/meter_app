part of 'products_bloc.dart';

@immutable
sealed class ProductsEvent {}

/// Cargar todos los productos de una ubicación
class LoadLocationProducts extends ProductsEvent {
  final String locationId;

  LoadLocationProducts(this.locationId);
}

/// Cargar productos por categoría específica
class LoadProductsByCategory extends ProductsEvent {
  final String locationId;
  final String categoryId;

  LoadProductsByCategory({
    required this.locationId,
    required this.categoryId,
  });
}

/// Agregar nuevo producto
class AddProduct extends ProductsEvent {
  final Product product;

  AddProduct(this.product);
}

/// Actualizar producto existente
class UpdateProduct extends ProductsEvent {
  final Product product;

  UpdateProduct(this.product);
}

/// Eliminar producto
class DeleteProductEvent extends ProductsEvent {
  final String productId;

  DeleteProductEvent(this.productId);
}

/// Cambiar disponibilidad de stock
class ToggleProductStockEvent extends ProductsEvent {
  final String productId;
  final bool available;

  ToggleProductStockEvent({
    required this.productId,
    required this.available,
  });
}
