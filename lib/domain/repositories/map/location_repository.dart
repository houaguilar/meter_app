import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../entities/map/location.dart';
import '../../entities/map/location_with_distance.dart';

abstract interface class LocationRepository {

  /// Obtener todas las ubicaciones
  Future<Either<Failure, List<LocationMap>>> getAllLocations();

  /// Obtener ubicaciones cercanas optimizadas
  Future<Either<Failure, List<LocationWithDistance>>> getNearbyLocations({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    int maxResults = 15,
  });

  /// Guardar nueva ubicación
  Future<Either<Failure, void>> saveLocation(LocationMap location);

  /// Subir imagen de ubicación
  Future<Either<Failure, String>> uploadImage(File image);

  /// Verificar si PostGIS está disponible
  Future<Either<Failure, bool>> checkPostGISAvailability();

  /// Obtener ubicaciones por usuario
  Future<Either<Failure, List<LocationMap>>> getLocationsByUser(String userId);

  /// Eliminar ubicación
  Future<Either<Failure, void>> deleteLocation(String locationId);
}