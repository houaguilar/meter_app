import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/mapa/domain/entities/location.dart';
import 'package:meter_app/features/mapa/domain/repositories/location_repository.dart';

class GetLocationsByUser implements UseCase<List<LocationMap>, String> {
  final LocationRepository repository;

  GetLocationsByUser(this.repository);

  @override
  Future<Either<Failure, List<LocationMap>>> call(String userId) async {
    return await repository.getLocationsByUser(userId);
  }
}