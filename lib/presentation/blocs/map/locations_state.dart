
part of 'locations_bloc.dart';

@immutable
sealed class LocationsState {}

final class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsLoaded extends LocationsState {
  final List<LocationMap> locations;

  LocationsLoaded(this.locations);
}

class LocationsSaving extends LocationsState {}

class LocationSaved extends LocationsState {}

class LocationsError extends LocationsState {
  final String message;

  LocationsError(this.message);
}

class ImageUploading extends LocationsState {}

class ImageUploaded extends LocationsState {
  final String imageUrl;

  ImageUploaded(this.imageUrl);
}

/// Estados para ubicaciones cercanas optimizadas
class NearbyLocationsLoading extends LocationsState {}

class NearbyLocationsLoaded extends LocationsState {
  final List<LocationWithDistance> nearbyLocations;
  final double userLat;
  final double userLng;
  final double radiusKm;
  final bool usingPostGIS;

  NearbyLocationsLoaded({
    required this.nearbyLocations,
    required this.userLat,
    required this.userLng,
    required this.radiusKm,
    this.usingPostGIS = false,
  });
}

class NearbyLocationsEmpty extends LocationsState {
  final double userLat;
  final double userLng;
  final double radiusKm;

  NearbyLocationsEmpty({
    required this.userLat,
    required this.userLng,
    required this.radiusKm,
  });
}

/// Estados para PostGIS
class PostGISChecking extends LocationsState {}

class PostGISAvailable extends LocationsState {
  final bool isAvailable;

  PostGISAvailable(this.isAvailable);
}

/// Estados para ubicaciones por usuario
class UserLocationsLoading extends LocationsState {}

class UserLocationsLoaded extends LocationsState {
  final List<LocationMap> userLocations;
  final String userId;

  UserLocationsLoaded({
    required this.userLocations,
    required this.userId,
  });
}

/// Estados para eliminación
class LocationDeleting extends LocationsState {}

class LocationDeleted extends LocationsState {
  final String deletedLocationId;

  LocationDeleted(this.deletedLocationId);
}

/// Estados para activar/desactivar ubicación
class LocationTogglingActive extends LocationsState {}

class LocationActiveToggled extends LocationsState {
  final String locationId;
  final bool isActive;

  LocationActiveToggled({
    required this.locationId,
    required this.isActive,
  });
}

/// Estados combinados para mejor UX
class LocationsRefreshing extends LocationsState {
  final List<LocationWithDistance>? previousNearbyLocations;

  LocationsRefreshing({this.previousNearbyLocations});
}

class LocationOperationSuccess extends LocationsState {
  final String message;
  final LocationsState? previousState;

  LocationOperationSuccess({
    required this.message,
    this.previousState,
  });
}