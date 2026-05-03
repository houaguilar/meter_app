import 'package:fpdart/fpdart.dart';

import '../../../core/constants/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/map/location_repository.dart';

class CheckPostGISAvailability implements UseCase<bool, NoParams> {
  final LocationRepository repository;

  CheckPostGISAvailability(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkPostGISAvailability();
  }
}
