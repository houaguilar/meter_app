import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';

class DeleteLocation implements UseCase<void, String> {
  final LocationRepository repository;

  DeleteLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(String locationId) async {
    return await repository.deleteLocation(locationId);
  }
}