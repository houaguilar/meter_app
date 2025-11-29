import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/theme.dart';

/// Diálogo reutilizable para mostrar el estado de una funcionalidad
///
/// Este componente permite informar al usuario sobre funcionalidades
/// que están en desarrollo, próximamente disponibles, o temporalmente
/// deshabilitadas de manera clara y consistente.
///
/// ### Uso básico:
/// ```dart
/// // Mostrar diálogo de desarrollo
/// FeatureStatusDialog.showInDevelopment(context);
///
/// // Mostrar con mensaje personalizado
/// FeatureStatusDialog.show(
///   context,
///   type: FeatureStatusType.inDevelopment,
///   title: 'Título personalizado',
///   message: 'Mensaje personalizado',
/// );
/// ```
class FeatureStatusDialog extends StatefulWidget {
  final FeatureStatusType type;
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const FeatureStatusDialog({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  State<FeatureStatusDialog> createState() => _FeatureStatusDialogState();

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS ESTÁTICOS HELPER - Para mostrar el diálogo fácilmente
  // ═══════════════════════════════════════════════════════════════════════════

  /// Muestra un diálogo indicando que la funcionalidad está en desarrollo
  static Future<void> showInDevelopment(
    BuildContext context, {
    String? title,
    String? message,
    String? buttonText,
  }) {
    return show(
      context,
      type: FeatureStatusType.inDevelopment,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Muestra un diálogo indicando que la funcionalidad estará disponible pronto
  static Future<void> showComingSoon(
    BuildContext context, {
    String? title,
    String? message,
    String? buttonText,
  }) {
    return show(
      context,
      type: FeatureStatusType.comingSoon,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Muestra un diálogo indicando que la funcionalidad está temporalmente deshabilitada
  static Future<void> showTemporarilyDisabled(
    BuildContext context, {
    String? title,
    String? message,
    String? buttonText,
  }) {
    return show(
      context,
      type: FeatureStatusType.temporarilyDisabled,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Muestra un diálogo genérico de información
  static Future<void> showInfo(
    BuildContext context, {
    String? title,
    String? message,
    String? buttonText,
  }) {
    return show(
      context,
      type: FeatureStatusType.info,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Método principal para mostrar el diálogo con todas las opciones
  static Future<void> show(
    BuildContext context, {
    required FeatureStatusType type,
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    // Feedback háptico
    HapticFeedback.lightImpact();

    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.neutral900.withOpacity(0.5),
      builder: (context) => FeatureStatusDialog(
        type: type,
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }
}

class _FeatureStatusDialogState extends State<FeatureStatusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutral900.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(config),
                _buildContent(config),
                _buildActions(config),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_DialogConfig config) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.color,
            config.color.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Icono animado
          ScaleTransition(
            scale: _iconScaleAnimation,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: 32,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Título
          Text(
            widget.title ?? config.defaultTitle,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_DialogConfig config) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mensaje
          Text(
            widget.message ?? config.defaultMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtítulo adicional
          if (config.subtitle != null)
            Text(
              config.subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: config.color,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildActions(_DialogConfig config) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // Botón principal
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                if (widget.onButtonPressed != null) {
                  widget.onButtonPressed!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: config.color,
                foregroundColor: AppColors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.buttonText ?? config.defaultButtonText,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _DialogConfig _getConfig() {
    switch (widget.type) {
      case FeatureStatusType.inDevelopment:
        return _DialogConfig(
          color: AppColors.blueMetraShop,
          icon: Icons.construction_rounded,
          defaultTitle: 'En Desarrollo',
          defaultMessage:
              'Esta funcionalidad se encuentra actualmente en desarrollo. Estamos trabajando para traértela pronto.',
          subtitle: '¡Mantente atento a las actualizaciones!',
          defaultButtonText: 'Entendido',
        );

      case FeatureStatusType.comingSoon:
        return _DialogConfig(
          color: AppColors.yellowMetraShop,
          icon: Icons.rocket_launch_rounded,
          defaultTitle: 'Próximamente',
          defaultMessage:
              'Esta increíble funcionalidad estará disponible muy pronto. Estamos preparando algo especial para ti.',
          subtitle: '¡Estate atento!',
          defaultButtonText: 'De acuerdo',
        );

      case FeatureStatusType.temporarilyDisabled:
        return _DialogConfig(
          color: AppColors.warning,
          icon: Icons.schedule_rounded,
          defaultTitle: 'Temporalmente No Disponible',
          defaultMessage:
              'Esta funcionalidad está temporalmente deshabilitada para realizar mejoras. Volverá pronto.',
          subtitle: 'Gracias por tu paciencia',
          defaultButtonText: 'Entendido',
        );

      case FeatureStatusType.info:
        return _DialogConfig(
          color: AppColors.secondary,
          icon: Icons.info_rounded,
          defaultTitle: 'Información',
          defaultMessage: 'Esta es una notificación informativa.',
          subtitle: null,
          defaultButtonText: 'Aceptar',
        );

      case FeatureStatusType.maintenance:
        return _DialogConfig(
          color: AppColors.error,
          icon: Icons.engineering_rounded,
          defaultTitle: 'En Mantenimiento',
          defaultMessage:
              'Estamos realizando mantenimiento para mejorar tu experiencia. Vuelve a intentarlo más tarde.',
          subtitle: 'Disculpa las molestias',
          defaultButtonText: 'Entendido',
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

/// Tipos de estado de funcionalidad disponibles
enum FeatureStatusType {
  /// Funcionalidad en desarrollo activo
  inDevelopment,

  /// Funcionalidad que estará disponible pronto
  comingSoon,

  /// Funcionalidad temporalmente deshabilitada
  temporarilyDisabled,

  /// Información general
  info,

  /// En mantenimiento
  maintenance,
}

/// Configuración interna del diálogo
class _DialogConfig {
  final Color color;
  final IconData icon;
  final String defaultTitle;
  final String defaultMessage;
  final String? subtitle;
  final String defaultButtonText;

  const _DialogConfig({
    required this.color,
    required this.icon,
    required this.defaultTitle,
    required this.defaultMessage,
    this.subtitle,
    required this.defaultButtonText,
  });
}
