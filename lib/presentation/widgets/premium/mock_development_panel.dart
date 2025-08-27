
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_config.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../blocs/premium/premium_bloc.dart';

class MockDevelopmentPanel extends StatelessWidget {
  const MockDevelopmentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDevelopment) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Panel de Desarrollo Mock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          BlocBuilder<PremiumBloc, PremiumState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusDisplay(state),
                  const SizedBox(height: 16),
                  _buildActionButtons(context, state),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDisplay(PremiumState state) {
    PremiumStatus? status;
    String stateInfo = 'Desconocido';

    if (state is PremiumLoaded) {
      status = state.status;
      stateInfo = state.isPerformingAction ? 'Ejecutando acción...' : 'Cargado';
    } else if (state is PremiumLoading) {
      stateInfo = 'Cargando...';
    } else if (state is PremiumError) {
      status = state.lastKnownStatus;
      stateInfo = 'Error: ${state.message}';
    } else if (state is PurchaseInProgress) {
      status = state.currentStatus;
      stateInfo = 'Compra en progreso...';
    } else if (state is PurchaseSuccess) {
      status = state.newStatus;
      stateInfo = 'Compra exitosa';
    } else if (state is PurchaseFailure) {
      status = state.currentStatus;
      stateInfo = 'Error en compra: ${state.message}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado Actual:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text('Estado BLoC: $stateInfo'),

          if (status != null) ...[
            const SizedBox(height: 8),
            Text('Premium: ${status.isPremium ? "✅ SÍ" : "❌ NO"}'),
            if (status.premiumUntil != null)
              Text('Expira: ${_formatDate(status.premiumUntil!)}'),
            Text('Fuente: ${status.source.displayName}'),
            if (status.entitlementId != null)
              Text('Entitlement: ${status.entitlementId}'),
            Text('Activo: ${status.isActive ? "✅ SÍ" : "❌ NO"}'),
            if (status.daysRemaining != null)
              Text('Días restantes: ${status.daysRemaining}'),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PremiumState state) {
    final isLoading = state is PremiumLoading ||
        state is PurchaseInProgress ||
        (state is PremiumLoaded && state.isPerformingAction);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          context: context,
          label: '🎁 Trial Premium',
          onPressed: isLoading ? null : () {
            context.read<PremiumBloc>().add(GrantTrialPremium());
          },
          color: Colors.green,
        ),

        _buildActionButton(
          context: context,
          label: '💳 Comprar Premium',
          onPressed: isLoading ? null : () {
            context.read<PremiumBloc>().add(PurchaseMonthlySubscription());
          },
          color: Colors.blue,
        ),

        _buildActionButton(
          context: context,
          label: '🔄 Restaurar',
          onPressed: isLoading ? null : () {
            context.read<PremiumBloc>().add(RestorePurchases());
          },
          color: Colors.orange,
        ),

        _buildActionButton(
          context: context,
          label: '⏰ Forzar Expiración',
          onPressed: isLoading ? null : () {
            context.read<PremiumBloc>().add(ForceExpiration());
          },
          color: Colors.red,
        ),

        _buildActionButton(
          context: context,
          label: '🗑️ Limpiar Todo',
          onPressed: isLoading ? null : () {
            _showConfirmDialog(context, () {
              context.read<PremiumBloc>().add(ClearAllSubscriptions());
            });
          },
          color: Colors.grey,
        ),

        _buildActionButton(
          context: context,
          label: '☁️ Sincronizar',
          onPressed: isLoading ? null : () {
            context.read<PremiumBloc>().add(SyncWithSupabase());
          },
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Acción'),
        content: const Text(
            'Esta acción eliminará todas las suscripciones mock. ¿Continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}