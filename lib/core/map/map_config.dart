// lib/config/map/map_config.dart
class MapConfig {
  MapConfig._();

  // Configuración de límites geográficos (Perú)
  static const double peruNorthLat = -0.0389;
  static const double peruSouthLat = -18.3479;
  static const double peruWestLng = -81.3867;
  static const double peruEastLng = -68.6650;

  // Lima como centro por defecto
  static const double defaultLat = -12.0464;
  static const double defaultLng = -77.0428;
  static const double defaultZoom = 11.0;

  // Configuración de optimización mejorada
  static const int maxCacheSize = 100; // Aumentado para mejor cache
  static const Duration cacheValidDuration = Duration(minutes: 15); // Más tiempo de cache
  static const Duration rateLimitDuration = Duration(milliseconds: 200); // Más responsive
  static const int minSearchLength = 3;
  static const Duration searchDebounce = Duration(milliseconds: 400); // Más responsive

  // Configuración de ubicación
  static const int locationUpdateDistance = 50;
  static const Duration locationTimeout = Duration(seconds: 10);

  // Configuración de marcadores
  static const double markerIconSize = 40.0;
  static const double userMarkerSize = 50.0;

  // Configuración de UI
  static const double searchBarHeight = 56.0;
  static const double providersListHeight = 280.0;
  static const double mapPadding = 16.0;

  // NUEVAS CONFIGURACIONES PARA MEJORAR LA BÚSQUEDA

  // Configuración de idioma y región
  static const String language = 'es';
  static const String region = 'PE';
  static const String countryRestriction = 'country:pe';

  // Configuración de tipos de búsqueda mejorada
  static const List<String> searchTypes = [
    'address',          // Direcciones completas
    'establishment',    // Establecimientos
    'geocode',         // Códigos geográficos
  ];

  // Tipos de lugar principales para el autocompletado
  static const List<String> primaryPlaceTypes = [
    'street_address',
    'route',
    'neighborhood',
    'locality',
    'sublocality',
    'administrative_area_level_1',
    'administrative_area_level_2',
  ];

  // Configuración de campos para optimizar llamadas API
  static const String autocompleteFields = 'place_id,description,structured_formatting';
  static const String detailsFields = 'place_id,formatted_address,geometry,name,types,address_components';

  // Configuración de radio de búsqueda específica por tipo
  static const Map<String, double> searchRadiusByType = {
    'address': 100000,      // 100km para direcciones
    'establishment': 50000,  // 50km para establecimientos
    'geocode': 150000,      // 150km para geocoding
  };

  // Configuración de session tokens (para optimizar costos de Google API)
  static const Duration sessionTokenDuration = Duration(minutes: 3);

  // Configuración específica para Perú
  static const Map<String, String> peruSpecificConfig = {
    'bounds': '-18.3479,-81.3867|-0.0389,-68.6650', // Límites de Perú
    'strictbounds': 'false', // Permitir resultados fuera pero priorizar dentro
    'region': 'pe',
    'language': 'es',
  };

  // Configuración de filtros de texto para mejorar relevancia
  static const List<String> commonPeruvianTerms = [
    'av\\.', 'avenida', 'av',
    'jr\\.', 'jirón', 'jr',
    'ca\\.', 'calle', 'ca',
    'psje\\.', 'pasaje', 'psje',
    'urb\\.', 'urbanización', 'urb',
    'dist\\.', 'distrito', 'dist',
    'prov\\.', 'provincia', 'prov',
    'dpto\\.', 'departamento', 'dpto',
    'mz\\.', 'manzana', 'mz',
    'lt\\.', 'lote', 'lt',
  ];

  // Configuración de timeout para requests
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Configuración de retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Configuración de logging para debugging
  static const bool enableApiLogging = true;
  static const bool enableCacheLogging = false;
  static const bool enablePerformanceLogging = true;

  // Método para obtener configuración de autocomplete específica para Perú
  static Map<String, dynamic> getAutocompleteConfig({
    String? location,
    double? radius,
    String? types,
  }) {
    return {
      'components': countryRestriction,
      'language': language,
      'region': region,
      'types': types ?? 'address',
      if (location != null) 'location': location,
      if (radius != null) 'radius': radius.toString(),
      'strictbounds': 'false',
    };
  }

  // Método para obtener configuración de place details
  static Map<String, dynamic> getPlaceDetailsConfig() {
    return {
      'fields': detailsFields,
      'language': language,
      'region': region,
    };
  }

  // Método para validar si una query es válida para búsqueda
  static bool isValidSearchQuery(String query) {
    if (query.trim().length < minSearchLength) return false;

    // Verificar que no sea solo espacios o caracteres especiales
    if (query.trim().replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').isEmpty) {
      return false;
    }

    return true;
  }

  // Método para normalizar queries de búsqueda
  static String normalizeSearchQuery(String query) {
    return query
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ') // Eliminar espacios múltiples
        .replaceAll(RegExp(r'[^\w\s,.-]'), ''); // Mantener solo caracteres válidos
  }

  // Método para obtener sugerencias de mejora de query
  static List<String> getQuerySuggestions(String originalQuery) {
    final suggestions = <String>[];
    final normalized = normalizeSearchQuery(originalQuery);

    // Sugerencias específicas para direcciones peruanas
    if (!normalized.contains('lima') && !normalized.contains('distrito')) {
      suggestions.add('$originalQuery, Lima');
    }

    if (!normalized.contains(',')) {
      suggestions.add('$originalQuery, distrito');
    }

    // Agregar prefijos comunes si no están presentes
    for (final term in commonPeruvianTerms) {
      if (normalized.startsWith(term.replaceAll('\\.', ''))) {
        continue; // Ya tiene el prefijo
      }
      if (RegExp(r'^\d+').hasMatch(normalized)) {
        suggestions.add('$term $originalQuery');
        break;
      }
    }

    return suggestions.take(3).toList();
  }
}