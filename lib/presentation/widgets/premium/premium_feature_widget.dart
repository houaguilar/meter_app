
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/widgets/premium/premium_paywall_screen.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../blocs/premium/premium_bloc.dart';

class PremiumFeatureWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final String? featureName;
  final VoidCallback? onPremiumRequired;
  final bool showLockOverlay;
  final String? lockMessage;

  const PremiumFeatureWidget({
    super.key,
    required this.child,
    this.fallback,
    this.featureName,
    this.onPremiumRequired,
    this.showLockOverlay = true,
    this.lockMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        PremiumStatus? status;

        if (state is PremiumLoaded) {
          status = state.status;
        } else if (state is PurchaseInProgress) {
          status = state.currentStatus;
        } else if (state is PurchaseSuccess) {
          status = state.newStatus;
        } else if (state is PurchaseFailure) {
          status = state.currentStatus;
        } else if (state is PremiumError) {
          status = state.lastKnownStatus;
        }

        // Si no hay status o no es premium, mostrar versión bloqueada
        if (status == null || !status.isActive) {
          if (fallback != null) {
            return fallback!;
          }

          if (showLockOverlay) {
            return _buildLockedOverlay(context);
          }

          return const SizedBox.shrink();
        }

        // Usuario premium, mostrar contenido completo
        return child;
      },
    );
  }

  Widget _buildLockedOverlay(BuildContext context) {
    return Stack(
      children: [
        // Contenido deshabilitado
        IgnorePointer(
          child: Opacity(
            opacity: 0.3,
            child: child,
          ),
        ),

        // Overlay de bloqueo
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handlePremiumRequired(context),
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lockMessage ?? 'Función Premium',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Toca para ver planes',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePremiumRequired(BuildContext context) {
    // Log del feature para analytics
    if (featureName != null) {
      print('🔒 Feature premium requerido: $featureName');
    }

    // Callback personalizado
    if (onPremiumRequired != null) {
      onPremiumRequired!();
      return;
    }

    // Navegación por defecto al paywall
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PremiumPaywallScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}