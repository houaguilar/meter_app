import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blueMetraShop.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.blueMetraShop,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.suffix,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.onChanged,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late FocusNode _focusNode; // Añade FocusNode

  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // Inicializa FocusNode
    _focusNode.addListener(_handleFocusChange); // Añade listener

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  // Método para manejar cambios de foco
  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }


  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange); // Elimina listener
    _focusNode.dispose(); // Descarta FocusNode
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasError
                      ? AppColors.error
                      : _isFocused
                      ? AppColors.blueMetraShop
                      : AppColors.border,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                  BoxShadow(
                    color: AppColors.blueMetraShop.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
                    : null,
              ),
              child: TextFormField(
                focusNode: _focusNode, // Asigna el FocusNode
                controller: widget.controller,
                validator: (value) {
                  final result = widget.validator?.call(value);
                  setState(() {
                    _hasError = result != null;
                  });
                  return result;
                },
                // Usar teclado decimal en iOS para campos numéricos
                keyboardType: widget.keyboardType == TextInputType.number
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : widget.keyboardType,
                obscureText: widget.obscureText,
                maxLines: widget.maxLines,
                enabled: widget.enabled,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                inputFormatters: widget.keyboardType == TextInputType.number
                    ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                    : null,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppColors.blueMetraShop
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  )
                      : null,
                  suffixText: widget.suffix,
                  suffixStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Choice chips modernos
class ModernChoiceChips extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final Function(String) onSelected;
  final bool multiSelect;

  const ModernChoiceChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.multiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(option),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.blueMetraShop
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.blueMetraShop
                        : AppColors.border,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.blueMetraShop.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_circle,
                        color: AppColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Card para medidas con diseño moderno
class ModernMeasurementCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onRemove;

  const ModernMeasurementCard({
    super.key,
    required this.title,
    required this.children,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.blueMetraShop.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueMetraShop,
                  ),
                ),
              ),
              const Spacer(),
              if (onRemove != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Botón moderno para agregar elementos
class ModernAddButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const ModernAddButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  State<ModernAddButton> createState() => _ModernAddButtonState();
}

class _ModernAddButtonState extends State<ModernAddButton>
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _animationController.forward().then((_) {
                  _animationController.reverse();
                });
                widget.onPressed();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueMetraShop.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.blueMetraShop.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: AppColors.blueMetraShop,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: AppColors.blueMetraShop,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Botón de acción moderno principal
class ModernActionButtonD extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ModernActionButtonD({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<ModernActionButtonD> createState() => _ModernActionButtonDState();
}

class _ModernActionButtonDState extends State<ModernActionButtonD>
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
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled
                  ? () {
                HapticFeedback.mediumImpact();
                _animationController.forward().then((_) {
                  _animationController.reverse();
                });
                widget.onPressed!();
              }
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? LinearGradient(
                    colors: [
                      widget.backgroundColor ?? AppColors.blueMetraShop,
                      (widget.backgroundColor ?? AppColors.blueMetraShop)
                          .withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: isEnabled
                      ? null
                      : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isEnabled
                      ? [
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppColors.blueMetraShop)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.foregroundColor ?? AppColors.white,
                          ),
                        ),
                      )
                    else
                      Icon(
                        widget.icon,
                        color: isEnabled
                            ? (widget.foregroundColor ?? AppColors.white)
                            : AppColors.neutral500,
                        size: 22,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      widget.isLoading ? 'Procesando...' : widget.label,
                      style: TextStyle(
                        color: isEnabled
                            ? (widget.foregroundColor ?? AppColors.white)
                            : AppColors.neutral500,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}