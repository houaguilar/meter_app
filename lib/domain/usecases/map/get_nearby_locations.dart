import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/map/location_with_distance.dart';
import '../../repositories/map/location_repository.dart';

class GetNearbyLocations implements UseCase<List<LocationWithDistance>, GetNearbyLocationsParams> {
  final LocationRepository repository;

  GetNearbyLocations(this.repository);

  @override
  Future<Either<Failure, List<LocationWithDistance>>> call(GetNearbyLocationsParams params) async {
    return await repository.getNearbyLocations(
      userLat: params.userLat,
      userLng: params.userLng,
      radiusKm: params.radiusKm,
      maxResults: params.maxResults,
    );
  }
}

class GetNearbyLocationsParams {
  final double userLat;
  final double userLng;
  final double radiusKm;
  final int maxResults;

  GetNearbyLocationsParams({
    required this.userLat,
    required this.userLng,
    this.radiusKm = 25.0,
    this.maxResults = 15,
  });
}
