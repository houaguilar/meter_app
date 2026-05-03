import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/map/location_with_distance.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';

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
