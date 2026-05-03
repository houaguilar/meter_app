
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/map/place_entity.dart';
import 'package:meter_app/domain/repositories/map/place_repository.dart';

class GetPlaceDetails implements UseCase<PlaceEntity, String> {
  final PlaceRepository repository;

  GetPlaceDetails(this.repository);

  @override
  Future<Either<Failure, PlaceEntity>> call(String placeId) async {
    return repository.getPlaceDetails(placeId);
  }
}
