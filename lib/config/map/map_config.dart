
class MapConfig {
  MapConfig._();

  // Configuración de Google Maps API
  static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Reemplazar con tu API key

  // Configuración de límites geográficos (Perú)
  static const double peruNorthLat = -0.0389;
  static const double peruSouthLat = -18.3479;
  static const double peruWestLng = -81.3867;
  static const double peruEastLng = -68.6650;

  // Lima como centro por defecto
  static const double defaultLat = -12.0464;
  static const double defaultLng = -77.0428;
  static const double defaultZoom = 11.0;

  // Configuración de optimización
  static const int maxCacheSize = 50;
  static const Duration cacheValidDuration = Duration(minutes: 10);
  static const Duration rateLimitDuration = Duration(milliseconds: 300);
  static const int minSearchLength = 3;
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Configuración de ubicación
  static const int locationUpdateDistance = 50; // metros
  static const Duration locationTimeout = Duration(seconds: 10);

  // Configuración de marcadores
  static const double markerIconSize = 40.0;
  static const double userMarkerSize = 50.0;

  // Configuración de UI
  static const double searchBarHeight = 56.0;
  static const double providersListHeight = 280.0;
  static const double mapPadding = 16.0;

  // Configuración de tipos de lugar (para filtros futuros)
  static const List<String> supportedPlaceTypes = [
    'hardware_store',
    'home_goods_store',
    'store',
    'establishment',
  ];

  // Configuración de idioma
  static const String language = 'es';
  static const String region = 'PE';

  // Configuración de componentes para restringir a Perú
  static const String countryRestriction = 'country:pe';

  // Configuración de campos para optimizar llamadas API
  static const String autocompleteFields = 'place_id,description';
  static const String detailsFields = 'place_id,formatted_address,geometry';

  // Configuración de tipos de entrada de búsqueda
  static const List<String> searchInputTypes = [
    'address',
    'establishment',
    'geocode',
  ];

  // Configuración de radio de búsqueda (metros)
  static const double searchRadius = 50000; // 50km

  // URLs de respaldo para cuando Google Maps falle
  static const String fallbackGeocodingProvider = 'nominatim';
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  // Configuración de analytics
  static const bool enableAnalytics = true;
  static const Duration analyticsReportInterval = Duration(hours: 1);

  // Validaciones
  static bool isValidLatLng(double lat, double lng) {
    return lat >= peruSouthLat &&
        lat <= peruNorthLat &&
        lng >= peruWestLng &&
        lng <= peruEastLng;
  }

  static bool isValidSearchQuery(String query) {
    return query.trim().length >= minSearchLength;
  }

  // Métodos de utilidad
  static Map<String, dynamic> getAutocompleteParams(String input) {
    return {
      'input': input,
      'key': apiKey,
      'components': countryRestriction,
      'language': language,
      'region': region,
      'types': searchInputTypes.join('|'),
    };
  }

  static Map<String, dynamic> getDetailsParams(String placeId) {
    return {
      'place_id': placeId,
      'key': apiKey,
      'fields': detailsFields,
      'language': language,
      'region': region,
    };
  }
}