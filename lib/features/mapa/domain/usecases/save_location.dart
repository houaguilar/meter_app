
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/mapa/domain/entities/location.dart';
import 'package:meter_app/features/mapa/domain/repositories/location_repository.dart';

class SaveLocation implements UseCase<void, LocationMap> {
  final LocationRepository repository;

  SaveLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(LocationMap location) async {
    return await repository.saveLocation(location);
  }
}
