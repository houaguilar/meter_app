import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/map/product.dart';
import '../../../domain/usecases/map/delete_product.dart';
import '../../../domain/usecases/map/get_location_products.dart';
import '../../../domain/usecases/map/get_products_by_category.dart';
import '../../../domain/usecases/map/save_product.dart';
import '../../../domain/usecases/map/toggle_product_stock.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetLocationProducts getLocationProducts;
  final GetProductsByCategory getProductsByCategory;
  final SaveProduct saveProduct;
  final DeleteProduct deleteProduct;
  final ToggleProductStock toggleProductStock;

  ProductsBloc({
    required this.getLocationProducts,
    required this.getProductsByCategory,
    required this.saveProduct,
    required this.deleteProduct,
    required this.toggleProductStock,
  }) : super(ProductsInitial()) {
    on<LoadLocationProducts>(_onLoadLocationProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ToggleProductStockEvent>(_onToggleProductStock);
  }

  /// Cargar todos los productos de una ubicación
  void _onLoadLocationProducts(
      LoadLocationProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());

    final result = await getLocationProducts(event.locationId);

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  /// Cargar productos por categoría
  void _onLoadProductsByCategory(
      LoadProductsByCategory event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());

    final params = GetProductsByCategoryParams(
      locationId: event.locationId,
      categoryId: event.categoryId,
    );

    final result = await getProductsByCategory(params);

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsByCategoryLoaded(
        products: products,
        categoryId: event.categoryId,
      )),
    );
  }

  /// Agregar nuevo producto
  void _onAddProduct(AddProduct event, Emitter<ProductsState> emit) async {
    emit(ProductSaving());

    final result = await saveProduct(event.product);

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (savedProduct) => emit(ProductSaved(savedProduct)),
    );
  }

  /// Actualizar producto existente
  void _onUpdateProduct(
      UpdateProduct event, Emitter<ProductsState> emit) async {
    emit(ProductSaving());

    final result = await saveProduct(event.product);

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (updatedProduct) => emit(ProductUpdated(updatedProduct)),
    );
  }

  /// Eliminar producto
  void _onDeleteProduct(
      DeleteProductEvent event, Emitter<ProductsState> emit) async {
    emit(ProductDeleting());

    final result = await deleteProduct(event.productId);

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) => emit(ProductDeleted(event.productId)),
    );
  }

  /// Cambiar disponibilidad de stock
  void _onToggleProductStock(
      ToggleProductStockEvent event, Emitter<ProductsState> emit) async {
    final params = ToggleProductStockParams(
      productId: event.productId,
      available: event.available,
    );

    final result = await toggleProductStock(params);

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) => emit(ProductStockToggled(
        productId: event.productId,
        available: event.available,
      )),
    );
  }
}
