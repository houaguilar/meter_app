import 'package:dio/dio.dart';
import 'package:meter_app/domain/datasources/map/place_remote_data_source.dart';

import '../../models/map/place_model.dart';

class PlaceRemoteDataSourceImpl implements PlaceRemoteDataSource {
  final Dio dio;
  final String apiKey;

  PlaceRemoteDataSourceImpl({required this.dio, required this.apiKey});

  @override
  Future<List<PlaceModel>> getPlaceSuggestions(String input) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': apiKey,
          'components': 'country:pe',  // Ajusta esto según tu país o requerimientos
        },
      );

      if (response.statusCode == 200) {
        return (response.data['predictions'] as List)
            .map((e) => PlaceModel.fromJsonAutocomplete(e))
            .toList();
      } else {
        throw Exception("Failed to load suggestions: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('DioError Response: ${e.response}');
      } else {
        print('DioError Request: ${e.requestOptions}');
        print('DioError Message: ${e.message}');
      }
      throw Exception("Failed to load suggestions");
    } catch (e) {
      print('Error: $e');
      throw Exception("Failed to load suggestions");
    }
  }

  @override
  Future<PlaceModel> getPlaceDetails(String placeId) async {
    final response = await dio.get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': apiKey,
      },
    );
    if (response.statusCode == 200) {
      final location = response.data['result']['geometry']['location'];
      return PlaceModel.fromJsonDetails(response.data['result']);
    } else {
      throw Exception("Failed to load place details: ${response.statusCode}");
    }
  }
}
