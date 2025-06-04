// lib/config/services/optimized_location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../../map/map_config.dart';

class OptimizedLocationService {
  static final OptimizedLocationService _instance = OptimizedLocationService._internal();
  factory OptimizedLocationService() => _instance;
  OptimizedLocationService._internal();

  // Stream controllers
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  final StreamController<LocationServiceStatus> _statusController = StreamController<LocationServiceStatus>.broadcast();

  // Estado interno
  Position? _lastKnownPosition;
  DateTime? _lastUpdateTime;
  StreamSubscription<Position>? _positionStream;
  bool _isInitialized = false;
  LocationServiceStatus _currentStatus = LocationServiceStatus.disabled;

  // Configuración optimizada
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: MapConfig.locationUpdateDistance,
    timeLimit: MapConfig.locationTimeout,
  );

  // Getters públicos
  Stream<Position> get positionStream => _positionController.stream;
  Stream<LocationServiceStatus> get statusStream => _statusController.stream;
  Position? get lastKnownPosition => _lastKnownPosition;
  LocationServiceStatus get currentStatus => _currentStatus;
  bool get isInitialized => _isInitialized;

  // Inicialización del servicio
  Future<LocationInitResult> initialize() async {
    if (_isInitialized) {
      return LocationInitResult.success(_lastKnownPosition);
    }

    try {
      // Verificar servicios de ubicación
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateStatus(LocationServiceStatus.disabled);
        return LocationInitResult.failure(LocationError.serviceDisabled);
      }

      // Verificar permisos
      final permissionResult = await _checkAndRequestPermissions();
      if (!permissionResult.isGranted) {
        _updateStatus(LocationServiceStatus.permissionDenied);
        return LocationInitResult.failure(LocationError.permissionDenied);
      }

      // Obtener ubicación inicial
      final position = await _getCurrentPositionWithTimeout();
      if (position != null) {
        _updatePosition(position);
        _updateStatus(LocationServiceStatus.enabled);
        _isInitialized = true;
        return LocationInitResult.success(position);
      } else {
        _updateStatus(LocationServiceStatus.error);
        return LocationInitResult.failure(LocationError.timeout);
      }
    } catch (e) {
      _updateStatus(LocationServiceStatus.error);
      return LocationInitResult.failure(LocationError.unknown);
    }
  }

  // Iniciar actualizaciones de ubicación
  Future<void> startLocationUpdates() async {
    if (!_isInitialized) {
      final result = await initialize();
      if (!result.isSuccess) return;
    }

    if (_positionStream != null) return; // Ya está activo

    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen(
        _updatePosition,
        onError: _handleLocationError,
      );

      _updateStatus(LocationServiceStatus.enabled);
    } catch (e) {
      _updateStatus(LocationServiceStatus.error);
    }
  }

  // Detener actualizaciones de ubicación
  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
    _updateStatus(LocationServiceStatus.paused);
  }

  // Pausar actualizaciones (mantiene el stream pero pausa las actualizaciones)
  void pauseLocationUpdates() {
    _positionStream?.pause();
    _updateStatus(LocationServiceStatus.paused);
  }

  // Reanudar actualizaciones
  void resumeLocationUpdates() {
    if (_positionStream?.isPaused == true) {
      _positionStream?.resume();
      _updateStatus(LocationServiceStatus.enabled);
    }
  }

  // Obtener ubicación actual sin suscripción
  Future<Position?> getCurrentPosition() async {
    try {
      // Si tenemos una ubicación reciente, usarla
      if (_lastKnownPosition != null && _isLocationRecent()) {
        return _lastKnownPosition;
      }

      final position = await _getCurrentPositionWithTimeout();
      if (position != null) {
        _updatePosition(position);
      }
      return position;
    } catch (e) {
      return _lastKnownPosition; // Fallback a última ubicación conocida
    }
  }

  // Verificar permisos de ubicación
  Future<PermissionResult> checkPermissions() async {
    return await _checkAndRequestPermissions();
  }

  // Limpiar recursos
  void dispose() {
    _positionStream?.cancel();
    _positionController.close();
    _statusController.close();
    _isInitialized = false;
  }

  // Métodos privados

  Future<PermissionResult> _checkAndRequestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return PermissionResult.granted();
      case LocationPermission.denied:
        return PermissionResult.denied();
      case LocationPermission.deniedForever:
        return PermissionResult.deniedForever();
      case LocationPermission.unableToDetermine:
        return PermissionResult.undetermined();
    }
  }

  Future<Position?> _getCurrentPositionWithTimeout() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
    } on TimeoutException {
      return null;
    } catch (e) {
      return null;
    }
  }

  void _updatePosition(Position position) {
    // Validar que la posición esté en Perú (opcional)
    if (!MapConfig.isValidLatLng(position.latitude, position.longitude)) {
      return; // Ignorar posiciones fuera del rango válido
    }

    _lastKnownPosition = position;
    _lastUpdateTime = DateTime.now();
    _positionController.add(position);
  }

  void _updateStatus(LocationServiceStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  void _handleLocationError(dynamic error) {
    _updateStatus(LocationServiceStatus.error);
    // Log del error para debugging
    print('Location service error: $error');
  }

  bool _isLocationRecent() {
    if (_lastUpdateTime == null) return false;
    final now = DateTime.now();
    return now.difference(_lastUpdateTime!) < const Duration(minutes: 5);
  }
}

// Enums y clases de apoyo

enum LocationServiceStatus {
  disabled,
  permissionDenied,
  enabled,
  paused,
  error,
}

enum LocationError {
  serviceDisabled,
  permissionDenied,
  timeout,
  unknown,
}

class LocationInitResult {
  final bool isSuccess;
  final Position? position;
  final LocationError? error;

  LocationInitResult._(this.isSuccess, this.position, this.error);

  factory LocationInitResult.success(Position? position) =>
      LocationInitResult._(true, position, null);

  factory LocationInitResult.failure(LocationError error) =>
      LocationInitResult._(false, null, error);
}

class PermissionResult {
  final bool isGranted;
  final bool isDeniedForever;
  final bool isUndetermined;

  PermissionResult._(this.isGranted, this.isDeniedForever, this.isUndetermined);

  factory PermissionResult.granted() => PermissionResult._(true, false, false);
  factory PermissionResult.denied() => PermissionResult._(false, false, false);
  factory PermissionResult.deniedForever() => PermissionResult._(false, true, false);
  factory PermissionResult.undetermined() => PermissionResult._(false, false, true);
}
