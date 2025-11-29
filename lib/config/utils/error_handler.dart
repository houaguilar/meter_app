import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

import '../constants/error/failures.dart';

/// Manejador centralizado de errores para la aplicación
/// Proporciona métodos estáticos para manejo consistente de errores
class ErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Convierte un mensaje de error genérico en uno amigable para el usuario
  static String getErrorMessage(String originalError) {
    final error = originalError.toLowerCase();

    if (_isConnectionError(error)) {
      return 'Sin conexión a internet. Revisa tu conexión y vuelve a intentar.';
    }

    if (error.contains('timeout')) {
      return 'La conexión está tardando demasiado. Inténtalo de nuevo.';
    }

    if (error.contains('server') || error.contains('502') || error.contains('503')) {
      return 'Problema con el servidor. Inténtalo más tarde.';
    }

    if (error.contains('404')) {
      return 'Contenido no encontrado.';
    }

    if (error.contains('unauthorized') || error.contains('401')) {
      return 'Error de autorización. Inicia sesión nuevamente.';
    }

    if (error.contains('forbidden') || error.contains('403')) {
      return 'No tienes permisos para acceder a este contenido.';
    }

    if (error.contains('duplicate')) {
      return 'Ya existe un elemento con ese nombre.';
    }

    return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
  }

  /// Mapea un Failure a un mensaje amigable para el usuario
  static String mapFailureToMessage(Failure failure) {
    _logger.d('Mapeando failure: ${failure.type} - ${failure.message}');

    switch (failure.type) {
      case FailureType.duplicateName:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Ya existe un elemento con ese nombre';

      case FailureType.network:
        return 'Error de conexión. Verifica tu internet.';

      case FailureType.server:
        return 'Problema con el servidor. Inténtalo más tarde.';

      case FailureType.notFound:
        return 'El elemento solicitado no fue encontrado.';

      case FailureType.unauthorized:
        return 'No estás autorizado. Inicia sesión nuevamente.';

      case FailureType.validation:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Los datos ingresados no son válidos';

      case FailureType.general:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Ocurrió un error. Inténtalo de nuevo.';

      case FailureType.unknown:
      default:
        return 'Error inesperado. Por favor, inténtalo de nuevo.';
    }
  }

  /// Registra un error en el logger
  static void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    final contextPrefix = context != null ? '[$context] ' : '';
    _logger.e('$contextPrefix$message', error: error, stackTrace: stackTrace);
  }

  /// Registra una advertencia en el logger
  static void logWarning(String message, {String? context}) {
    final contextPrefix = context != null ? '[$context] ' : '';
    _logger.w('$contextPrefix$message');
  }

  /// Registra información en el logger
  static void logInfo(String message, {String? context}) {
    final contextPrefix = context != null ? '[$context] ' : '';
    _logger.i('$contextPrefix$message');
  }

  static bool _isConnectionError(String error) {
    final connectionKeywords = [
      'no internet',
      'connection',
      'network',
      'unreachable',
      'failed host lookup',
      'socket exception',
    ];

    return connectionKeywords.any((keyword) => error.contains(keyword));
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  static void showErrorSnackBar(
      BuildContext context,
      String message, {
        VoidCallback? onRetry,
        String retryLabel = 'Reintentar',
      }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
          label: retryLabel,
          textColor: Colors.white,
          onPressed: onRetry,
        )
            : null,
      ),
    );
  }

  static void showSuccessSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 2),
      }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  static void showInfoSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  static Widget buildErrorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
    String retryButtonText = 'Reintentar',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Algo salió mal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyWidget({
    required String message,
    IconData icon = Icons.inbox_outlined,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}