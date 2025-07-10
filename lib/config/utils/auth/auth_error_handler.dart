// lib/config/utils/auth/auth_error_handler.dart
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
    final titleAndIcon = _getLoginTitleAndIcon(error);

    _showAuthDialog(
      context,
      title: titleAndIcon.title,
      message: userFriendlyMessage.message,
      icon: titleAndIcon.icon,
      iconColor: titleAndIcon.color,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Maneja errores de registro con mensajes amigables
  static void handleRegistrationError(BuildContext context, String error) {
    final userFriendlyMessage = _getRegistrationErrorMessage(error);
    final titleAndIcon = _getRegistrationTitleAndIcon(error);

    _showAuthDialog(
      context,
      title: titleAndIcon.title,
      message: userFriendlyMessage.message,
      icon: titleAndIcon.icon,
      iconColor: titleAndIcon.color,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Maneja errores de Google Sign-In
  static void handleGoogleSignInError(BuildContext context, String error) {
    final userFriendlyMessage = _getGoogleSignInErrorMessage(error);
    final titleAndIcon = _getGoogleSignInTitleAndIcon(error);

    _showAuthDialog(
      context,
      title: titleAndIcon.title,
      message: userFriendlyMessage.message,
      icon: titleAndIcon.icon,
      iconColor: titleAndIcon.color,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Maneja errores de cambio de contraseña
  static void handlePasswordChangeError(BuildContext context, String error) {
    final userFriendlyMessage = _getPasswordChangeErrorMessage(error);
    final titleAndIcon = _getPasswordChangeTitleAndIcon(error);

    _showAuthDialog(
      context,
      title: titleAndIcon.title,
      message: userFriendlyMessage.message,
      icon: titleAndIcon.icon,
      iconColor: titleAndIcon.color,
      actions: userFriendlyMessage.actions,
    );
  }

  /// Muestra mensaje de éxito de autenticación
  static void showAuthSuccess(BuildContext context, String message) {
    _showSuccessSnackBar(context, message);
  }

  /// Obtiene título e icono específico según el tipo de error de login
  static ({String title, IconData icon, Color color}) _getLoginTitleAndIcon(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('user-not-found') ||
        lowerError.contains('user not found') ||
        lowerError.contains('no user record')) {
      return (
      title: 'Usuario no encontrado',
      icon: Icons.person_search_outlined,
      color: AppColors.warning,
      );
    }

    if (lowerError.contains('wrong-password') ||
        lowerError.contains('invalid-credential') ||
        lowerError.contains('invalid credential') ||
        lowerError.contains('incorrect password')) {
      return (
      title: 'Contraseña incorrecta',
      icon: Icons.lock_outline,
      color: AppColors.error,
      );
    }

    if (lowerError.contains('too-many-requests') ||
        lowerError.contains('too many attempts')) {
      return (
      title: 'Demasiados intentos',
      icon: Icons.security_outlined,
      color: AppColors.warning,
      );
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return (
      title: 'Sin conexión',
      icon: Icons.wifi_off_outlined,
      color: AppColors.warning,
      );
    }

    // Default
    return (
    title: 'Error de inicio de sesión',
    icon: Icons.login_outlined,
    color: AppColors.error,
    );
  }

  /// Obtiene título e icono específico según el tipo de error de registro
  static ({String title, IconData icon, Color color}) _getRegistrationTitleAndIcon(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('email-already-in-use') ||
        lowerError.contains('email already in use')) {
      return (
      title: 'Email ya registrado',
      icon: Icons.email_outlined,
      color: AppColors.warning,
      );
    }

    if (lowerError.contains('weak-password') ||
        lowerError.contains('password should be at least')) {
      return (
      title: 'Contraseña muy débil',
      icon: Icons.security_outlined,
      color: AppColors.warning,
      );
    }

    if (lowerError.contains('invalid-email')) {
      return (
      title: 'Email inválido',
      icon: Icons.alternate_email,
      color: AppColors.error,
      );
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return (
      title: 'Sin conexión',
      icon: Icons.wifi_off_outlined,
      color: AppColors.warning,
      );
    }

    if (lowerError.contains('too-many-requests') ||
        lowerError.contains('rate limit')) {
      return (
      title: 'Demasiados intentos',
      icon: Icons.security_outlined,
      color: AppColors.warning,
      );
    }

    // Default
    return (
    title: 'Error de registro',
    icon: Icons.person_add_outlined,
    color: AppColors.error,
    );
  }

  /// Obtiene título e icono específico según el tipo de error de Google Sign-In
  static ({String title, IconData icon, Color color}) _getGoogleSignInTitleAndIcon(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('sign_in_canceled') ||
        lowerError.contains('cancelled') ||
        lowerError.contains('canceled')) {
      return (
      title: 'Inicio cancelado',
      icon: Icons.cancel_outlined,
      color: AppColors.warning,
      );
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection')) {
      return (
      title: 'Sin conexión',
      icon: Icons.wifi_off_outlined,
      color: AppColors.warning,
      );
    }

    // Default
    return (
    title: 'Error con Google',
    icon: Icons.g_mobiledata,
    color: AppColors.error,
    );
  }

  /// Obtiene título e icono específico según el tipo de error de cambio de contraseña
  static ({String title, IconData icon, Color color}) _getPasswordChangeTitleAndIcon(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('wrong-password') ||
        lowerError.contains('incorrect password')) {
      return (
      title: 'Contraseña actual incorrecta',
      icon: Icons.lock_outline,
      color: AppColors.error,
      );
    }

    if (lowerError.contains('weak-password')) {
      return (
      title: 'Nueva contraseña muy débil',
      icon: Icons.security_outlined,
      color: AppColors.warning,
      );
    }

    // Default
    return (
    title: 'Error al cambiar contraseña',
    icon: Icons.lock_outline,
    color: AppColors.error,
    );
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
      actions: [
        AuthAction(
          label: 'Reintentar',
          isPrimary: true,
          onPressed: () => Navigator.of,
        ),
      ],
    );
  }

  /// Obtiene mensaje amigable para errores de registro
  static AuthErrorMessage _getRegistrationErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    // ⭐ CASO MÁS IMPORTANTE: Email ya existe
    if (lowerError.contains('email-already-in-use') ||
        lowerError.contains('email already in use')) {
      return AuthErrorMessage(
        message: '📧 Ya existe una cuenta con este correo electrónico.\n\n'
            '¡No te preocupes! Esto significa que ya tienes una cuenta con nosotros.\n\n'
            '¿Quieres iniciar sesión o recuperar tu contraseña?',
        actions: [
          AuthAction(
            label: 'Iniciar sesión',
            isPrimary: true,
            onPressed: () => _navigateToLogin,
          ),
          AuthAction(
            label: '¿Olvidaste tu contraseña?',
            isPrimary: false,
            onPressed: () => _showForgotPasswordDialog,
          ),
        ],
      );
    }

    // Contraseña débil con requisitos específicos
    if (lowerError.contains('weak-password') ||
        lowerError.contains('password should be at least')) {
      return AuthErrorMessage(
        message: 'Tu contraseña necesita ser más segura para proteger tu cuenta.\n\n'
            'Requisitos mínimos:\n'
            '✓ Al menos 8 caracteres\n'
            '✓ Una letra mayúscula (A-Z)\n'
            '✓ Una letra minúscula (a-z)\n'
            '✓ Un número (0-9)\n'
            '✓ Un carácter especial (!@#\$%^&*)',
        actions: [
          AuthAction(
            label: 'Entendido',
            isPrimary: true,
            onPressed: () => Navigator.of,
          ),
        ],
      );
    }

    // Email inválido con ejemplo
    if (lowerError.contains('invalid-email')) {
      return AuthErrorMessage(
        message: 'El formato del correo electrónico no es correcto.\n\n'
            'Asegúrate de usar el formato:\nusuario@ejemplo.com',
      );
    }

    // Operación no permitida
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

    // Timeout específico
    if (lowerError.contains('timeout') ||
        lowerError.contains('time out') ||
        lowerError.contains('tiempo de espera agotado')) {
      return AuthErrorMessage(
        message: 'La operación tardó demasiado tiempo.\n\n'
            'Esto puede deberse a una conexión lenta. Inténtalo de nuevo.',
        actions: [
          AuthAction(
            label: 'Reintentar',
            isPrimary: true,
            onPressed: () => Navigator.of,
          ),
        ],
      );
    }

    // Demasiados intentos / Rate limiting
    if (lowerError.contains('too-many-requests') ||
        lowerError.contains('rate limit') ||
        lowerError.contains('too many attempts')) {
      return AuthErrorMessage(
        message: 'Has intentado registrarte demasiadas veces.\n\n'
            'Por tu seguridad, espera unos minutos antes de intentar de nuevo.',
        actions: [
          AuthAction(
            label: 'Entendido',
            isPrimary: true,
            onPressed: () => Navigator.of,
          ),
        ],
      );
    }

    // Problemas de conexión
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return AuthErrorMessage(
        message: 'Error de conexión a internet.\n\n'
            'Verifica tu conexión e inténtalo de nuevo.',
        actions: [
          AuthAction(
            label: 'Reintentar',
            isPrimary: true,
            onPressed: () => Navigator.of,
          ),
        ],
      );
    }

    // Dominio de email no permitido
    if (lowerError.contains('domain not allowed') ||
        lowerError.contains('email domain')) {
      return AuthErrorMessage(
        message: 'Este dominio de email no está permitido.\n\n'
            'Por favor, usa un email de un proveedor diferente (Gmail, Outlook, etc.)',
      );
    }

    // Usuario ya existe pero con otro método
    if (lowerError.contains('account-exists-with-different-credential')) {
      return AuthErrorMessage(
        message: 'Ya existe una cuenta con este email pero con un método diferente.\n\n'
            'Intenta iniciar sesión con Google o recupera tu contraseña.',
        actions: [
          AuthAction(
            label: 'Iniciar con Google',
            isPrimary: true,
            onPressed: () => Navigator.of,
          ),
          AuthAction(
            label: 'Recuperar contraseña',
            isPrimary: false,
            onPressed: () => _showForgotPasswordDialog,
          ),
        ],
      );
    }

    // Error genérico mejorado
    return AuthErrorMessage(
      message: 'No pudimos crear tu cuenta en este momento.\n\n'
          'Verifica que todos los datos sean correctos e inténtalo de nuevo.\n\n'
          'Si el problema persiste, contacta con nuestro soporte.',
      actions: [
        AuthAction(
          label: 'Reintentar',
          isPrimary: true,
          onPressed: () => Navigator.of,
        ),
        AuthAction(
          label: 'Contactar soporte',
          isPrimary: false,
          onPressed: () => _contactSupport,
        ),
      ],
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
            onPressed: () => Navigator.of,
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
            onPressed: () => Navigator.of,
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
          onPressed: () => Navigator.of,
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
        message: 'Esta operación requiere una autenticación reciente.\n\n'
            'Por seguridad, cierra sesión y vuelve a iniciar para cambiar tu contraseña.',
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
          'Inténtalo de nuevo o contacta con soporte.',
      actions: [
        AuthAction(
          label: 'Contactar soporte',
          isPrimary: true,
          onPressed: () => _contactSupport,
        ),
      ],
    );
  }

  /// Muestra un diálogo de error de autenticación con diseño mejorado
  static Future<void> _showAuthDialog(
      BuildContext context, {
        required String title,
        required String message,
        required IconData icon,
        required Color iconColor,
        List<AuthAction>? actions,
      }) async {
    if (!context.mounted) return;

    // Feedback háptico específico según la severidad
    if (iconColor == AppColors.error) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

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
              // Icono con animación sutil
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 400),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
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
                  );
                },
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

  /// Construye un botón de acción mejorado
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
              ? AppColors.primary
              : AppColors.white,
          foregroundColor: action.isPrimary
              ? AppColors.white
              : AppColors.primary,
          side: action.isPrimary
              ? null
              : const BorderSide(color: AppColors.primary),
          elevation: action.isPrimary ? 3 : 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
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

  /// Construye el botón de cerrar mejorado
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

  /// Muestra SnackBar de éxito mejorado
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
        margin: const EdgeInsets.all(16),
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