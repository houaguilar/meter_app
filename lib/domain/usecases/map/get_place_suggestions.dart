
import 'package:fpdart/fpdart.dart';

import '../../../core/constants/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/map/place_entity.dart';
import '../../repositories/map/place_repository.dart';

class GetPlaceSuggestions implements UseCase<List<PlaceEntity>, String> {
  final PlaceRepository repository;

  GetPlaceSuggestions(this.repository);

  @override
  Future<Either<Failure, List<PlaceEntity>>> call(String input) async {
    return repository.getPlaceSuggestions(input);
  }
}
