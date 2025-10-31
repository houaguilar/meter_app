import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../domain/entities/map/product.dart';
import '../../../blocs/cart/cart_bloc.dart';

/// Pantalla de checkout para confirmar y completar el pedido
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _deliveryMethod = 'delivery'; // delivery o pickup
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Confirmar Pedido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos en el carrito',
                    style: context.typography.bodyLarge.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(context.spacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen del pedido
                  _buildOrderSummary(context, state),
                  SizedBox(height: context.spacing.lg),

                  // Método de entrega
                  _buildDeliveryMethod(context),
                  SizedBox(height: context.spacing.lg),

                  // Dirección de entrega (solo si es delivery)
                  if (_deliveryMethod == 'delivery') ...[
                    _buildDeliveryAddress(context),
                    SizedBox(height: context.spacing.lg),
                  ],

                  // Fecha y hora programada
                  _buildScheduledDateTime(context),
                  SizedBox(height: context.spacing.lg),

                  // Notas adicionales
                  _buildNotes(context),
                  SizedBox(height: context.spacing.xl),

                  // Botón de confirmar pedido
                  _buildConfirmButton(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartLoaded state) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: context.colors.primary),
              SizedBox(width: context.spacing.sm),
              Text(
                'Resumen del Pedido',
                style: context.typography.h5.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),

          // Lista de productos por ubicación
          ...state.itemsByLocation.entries.map((entry) {
            final items = entry.value;
            final locationName = items.first.locationName;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationName,
                  style: context.typography.h6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.blue,
                  ),
                ),
                SizedBox(height: context.spacing.sm),
                ...items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: context.spacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.product.name ?? "Sin nombre"}',
                              style: context.typography.bodyMedium,
                            ),
                          ),
                          Text(
                            item.formattedSubtotal,
                            style: context.typography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: context.spacing.md),
              ],
            );
          }),

          Divider(height: context.spacing.lg),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: context.typography.h5.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
              Text(
                state.formattedTotal,
                style: context.typography.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethod(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de Entrega',
            style: context.typography.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.md),
          RadioListTile<String>(
            title: const Text('Entrega a domicilio'),
            subtitle: const Text('Recibirás tu pedido en la dirección indicada'),
            value: 'delivery',
            groupValue: _deliveryMethod,
            activeColor: context.colors.primary,
            onChanged: (value) {
              setState(() {
                _deliveryMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Recoger en tienda'),
            subtitle: const Text('Retira tu pedido directamente del proveedor'),
            value: 'pickup',
            groupValue: _deliveryMethod,
            activeColor: context.colors.primary,
            onChanged: (value) {
              setState(() {
                _deliveryMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dirección de Entrega',
            style: context.typography.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.md),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Ingresa tu dirección completa',
              prefixIcon: Icon(Icons.location_on, color: context.colors.primary),
              filled: true,
              fillColor: context.colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.primary.withOpacity(0.3)),
              ),
            ),
            maxLines: 2,
            validator: (value) {
              if (_deliveryMethod == 'delivery' &&
                  (value == null || value.trim().isEmpty)) {
                return 'La dirección es obligatoria para entregas a domicilio';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledDateTime(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha y Hora de Entrega (Opcional)',
            style: context.typography.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            'Programa cuándo deseas recibir tu pedido',
            style: context.typography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(context),
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: _buildTimePicker(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final firstDate = now;
        final lastDate = now.add(const Duration(days: 30));

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _scheduledDate ?? now,
          firstDate: firstDate,
          lastDate: lastDate,
        );

        if (pickedDate != null) {
          setState(() {
            _scheduledDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(context.spacing.md),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _scheduledDate != null
                ? context.colors.primary
                : context.colors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _scheduledDate != null
                  ? context.colors.primary
                  : context.colors.textSecondary,
              size: 20,
            ),
            SizedBox(width: context.spacing.sm),
            Expanded(
              child: Text(
                _scheduledDate != null
                    ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                    : 'Fecha',
                style: context.typography.bodyMedium.copyWith(
                  color: _scheduledDate != null
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: _scheduledTime ?? const TimeOfDay(hour: 9, minute: 0),
        );

        if (pickedTime != null) {
          setState(() {
            _scheduledTime = pickedTime;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(context.spacing.md),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _scheduledTime != null
                ? context.colors.primary
                : context.colors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: _scheduledTime != null
                  ? context.colors.primary
                  : context.colors.textSecondary,
              size: 20,
            ),
            SizedBox(width: context.spacing.sm),
            Expanded(
              child: Text(
                _scheduledTime != null
                    ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                    : 'Hora',
                style: context.typography.bodyMedium.copyWith(
                  color: _scheduledTime != null
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notas Adicionales',
            style: context.typography.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.md),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Agrega instrucciones especiales para tu pedido...',
              filled: true,
              fillColor: context.colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.primary.withOpacity(0.3)),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, CartLoaded state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _confirmOrder(context, state),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.check_circle),
        label: Text(
          'Confirmar Pedido',
          style: context.typography.buttonLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context, CartLoaded state) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO: Implementar lógica para crear el pedido
    // 1. Crear entidad Order
    // 2. Guardar en Supabase
    // 3. Limpiar carrito
    // 4. Navegar a pantalla de confirmación

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: context.colors.success),
            const SizedBox(width: 12),
            const Text('Pedido Confirmado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu pedido ha sido enviado exitosamente.',
              style: context.typography.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Detalles:',
              style: context.typography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text('• Total: ${state.formattedTotal}'),
            Text('• Productos: ${state.totalItems}'),
            Text('• Método: ${_deliveryMethod == "delivery" ? "Entrega a domicilio" : "Recoger en tienda"}'),
            if (_scheduledDate != null)
              Text(
                '• Fecha: ${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Limpiar carrito
              context.read<CartBloc>().add(ClearCart());
              // Volver a la pantalla anterior
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
