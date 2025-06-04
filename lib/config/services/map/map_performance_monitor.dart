// lib/config/services/map_performance_monitor.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class MapPerformanceMonitor {
  static final MapPerformanceMonitor _instance = MapPerformanceMonitor._internal();
  factory MapPerformanceMonitor() => _instance;
  MapPerformanceMonitor._internal();

  // Métricas de rendimiento
  int _apiCallsCount = 0;
  int _cacheHitsCount = 0;
  double _totalApiResponseTime = 0;
  final List<double> _responseTimes = [];
  final Map<String, int> _errorCount = {};

  Timer? _reportTimer;

  // Configuración
  static const int _maxResponseTimeSamples = 100;
  static const Duration _reportInterval = Duration(minutes: 5);

  void startMonitoring() {
    _reportTimer?.cancel();
    _reportTimer = Timer.periodic(_reportInterval, (_) => _generateReport());
  }

  void stopMonitoring() {
    _reportTimer?.cancel();
  }

  // Registrar llamada API
  void recordApiCall(Duration responseTime) {
    _apiCallsCount++;
    final timeMs = responseTime.inMilliseconds.toDouble();
    _totalApiResponseTime += timeMs;

    _responseTimes.add(timeMs);
    if (_responseTimes.length > _maxResponseTimeSamples) {
      _responseTimes.removeAt(0);
    }
  }

  // Registrar cache hit
  void recordCacheHit() {
    _cacheHitsCount++;
  }

  // Registrar error
  void recordError(String errorType) {
    _errorCount[errorType] = (_errorCount[errorType] ?? 0) + 1;
  }

  // Obtener métricas
  double get averageResponseTime {
    return _apiCallsCount > 0 ? _totalApiResponseTime / _apiCallsCount : 0;
  }

  double get cacheHitRatio {
    final totalRequests = _apiCallsCount + _cacheHitsCount;
    return totalRequests > 0 ? _cacheHitsCount / totalRequests : 0;
  }

  int get totalApiCalls => _apiCallsCount;
  int get totalCacheHits => _cacheHitsCount;
  Map<String, int> get errorCount => Map.unmodifiable(_errorCount);

  // Generar reporte de rendimiento
  void _generateReport() {
    if (!kDebugMode) return;

    print('=== Map Performance Report ===');
    print('API Calls: $_apiCallsCount');
    print('Cache Hits: $_cacheHitsCount');
    print('Cache Hit Ratio: ${(cacheHitRatio * 100).toStringAsFixed(2)}%');
    print('Average Response Time: ${averageResponseTime.toStringAsFixed(2)}ms');

    if (_responseTimes.isNotEmpty) {
      final sortedTimes = List<double>.from(_responseTimes)..sort();
      final p50 = sortedTimes[(sortedTimes.length * 0.5).floor()];
      final p95 = sortedTimes[(sortedTimes.length * 0.95).floor()];
      print('Response Time P50: ${p50.toStringAsFixed(2)}ms');
      print('Response Time P95: ${p95.toStringAsFixed(2)}ms');
    }

    if (_errorCount.isNotEmpty) {
      print('Errors:');
      _errorCount.forEach((type, count) {
        print('  $type: $count');
      });
    }
    print('==============================');
  }

  // Limpiar métricas
  void reset() {
    _apiCallsCount = 0;
    _cacheHitsCount = 0;
    _totalApiResponseTime = 0;
    _responseTimes.clear();
    _errorCount.clear();
  }
}