import 'brasil_location_repository.dart';
import 'colombia_location_repository.dart';
import 'location_repository.dart';
import 'peru_location_repository_v2.dart';

/// Factory para crear instancias de LocationRepository según el código de país
/// Uso: LocationRepositoryFactory.create('PE') → PeruLocationRepositoryV2
class LocationRepositoryFactory {
  /// Crea un repositorio de ubicación basado en el código de país
  /// Códigos soportados: PE (Perú), CO (Colombia), BR (Brasil)
  static LocationRepository create(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'PE':
        return PeruLocationRepositoryV2();
      case 'CO':
        return ColombiaLocationRepository();
      case 'BR':
        return BrasilLocationRepository();
      default:
        throw UnsupportedError(
            'País no soportado: $countryCode. '
                'Países disponibles: PE, CO, BR',
        );
    }
  }

  /// Obtiene todos los códigos de países soportados
  static List<String> getSupportedCountryCodes() {
    return ['PE', 'CO', 'BR'];
  }

  /// Verifica si un código de país está soportado
  static bool isSupported(String countryCode) {
    return getSupportedCountryCodes()
        .contains(countryCode.toUpperCase());
  }

  /// Obtiene la lista de todos los repositorios disponibles
  static List<LocationRepository> getAllRepositories() {
    return [
      PeruLocationRepositoryV2(),
      ColombiaLocationRepository(),
      BrasilLocationRepository(),
    ];
  }
}
