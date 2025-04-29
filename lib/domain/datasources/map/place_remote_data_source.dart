
import '../../../data/models/map/place_model.dart';

abstract interface class PlaceRemoteDataSource {
  Future<List<PlaceModel>> getPlaceSuggestions(String input);
  Future<PlaceModel> getPlaceDetails(String placeId);
}
