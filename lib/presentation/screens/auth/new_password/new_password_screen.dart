import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/usecase/usecase.dart';
import '../../../../domain/usecases/use_cases.dart';
import '../../../../init_dependencies.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUpdating = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      // Actualizar contraseña (la sesión de recovery ya está activa vía magic link)
      final changePassword = serviceLocator<ChangePassword>();
      final result = await changePassword(
        ChangePasswordParams(
          currentPassword: '',
          newPassword: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() => _isUpdating = false);
          _showError(failure.message);
        },
        (_) async {
          // Cerrar sesión para que el usuario inicie con la nueva contraseña
          final logout = serviceLocator<UserLogout>();
          await logout(NoParams());

          if (mounted) {
            setState(() => _isUpdating = false);
            _showSuccess('Contraseña actualizada exitosamente');
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) context.go('/login');
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        _showError('Error al actualizar contraseña: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.2),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_open, size: 64, color: AppColors.secondary),
        ),
        const SizedBox(height: 24),
        Text(
          'Nueva contraseña',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ingresa tu nueva contraseña',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Nueva contraseña',
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa una contraseña';
        if (value.length < 8) return 'Mínimo 8 caracteres';
        if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe incluir una letra mayúscula';
        if (!value.contains(RegExp(r'[a-z]'))) return 'Debe incluir una letra minúscula';
        if (!value.contains(RegExp(r'[0-9]'))) return 'Debe incluir un número';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Confirmar contraseña',
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Confirma tu contraseña';
        if (value != _passwordController.text) return 'Las contraseñas no coinciden';
        return null;
      },
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _handleUpdatePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isUpdating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                'Actualizar contraseña',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
