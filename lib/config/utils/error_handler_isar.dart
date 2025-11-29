import 'package:flutter/material.dart';
import 'package:meter_app/config/utils/security_service.dart';
import '../constants/error/failures.dart';

/// Utilidad centralizada para manejo de errores en la aplicación
class ErrorHandlerIsar {

  /// Muestra un SnackBar con mensaje de error
  static void showErrorSnackBar(
      BuildContext context,
      String message, {
        VoidCallback? onRetry,
        Duration duration = const Duration(seconds: 4),
      }) {
    if (!_isValidContext(context)) return;

    // Sanitizar el mensaje de error
    final sanitizedMessage = SecurityService.sanitizeText(message);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sanitizedMessage,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: onRetry,
        )
            : null,
      ),
    );
  }

  /// Muestra un SnackBar con mensaje de éxito
  static void showSuccessSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    if (!_isValidContext(context)) return;

    final sanitizedMessage = SecurityService.sanitizeText(message);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              sanitizedMessage,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
      ),
    );
  }

  /// Muestra un SnackBar con mensaje de advertencia
  static void showWarningSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 4),
      }) {
    if (!_isValidContext(context)) return;

    final sanitizedMessage = SecurityService.sanitizeText(message);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sanitizedMessage,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
      ),
    );
  }

  /// Muestra un diálogo de error con opciones
  static Future<void> showErrorDialog(
      BuildContext context, {
        required String title,
        required String message,
        String? details,
        VoidCallback? onRetry,
        VoidCallback? onDismiss,
      }) async {
    if (!_isValidContext(context)) return;

    // Sanitizar textos
    final sanitizedTitle = SecurityService.sanitizeText(title);
    final sanitizedMessage = SecurityService.sanitizeText(message);
    final sanitizedDetails = details != null
        ? SecurityService.sanitizeText(details)
        : null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sanitizedTitle,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sanitizedMessage),
              if (sanitizedDetails != null) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  title: const Text('Detalles técnicos'),
                  tilePadding: EdgeInsets.zero,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sanitizedDetails,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            if (onRetry != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  /// Convierte un Failure en un mensaje de error legible
  static String getErrorMessage(Failure failure) {
    switch (failure.type) {
      case FailureType.duplicateName:
        return 'Ya existe un elemento con ese nombre. Por favor elige otro nombre.';
      case FailureType.general:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Ha ocurrido un error inesperado.';
      case FailureType.unknown:
        return 'Error desconocido. Por favor intenta nuevamente.';
      case FailureType.validation:
        return 'Error validation';

      case FailureType.server:
        return 'Error server';
      case FailureType.network:
        // TODO: Handle this case.
        throw UnimplementedError();
      case FailureType.notFound:
        // TODO: Handle this case.
        throw UnimplementedError();
      case FailureType.unauthorized:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Maneja errores de conectividad
  static void handleConnectionError(BuildContext context) {
    if (!_isValidContext(context)) return;

    showWarningSnackBar(
      context,
      'Sin conexión a internet. Los datos se guardarán localmente.',
      duration: const Duration(seconds: 5),
    );
  }

  /// Maneja errores de validación
  static void handleValidationError(
      BuildContext context,
      ValidationResult validationResult,
      ) {
    if (!_isValidContext(context) || validationResult.isValid) return;

    if (validationResult.hasErrors) {
      showErrorSnackBar(context, validationResult.errorMessage);
    } else if (validationResult.hasWarnings) {
      showWarningSnackBar(context, validationResult.warningMessage);
    }
  }

  /// Maneja errores de autenticación
  static void handleAuthError(BuildContext context, String error) {
    if (!_isValidContext(context)) return;

    String message;
    if (error.toLowerCase().contains('network')) {
      message = 'Error de conexión. Verifica tu internet.';
    } else if (error.toLowerCase().contains('credential')) {
      message = 'Credenciales incorrectas. Verifica tu email y contraseña.';
    } else if (error.toLowerCase().contains('user not found')) {
      message = 'Usuario no encontrado. Verifica tus datos.';
    } else {
      message = 'Error de autenticación. Intenta nuevamente.';
    }

    showErrorDialog(
      context,
      title: 'Error de Autenticación',
      message: message,
      details: error,
    );
  }

  /// Maneja errores de sincronización
  static void handleSyncError(BuildContext context, String operation) {
    if (!_isValidContext(context)) return;

    showWarningSnackBar(
      context,
      'No se pudo sincronizar $operation. Se guardó localmente.',
      duration: const Duration(seconds: 4),
    );
  }

  /// Registra errores para análisis (en producción enviaría a servicio de logging)
  static void logError(
      String operation,
      dynamic error, {
        StackTrace? stackTrace,
        Map<String, dynamic>? context,
      }) {
    final timestamp = DateTime.now().toIso8601String();
    final errorLog = {
      'timestamp': timestamp,
      'operation': operation,
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
    };

    // En desarrollo: imprimir en consola
    debugPrint('🔥 ERROR LOG: $errorLog');

    // En producción: enviar a servicio de logging (Firebase Crashlytics, Sentry, etc.)
    // CrashlyticsService.recordError(error, stackTrace, context);
  }

  /// Registra errores de seguridad
  static void logSecurityError(
      String operation,
      String details, {
        Map<String, dynamic>? context,
      }) {
    SecurityService.logSuspiciousActivity(
      'SECURITY_ERROR: $operation',
      {
        'details': details,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Verifica si el contexto es válido para mostrar UI
  static bool _isValidContext(BuildContext context) {
    try {
      return context.mounted &&
          Navigator.of(context).canPop() ||
          ModalRoute.of(context)?.isCurrent == true;
    } catch (e) {
      return false;
    }
  }

  /// Crea un widget de error reutilizable
  static Widget buildErrorWidget({
    required String message,
    String? details,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SecurityService.sanitizeText(message),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (details != null) ...[
              const SizedBox(height: 12),
              Text(
                SecurityService.sanitizeText(details),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Crea un widget de loading con manejo de errores
  static Widget buildLoadingWidget({
    String message = 'Cargando...',
    VoidCallback? onCancel,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            SecurityService.sanitizeText(message),
            style: const TextStyle(fontSize: 16),
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
    );
  }
}