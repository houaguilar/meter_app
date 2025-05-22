// lib/config/utils/error_handler.dart
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorHandler {
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

    return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
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