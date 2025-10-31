import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../domain/entities/map/product.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../checkout/checkout_screen.dart';

/// Pantalla del carrito de compras integrada con CartBloc
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Carrito de Compras',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return state is CartLoaded
                  ? IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded),
                      onPressed: () => _showClearCartDialog(context),
                      tooltip: 'Vaciar carrito',
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          // Mostrar mensajes de feedback
          if (state is CartItemAdded) {
            showSnackBar(context, '${state.productName} agregado al carrito');
          } else if (state is CartItemRemoved) {
            showSnackBar(context, 'Producto eliminado del carrito');
          } else if (state is CartCleared) {
            showSnackBar(context, 'Carrito vaciado');
          } else if (state is CartError) {
            showSnackBar(context, 'Error: ${state.message}');
          }
        },
        builder: (context, state) {
          // Mostrar carrito vacío
          if (state is CartEmpty || state is CartInitial) {
            return _buildEmptyCart(context);
          }

          // Mostrar carrito con items
          if (state is CartLoaded) {
            return _buildCartContent(context, state);
          }

          // Estado por defecto
          return _buildEmptyCart(context);
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          return state is CartLoaded
              ? _buildCheckoutButton(context)
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.spacing.xl),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: context.spacing.lg),
            Text(
              'Tu carrito está vacío',
              style: context.typography.h4.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              'Explora el mapa y agrega productos de tus proveedores favoritos',
              style: context.typography.bodyLarge.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xl),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.xl,
                  vertical: context.spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.map_rounded),
              label: Text(
                'Explorar Mapa',
                style: context.typography.buttonLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    // Obtener items agrupados por ubicación desde el estado
    final itemsByLocation = state.itemsByLocation;

    return ListView.builder(
      padding: EdgeInsets.all(context.spacing.md),
      itemCount: itemsByLocation.length + 1, // +1 para el resumen
      itemBuilder: (context, index) {
        if (index == itemsByLocation.length) {
          return _buildOrderSummary(context, state);
        }

        final locationId = itemsByLocation.keys.elementAt(index);
        final items = itemsByLocation[locationId]!;
        final locationName = items.first.locationName;

        return _buildLocationGroup(context, locationName, items);
      },
    );
  }

  Widget _buildLocationGroup(
      BuildContext context, String locationName, List<CartItem> items) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del proveedor
          Container(
            padding: EdgeInsets.all(context.spacing.md),
            decoration: BoxDecoration(
              color: context.colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.store_rounded,
                  color: context.colors.blue,
                  size: 20,
                ),
                SizedBox(width: context.spacing.sm),
                Expanded(
                  child: Text(
                    locationName,
                    style: context.typography.h6.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.blue,
                    ),
                  ),
                ),
                Text(
                  '${items.length} ${items.length == 1 ? 'producto' : 'productos'}',
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Items del proveedor
          ...items.map((item) => _buildCartItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.textSecondary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto (placeholder por ahora)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.blue,
                  context.colors.blue.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: context.spacing.md),
          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name ?? 'Sin nombre',
                  style: context.typography.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Text(
                  item.product.formattedPrice,
                  style: context.typography.bodyMedium.copyWith(
                    color: context.colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.product.unit != null) ...[
                  SizedBox(height: context.spacing.xs),
                  Text(
                    'Por ${item.product.unit!.displayName}',
                    style: context.typography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Controles de cantidad
          Column(
            children: [
              _buildQuantityControls(context, item),
              SizedBox(height: context.spacing.xs),
              Text(
                item.formattedSubtotal,
                style: context.typography.h6.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colors.textSecondary.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            context: context,
            icon: item.quantity > 1 ? Icons.remove : Icons.delete_outline,
            color: item.quantity > 1
                ? context.colors.primary
                : context.colors.error,
            onTap: () => _decreaseQuantity(context, item),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: context.typography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildQuantityButton(
            context: context,
            icon: Icons.add,
            color: context.colors.primary,
            onTap: () => _increaseQuantity(context, item),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartLoaded state) {
    final total = state.totalPrice;
    final totalItems = state.totalItems;

    // Asumiendo que todos los productos tienen la misma moneda (PEN)
    final currency = state.items.isNotEmpty
        ? state.items.first.product.currency
        : Currency.PEN;

    return Container(
      margin: EdgeInsets.only(top: context.spacing.md),
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Pedido',
            style: context.typography.h5.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacing.md),
          _buildSummaryRow(
            context,
            'Productos',
            '$totalItems ${totalItems == 1 ? 'producto' : 'productos'}',
          ),
          SizedBox(height: context.spacing.sm),
          _buildSummaryRow(
            context,
            'Subtotal',
            '${currency.symbol} ${total.toStringAsFixed(2)}',
          ),
          Divider(height: context.spacing.lg),
          _buildSummaryRow(
            context,
            'Total',
            '${currency.symbol} ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal
                  ? context.typography.h5
                  : context.typography.bodyLarge)
              .copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal
                ? context.colors.primary
                : context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: (isTotal
                  ? context.typography.h4
                  : context.typography.bodyLarge)
              .copyWith(
            fontWeight: FontWeight.w700,
            color: isTotal ? context.colors.primary : context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _proceedToCheckout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.shopping_bag_rounded),
            label: Text(
              'Proceder al Pedido',
              style: context.typography.buttonLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _increaseQuantity(BuildContext context, CartItem item) {
    final productId = item.product.supabaseId;
    if (productId == null) return;

    context.read<CartBloc>().add(UpdateQuantity(
          productId: productId,
          quantity: item.quantity + 1,
        ));
  }

  void _decreaseQuantity(BuildContext context, CartItem item) {
    final productId = item.product.supabaseId;
    if (productId == null) return;

    if (item.quantity > 1) {
      context.read<CartBloc>().add(UpdateQuantity(
            productId: productId,
            quantity: item.quantity - 1,
          ));
    } else {
      _removeItem(context, item);
    }
  }

  void _removeItem(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Deseas eliminar "${item.product.name}" del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final productId = item.product.supabaseId;
              if (productId != null) {
                context.read<CartBloc>().add(RemoveFromCart(productId));
              }
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vaciar Carrito'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todos los productos del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartBloc>().add(ClearCart());
            },
            child: Text(
              'Vaciar',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(),
      ),
    );
  }
}
