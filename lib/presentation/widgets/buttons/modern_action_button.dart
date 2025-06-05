import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/theme.dart';

/// Botón de acción moderno con gradiente y animaciones
class ModernActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final Color? secondaryColor;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsets? padding;
  final double? width;
  final double height;

  const ModernActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.primaryColor = AppColors.blueMetraShop,
    this.secondaryColor,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.width,
    this.height = 56,
  });

  @override
  State<ModernActionButton> createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<ModernActionButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _handleTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final secondaryColor = widget.secondaryColor ??
        widget.primaryColor.withOpacity(0.8);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              width: widget.isExpanded ? double.infinity : widget.width,
              height: widget.height,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? LinearGradient(
                  colors: [widget.primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isEnabled ? null : AppColors.neutral300,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isEnabled ? [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    blurRadius: _isPressed ? _elevationAnimation.value : 4.0,
                    spreadRadius: 0,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isEnabled ? AppColors.white : AppColors.neutral500,
                        ),
                      ),
                    )
                  else
                    Icon(
                      widget.icon,
                      color: isEnabled ? AppColors.white : AppColors.neutral500,
                      size: 20,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isLoading ? 'Procesando...' : widget.label,
                    style: TextStyle(
                      color: isEnabled ? AppColors.white : AppColors.neutral500,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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
}