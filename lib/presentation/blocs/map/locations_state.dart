
part of 'locations_bloc.dart';

@immutable
sealed class LocationsState {}

final class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsLoaded extends LocationsState {
  final List<Location> locations;

  LocationsLoaded(this.locations);
}

class LocationsError extends LocationsState {
  final String message;

  LocationsError(this.message);
}