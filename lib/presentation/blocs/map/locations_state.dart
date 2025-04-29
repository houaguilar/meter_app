
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
