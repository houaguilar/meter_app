import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../entities/map/location.dart';

abstract interface class LocationRepository {

  Future<Either<Failure, List<Location>>> getAllLocations();
  Future<Either<Failure, void>> saveLocation(Location location);
}