import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../config/theme/theme.dart';
import '../../blocs/auth/auth_bloc.dart';

/// Dialog multi-paso para eliminar cuenta con confirmaciones de seguridad
class DeleteAccountDialog {
  static Future<void> show(BuildContext context) async {
    // Paso 1: Advertencia inicial
    final shouldContinue = await _showInitialWarning(context);
    if (!shouldContinue) return;

    // Paso 2: Mostrar consecuencias específicas
    final understandsConsequences = await _showConsequences(context);
    if (!understandsConsequences) return;

    // Detectar si el usuario usó Google Sign-In
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final isGoogleUser = user?.appMetadata['provider'] == 'google' ||
        (user?.identities?.any((identity) => identity.provider == 'google') ?? false);

    String password = '';

    // Paso 3: Verificación de identidad según el proveedor
    if (!isGoogleUser) {
      // Usuarios de email/password: Pedir contraseña
      final pwd = await _showPasswordVerification(context);
      if (pwd == null || pwd.isEmpty) return;
      password = pwd;
    } else {
      // Usuarios de Google: Mostrar advertencia especial
      final confirmedGoogle = await _showGoogleUserWarning(context);
      if (!confirmedGoogle) return;
    }

    // Paso 4: Confirmación final con typing
    final confirmed = await _showFinalConfirmation(context);
    if (!confirmed) return;

    // Paso 5: Ejecutar eliminación
    _executeAccountDeletion(context, password);
  }

  /// Paso 1: Dialog de advertencia inicial
  static Future<bool> _showInitialWarning(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: AppColors.warning,
          size: 48,
        ),
        title: const Text(
          '¿Eliminar tu cuenta?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Esta acción es permanente e irreversible. '
          'No podrás recuperar tu cuenta ni tus datos después de eliminarla.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Paso 2: Mostrar consecuencias específicas
  static Future<bool> _showConsequences(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.info_outline,
          color: AppColors.error,
          size: 48,
        ),
        title: const Text(
          'Esto es lo que perderás',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Al eliminar tu cuenta se perderá:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildConsequenceItem(
              icon: Icons.person_off_outlined,
              text: 'Todos tus datos personales',
            ),
            _buildConsequenceItem(
              icon: Icons.folder_off_outlined,
              text: 'Todos tus proyectos y metrados guardados',
            ),
            _buildConsequenceItem(
              icon: Icons.store_outlined,
              text: 'Tu perfil de proveedor (si aplica)',
            ),
            _buildConsequenceItem(
              icon: Icons.history_outlined,
              text: 'Todo tu historial de actividad',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Entiendo, continuar'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Paso 3: Verificación de identidad con contraseña
  static Future<String?> _showPasswordVerification(BuildContext context) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.lock_person_outlined,
          color: AppColors.primary,
          size: 48,
        ),
        title: const Text(
          'Verifica tu identidad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por seguridad, ingresa tu contraseña actual:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Debes ingresar tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, passwordController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
  }

  /// Paso 4: Confirmación final con typing
  static Future<bool> _showFinalConfirmation(BuildContext context) async {
    final confirmationController = TextEditingController();
    final notifier = ValueNotifier<bool>(false);

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.delete_forever_outlined,
          color: AppColors.error,
          size: 48,
        ),
        title: const Text(
          'Confirmación final',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para confirmar la eliminación de tu cuenta, escribe:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Center(
                child: SelectableText(
                  'ELIMINAR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmationController,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'Escribe ELIMINAR',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
              onChanged: (value) {
                notifier.value = value.trim().toUpperCase() == 'ELIMINAR';
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (context, isValid, _) {
              return ElevatedButton(
                onPressed: isValid
                    ? () => Navigator.pop(context, true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Eliminar definitivamente'),
              );
            },
          ),
        ],
      ),
    ) ?? false;
  }

  /// Paso 5: Ejecutar eliminación
  static void _executeAccountDeletion(BuildContext context, String password) {
    // Mostrar dialog de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAccountDeleted) {
            // Cerrar dialog de carga
            Navigator.of(dialogContext).pop();

            // Mostrar mensaje de despedida y redirigir
            _showGoodbyeMessage(context);
          } else if (state is AuthFailure) {
            // Cerrar dialog de carga
            Navigator.of(dialogContext).pop();

            // Mostrar error
            _showErrorDialog(context, state.message);
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'Eliminando tu cuenta...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Por favor espera, esto puede tomar unos momentos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // Disparar evento de eliminación
    context.read<AuthBloc>().add(AuthDeleteAccount(password: password));
  }

  /// Mostrar mensaje de despedida
  static void _showGoodbyeMessage(BuildContext context) {
    // Guardar referencias antes del dialog
    final navigator = Navigator.of(context);
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 64,
          ),
          title: const Text(
            'Cuenta eliminada',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Tu cuenta ha sido eliminada exitosamente. '
            'Redirigiendo...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    ).then((_) {
      // Este código se ejecuta cuando se cierra el dialog
      // pero lo cerraremos automáticamente con el timer
    });

    // Cerrar automáticamente después de 1.5 segundos y forzar verificación de autenticación
    Future.delayed(const Duration(milliseconds: 1500), () {
      // Cerrar todos los dialogs usando el navigator guardado
      navigator.popUntil((route) => route.isFirst);

      // Forzar verificación inmediata del estado de autenticación
      authBloc.add(AuthIsUserLoggedIn());
    });
  }

  /// DEPRECATED - Ya no se usa el botón manual
  static void _showGoodbyeMessageWithButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 64,
          ),
          title: const Text(
            'Cuenta eliminada',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Tu cuenta ha sido eliminada exitosamente. '
            'Lamentamos verte partir. Esperamos verte de nuevo en el futuro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Cerrar todos los dialogs y navegar al inicio
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // Forzar verificación de autenticación
                  context.read<AuthBloc>().add(AuthIsUserLoggedIn());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Ir al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar error
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 48,
        ),
        title: const Text(
          'Error al eliminar cuenta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper para items de consecuencias
  static Widget _buildConsequenceItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog especial para usuarios de Google Sign-In
  static Future<bool> _showGoogleUserWarning(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.verified_user_outlined,
          color: AppColors.primary,
          size: 48,
        ),
        title: const Text(
          'Cuenta de Google',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Iniciaste sesión con Google. Al eliminar tu cuenta de MetraShop:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu cuenta de Google permanecerá activa',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Todos tus datos en MetraShop serán eliminados permanentemente',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ) ?? false;
  }
}
