import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

class ProfileSettingsTab extends StatefulWidget {
  const ProfileSettingsTab({super.key});

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _formChanged = false;

  @override
  void initState() {
    super.initState();

    // Add listeners to detect form changes
    _currentPasswordController.addListener(_onFormChanged);
    _newPasswordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      _formChanged = _currentPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is PasswordChangeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cambiar contraseña',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Actualiza tu contraseña para mantener la seguridad de tu cuenta',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Password security guidelines
                _buildSecurityInfoCard(),
                const SizedBox(height: 24),

                // Current password field
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Contraseña actual',
                  hintText: 'Ingresa tu contraseña actual',
                  showPassword: _showCurrentPassword,
                  togglePasswordVisibility: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // New password field
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'Nueva contraseña',
                  hintText: 'Ingresa tu nueva contraseña',
                  showPassword: _showNewPassword,
                  togglePasswordVisibility: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nueva contraseña';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Debe incluir al menos una letra mayúscula';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Debe incluir al menos una letra minúscula';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Debe incluir al menos un número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar contraseña',
                  hintText: 'Confirma tu nueva contraseña',
                  showPassword: _showConfirmPassword,
                  togglePasswordVisibility: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu nueva contraseña';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueMetraShop,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _formChanged ? _changePassword : null,
                    child: Text(
                      state is PasswordChangeLoading
                          ? 'Actualizando...'
                          : 'Actualizar contraseña',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tu contraseña debe:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          _PasswordRequirementRow(
            text: 'Tener al menos 8 caracteres',
            icon: Icons.check_circle,
          ),
          _PasswordRequirementRow(
            text: 'Incluir al menos una letra mayúscula',
            icon: Icons.check_circle,
          ),
          _PasswordRequirementRow(
            text: 'Incluir al menos una letra minúscula',
            icon: Icons.check_circle,
          ),
          _PasswordRequirementRow(
            text: 'Incluir al menos un número',
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool showPassword,
    required VoidCallback togglePasswordVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: togglePasswordVisibility,
        ),
      ),
      validator: validator,
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePasswordEvent(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );

      // Clear form after submitting
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _formChanged = false;
      });
    }
  }
}

class _PasswordRequirementRow extends StatelessWidget {
  final String text;
  final IconData icon;

  const _PasswordRequirementRow({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}