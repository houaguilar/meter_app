

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/core/constants/error/failures.dart';

import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/mapa/domain/entities/location.dart';
import 'package:meter_app/features/mapa/domain/repositories/location_repository.dart';

class GetAllLocations implements UseCase<List<LocationMap>, NoParams> {
  final LocationRepository repository;

  GetAllLocations(this.repository);

  @override
  Future<Either<Failure, List<LocationMap>>> call(NoParams params) async {
    return await repository.getAllLocations();
  }
}