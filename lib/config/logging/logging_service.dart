// lib/config/logging/logging_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Niveles de logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Entrada de log
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Map<String, dynamic>? metadata;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.metadata,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'tag': tag,
      'message': message,
      'metadata': metadata,
      'stackTrace': stackTrace,
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('${level.name.toUpperCase()} ');
    buffer.write('[$tag] ');
    buffer.write(message);

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' | Metadata: ${jsonEncode(metadata)}');
    }

    if (stackTrace != null) {
      buffer.write('\nStack Trace: $stackTrace');
    }

    return buffer.toString();
  }
}

/// Servicio de logging centralizado
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  final List<LogEntry> _logs = [];
  final StreamController<LogEntry> _logStreamController = StreamController<LogEntry>.broadcast();

  LogLevel _minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  int _maxLogEntries = 1000;
  bool _writeToFile = true;
  File? _logFile;

  /// Stream de logs para monitoreo en tiempo real
  Stream<LogEntry> get logStream => _logStreamController.stream;

  /// Configurar el servicio de logging
  Future<void> configure({
    LogLevel? minimumLevel,
    int? maxLogEntries,
    bool? writeToFile,
  }) async {
    _minimumLevel = minimumLevel ?? _minimumLevel;
    _maxLogEntries = maxLogEntries ?? _maxLogEntries;
    _writeToFile = writeToFile ?? _writeToFile;

    if (_writeToFile) {
      await _initializeLogFile();
    }
  }

  /// Inicializar archivo de log
  Future<void> _initializeLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${directory.path}/logs');

      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }

      final fileName = 'app_log_${DateTime.now().toIso8601String().split('T')[0]}.log';
      _logFile = File('${logDirectory.path}/$fileName');
    } catch (e) {
      debugPrint('Error inicializando archivo de log: $e');
    }
  }

  /// Log debug
  void debug(String tag, String message, [Map<String, dynamic>? metadata]) {
    _log(LogLevel.debug, tag, message, metadata);
  }

  /// Log info
  void info(String tag, String message, [Map<String, dynamic>? metadata]) {
    _log(LogLevel.info, tag, message, metadata);
  }

  /// Log warning
  void warning(String tag, String message, [Map<String, dynamic>? metadata]) {
    _log(LogLevel.warning, tag, message, metadata);
  }

  /// Log error
  void error(String tag, String message, [Map<String, dynamic>? metadata, StackTrace? stackTrace]) {
    _log(LogLevel.error, tag, message, metadata, stackTrace?.toString());
  }

  /// Log critical
  void critical(String tag, String message, [Map<String, dynamic>? metadata, StackTrace? stackTrace]) {
    _log(LogLevel.critical, tag, message, metadata, stackTrace?.toString());
  }

  /// Método interno para logging
  void _log(
      LogLevel level,
      String tag,
      String message, [
        Map<String, dynamic>? metadata,
        String? stackTrace,
      ]) {
    if (_shouldLog(level)) {
      final entry = LogEntry(
        timestamp: DateTime.now(),
        level: level,
        tag: tag,
        message: message,
        metadata: metadata,
        stackTrace: stackTrace,
      );

      _addLogEntry(entry);
      _outputLog(entry);
      _streamLog(entry);

      if (_writeToFile) {
        _writeLogToFile(entry);
      }
    }
  }

  /// Verificar si debe logear este nivel
  bool _shouldLog(LogLevel level) {
    return level.index >= _minimumLevel.index;
  }

  /// Agregar entrada al buffer
  void _addLogEntry(LogEntry entry) {
    _logs.add(entry);

    // Limitar el número de logs en memoria
    if (_logs.length > _maxLogEntries) {
      _logs.removeAt(0);
    }
  }

  /// Salida de log (consola en desarrollo)
  void _outputLog(LogEntry entry) {
    if (kDebugMode) {
      final emoji = _getLevelEmoji(entry.level);
      debugPrint('$emoji ${entry.toString()}');
    }
  }

  /// Emitir log al stream
  void _streamLog(LogEntry entry) {
    if (!_logStreamController.isClosed) {
      _logStreamController.add(entry);
    }
  }

  /// Escribir log a archivo
  Future<void> _writeLogToFile(LogEntry entry) async {
    try {
      if (_logFile != null) {
        await _logFile!.writeAsString(
          '${entry.toString()}\n',
          mode: FileMode.append,
        );
      }
    } catch (e) {
      debugPrint('Error escribiendo log a archivo: $e');
    }
  }

  /// Obtener emoji para el nivel de log
  String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔥';
    }
  }

  /// Obtener todos los logs
  List<LogEntry> getAllLogs() => List.unmodifiable(_logs);

  /// Obtener logs por nivel
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Obtener logs por tag
  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// Obtener logs en un rango de tiempo
  List<LogEntry> getLogsByTimeRange(DateTime start, DateTime end) {
    return _logs.where((log) =>
    log.timestamp.isAfter(start) && log.timestamp.isBefore(end)
    ).toList();
  }

  /// Limpiar logs
  void clearLogs() {
    _logs.clear();
  }

  /// Exportar logs como JSON
  String exportLogsAsJson() {
    final logsJson = _logs.map((log) => log.toJson()).toList();
    return jsonEncode({
      'exported_at': DateTime.now().toIso8601String(),
      'total_entries': _logs.length,
      'logs': logsJson,
    });
  }

  /// Obtener estadísticas de logs
  Map<String, dynamic> getLogStatistics() {
    final stats = <String, dynamic>{};

    // Contar por nivel
    for (final level in LogLevel.values) {
      stats['count_${level.name}'] = _logs.where((log) => log.level == level).length;
    }

    // Contar por tag
    final tagCounts = <String, int>{};
    for (final log in _logs) {
      tagCounts[log.tag] = (tagCounts[log.tag] ?? 0) + 1;
    }
    stats['by_tag'] = tagCounts;

    // Información general
    stats['total_entries'] = _logs.length;
    stats['oldest_entry'] = _logs.isNotEmpty ? _logs.first.timestamp.toIso8601String() : null;
    stats['newest_entry'] = _logs.isNotEmpty ? _logs.last.timestamp.toIso8601String() : null;

    return stats;
  }

  /// Dispose del servicio
  void dispose() {
    _logStreamController.close();
  }
}

/// Extension para logging específico de la app
extension AppLogging on LoggingService {
  /// Log para operaciones de proyectos
  void projectOperation(String operation, Map<String, dynamic> data) {
    info('PROJECT', 'Operation: $operation', data);
  }

  /// Log para operaciones de metrados
  void metradoOperation(String operation, Map<String, dynamic> data) {
    info('METRADO', 'Operation: $operation', data);
  }

  /// Log para operaciones de autenticación
  void authOperation(String operation, {String? userId}) {
    info('AUTH', 'Operation: $operation', userId != null ? {'userId': userId} : null);
  }

  /// Log para errores de sincronización
  void syncError(String operation, String error) {
    this.error('SYNC', 'Sync failed for $operation: $error');
  }

  /// Log para validaciones de seguridad
  void securityValidation(String validation, bool passed, {Map<String, dynamic>? details}) {
    if (passed) {
      debug('SECURITY', 'Validation passed: $validation', details);
    } else {
      warning('SECURITY', 'Validation failed: $validation', details);
    }
  }

  /// Log para rendimiento
  void performance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    final data = {'duration_ms': duration.inMilliseconds, ...?metadata};
    info('PERFORMANCE', 'Operation: $operation', data);
  }
}

/// Mixin para agregar logging a cualquier clase
mixin LoggingMixin {
  LoggingService get logger => LoggingService();

  void logDebug(String message, [Map<String, dynamic>? metadata]) {
    logger.debug(runtimeType.toString(), message, metadata);
  }

  void logInfo(String message, [Map<String, dynamic>? metadata]) {
    logger.info(runtimeType.toString(), message, metadata);
  }

  void logWarning(String message, [Map<String, dynamic>? metadata]) {
    logger.warning(runtimeType.toString(), message, metadata);
  }

  void logError(String message, [Map<String, dynamic>? metadata, StackTrace? stackTrace]) {
    logger.error(runtimeType.toString(), message, metadata, stackTrace);
  }

  void logCritical(String message, [Map<String, dynamic>? metadata, StackTrace? stackTrace]) {
    logger.critical(runtimeType.toString(), message, metadata, stackTrace);
  }
}