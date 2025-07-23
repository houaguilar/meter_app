// lib/data/datasources/map/place_remote_data_source_impl.dart
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
          'components': 'country:pe',
          'language': 'es',
          'region': 'pe',
          'types': 'address',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Verificar si hay errores en la respuesta de Google
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          print(
              'Google Places API Error: ${data['status']} - ${data['error_message'] ??
                  'Unknown error'}');

          // Manejar errores específicos
          switch (data['status']) {
            case 'OVER_QUERY_LIMIT':
              throw Exception(
                  "Límite de consultas excedido. Inténtelo más tarde.");
            case 'REQUEST_DENIED':
              throw Exception(
                  "Solicitud denegada. Verifique la configuración de la API key.");
            case 'INVALID_REQUEST':
              throw Exception("Solicitud inválida. Verifique los parámetros.");
            default:
              throw Exception("Error del servicio: ${data['status']}");
          }
        }

        // Si no hay resultados, retornar lista vacía en lugar de error
        if (data['status'] == 'ZERO_RESULTS') {
          return [];
        }

        return (data['predictions'] as List)
            .map((e) => PlaceModel.fromJsonAutocomplete(e))
            .toList();
      } else {
        throw Exception("Failed to load suggestions: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Mejorar el manejo de errores de red
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            "Tiempo de conexión agotado. Verifique su conexión a internet.");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Tiempo de respuesta agotado. Inténtelo nuevamente.");
      } else if (e.response != null) {
        print('DioError Response: ${e.response}');
        throw Exception("Error del servidor: ${e.response?.statusCode}");
      } else {
        print('DioError Request: ${e.requestOptions}');
        print('DioError Message: ${e.message}');
        throw Exception("Error de conexión. Verifique su conexión a internet.");
      }
    } catch (e) {
      print('Error general en getPlaceSuggestions: $e');
      throw Exception("Error inesperado: ${e.toString()}");
    }
  }

  @override
  Future<PlaceModel> getPlaceDetails(String placeId) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': apiKey,
          'language': 'es',
          'region': 'pe',
          'fields': 'place_id,formatted_address,geometry,name,types,address_components',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Verificar errores en la respuesta
        if (data['status'] != 'OK') {
          print(
              'Google Places Details API Error: ${data['status']} - ${data['error_message'] ??
                  'Unknown error'}');
          throw Exception("Error al obtener detalles: ${data['status']}");
        }

        return PlaceModel.fromJsonDetails(data['result']);
      } else {
        throw Exception("Failed to load place details: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            "Tiempo de conexión agotado. Verifique su conexión a internet.");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Tiempo de respuesta agotado. Inténtelo nuevamente.");
      } else if (e.response != null) {
        throw Exception("Error del servidor: ${e.response?.statusCode}");
      } else {
        throw Exception("Error de conexión. Verifique su conexión a internet.");
      }
    } catch (e) {
      print('Error general en getPlaceDetails: $e');
      throw Exception("Error inesperado: ${e.toString()}");
    }
  }
}