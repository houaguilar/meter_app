
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/features/mapa/domain/entities/place_entity.dart';

abstract interface class PlaceRepository {

  Future<Either<Failure, List<PlaceEntity>>> getPlaceSuggestions(String input);
  Future<Either<Failure, PlaceEntity>> getPlaceDetails(String placeId);
  
}
