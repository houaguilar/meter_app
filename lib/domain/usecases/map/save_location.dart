
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/map/location.dart';
import '../../repositories/map/location_repository.dart';

class SaveLocation implements UseCase<void, LocationMap> {
  final LocationRepository repository;

  SaveLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(LocationMap location) async {
    return await repository.saveLocation(location);
  }
}
