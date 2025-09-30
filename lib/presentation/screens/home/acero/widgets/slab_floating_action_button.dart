// lib/presentation/screens/home/acero/losa/widgets/slab_floating_action_button.dart
import 'package:flutter/material.dart';
import '../../../../../../config/theme/theme.dart';

class SlabFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final String tooltip;

  const SlabFloatingActionButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.icon = Icons.calculate,
    this.tooltip = 'Calcular',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      backgroundColor: onPressed != null ? AppColors.primary : AppColors.neutral400,
      foregroundColor: AppColors.white,
      elevation: isLoading ? 0 : 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      )
          : Icon(icon, size: 24),
      label: Text(
        isLoading ? 'Calculando...' : 'Calcular',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}