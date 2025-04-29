

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';

import '../../../config/usecase/usecase.dart';
import '../../entities/map/location.dart';
import '../../repositories/map/location_repository.dart';

class GetAllLocations implements UseCase<List<LocationMap>, NoParams> {
  final LocationRepository repository;

  GetAllLocations(this.repository);

  @override
  Future<Either<Failure, List<LocationMap>>> call(NoParams params) async {
    return await repository.getAllLocations();
  }
}