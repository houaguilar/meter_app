import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/theme.dart';

/// Botón secundario moderno con borde
class ModernOutlinedButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color textColor;
  final bool isExpanded;
  final double height;

  const ModernOutlinedButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.borderColor = AppColors.blueMetraShop,
    this.textColor = AppColors.blueMetraShop,
    this.isExpanded = false,
    this.height = 56,
  });

  @override
  State<ModernOutlinedButton> createState() => _ModernOutlinedButtonState();
}

class _ModernOutlinedButtonState extends State<ModernOutlinedButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
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
    final isEnabled = widget.onPressed != null;

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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.isExpanded ? double.infinity : null,
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: _isPressed
                    ? widget.borderColor.withOpacity(0.1)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEnabled ? widget.borderColor : AppColors.neutral300,
                  width: 2,
                ),
                boxShadow: isEnabled ? [
                  BoxShadow(
                    color: widget.borderColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: isEnabled ? widget.textColor : AppColors.neutral400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: isEnabled ? widget.textColor : AppColors.neutral400,
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
