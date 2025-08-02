import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/validators.dart';

class EnhancedAuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isEmail;
  final bool isName;
  final bool isPhone;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool showValidationInRealTime;
  final bool enabled;
  final TextInputAction textInputAction;
  final Function(String)? handleLogin;

  const EnhancedAuthTextField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.isEmail = false,
    this.isName = false,
    this.isPhone = false,
    this.onChanged,
    this.validator,
    this.showValidationInRealTime = true,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.handleLogin,
  }) : super(key: key);

  @override
  State<EnhancedAuthTextField> createState() => _EnhancedAuthTextFieldState();
}

class _EnhancedAuthTextFieldState extends State<EnhancedAuthTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  ValidationResult? _validationResult;
  PasswordValidationResult? _passwordResult;

  late AnimationController _validationAnimationController;
  late Animation<double> _validationAnimation;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;

    _validationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _validationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _validationAnimationController,
      curve: Curves.easeInOut,
    ));

    _focusAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _validationAnimationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_validateInput);
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (widget.focusNode.hasFocus) {
      _validationAnimationController.forward();
    } else {
      _validationAnimationController.reverse();
    }
    setState(() {});
  }

  void _validateInput() {
    if (!widget.showValidationInRealTime) return;

    final value = widget.controller.text;

    // Solo validar si hay texto o si el campo perdió el foco
    if (value.isEmpty && widget.focusNode.hasFocus) {
      return;
    }

    ValidationResult? newResult;

    if (widget.isPassword) {
      _passwordResult = Validators.validatePasswordAdvanced(value);
      newResult = ValidationResult(
        isValid: _passwordResult!.isValid,
        message: _passwordResult!.message,
        severity: _passwordResult!.severity,
      );
    } else if (widget.isEmail) {
      newResult = Validators.validateEmailAdvanced(value);
    } else if (widget.isName) {
      newResult = Validators.validateName(value);
    } else if (widget.isPhone) {
      newResult = Validators.validatePhone(value);
    }

    if (newResult != null && newResult != _validationResult) {
      setState(() {
        _validationResult = newResult;
      });

      if (_validationResult!.isValid || value.isNotEmpty) {
        _validationAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SOLUCIÓN: Label EXTERNO para evitar el problema del texto "tachado"
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.focusNode.hasFocus
                ? AppColors.secondary // Cambiar a secondary como RegisterScreen
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Campo de texto principal con animación
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _focusAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: widget.enabled ? AppColors.white : AppColors.textSecondary.withOpacity(0.1),
                  boxShadow: widget.focusNode.hasFocus
                      ? [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.isPassword ? _obscureText : false,
                  keyboardType: _getKeyboardType(),
                  textInputAction: widget.textInputAction,
                  inputFormatters: _getInputFormatters(),
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    _validateInput();
                  },
                  validator: widget.validator,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.enabled ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  decoration: InputDecoration(
                    // NO usar labelText - esto causa el problema del texto "tachado"
                    hintText: widget.hint,
                    prefixIcon: Icon(
                      widget.prefixIcon,
                      color: _getIconColor(),
                    ),
                    suffixIcon: _buildSuffixIcon(),
                    filled: true,
                    fillColor: Colors.transparent, // Transparente para usar el color del Container
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _getBorderColor(),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.secondary, // Mismo color que RegisterScreen
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                  onFieldSubmitted: widget.handleLogin,
                ),
              ),
            );
          },
        ),

        // Indicador de validación en tiempo real
        if (_validationResult != null && widget.showValidationInRealTime)
          AnimatedBuilder(
            animation: _validationAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _validationAnimation.value,
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 8, left: 16),
                  child: Row(
                    children: [
                      Icon(
                        _getValidationIcon(),
                        size: 16,
                        color: _getValidationColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationResult!.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getValidationColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Indicador de fuerza de contraseña
        if (widget.isPassword && _passwordResult != null)
          _buildPasswordStrengthIndicator(),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: widget.enabled ? () {
          setState(() {
            _obscureText = !_obscureText;
          });
          HapticFeedback.lightImpact();
        } : null,
      );
    }

    if (_validationResult?.isValid == true && widget.controller.text.isNotEmpty) {
      return const Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: 20,
      );
    }

    return null;
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordResult == null || widget.controller.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de progreso de fuerza
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: Validators.getPasswordStrengthProgress(_passwordResult!),
                    backgroundColor: AppColors.textSecondary.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(_passwordResult!.color),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _passwordResult!.message,
                style: TextStyle(
                  fontSize: 12,
                  color: _passwordResult!.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Requisitos en chips (solo si hay texto)
          if (widget.controller.text.isNotEmpty &&
              _passwordResult!.strength != PasswordStrength.veryStrong)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildRequirementChip(
                    '8+ caracteres',
                    _passwordResult!.hasMinLength,
                    Icons.straighten,
                  ),
                  _buildRequirementChip(
                    'Mayúscula',
                    _passwordResult!.hasUppercase,
                    Icons.keyboard_arrow_up,
                  ),
                  _buildRequirementChip(
                    'Minúscula',
                    _passwordResult!.hasLowercase,
                    Icons.keyboard_arrow_down,
                  ),
                  _buildRequirementChip(
                    'Número',
                    _passwordResult!.hasNumber,
                    Icons.pin,
                  ),
                  _buildRequirementChip(
                    'Especial',
                    _passwordResult!.hasSpecialChar,
                    Icons.star_outline,
                  ),
                ],
              ),
            ),

          // Sugerencias específicas
          if (widget.controller.text.isNotEmpty && !_passwordResult!.isValid)
            _buildPasswordSuggestions(),
        ],
      ),
    );
  }

  Widget _buildRequirementChip(String label, bool isCompleted, IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check : icon,
            size: 12,
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isCompleted ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sugerencia: Combina letras, números y símbolos para mayor seguridad',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextInputType _getKeyboardType() {
    if (widget.isEmail) return TextInputType.emailAddress;
    if (widget.isPhone) return TextInputType.phone;
    if (widget.isName) return TextInputType.name;
    return TextInputType.text;
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];

    if (widget.isName) {
      // Limitar caracteres especiales en nombres
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\u00f1\u00d1\s'-]")));
      formatters.add(LengthLimitingTextInputFormatter(50));
    }

    if (widget.isEmail) {
      // Remover espacios en emails
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
      formatters.add(LengthLimitingTextInputFormatter(254));
    }

    if (widget.isPhone) {
      // Permitir solo números, espacios, guiones, paréntesis y +
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-\(\)\+]')));
      formatters.add(LengthLimitingTextInputFormatter(20));
    }

    return formatters;
  }

  Color _getBorderColor() {
    if (!widget.enabled) {
      return AppColors.textSecondary.withOpacity(0.3);
    }

    if (_validationResult?.isValid == true && widget.controller.text.isNotEmpty) {
      return AppColors.success;
    }

    if (_validationResult?.isValid == false && widget.controller.text.isNotEmpty) {
      return AppColors.error;
    }

    return AppColors.textSecondary.withOpacity(0.3);
  }

  Color _getIconColor() {
    if (!widget.enabled) {
      return AppColors.textSecondary.withOpacity(0.5);
    }

    if (widget.focusNode.hasFocus) {
      return AppColors.secondary; // Cambiar a secondary como en RegisterScreen
    }

    if (_validationResult?.isValid == true && widget.controller.text.isNotEmpty) {
      return AppColors.success;
    }

    return AppColors.textSecondary;
  }

  IconData _getValidationIcon() {
    switch (_validationResult?.severity) {
      case ValidationSeverity.success:
        return Icons.check_circle;
      case ValidationSeverity.warning:
        return Icons.warning;
      case ValidationSeverity.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getValidationColor() {
    switch (_validationResult?.severity) {
      case ValidationSeverity.success:
        return AppColors.success;
      case ValidationSeverity.warning:
        return AppColors.warning;
      case ValidationSeverity.error:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  void dispose() {
    _validationAnimationController.dispose();
    widget.controller.removeListener(_validateInput);
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }
}