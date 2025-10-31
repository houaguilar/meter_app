part of 'products_bloc.dart';

@immutable
sealed class ProductsState {}

/// Estado inicial
final class ProductsInitial extends ProductsState {}

/// Cargando productos
class ProductsLoading extends ProductsState {}

/// Productos cargados
class ProductsLoaded extends ProductsState {
  final List<Product> products;

  ProductsLoaded({required this.products});
}

/// Productos cargados por categoría
class ProductsByCategoryLoaded extends ProductsState {
  final List<Product> products;
  final String categoryId;

  ProductsByCategoryLoaded({
    required this.products,
    required this.categoryId,
  });
}

/// Guardando producto
class ProductSaving extends ProductsState {}

/// Producto guardado
class ProductSaved extends ProductsState {
  final Product product;

  ProductSaved(this.product);
}

/// Producto actualizado
class ProductUpdated extends ProductsState {
  final Product product;

  ProductUpdated(this.product);
}

/// Eliminando producto
class ProductDeleting extends ProductsState {}

/// Producto eliminado
class ProductDeleted extends ProductsState {
  final String productId;

  ProductDeleted(this.productId);
}

/// Stock cambiado
class ProductStockToggled extends ProductsState {
  final String productId;
  final bool available;

  ProductStockToggled({
    required this.productId,
    required this.available,
  });
}

/// Error en productos
class ProductsError extends ProductsState {
  final String message;

  ProductsError(this.message);
}
