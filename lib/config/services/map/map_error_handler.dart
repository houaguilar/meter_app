// lib/config/services/map_error_handler.dart
import 'package:flutter/material.dart';

enum MapErrorType {
  networkError,
  apiQuotaExceeded,
  invalidApiKey,
  locationPermissionDenied,
  locationServiceDisabled,
  placeNotFound,
  invalidRequest,
  unknown,
}

class MapErrorHandler {
  static MapErrorType getErrorType(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('quota') || errorString.contains('billing')) {
      return MapErrorType.apiQuotaExceeded;
    }

    if (errorString.contains('api key') || errorString.contains('invalid key')) {
      return MapErrorType.invalidApiKey;
    }

    if (errorString.contains('network') || errorString.contains('internet')) {
      return MapErrorType.networkError;
    }

    if (errorString.contains('permission denied')) {
      return MapErrorType.locationPermissionDenied;
    }

    if (errorString.contains('location service')) {
      return MapErrorType.locationServiceDisabled;
    }

    if (errorString.contains('not found') || errorString.contains('zero results')) {
      return MapErrorType.placeNotFound;
    }

    if (errorString.contains('invalid request')) {
      return MapErrorType.invalidRequest;
    }

    return MapErrorType.unknown;
  }

  static String getErrorMessage(MapErrorType errorType) {
    switch (errorType) {
      case MapErrorType.networkError:
        return 'No hay conexión a internet. Verifica tu conexión y vuelve a intentar.';
      case MapErrorType.apiQuotaExceeded:
        return 'Se ha excedido el límite de búsquedas. Inténtalo más tarde.';
      case MapErrorType.invalidApiKey:
        return 'Error de configuración. Contacta al soporte técnico.';
      case MapErrorType.locationPermissionDenied:
        return 'Permisos de ubicación denegados. Actívalos en configuración.';
      case MapErrorType.locationServiceDisabled:
        return 'Los servicios de ubicación están desactivados.';
      case MapErrorType.placeNotFound:
        return 'No se encontraron resultados para tu búsqueda.';
      case MapErrorType.invalidRequest:
        return 'Búsqueda inválida. Verifica los términos ingresados.';
      case MapErrorType.unknown:
        return 'Error inesperado. Inténtalo de nuevo.';
    }
  }

  static IconData getErrorIcon(MapErrorType errorType) {
    switch (errorType) {
      case MapErrorType.networkError:
        return Icons.wifi_off;
      case MapErrorType.apiQuotaExceeded:
        return Icons.error_outline;
      case MapErrorType.invalidApiKey:
        return Icons.key_off;
      case MapErrorType.locationPermissionDenied:
        return Icons.location_disabled;
      case MapErrorType.locationServiceDisabled:
        return Icons.location_off;
      case MapErrorType.placeNotFound:
        return Icons.search_off;
      case MapErrorType.invalidRequest:
        return Icons.warning;
      case MapErrorType.unknown:
        return Icons.error;
    }
  }

  static Color getErrorColor(MapErrorType errorType) {
    switch (errorType) {
      case MapErrorType.networkError:
      case MapErrorType.locationPermissionDenied:
      case MapErrorType.locationServiceDisabled:
        return Colors.orange;
      case MapErrorType.apiQuotaExceeded:
      case MapErrorType.invalidApiKey:
        return Colors.red;
      case MapErrorType.placeNotFound:
      case MapErrorType.invalidRequest:
        return Colors.blue;
      case MapErrorType.unknown:
        return Colors.grey;
    }
  }

  static bool isRetryable(MapErrorType errorType) {
    switch (errorType) {
      case MapErrorType.networkError:
      case MapErrorType.placeNotFound:
      case MapErrorType.unknown:
        return true;
      case MapErrorType.apiQuotaExceeded:
      case MapErrorType.invalidApiKey:
      case MapErrorType.locationPermissionDenied:
      case MapErrorType.locationServiceDisabled:
      case MapErrorType.invalidRequest:
        return false;
    }
  }

  static void showErrorSnackBar(
      BuildContext context,
      dynamic error, {
        VoidCallback? onRetry,
      }) {
    final errorType = getErrorType(error);
    final message = getErrorMessage(errorType);
    final color = getErrorColor(errorType);
    final canRetry = isRetryable(errorType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              getErrorIcon(errorType),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: canRetry && onRetry != null
            ? SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: onRetry,
        )
            : null,
      ),
    );
  }
}