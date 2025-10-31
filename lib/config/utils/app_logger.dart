import 'package:logger/logger.dart';
import '../app_config.dart';

/// Logger centralizado para toda la aplicación
///
/// Uso:
/// ```dart
/// AppLogger.premium.info('Usuario activó premium');
/// AppLogger.premium.error('Error en compra', error: e, stackTrace: st);
/// ```
class AppLogger {
  // Loggers por módulo
  static final Logger premium = _createLogger('PREMIUM');
  static final Logger auth = _createLogger('AUTH');
  static final Logger network = _createLogger('NETWORK');
  static final Logger database = _createLogger('DATABASE');
  static final Logger app = _createLogger('APP');

  static Logger _createLogger(String tag) {
    return Logger(
      filter: _AppLogFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: _AppLogOutput(tag),
    );
  }
}

/// Filtro personalizado para controlar qué logs se muestran
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // En producción, solo mostrar warnings y errores
    if (AppConfig.isProduction) {
      return event.level.value >= Level.warning.value;
    }

    // En desarrollo y sandbox, mostrar todo excepto verbose
    return event.level.value >= Level.debug.value;
  }
}

/// Output personalizado que agrega el tag del módulo
class _AppLogOutput extends LogOutput {
  final String tag;

  _AppLogOutput(this.tag);

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      // Agregar tag al inicio de cada línea
      print('[$tag] $line');
    }
  }
}

/// Extension para facilitar el logging con contexto
extension LoggerExtension on Logger {
  /// Log con contexto adicional
  void infoWithContext(String message, {Map<String, dynamic>? context}) {
    if (context != null && context.isNotEmpty) {
      i('$message | Context: $context');
    } else {
      i(message);
    }
  }

  /// Log de error con más detalles
  void errorWithDetails(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final contextStr = context != null && context.isNotEmpty
        ? ' | Context: $context'
        : '';
    e('$message$contextStr', error: error, stackTrace: stackTrace);
  }
}
