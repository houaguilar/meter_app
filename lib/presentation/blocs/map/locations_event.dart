part of 'locations_bloc.dart';

@immutable
sealed class LocationsEvent {}

class LoadLocations extends LocationsEvent {}

class AddNewLocation extends LocationsEvent {
  final Location location;

  AddNewLocation(this.location);
}