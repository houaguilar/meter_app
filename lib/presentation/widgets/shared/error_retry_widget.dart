// lib/presentation/widgets/shared/error_retry_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/presentation/assets/icons.dart';

import '../../../config/theme/theme.dart';

/// Widget reutilizable para mostrar estados de error con opción de reintento
///
/// Proporciona una interfaz consistente para manejar errores en toda la aplicación
/// con diferentes niveles de detalle según el contexto.
class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final Widget? customIcon;
  final ErrorType errorType;
  final bool showDetails;

  const ErrorRetryWidget({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.retryButtonText,
    this.customIcon,
    this.errorType = ErrorType.general,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: AppSpacing.lg),
            _buildMessage(),
            if (details != null && showDetails) ...[
              const SizedBox(height: AppSpacing.md),
              _buildDetails(),
            ],
            const SizedBox(height: AppSpacing.xl),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconWidget = customIcon ?? _getDefaultIcon();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(
            opacity: value,
            child: iconWidget,
          ),
        );
      },
    );
  }

  Widget _getDefaultIcon() {
    Color iconColor;
    String iconAsset;

    switch (errorType) {
      case ErrorType.network:
        iconColor = AppColors.warning;
        iconAsset = AppIcons.yellowWarningTriangleIcon;
        break;
      case ErrorType.server:
        iconColor = AppColors.error;
        iconAsset = AppIcons.yellowWarningTriangleIcon;
        break;
      case ErrorType.notFound:
        iconColor = AppColors.neutral400;
        iconAsset = AppIcons.infoIcon;
        break;
      case ErrorType.general:
      default:
        iconColor = AppColors.error;
        iconAsset = AppIcons.yellowWarningTriangleIcon;
        break;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          iconAsset,
          width: 40,
          height: 40,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Column(
      children: [
        Text(
          _getErrorTitle(),
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getErrorTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'Sin conexión';
      case ErrorType.server:
        return 'Error del servidor';
      case ErrorType.notFound:
        return 'No encontrado';
      case ErrorType.general:
      default:
        return 'Algo salió mal';
    }
  }

  Widget _buildDetails() {
    return ExpansionTile(
      title: Text(
        'Ver detalles',
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.secondary,
        ),
      ),
      childrenPadding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppColors.error.withOpacity(0.2),
            ),
          ),
          child: Text(
            details!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        if (onRetry != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText ?? 'Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getRetryButtonColor(),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text('Volver'),
          ),
        ),
      ],
    );
  }

  Color _getRetryButtonColor() {
    switch (errorType) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.server:
        return AppColors.error;
      case ErrorType.notFound:
        return AppColors.secondary;
      case ErrorType.general:
      default:
        return AppColors.secondary;
    }
  }
}

/// Tipos de error para personalizar la presentación
enum ErrorType {
  general,
  network,
  server,
  notFound,
}

/// Widget compacto para errores en línea
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: AppColors.error,
            size: AppConstants.iconMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: AppColors.secondary,
              iconSize: AppConstants.iconSmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension para mostrar errores fácilmente desde cualquier BuildContext
extension ErrorDisplayExtension on BuildContext {
  void showErrorSnackBar(String message, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
          label: 'Reintentar',
          textColor: AppColors.white,
          onPressed: onRetry,
        )
            : null,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}