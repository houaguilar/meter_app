
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/map/place_entity.dart';
import 'package:meter_app/domain/repositories/map/place_repository.dart';

class GetPlaceSuggestions implements UseCase<List<PlaceEntity>, String> {
  final PlaceRepository repository;

  GetPlaceSuggestions(this.repository);

  @override
  Future<Either<Failure, List<PlaceEntity>>> call(String input) async {
    return repository.getPlaceSuggestions(input);
  }
}
