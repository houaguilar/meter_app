import '../../../domain/entities/map/place_entity.dart';

class PlaceModel extends PlaceEntity {
  PlaceModel({
    required super.placeId,
    required super.description,
    double? lat,
    double? lng,
  }) : super(
    lat: lat ?? 0.0,  // Valor predeterminado para autocomplete
    lng: lng ?? 0.0,
  );

  // Para Autocomplete (sin coordenadas)
  factory PlaceModel.fromJsonAutocomplete(Map<String, dynamic> json) {
    return PlaceModel(
      placeId: json['place_id'],  // Tomamos solo place_id y description
      description: json['description'],
    );
  }

  // Para Details (con coordenadas)
  factory PlaceModel.fromJsonDetails(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return PlaceModel(
      placeId: json['place_id'],
      description: json['formatted_address'],
      lat: location['lat'],
      lng: location['lng'],
    );
  }
}
