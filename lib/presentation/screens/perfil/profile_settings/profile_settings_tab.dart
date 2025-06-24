import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';
import '../../../../config/theme/theme.dart';

class ImprovedProfileSettingsTab extends StatefulWidget {
  const ImprovedProfileSettingsTab({super.key});

  @override
  State<ImprovedProfileSettingsTab> createState() => _ImprovedProfileSettingsTabState();
}

class _ImprovedProfileSettingsTabState extends State<ImprovedProfileSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _formChanged = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _currentPasswordController.addListener(_onFormChanged);
    _newPasswordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final hasContent = _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;

    if (_formChanged != hasContent) {
      setState(() {
        _formChanged = hasContent;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(ChangePasswordEvent(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ));
    }
  }

  void _clearForm() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _formChanged = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is PasswordChangeSuccess) {
          setState(() {
            _isLoading = false;
          });
          _clearForm();
        } else if (state is PasswordChangeError) {
          setState(() {
            _isLoading = false;
          });
        } else if (state is PasswordChangeLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.surfaceVariant,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecurityHeader(),
                  SizedBox(height: 24),
                  _buildPasswordChangeSection(),
                  SizedBox(height: 32),
                  _buildSecurityTips(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seguridad de la cuenta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mantén tu cuenta segura cambiando tu contraseña regularmente',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordChangeSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Cambiar contraseña',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Contraseña actual',
            hint: 'Ingresa tu contraseña actual',
            showPassword: _showCurrentPassword,
            onToggleVisibility: () {
              setState(() {
                _showCurrentPassword = !_showCurrentPassword;
              });
            },
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'La contraseña actual es requerida';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Nueva contraseña',
            hint: 'Ingresa tu nueva contraseña',
            showPassword: _showNewPassword,
            onToggleVisibility: () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            },
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'La nueva contraseña es requerida';
              }
              if (value!.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Debe contener mayúsculas, minúsculas y números';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmar nueva contraseña',
            hint: 'Confirma tu nueva contraseña',
            showPassword: _showConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Confirma tu nueva contraseña';
              }
              if (value != _newPasswordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          SizedBox(height: 32),
          _buildPasswordStrengthIndicator(),
          SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !showPassword,
          validator: validator,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final strength = _calculatePasswordStrength(password);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fortaleza de la contraseña',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: strength.value,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                  minHeight: 6,
                ),
              ),
              SizedBox(width: 12),
              Text(
                strength.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: strength.color,
                ),
              ),
            ],
          ),
          if (password.isNotEmpty) ...[
            SizedBox(height: 12),
            ...strength.requirements.map((req) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    req.met ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: req.met ? AppColors.success : AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    req.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: req.met ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        value: 0.0,
        label: 'Sin contraseña',
        color: AppColors.border,
        requirements: [
          PasswordRequirement('Al menos 8 caracteres', false),
          PasswordRequirement('Incluye mayúsculas', false),
          PasswordRequirement('Incluye minúsculas', false),
          PasswordRequirement('Incluye números', false),
        ],
      );
    }

    final requirements = [
      PasswordRequirement('Al menos 8 caracteres', password.length >= 8),
      PasswordRequirement('Incluye mayúsculas', password.contains(RegExp(r'[A-Z]'))),
      PasswordRequirement('Incluye minúsculas', password.contains(RegExp(r'[a-z]'))),
      PasswordRequirement('Incluye números', password.contains(RegExp(r'\d'))),
    ];

    final metCount = requirements.where((req) => req.met).length;

    switch (metCount) {
      case 0:
      case 1:
        return PasswordStrength(
          value: 0.25,
          label: 'Muy débil',
          color: AppColors.error,
          requirements: requirements,
        );
      case 2:
        return PasswordStrength(
          value: 0.5,
          label: 'Débil',
          color: AppColors.warning,
          requirements: requirements,
        );
      case 3:
        return PasswordStrength(
          value: 0.75,
          label: 'Buena',
          color: AppColors.info,
          requirements: requirements,
        );
      case 4:
        return PasswordStrength(
          value: 1.0,
          label: 'Fuerte',
          color: AppColors.success,
          requirements: requirements,
        );
      default:
        return PasswordStrength(
          value: 0.0,
          label: 'Sin evaluar',
          color: AppColors.border,
          requirements: requirements,
        );
    }
  }

  Widget _buildActionButtons() {
    final hasValidForm = _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: hasValidForm && !_isLoading ? _changePassword : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasValidForm ? AppColors.primary : AppColors.border,
              foregroundColor: AppColors.white,
              elevation: hasValidForm ? 4 : 0,
              shadowColor: AppColors.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                strokeWidth: 2,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security_update_good_outlined,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Cambiar contraseña',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_formChanged) ...[
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: _isLoading ? null : _clearForm,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.clear_outlined,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Limpiar campos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSecurityTips() {
    final tips = [
      SecurityTip(
        icon: Icons.schedule_outlined,
        title: 'Cambia tu contraseña regularmente',
        description: 'Se recomienda cambiar la contraseña cada 3-6 meses',
      ),
      SecurityTip(
        icon: Icons.privacy_tip_outlined,
        title: 'No compartas tu contraseña',
        description: 'Nunca compartas tu contraseña con otras personas',
      ),
      SecurityTip(
        icon: Icons.devices_outlined,
        title: 'Usa contraseñas únicas',
        description: 'No uses la misma contraseña en múltiples servicios',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.accent,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Consejos de seguridad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...tips.map((tip) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tip.icon,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        tip.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class PasswordStrength {
  final double value;
  final String label;
  final Color color;
  final List<PasswordRequirement> requirements;

  PasswordStrength({
    required this.value,
    required this.label,
    required this.color,
    required this.requirements,
  });
}

class PasswordRequirement {
  final String text;
  final bool met;

  PasswordRequirement(this.text, this.met);
}

class SecurityTip {
  final IconData icon;
  final String title;
  final String description;

  SecurityTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}