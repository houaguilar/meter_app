import 'dart:io';

import '../../../data/models/map/location_model.dart';
import '../../../data/models/map/location_model_with_distance.dart';

abstract interface class LocationDataSource {

  /// Cargar todas las ubicaciones
  Future<List<LocationModel>> loadLocations();

  /// Cargar ubicaciones cercanas con PostGIS
  Future<List<LocationModelWithDistance>> loadNearbyLocations({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    int maxResults = 15,
  });

  /// Guardar nueva ubicación
  Future<void> saveLocation(LocationModel location);

  /// Subir imagen de ubicación
  Future<String> uploadImage(File image);

  /// Verificar si PostGIS está disponible
  Future<bool> isPostGISAvailable();

  /// Configurar PostGIS
  Future<bool> setupPostGIS();

  /// Obtener ubicaciones por usuario específico
  Future<List<LocationModel>> getLocationsByUser(String userId);

  /// Eliminar una ubicación
  Future<void> deleteLocation(String locationId);
}