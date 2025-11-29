// lib/presentation/widgets/dialogs/unified_feature_disabled_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/config/assets/app_icons.dart';

import '../../../config/theme/theme.dart';

/// Dialog unificado para mostrar funciones no disponibles
///
/// Proporciona una interfaz consistente para informar al usuario
/// sobre funcionalidades en desarrollo, con personalización por módulo.
class UnifiedFeatureDisabledDialog extends StatelessWidget {
  final String title;
  final String message;
  final FeatureType featureType;
  final String? customButtonText;
  final VoidCallback? onContactSupport;
  final VoidCallback? onCustomAction;
  final Color? primaryColor;

  const UnifiedFeatureDisabledDialog({
    super.key,
    required this.title,
    required this.message,
    required this.featureType,
    this.customButtonText,
    this.onContactSupport,
    this.onCustomAction,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getFeatureColor().withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Icono animado
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getFeatureColor().withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    _getFeatureIcon(),
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      _getFeatureColor(),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Información específica del tipo de feature
          _buildFeatureInfo(),

          const SizedBox(height: 16),

          // Mensaje de desarrollo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getDevelopmentMessage(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textInfo,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureInfo() {
    final info = _getFeatureInfo();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            info.icon,
            color: info.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: info.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Botón personalizado (opcional)
          if (onCustomAction != null && customButtonText != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCustomAction,
                icon: Icon(_getCustomActionIcon()),
                label: Text(customButtonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getFeatureColor(),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Botón de contacto (opcional)
          if (onContactSupport != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onContactSupport,
                icon: const Icon(Icons.support_agent),
                label: const Text('Contactar Soporte'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Botón de cerrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFeatureColor() {
    if (primaryColor != null) return primaryColor!;

    switch (featureType) {
      case FeatureType.wallMaterial:
        return AppColors.success;
      case FeatureType.slab:
        return AppColors.secondary;
      case FeatureType.floor:
        return AppColors.blueMetraShop;
      case FeatureType.coating:
        return AppColors.yellowMetraShop;
      case FeatureType.structural:
        return AppColors.primary;
      case FeatureType.generic:
        return AppColors.warning;
    }
  }

  String _getFeatureIcon() {
    switch (featureType) {
      case FeatureType.wallMaterial:
      case FeatureType.slab:
      case FeatureType.floor:
      case FeatureType.coating:
      case FeatureType.structural:
      case FeatureType.generic:
        return AppIcons.yellowWarningTriangleIcon;
    }
  }

  FeatureInfo _getFeatureInfo() {
    switch (featureType) {
      case FeatureType.wallMaterial:
        return FeatureInfo(
          icon: Icons.construction,
          color: AppColors.warning,
          title: 'Material de construcción',
          description: 'Los cálculos para este material requieren algoritmos especializados.',
        );
      case FeatureType.slab:
        return FeatureInfo(
          icon: Icons.grid_view,
          color: AppColors.secondary,
          title: 'Elemento estructural',
          description: 'Esta losa necesita validaciones adicionales de ingeniería.',
        );
      case FeatureType.floor:
        return FeatureInfo(
          icon: Icons.layers,
          color: AppColors.blueMetraShop,
          title: 'Revestimiento de piso',
          description: 'Los cálculos para este tipo de piso están en desarrollo.',
        );
      case FeatureType.coating:
        return FeatureInfo(
          icon: Icons.format_paint,
          color: AppColors.yellowMetraShop,
          title: 'Revestimiento de pared',
          description: 'Este tipo de tarrajeo requiere fórmulas especializadas.',
        );
      case FeatureType.structural:
        return FeatureInfo(
          icon: Icons.account_balance,
          color: AppColors.primary,
          title: 'Elemento estructural',
          description: 'Los cálculos estructurales necesitan validaciones adicionales.',
        );
      case FeatureType.generic:
        return FeatureInfo(
          icon: Icons.build,
          color: AppColors.neutral400,
          title: 'Funcionalidad',
          description: 'Esta funcionalidad está en desarrollo activo.',
        );
    }
  }

  String _getDevelopmentMessage() {
    switch (featureType) {
      case FeatureType.wallMaterial:
        return 'Estamos trabajando en los algoritmos de cálculo para este material.';
      case FeatureType.slab:
        return 'Los cálculos para losas están siendo optimizados por nuestro equipo.';
      case FeatureType.floor:
        return 'Estamos desarrollando las fórmulas para este tipo de piso.';
      case FeatureType.coating:
        return 'Los cálculos de tarrajeo están siendo refinados por expertos.';
      case FeatureType.structural:
        return 'Estamos validando los cálculos estructurales con ingenieros.';
      case FeatureType.generic:
        return 'Estamos trabajando para incluir esta funcionalidad pronto.';
    }
  }

  IconData _getCustomActionIcon() {
    switch (featureType) {
      case FeatureType.wallMaterial:
        return Icons.calculate;
      case FeatureType.slab:
        return Icons.architecture;
      case FeatureType.floor:
        return Icons.straighten;
      case FeatureType.coating:
        return Icons.palette;
      case FeatureType.structural:
        return Icons.engineering;
      case FeatureType.generic:
        return Icons.info;
    }
  }
}

/// Tipos de features disponibles
enum FeatureType {
  wallMaterial,
  slab,
  floor,
  coating,
  structural,
  generic,
}

/// Información específica de un tipo de feature
class FeatureInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const FeatureInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}

/// Version simplificada para usar como SnackBar
class UnifiedFeatureDisabledSnackBar {
  static void show(
      BuildContext context, {
        required String feature,
        required FeatureType featureType,
        String? customMessage,
        Color? primaryColor,
      }) {
    if (!context.mounted) return;

    final message = customMessage ??
        '$feature no está disponible actualmente. Estamos trabajando en ello.';

    final color = primaryColor ?? _getDefaultColor(featureType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getFeatureSnackBarIcon(featureType),
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static Color _getDefaultColor(FeatureType featureType) {
    switch (featureType) {
      case FeatureType.wallMaterial:
        return AppColors.success;
      case FeatureType.slab:
        return AppColors.secondary;
      case FeatureType.floor:
        return AppColors.blueMetraShop;
      case FeatureType.coating:
        return AppColors.yellowMetraShop;
      case FeatureType.structural:
        return AppColors.primary;
      case FeatureType.generic:
        return AppColors.warning;
    }
  }

  static IconData _getFeatureSnackBarIcon(FeatureType featureType) {
    switch (featureType) {
      case FeatureType.wallMaterial:
        return Icons.construction;
      case FeatureType.slab:
        return Icons.grid_view;
      case FeatureType.floor:
        return Icons.layers;
      case FeatureType.coating:
        return Icons.format_paint;
      case FeatureType.structural:
        return Icons.account_balance;
      case FeatureType.generic:
        return Icons.info_outline;
    }
  }
}

/// Extension para facilitar el uso desde cualquier BuildContext
extension UnifiedFeatureDisabledExtension on BuildContext {
  /// Muestra snackbar de feature no disponible
  void showFeatureDisabled(
      String feature,
      FeatureType featureType, [
        String? customMessage,
      ]) {
    UnifiedFeatureDisabledSnackBar.show(
      this,
      feature: feature,
      featureType: featureType,
      customMessage: customMessage,
    );
  }

  /// Muestra dialog de feature no disponible
  void showFeatureDisabledDialog({
    required String title,
    required String message,
    required FeatureType featureType,
    String? customButtonText,
    VoidCallback? onCustomAction,
    VoidCallback? onContactSupport,
    Color? primaryColor,
  }) {
    showDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => UnifiedFeatureDisabledDialog(
        title: title,
        message: message,
        featureType: featureType,
        customButtonText: customButtonText,
        onCustomAction: onCustomAction,
        onContactSupport: onContactSupport,
        primaryColor: primaryColor,
      ),
    );
  }
}

/// Factory methods para crear dialogs específicos por módulo

/// Dialog para materiales de muro no disponibles
void showWallMaterialNotAvailable(
    BuildContext context, {
      required String materialName,
      String? customMessage,
      VoidCallback? onContactSupport,
    }) {
  context.showFeatureDisabledDialog(
    title: '$materialName no disponible',
    message: customMessage ??
        'Este material está en desarrollo y estará disponible próximamente.',
    featureType: FeatureType.wallMaterial,
    onContactSupport: onContactSupport,
  );
}

/// Dialog para losas no disponibles
void showSlabNotAvailable(
    BuildContext context, {
      required String slabName,
      String? customMessage,
      VoidCallback? onContactSupport,
    }) {
  context.showFeatureDisabledDialog(
    title: '$slabName no disponible',
    message: customMessage ??
        'Esta losa está en desarrollo y estará disponible próximamente.',
    featureType: FeatureType.slab,
    onContactSupport: onContactSupport,
  );
}

/// Dialog para pisos no disponibles
void showFloorNotAvailable(
    BuildContext context, {
      required String floorName,
      String? customMessage,
      VoidCallback? onContactSupport,
    }) {
  context.showFeatureDisabledDialog(
    title: '$floorName no disponible',
    message: customMessage ??
        'Este piso está en desarrollo y estará disponible próximamente.',
    featureType: FeatureType.floor,
    onContactSupport: onContactSupport,
  );
}

/// Dialog para revestimientos no disponibles
void showCoatingNotAvailable(
    BuildContext context, {
      required String coatingName,
      String? customMessage,
      VoidCallback? onContactSupport,
    }) {
  context.showFeatureDisabledDialog(
    title: '$coatingName no disponible',
    message: customMessage ??
        'Este revestimiento está en desarrollo y estará disponible próximamente.',
    featureType: FeatureType.coating,
    onContactSupport: onContactSupport,
  );
}