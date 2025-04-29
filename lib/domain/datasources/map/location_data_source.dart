import 'dart:io';

import '../../../data/models/map/location_model.dart';

abstract interface class LocationDataSource {

  Future<List<LocationModel>> loadLocations();
  Future<void> saveLocation(LocationModel location);
  Future<String> uploadImage(File image);
}