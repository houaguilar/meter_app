part of 'locations_bloc.dart';

@immutable
sealed class LocationsEvent {}

class LoadLocations extends LocationsEvent {}

class AddNewLocation extends LocationsEvent {
  final LocationMap location;

  AddNewLocation(this.location);
}

class UploadImageEvent extends LocationsEvent {
  final File image;

  UploadImageEvent(this.image);
}

final class LoadNearbyLocations extends LocationsEvent {
  final double userLat;
  final double userLng;
  final double radiusKm;
  final int maxResults;

  LoadNearbyLocations({
    required this.userLat,
    required this.userLng,
    this.radiusKm = 25.0,
    this.maxResults = 15,
  });
}

/// Verificar disponibilidad de PostGIS
final class CheckPostGISAvailabilityEvent extends LocationsEvent {}

/// Cargar ubicaciones por usuario
final class LoadLocationsByUser extends LocationsEvent {
  final String userId;

  LoadLocationsByUser(this.userId);
}

/// Eliminar ubicación
final class DeleteLocationEvent extends LocationsEvent {
  final String locationId;

  DeleteLocationEvent(this.locationId);
}

/// Refrescar ubicaciones cercanas con nueva posición
final class RefreshNearbyLocations extends LocationsEvent {
  final double userLat;
  final double userLng;
  final double radiusKm;

  RefreshNearbyLocations({
    required this.userLat,
    required this.userLng,
    this.radiusKm = 25.0,
  });
}