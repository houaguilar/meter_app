
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/domain/entities/map/place_entity.dart';

abstract interface class PlaceRepository {

  Future<Either<Failure, List<PlaceEntity>>> getPlaceSuggestions(String input);
  Future<Either<Failure, PlaceEntity>> getPlaceDetails(String placeId);
  
}
