
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_config.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../blocs/premium/premium_bloc.dart';

class PremiumStatusIndicator extends StatelessWidget {
  final bool showMockBadge;
  final EdgeInsets? padding;

  const PremiumStatusIndicator({
    super.key,
    this.showMockBadge = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        PremiumStatus? status;
        bool isLoading = false;

        if (state is PremiumLoaded) {
          status = state.status;
          isLoading = state.isPerformingAction;
        } else if (state is PremiumLoading) {
          isLoading = true;
        } else if (state is PurchaseInProgress) {
          status = state.currentStatus;
          isLoading = true;
        } else if (state is PurchaseSuccess) {
          status = state.newStatus;
        } else if (state is PurchaseFailure) {
          status = state.currentStatus;
        } else if (state is PremiumError) {
          status = state.lastKnownStatus;
        }

        return Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
              ],

              if (status != null)
                _buildStatusBadge(status)
              else
                _buildUnknownBadge(),

              if (AppConfig.isDevelopment && showMockBadge) ...[
                const SizedBox(width: 8),
                _buildMockBadge(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(PremiumStatus status) {
    if (status.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            const Text(
              'PREMIUM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (status.daysRemaining != null && status.daysRemaining! <= 7) ...[
              const SizedBox(width: 4),
              Text(
                '(${status.daysRemaining}d)',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'GRATUITO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildUnknownBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'CARGANDO...',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade400),
      ),
      child: Text(
        'MOCK',
        style: TextStyle(
          color: Colors.orange.shade700,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}