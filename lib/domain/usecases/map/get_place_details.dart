
import 'package:fpdart/fpdart.dart';
import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/map/place_entity.dart';
import '../../repositories/map/place_repository.dart';

class GetPlaceDetails implements UseCase<PlaceEntity, String> {
  final PlaceRepository repository;

  GetPlaceDetails(this.repository);

  @override
  Future<Either<Failure, PlaceEntity>> call(String placeId) async {
    return repository.getPlaceDetails(placeId);
  }
}
