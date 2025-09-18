// lib/presentation/widgets/dialogs/confirmation_dialog.dart
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

/// Widget de confirmación personalizado para usar en lugar de AlertDialog
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  /// Método estático para mostrar el diálogo
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDestructive ? AppColors.error : AppColors.warning).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isDestructive ? Icons.warning_amber_outlined : Icons.help_outline,
              color: isDestructive ? AppColors.error : AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
      actions: [
        // Botón cancelar
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(
            cancelText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Botón confirmar
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}