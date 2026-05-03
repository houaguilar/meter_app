
import 'package:fpdart/fpdart.dart';
import '../../../core/constants/error/failures.dart';
import '../../entities/map/place_entity.dart';

abstract interface class PlaceRepository {

  Future<Either<Failure, List<PlaceEntity>>> getPlaceSuggestions(String input);
  Future<Either<Failure, PlaceEntity>> getPlaceDetails(String placeId);
  
}
