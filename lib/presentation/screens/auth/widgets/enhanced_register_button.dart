// lib/presentation/widgets/auth/enhanced_register_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/theme.dart';

class EnhancedRegisterButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String text;
  final String loadingText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double borderRadius;

  const EnhancedRegisterButton({
    Key? key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.text = 'Crear cuenta',
    this.loadingText = 'Creando cuenta...',
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 56,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  State<EnhancedRegisterButton> createState() => _EnhancedRegisterButtonState();
}

class _EnhancedRegisterButtonState extends State<EnhancedRegisterButton>
    with TickerProviderStateMixin {
  late AnimationController _pressAnimationController;
  late AnimationController _loadingAnimationController;
  late AnimationController _successAnimationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _successAnimation;

  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    _pressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeInOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    // Animar loading si ya está en estado loading
    if (widget.isLoading) {
      _loadingAnimationController.repeat();
    }
  }

  @override
  void didUpdateWidget(EnhancedRegisterButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Manejar cambios en el estado de loading
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingAnimationController.repeat();
      } else {
        _loadingAnimationController.stop();
        _loadingAnimationController.reset();

        // Mostrar éxito brevemente si se completó la carga
        if (oldWidget.isLoading && !widget.isLoading && widget.isEnabled) {
          _showSuccessAnimation();
        }
      }
    }
  }

  void _showSuccessAnimation() {
    setState(() {
      _showSuccess = true;
    });

    _successAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _successAnimationController.reverse().then((_) {
            setState(() {
              _showSuccess = false;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPress = widget.isEnabled && !widget.isLoading;
    final backgroundColor = widget.backgroundColor ??
        (canPress ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3));
    final foregroundColor = widget.foregroundColor ?? AppColors.white;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _loadingAnimation,
        _successAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: canPress ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: ElevatedButton(
              onPressed: canPress ? _handlePress : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                padding: EdgeInsets.zero,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showSuccess
                    ? _buildSuccessContent()
                    : widget.isLoading
                    ? _buildLoadingContent()
                    : _buildNormalContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessContent() {
    return ScaleTransition(
      scale: _successAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 24,
            color: AppColors.white,
          ),
          const SizedBox(width: 8),
          Text(
            '¡Cuenta creada!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(AppColors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.loadingText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNormalContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: 20,
            color: AppColors.white,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  void _handlePress() {
    // Animación de presión
    _pressAnimationController.forward().then((_) {
      _pressAnimationController.reverse();
    });

    // Feedback háptico
    HapticFeedback.lightImpact();

    // Llamar callback
    widget.onPressed?.call();
  }

  @override
  void dispose() {
    _pressAnimationController.dispose();
    _loadingAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }
}

// Widget adicional para botones de acción secundarios
class EnhancedSecondaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isEnabled;
  final Color? borderColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const EnhancedSecondaryButton({
    Key? key,
    this.onPressed,
    required this.text,
    this.icon,
    this.isEnabled = true,
    this.borderColor,
    this.textColor,
    this.height = 48,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<EnhancedSecondaryButton> createState() => _EnhancedSecondaryButtonState();
}

class _EnhancedSecondaryButtonState extends State<EnhancedSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? AppColors.primary;
    final textColor = widget.textColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: widget.height,
            child: OutlinedButton(
              onPressed: widget.isEnabled ? _handlePress : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: widget.isEnabled
                      ? borderColor
                      : AppColors.textSecondary.withOpacity(0.3),
                ),
                foregroundColor: widget.isEnabled
                    ? textColor
                    : AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}