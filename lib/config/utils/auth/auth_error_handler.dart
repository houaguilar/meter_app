// lib/config/utils/auth_error_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';
import '../security_service.dart';
import 'auth_error_extensions.dart';

/// Manejador especializado para errores de autenticación con mensajes amigables
class AuthErrorHandler {
  AuthErrorHandler._();

  /// Maneja errores de inicio de sesión con mensajes amigables
  static void handleLoginError(BuildContext context, String error) {
    final userFriendlyMessage = _getLoginErrorMessage(error);
    _showAuthDialog(
      context,
      title: 'Error de Inicio de Sesión',
      message: userFriendlyMessage.message,
      icon: Icons.login_outlined,
      iconColor: AppColors.error,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Maneja errores de registro con mensajes amigables
  static void handleRegistrationError(BuildContext context, String error) {
    final userFriendlyMessage = _getRegistrationErrorMessage(error);
    _showAuthDialog(
      context,
      title: 'Error de Registro',
      message: userFriendlyMessage.message,
      icon: Icons.person_add_outlined,
      iconColor: AppColors.error,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Maneja errores de Google Sign-In
  static void handleGoogleSignInError(BuildContext context, String error) {
    final userFriendlyMessage = _getGoogleSignInErrorMessage(error);
    _showAuthDialog(
      context,
      title: 'Error con Google',
      message: userFriendlyMessage.message,
      icon: Icons.g_mobiledata,
      iconColor: AppColors.error,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Maneja errores de cambio de contraseña
  static void handlePasswordChangeError(BuildContext context, String error) {
    final userFriendlyMessage = _getPasswordChangeErrorMessage(error);
    _showAuthDialog(
      context,
      title: 'Error al Cambiar Contraseña',
      message: userFriendlyMessage.message,
      icon: Icons.lock_outline,
      iconColor: AppColors.error,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Muestra mensaje de éxito de autenticación
  static void showAuthSuccess(BuildContext context, String message) {
    _showSuccessSnackBar(context, message);
  }

  /// Obtiene mensaje amigable para errores de login
  static AuthErrorMessage _getLoginErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('user-not-found') ||
        lowerError.contains('user not found') ||
        lowerError.contains('no user record')) {
      return AuthErrorMessage(
        message: 'No existe una cuenta con este correo electrónico.\n\n'
            'Verifica que hayas escrito correctamente tu email o crea una cuenta nueva.',
        actions: [
          AuthAction(
            label: 'Crear cuenta',
            isPrimary: true,
            onPressed: () => _navigateToRegister,
          ),
        ],
      );
    }

    if (lowerError.contains('wrong-password') ||
        lowerError.contains('invalid-credential') ||
        lowerError.contains('invalid credential') ||
        lowerError.contains('incorrect password')) {
      return AuthErrorMessage(
        message: 'La contraseña es incorrecta.\n\n'
            'Verifica tu contraseña e inténtalo de nuevo.',
        actions: [
          AuthAction(
            label: 'Recuperar contraseña',
            isPrimary: true,
            onPressed: () => _showForgotPasswordDialog,
          ),
        ],
      );
    }

    if (lowerError.contains('invalid-email') ||
        lowerError.contains('badly formatted') ||
        lowerError.contains('invalid email')) {
      return AuthErrorMessage(
        message: 'El formato del correo electrónico no es válido.\n\n'
            'Por favor, introduce una dirección de email correcta.',
      );
    }

    if (lowerError.contains('user-disabled') ||
        lowerError.contains('account disabled')) {
      return AuthErrorMessage(
        message: 'Esta cuenta ha sido deshabilitada.\n\n'
            'Contacta con el soporte técnico para obtener ayuda.',
        actions: [
          AuthAction(
            label: 'Contactar soporte',
            isPrimary: true,
            onPressed: () => _contactSupport,
          ),
        ],
      );
    }

    if (lowerError.contains('too-many-requests') ||
        lowerError.contains('too many attempts')) {
      return AuthErrorMessage(
        message: 'Has realizado demasiados intentos de inicio de sesión.\n\n'
            'Por favor, espera unos minutos antes de intentarlo de nuevo.',
        actions: [
          AuthAction(
            label: 'Recuperar contraseña',
            isPrimary: true,
            onPressed: () => _showForgotPasswordDialog,
          ),
        ],
      );
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return AuthErrorMessage(
        message: 'Error de conexión a internet.\n\n'
            'Verifica tu conexión e inténtalo de nuevo.',
        actions: [
          AuthAction(
            label: 'Reintentar',
            isPrimary: true,
            onPressed: () => Navigator.of, // El contexto se pasará después
          ),
        ],
      );
    }

    // Error genérico más amigable
    return AuthErrorMessage(
      message: 'No pudimos iniciar sesión en este momento.\n\n'
          'Verifica tus credenciales e inténtalo de nuevo.',
    );
  }

  /// Obtiene mensaje amigable para errores de registro
  static AuthErrorMessage _getRegistrationErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('email-already-in-use') ||
        lowerError.contains('email already in use')) {
      return AuthErrorMessage(
        message: 'Ya existe una cuenta con este correo electrónico.\n\n'
            '¿Quieres iniciar sesión en su lugar?',
        actions: [
          AuthAction(
            label: 'Iniciar sesión',
            isPrimary: true,
            onPressed: () => _navigateToLogin,
          ),
        ],
      );
    }

    if (lowerError.contains('weak-password') ||
        lowerError.contains('password should be at least')) {
      return AuthErrorMessage(
        message: 'La contraseña es demasiado débil.\n\n'
            'Debe tener al menos 8 caracteres e incluir:\n'
            '• Una letra mayúscula\n'
            '• Una letra minúscula\n'
            '• Un número',
      );
    }

    if (lowerError.contains('invalid-email')) {
      return AuthErrorMessage(
        message: 'El formato del correo electrónico no es válido.\n\n'
            'Por favor, introduce una dirección de email correcta.',
      );
    }

    if (lowerError.contains('operation-not-allowed')) {
      return AuthErrorMessage(
        message: 'El registro con email y contraseña no está habilitado.\n\n'
            'Contacta con el soporte técnico.',
        actions: [
          AuthAction(
            label: 'Contactar soporte',
            isPrimary: true,
            onPressed: () => _contactSupport,
          ),
        ],
      );
    }

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return AuthErrorMessage(
        message: 'Error de conexión a internet.\n\n'
            'Verifica tu conexión e inténtalo de nuevo.',
        actions: [
          AuthAction(
            label: 'Reintentar',
            isPrimary: true,
            onPressed: () => Navigator.of, // Se pasará el contexto después
          ),
        ],
      );
    }

    return AuthErrorMessage(
      message: 'No pudimos crear tu cuenta en este momento.\n\n'
          'Verifica tus datos e inténtalo de nuevo.',
    );
  }

  /// Obtiene mensaje amigable para errores de Google Sign-In
  static AuthErrorMessage _getGoogleSignInErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('sign_in_canceled') ||
        lowerError.contains('cancelled') ||
        lowerError.contains('canceled')) {
      return AuthErrorMessage(
        message: 'Inicio de sesión cancelado.\n\n'
            'No se completó el proceso de autenticación con Google.',
      );
    }

    if (lowerError.contains('sign_in_failed') ||
        lowerError.contains('failed')) {
      return AuthErrorMessage(
        message: 'No se pudo completar el inicio de sesión con Google.\n\n'
            'Inténtalo de nuevo o usa otro método de inicio de sesión.',
        actions: [
          AuthAction(
            label: 'Usar email',
            isPrimary: false,
            onPressed: () => Navigator.of, // Se manejará después
          ),
        ],
      );
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection')) {
      return AuthErrorMessage(
        message: 'Error de conexión.\n\n'
            'Verifica tu conexión a internet e inténtalo de nuevo.',
        actions: [
          AuthAction(
            label: 'Reintentar',
            isPrimary: true,
            onPressed: () => Navigator.of, // Se manejará después
          ),
        ],
      );
    }

    return AuthErrorMessage(
      message: 'Error con el inicio de sesión de Google.\n\n'
          'Inténtalo de nuevo o usa otro método.',
      actions: [
        AuthAction(
          label: 'Usar email',
          isPrimary: false,
          onPressed: () => Navigator.of, // Se manejará después
        ),
      ],
    );
  }

  /// Obtiene mensaje amigable para errores de cambio de contraseña
  static AuthErrorMessage _getPasswordChangeErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('wrong-password') ||
        lowerError.contains('incorrect password')) {
      return AuthErrorMessage(
        message: 'La contraseña actual es incorrecta.\n\n'
            'Verifica tu contraseña actual e inténtalo de nuevo.',
      );
    }

    if (lowerError.contains('weak-password')) {
      return AuthErrorMessage(
        message: 'La nueva contraseña es demasiado débil.\n\n'
            'Debe tener al menos 8 caracteres e incluir mayúsculas, minúsculas y números.',
      );
    }

    if (lowerError.contains('requires-recent-login')) {
      return AuthErrorMessage(
        message: 'Por seguridad, necesitas iniciar sesión de nuevo.\n\n'
            'Cierra sesión e inicia sesión nuevamente para cambiar tu contraseña.',
        actions: [
          AuthAction(
            label: 'Cerrar sesión',
            isPrimary: true,
            onPressed: () => _logout,
          ),
        ],
      );
    }

    return AuthErrorMessage(
      message: 'No se pudo cambiar la contraseña.\n\n'
          'Inténtalo de nuevo más tarde.',
    );
  }

  /// Muestra un diálogo de error de autenticación
  static Future<void> _showAuthDialog(
      BuildContext context, {
        required String title,
        required String message,
        required IconData icon,
        required Color iconColor,
        List<AuthAction>? actions,
      }) async {
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Mensaje
              Text(
                SecurityService.sanitizeText(message),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Column(
                children: [
                  // Botones de acciones específicas
                  if (actions != null && actions.isNotEmpty) ...[
                    ...actions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActionButton(context, action),
                    )),
                    const SizedBox(height: 8),
                  ],

                  // Botón de cerrar
                  _buildCloseButton(context),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye un botón de acción
  static Widget _buildActionButton(BuildContext context, AuthAction action) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          action.onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: action.isPrimary
              ? AppColors.secondary
              : Colors.transparent,
          foregroundColor: action.isPrimary
              ? AppColors.white
              : AppColors.secondary,
          side: action.isPrimary
              ? null
              : const BorderSide(color: AppColors.secondary),
          elevation: action.isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          action.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Construye el botón de cerrar
  static Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Cerrar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Muestra SnackBar de éxito
  static void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                SecurityService.sanitizeText(message),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Métodos de acción implementados usando las extensiones
  static void _navigateToRegister() {
    AuthErrorHandlerExtensions.navigateToRegister();
  }

  static void _navigateToLogin() {
    AuthErrorHandlerExtensions.navigateToLogin();
  }

  static void _showForgotPasswordDialog() {
    AuthErrorHandlerExtensions.showForgotPasswordDialog();
  }

  static void _contactSupport() {
    AuthErrorHandlerExtensions.contactSupport();
  }

  static void _logout() {
    AuthErrorHandlerExtensions.logout();
  }
}

/// Clase para representar un mensaje de error de autenticación
class AuthErrorMessage {
  final String message;
  final List<AuthAction> actions;

  AuthErrorMessage({
    required this.message,
    this.actions = const [],
  });
}

/// Clase para representar una acción en un diálogo de error
class AuthAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  AuthAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
  });
}