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