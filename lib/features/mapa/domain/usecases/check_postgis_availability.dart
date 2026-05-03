import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/mapa/domain/repositories/location_repository.dart';

class CheckPostGISAvailability implements UseCase<bool, NoParams> {
  final LocationRepository repository;

  CheckPostGISAvailability(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkPostGISAvailability();
  }
}
