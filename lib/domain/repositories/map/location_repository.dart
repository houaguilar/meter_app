import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../entities/map/location.dart';

abstract interface class LocationRepository {

  Future<Either<Failure, List<LocationMap>>> getAllLocations();
  Future<Either<Failure, void>> saveLocation(LocationMap location);
  Future<Either<Failure, String>> uploadImage(File image);

}