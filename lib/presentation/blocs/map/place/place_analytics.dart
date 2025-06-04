import 'package:flutter/foundation.dart';

class PlaceSearchAnalytics {
  static final PlaceSearchAnalytics _instance = PlaceSearchAnalytics._internal();
  factory PlaceSearchAnalytics() => _instance;
  PlaceSearchAnalytics._internal();

  // Contadores para análisis de uso
  int _totalSearches = 0;
  int _cacheHits = 0;
  int _apiCalls = 0;
  int _errors = 0;
  final Map<String, int> _queryFrequency = {};

  // Métricas adicionales
  int _totalResponseTime = 0; // en milisegundos
  int _timeoutErrors = 0;
  int _networkErrors = 0;
  int _quotaErrors = 0;

  DateTime? _sessionStartTime;

  // Métodos para registrar eventos
  void recordSearch(String query) {
    _sessionStartTime ??= DateTime.now();
    _totalSearches++;
    _queryFrequency[query] = (_queryFrequency[query] ?? 0) + 1;
  }

  void recordCacheHit() {
    _cacheHits++;
  }

  void recordApiCall() {
    _apiCalls++;
  }

  void recordError([String? errorType]) {
    _errors++;

    // Categorizar errores
    if (errorType != null) {
      switch (errorType.toLowerCase()) {
        case 'timeout':
          _timeoutErrors++;
          break;
        case 'network':
          _networkErrors++;
          break;
        case 'quota':
          _quotaErrors++;
          break;
      }
    }
  }

  void recordResponseTime(int milliseconds) {
    _totalResponseTime += milliseconds;
  }

  // Métodos para obtener estadísticas
  double get cacheHitRatio => _totalSearches > 0 ? _cacheHits / _totalSearches : 0;
  double get errorRate => _totalSearches > 0 ? _errors / _totalSearches : 0;
  double get apiEfficiency => _totalSearches > 0 ? _apiCalls / _totalSearches : 0;
  double get averageResponseTime => _apiCalls > 0 ? _totalResponseTime / _apiCalls : 0;

  int get totalSearches => _totalSearches;
  int get cacheHits => _cacheHits;
  int get apiCalls => _apiCalls;
  int get errors => _errors;
  int get timeoutErrors => _timeoutErrors;
  int get networkErrors => _networkErrors;
  int get quotaErrors => _quotaErrors;

  Map<String, int> get queryFrequency => Map.unmodifiable(_queryFrequency);

  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  // Método para obtener las búsquedas más frecuentes
  List<MapEntry<String, int>> get topQueries {
    final entries = _queryFrequency.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(10).toList();
  }

  // Método para obtener estadísticas como mapa
  Map<String, dynamic> get stats => {
    'total_searches': _totalSearches,
    'cache_hits': _cacheHits,
    'api_calls': _apiCalls,
    'errors': _errors,
    'cache_hit_ratio': cacheHitRatio,
    'error_rate': errorRate,
    'api_efficiency': apiEfficiency,
    'average_response_time_ms': averageResponseTime,
    'timeout_errors': _timeoutErrors,
    'network_errors': _networkErrors,
    'quota_errors': _quotaErrors,
    'session_duration_minutes': sessionDuration?.inMinutes,
    'top_queries': topQueries.take(5).map((e) => {
      'query': e.key,
      'count': e.value,
    }).toList(),
  };

  // Método para evaluar la eficiencia del cache
  String get cachePerformanceMessage {
    final ratio = cacheHitRatio;
    if (ratio >= 0.7) return 'Excelente eficiencia de cache';
    if (ratio >= 0.5) return 'Buena eficiencia de cache';
    if (ratio >= 0.3) return 'Eficiencia de cache regular';
    return 'Cache necesita optimización';
  }

  // Método para evaluar el rendimiento general
  String get overallPerformanceMessage {
    if (errorRate > 0.1) return 'Alto rate de errores - revisar conexión';
    if (averageResponseTime > 2000) return 'Tiempos de respuesta lentos';
    if (cacheHitRatio < 0.3) return 'Cache poco eficiente';
    return 'Rendimiento óptimo';
  }

  // Método para limpiar estadísticas
  void reset() {
    _totalSearches = 0;
    _cacheHits = 0;
    _apiCalls = 0;
    _errors = 0;
    _totalResponseTime = 0;
    _timeoutErrors = 0;
    _networkErrors = 0;
    _quotaErrors = 0;
    _queryFrequency.clear();
    _sessionStartTime = null;
  }

  // Método para imprimir estadísticas (útil para debugging)
  void printStats() {
    if (kDebugMode) {
      print('=== Place Search Analytics ===');
      print('Total searches: $_totalSearches');
      print('Cache hits: $_cacheHits');
      print('API calls: $_apiCalls');
      print('Errors: $_errors');
      print('Cache hit ratio: ${(cacheHitRatio * 100).toStringAsFixed(2)}%');
      print('Error rate: ${(errorRate * 100).toStringAsFixed(2)}%');
      print('API efficiency: ${(apiEfficiency * 100).toStringAsFixed(2)}%');
      print('Average response time: ${averageResponseTime.toStringAsFixed(0)}ms');
      print('Session duration: ${sessionDuration?.inMinutes ?? 0} minutes');
      print('Cache performance: $cachePerformanceMessage');
      print('Overall performance: $overallPerformanceMessage');
      print('Error breakdown:');
      print('  - Timeout errors: $_timeoutErrors');
      print('  - Network errors: $_networkErrors');
      print('  - Quota errors: $_quotaErrors');
      print('Top queries:');
      for (final entry in topQueries) {
        print('  "${entry.key}": ${entry.value} times');
      }
      print('==============================');
    }
  }

  // Método para exportar estadísticas (útil para análisis)
  String exportStatsAsJson() {
    return stats.toString();
  }

  // Método para verificar si necesita optimización
  bool get needsOptimization {
    return cacheHitRatio < 0.5 || errorRate > 0.05 || averageResponseTime > 1500;
  }

  // Recomendaciones de optimización
  List<String> get optimizationRecommendations {
    final recommendations = <String>[];

    if (cacheHitRatio < 0.5) {
      recommendations.add('Incrementar duración del cache para mejorar hit ratio');
    }

    if (errorRate > 0.05) {
      recommendations.add('Implementar mejor manejo de errores y retry logic');
    }

    if (averageResponseTime > 1500) {
      recommendations.add('Optimizar timeouts y configuración de red');
    }

    if (_quotaErrors > 0) {
      recommendations.add('Implementar rate limiting más agresivo para evitar cuota');
    }

    if (_networkErrors > _errors * 0.5) {
      recommendations.add('Mejorar manejo de conectividad de red');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Rendimiento óptimo - continuar monitoreando');
    }

    return recommendations;
  }
}