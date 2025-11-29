// lib/presentation/blocs/common/error_handler_mixin.dart

import '../../../config/constants/error/failures.dart';
import '../../../config/utils/error_handler.dart';

/// Mixin para proporcionar manejo consistente de errores en todos los BLoCs
///
/// Uso:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with ErrorHandlerMixin {
///   // ...
/// }
/// ```
mixin ErrorHandlerMixin {
  /// Contexto del BLoC para logging (opcional, override si se desea)
  String get blocContext => runtimeType.toString();

  /// Mapea un Failure a un mensaje amigable para el usuario
  /// Utiliza el ErrorHandler centralizado
  String mapFailureToMessage(Failure failure) {
    ErrorHandler.logError(
      'Failure detectado: ${failure.type}',
      error: failure.message,
      context: blocContext,
    );
    return ErrorHandler.mapFailureToMessage(failure);
  }

  /// Registra un error de forma consistente
  void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    ErrorHandler.logError(
      message,
      error: error,
      stackTrace: stackTrace,
      context: blocContext,
    );
  }

  /// Registra una advertencia
  void logWarning(String message) {
    ErrorHandler.logWarning(message, context: blocContext);
  }

  /// Registra información
  void logInfo(String message) {
    ErrorHandler.logInfo(message, context: blocContext);
  }

  /// Maneja una excepción genérica y retorna un mensaje apropiado
  String handleException(dynamic exception, {StackTrace? stackTrace}) {
    logError(
      'Excepción no controlada',
      error: exception,
      stackTrace: stackTrace,
    );

    if (exception is Exception) {
      return ErrorHandler.getErrorMessage(exception.toString());
    }

    return 'Error inesperado: ${exception.toString()}';
  }
}
