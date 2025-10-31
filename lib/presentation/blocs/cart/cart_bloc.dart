import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/map/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

/// BLoC para gestión del carrito de compras
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
    on<LoadCart>(_onLoadCart);
  }

  /// Agregar producto al carrito
  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    // Obtener items actuales
    final currentItems = _getCurrentItems();
    final items = List<CartItem>.from(currentItems);

    // Buscar si el producto ya existe en el carrito
    final existingIndex = items.indexWhere(
      (item) =>
          item.product.supabaseId == event.product.supabaseId &&
          item.locationId == event.locationId,
    );

    if (existingIndex != -1) {
      // Incrementar cantidad si ya existe
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + event.quantity,
      );
    } else {
      // Agregar nuevo item
      items.add(CartItem(
        product: event.product,
        quantity: event.quantity,
        locationId: event.locationId,
        locationName: event.locationName,
      ));
    }

    emit(CartItemAdded(event.product.name ?? 'Producto'));
    emit(_emitCartState(items));
  }

  /// Eliminar producto del carrito
  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final currentItems = _getCurrentItems();
    final items = List<CartItem>.from(currentItems);

    final removedItem = items.firstWhere(
      (item) => item.product.supabaseId == event.productId,
    );

    items.removeWhere((item) => item.product.supabaseId == event.productId);

    emit(CartItemRemoved(removedItem.product.name ?? 'Producto'));
    emit(_emitCartState(items));
  }

  /// Actualizar cantidad de un producto
  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    final currentItems = _getCurrentItems();
    final items = List<CartItem>.from(currentItems);

    final index = items.indexWhere(
      (item) => item.product.supabaseId == event.productId,
    );

    if (index != -1) {
      if (event.quantity <= 0) {
        // Si la cantidad es 0 o menor, eliminar el item
        items.removeAt(index);
      } else {
        // Actualizar cantidad
        items[index] = items[index].copyWith(quantity: event.quantity);
      }

      emit(CartItemUpdated());
      emit(_emitCartState(items));
    }
  }

  /// Vaciar carrito
  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartCleared());
    emit(CartEmpty());
  }

  /// Cargar carrito (para persistencia futura)
  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    // TODO: Implementar carga desde almacenamiento local
    emit(CartEmpty());
  }

  // ============================================================
  // MÉTODOS AUXILIARES PRIVADOS
  // ============================================================

  /// Obtener items actuales del estado
  List<CartItem> _getCurrentItems() {
    if (state is CartLoaded) {
      return (state as CartLoaded).items;
    }
    return [];
  }

  /// Emitir el estado correcto según si hay items o no
  CartState _emitCartState(List<CartItem> items) {
    if (items.isEmpty) {
      return CartEmpty();
    }
    return CartLoaded(items);
  }

  // ============================================================
  // MÉTODOS AUXILIARES PÚBLICOS
  // ============================================================

  /// Verificar si el carrito tiene items
  bool get hasItems => state is CartLoaded;

  /// Obtener items actuales (solo lectura)
  List<CartItem> get currentItems {
    if (state is CartLoaded) {
      return (state as CartLoaded).items;
    }
    return [];
  }

  /// Obtener total de items
  int get totalItems {
    if (state is CartLoaded) {
      return (state as CartLoaded).totalItems;
    }
    return 0;
  }

  /// Obtener precio total
  double get totalPrice {
    if (state is CartLoaded) {
      return (state as CartLoaded).totalPrice;
    }
    return 0.0;
  }
}

/// Item del carrito
class CartItem {
  final Product product;
  final int quantity;
  final String locationId;
  final String locationName;

  CartItem({
    required this.product,
    required this.quantity,
    required this.locationId,
    required this.locationName,
  });

  double get subtotal {
    final price = product.price ?? 0.0;
    return price * quantity;
  }

  String get formattedSubtotal {
    return '${product.currency.symbol} ${subtotal.toStringAsFixed(2)}';
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? locationId,
    String? locationName,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
    );
  }
}
