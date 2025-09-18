import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/network/connection_checker.dart';
import '../../../domain/datasources/map/location_data_source.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/entities/map/location_with_distance.dart';
import '../../../domain/repositories/map/location_repository.dart';
import '../../models/map/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource locationRemoteDataSource;
  final ConnectionChecker connectionChecker;

  LocationRepositoryImpl(
      this.locationRemoteDataSource,
      this.connectionChecker,
      );

  @override
  Future<Either<Failure, List<LocationMap>>> getAllLocations() async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection', type: FailureType.general));
    }
    try {
      final locationModels = await locationRemoteDataSource.loadLocations();
      final locations = locationModels.map((model) => model as LocationMap).toList();
      return right(locations);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  /// 🚀 NUEVO: Obtener ubicaciones cercanas optimizadas
  @override
  Future<Either<Failure, List<LocationWithDistance>>> getNearbyLocations({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    int maxResults = 15,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      // Validar coordenadas de entrada
      if (userLat.abs() > 90 || userLng.abs() > 180) {
        return left(Failure(
          message: 'Coordenadas inválidas: lat=$userLat, lng=$userLng',
          type: FailureType.validation,
        ));
      }

      if (radiusKm <= 0 || radiusKm > 1000) {
        return left(Failure(
          message: 'Radio debe estar entre 1 y 1000 km',
          type: FailureType.validation,
        ));
      }

      // Llamar al datasource optimizado
      final locationModels = await locationRemoteDataSource.loadNearbyLocations(
        userLat: userLat,
        userLng: userLng,
        radiusKm: radiusKm,
        maxResults: maxResults,
      );

      // Convertir a entidades de dominio
      final locations = locationModels
          .map((model) => model.toLocationWithDistance())
          .toList();

      return right(locations);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener ubicaciones cercanas: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocation(LocationMap location) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection', type: FailureType.general));
    }
    try {
      final locationModel = LocationModel(
        id: location.id,
        title: location.title,
        description: location.description,
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        userId: location.userId,
        imageUrl: location.imageUrl,
        createdAt: location.createdAt,
      );
      await locationRemoteDataSource.saveLocation(locationModel);
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection'));
    }
    try {
      final imageUrl = await locationRemoteDataSource.uploadImage(image);
      return right(imageUrl);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  /// 🔧 NUEVO: Verificar disponibilidad de PostGIS
  @override
  Future<Either<Failure, bool>> checkPostGISAvailability() async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final isAvailable = await locationRemoteDataSource.isPostGISAvailable();
      return right(isAvailable);
    } catch (e) {
      return left(Failure(
        message: 'Error verificando PostGIS: $e',
        type: FailureType.server,
      ));
    }
  }

  /// 📍 NUEVO: Obtener ubicaciones por usuario
  @override
  Future<Either<Failure, List<LocationMap>>> getLocationsByUser(String userId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      if (userId.trim().isEmpty) {
        return left(Failure(
          message: 'ID de usuario no puede estar vacío',
          type: FailureType.validation,
        ));
      }

      final locationModels = await locationRemoteDataSource.getLocationsByUser(userId);
      final locations = locationModels.map((model) => model as LocationMap).toList();

      return right(locations);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener ubicaciones del usuario: $e',
        type: FailureType.server,
      ));
    }
  }

  /// 🗑️ NUEVO: Eliminar ubicación
  @override
  Future<Either<Failure, void>> deleteLocation(String locationId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      if (locationId.trim().isEmpty) {
        return left(Failure(
          message: 'ID de ubicación no puede estar vacío',
          type: FailureType.validation,
        ));
      }

      await locationRemoteDataSource.deleteLocation(locationId);
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al eliminar ubicación: $e',
        type: FailureType.server,
      ));
    }
  }
}