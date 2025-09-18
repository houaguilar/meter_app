import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../repositories/map/location_repository.dart';

class DeleteLocation implements UseCase<void, String> {
  final LocationRepository repository;

  DeleteLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(String locationId) async {
    return await repository.deleteLocation(locationId);
  }
}