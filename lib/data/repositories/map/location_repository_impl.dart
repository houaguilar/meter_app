
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/network/connection_checker.dart';
import '../../../domain/datasources/map/location_data_source.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/repositories/map/location_repository.dart';
import '../../models/map/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource locationRemoteDataSource;
  final ConnectionChecker connectionChecker;

  LocationRepositoryImpl(
    this.locationRemoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<Location>>> getAllLocations() async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection', type: FailureType.general));
    }
    try {
      final locationModels = await locationRemoteDataSource.loadLocations();
      final locations = locationModels.map((model) => model as Location).toList();
      return right(locations);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocation(Location location) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection', type: FailureType.general));
    }
    try {
      final locationModel = LocationModel(
        id: location.id,
        title: location.title,
        description: location.description,
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        userId: location.userId,
      );
      await locationRemoteDataSource.saveLocation(locationModel);
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}