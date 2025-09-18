import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/map/location.dart';
import '../../repositories/map/location_repository.dart';

class GetLocationsByUser implements UseCase<List<LocationMap>, String> {
  final LocationRepository repository;

  GetLocationsByUser(this.repository);

  @override
  Future<Either<Failure, List<LocationMap>>> call(String userId) async {
    return await repository.getLocationsByUser(userId);
  }
}