// lib/config/mixins/location_permissions_mixin.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

mixin LocationPermissionsMixin<T extends StatefulWidget> on State<T> {

  /// Verificar y solicitar permisos de ubicación
  Future<LocationPermissionResult> checkAndRequestLocationPermission() async {
    try {
      // 1. Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult.serviceDisabled;
      }

      // 2. Verificar permisos actuales
      LocationPermission permission = await Geolocator.checkPermission();

      // 3. Solicitar permisos si es necesario
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return LocationPermissionResult.denied;
        }
      }

      // 4. Verificar si los permisos están denegados permanentemente
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult.deniedForever;
      }

      // 5. Verificar permisos específicos con permission_handler
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          return LocationPermissionResult.denied;
        }
      }

      return LocationPermissionResult.granted;

    } catch (e) {
      debugPrint('Error checking location permissions: $e');
      return LocationPermissionResult.error;
    }
  }

  /// Mostrar diálogo para ir a configuración de la app
  Future<void> showGoToSettingsDialog() async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos de Ubicación'),
          content: const Text(
            'Esta aplicación necesita acceso a la ubicación para funcionar correctamente. '
                'Por favor, habilita los permisos de ubicación en la configuración de la aplicación.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ir a Configuración'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// Mostrar diálogo para habilitar servicios de ubicación
  Future<void> showEnableLocationServicesDialog() async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Servicios de Ubicación'),
          content: const Text(
            'Los servicios de ubicación están deshabilitados. '
                'Por favor, habilítalos en la configuración del dispositivo.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Abrir Configuración'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// Obtener ubicación actual con manejo de errores
  Future<Position?> getCurrentLocationSafely({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Verificar permisos primero
      final permissionResult = await checkAndRequestLocationPermission();

      switch (permissionResult) {
        case LocationPermissionResult.serviceDisabled:
          await showEnableLocationServicesDialog();
          return null;

        case LocationPermissionResult.denied:
          await showGoToSettingsDialog();
          return null;

        case LocationPermissionResult.deniedForever:
          await showGoToSettingsDialog();
          return null;

        case LocationPermissionResult.error:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al verificar permisos de ubicación'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return null;

        case LocationPermissionResult.granted:
          break;
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );

      return position;

    } on LocationServiceDisabledException {
      await showEnableLocationServicesDialog();
      return null;
    } on PermissionDeniedException {
      await showGoToSettingsDialog();
      return null;
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiempo agotado al obtener ubicación'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Verificar si la ubicación está disponible sin solicitar permisos
  Future<bool> isLocationAvailable() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
}

/// Enum para resultados de permisos de ubicación
enum LocationPermissionResult {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

/// Extension para facilitar el uso
extension LocationPermissionResultExtension on LocationPermissionResult {
  bool get isGranted => this == LocationPermissionResult.granted;
  bool get isDenied => this == LocationPermissionResult.denied;
  bool get isDeniedForever => this == LocationPermissionResult.deniedForever;
  bool get isServiceDisabled => this == LocationPermissionResult.serviceDisabled;
  bool get isError => this == LocationPermissionResult.error;

  String get message {
    switch (this) {
      case LocationPermissionResult.granted:
        return 'Permisos de ubicación concedidos';
      case LocationPermissionResult.denied:
        return 'Permisos de ubicación denegados';
      case LocationPermissionResult.deniedForever:
        return 'Permisos de ubicación denegados permanentemente';
      case LocationPermissionResult.serviceDisabled:
        return 'Servicios de ubicación deshabilitados';
      case LocationPermissionResult.error:
        return 'Error al verificar permisos de ubicación';
    }
  }
}