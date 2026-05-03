
import 'package:meter_app/features/mapa/data/models/place_model.dart';

abstract interface class PlaceRemoteDataSource {
  Future<List<PlaceModel>> getPlaceSuggestions(String input);
  Future<PlaceModel> getPlaceDetails(String placeId);
}
