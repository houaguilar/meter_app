import 'package:meter_app/domain/entities/perfil/location/country.dart';

/// Configuración de ubicación para un país específico
/// Define los labels personalizados para cada nivel administrativo
class LocationConfig {
  final Country country;
  final String level2Label;      // Ej: "Departamento", "Estado"
  final String level2LabelPlural; // Ej: "Departamentos", "Estados"
  final String level3Label;      // Ej: "Provincia", "Municipio", "Município"
  final String level3LabelPlural;
  final String level4Label;      // Ej: "Distrito", "Corregimiento"
  final String level4LabelPlural;
  final bool level4Optional;     // Si el nivel 4 es opcional

  const LocationConfig({
    required this.country,
    required this.level2Label,
    required this.level2LabelPlural,
    required this.level3Label,
    required this.level3LabelPlural,
    required this.level4Label,
    required this.level4LabelPlural,
    this.level4Optional = false,
  });

  /// Configuración para Perú 🇵🇪
  static const LocationConfig peru = LocationConfig(
    country: Country(code: 'PE', name: 'Perú', flag: '🇵🇪'),
    level2Label: 'Departamento',
    level2LabelPlural: 'Departamentos',
    level3Label: 'Provincia',
    level3LabelPlural: 'Provincias',
    level4Label: 'Distrito',
    level4LabelPlural: 'Distritos',
    level4Optional: false,
  );

  /// Configuración para Colombia 🇨🇴
  static const LocationConfig colombia = LocationConfig(
    country: Country(code: 'CO', name: 'Colombia', flag: '🇨🇴'),
    level2Label: 'Departamento',
    level2LabelPlural: 'Departamentos',
    level3Label: 'Municipio',
    level3LabelPlural: 'Municipios',
    level4Label: 'Corregimiento',
    level4LabelPlural: 'Corregimientos',
    level4Optional: true, // Corregimiento es opcional
  );

  /// Configuración para México 🇲🇽
  static const LocationConfig mexico = LocationConfig(
    country: Country(code: 'MX', name: 'México', flag: '🇲🇽'),
    level2Label: 'Estado',
    level2LabelPlural: 'Estados',
    level3Label: 'Municipio',
    level3LabelPlural: 'Municipios',
    level4Label: 'Colonia',
    level4LabelPlural: 'Colonias',
    level4Optional: true, // Colonia es opcional
  );

  /// Obtiene la configuración por código de país
  static LocationConfig? fromCountryCode(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'PE':
        return peru;
      case 'CO':
        return colombia;
      case 'MX':
        return mexico;
      default:
        return null;
    }
  }

  /// Lista de todas las configuraciones disponibles
  static const List<LocationConfig> all = [
    peru,
    colombia,
    mexico,
  ];

  @override
  String toString() => 'LocationConfig(country: ${country.name})';
}
