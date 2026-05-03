// lib/data/repositories/location/colombia_location_repository.dart

import 'package:meter_app/domain/entities/perfil/location/administrative_level_2.dart';
import 'package:meter_app/domain/entities/perfil/location/administrative_level_3.dart';
import 'package:meter_app/domain/entities/perfil/location/administrative_level_4.dart';
import 'package:meter_app/domain/entities/perfil/location/country.dart';
import 'package:meter_app/domain/entities/perfil/location/location_config.dart';
import 'package:meter_app/domain/repositories/perfil/location/location_repository.dart';

/// Repositorio de ubicaciones de Colombia 🇨🇴
/// Colombia tiene 32 departamentos, 1,102 municipios
class ColombiaLocationRepository extends LocationRepository {
  @override
  LocationConfig get config => LocationConfig.colombia;

  /// Datos de Colombia con departamentos, municipios y corregimientos
  /// Estructura: {Departamento: {Municipio: [Corregimientos]}}
  /// NOTA: Los datos aquí son de ejemplo. Debes reemplazarlos con datos reales completos.
  static const Map<String, Map<String, List<String>>> _colombiaData = {
    'AMAZONAS': {
      'Leticia': [
        'El Encanto',
        'La Chorrera',
        'La Pedrera',
        'La Victoria',
        'Mirití-Paraná',
        'Puerto Alegría',
        'Puerto Arica',
        'Puerto Nariño',
        'Puerto Santander',
        'Tarapacá',
      ],
    },
    'ANTIOQUIA': {
      'Medellín': [
        'Altavista',
        'San Antonio de Prado',
        'San Cristóbal',
        'Palmitas',
        'Santa Elena',
      ],
      'Bello': ['Bello Centro'],
      'Itagüí': ['Itagüí Centro'],
      'Envigado': ['Envigado Centro'],
      'Rionegro': ['Aeropuerto José María Córdova'],
    },
    'ATLÁNTICO': {
      'Barranquilla': [
        'La Playa',
        'Las Flores',
        'Juan Mina',
      ],
      'Soledad': ['Soledad Centro'],
      'Malambo': ['Malambo Centro'],
    },
    'BOGOTÁ D.C.': {
      'Bogotá': [
        'Usaquén',
        'Chapinero',
        'Santa Fe',
        'San Cristóbal',
        'Usme',
        'Tunjuelito',
        'Bosa',
        'Kennedy',
        'Fontibón',
        'Engativá',
        'Suba',
        'Barrios Unidos',
        'Teusaquillo',
        'Los Mártires',
        'Antonio Nariño',
        'Puente Aranda',
        'La Candelaria',
        'Rafael Uribe Uribe',
        'Ciudad Bolívar',
        'Sumapaz',
      ],
    },
    'BOLÍVAR': {
      'Cartagena': [
        'Ararca',
        'Bayunca',
        'Pasacaballos',
        'Santa Ana',
        'Tierra Baja',
      ],
      'Magangué': ['Magangué Centro'],
    },
    'BOYACÁ': {
      'Tunja': ['Tunja Centro'],
      'Duitama': ['Duitama Centro'],
      'Sogamoso': ['Sogamoso Centro'],
    },
    'CALDAS': {
      'Manizales': ['Manizales Centro'],
      'Villamaría': ['Villamaría Centro'],
    },
    'CAQUETÁ': {
      'Florencia': ['Florencia Centro'],
    },
    'CASANARE': {
      'Yopal': ['Yopal Centro'],
    },
    'CAUCA': {
      'Popayán': ['Popayán Centro'],
    },
    'CESAR': {
      'Valledupar': ['Valledupar Centro'],
    },
    'CHOCÓ': {
      'Quibdó': ['Quibdó Centro'],
    },
    'CÓRDOBA': {
      'Montería': ['Montería Centro'],
    },
    'CUNDINAMARCA': {
      'Soacha': ['Soacha Centro'],
      'Facatativá': ['Facatativá Centro'],
      'Zipaquirá': ['Zipaquirá Centro'],
      'Chía': ['Chía Centro'],
      'Mosquera': ['Mosquera Centro'],
      'Fusagasugá': ['Fusagasugá Centro'],
    },
    'GUAINÍA': {
      'Inírida': ['Inírida Centro'],
    },
    'GUAVIARE': {
      'San José del Guaviare': ['San José Centro'],
    },
    'HUILA': {
      'Neiva': ['Neiva Centro'],
    },
    'LA GUAJIRA': {
      'Riohacha': ['Riohacha Centro'],
    },
    'MAGDALENA': {
      'Santa Marta': ['Santa Marta Centro'],
    },
    'META': {
      'Villavicencio': ['Villavicencio Centro'],
    },
    'NARIÑO': {
      'Pasto': ['Pasto Centro'],
    },
    'NORTE DE SANTANDER': {
      'Cúcuta': ['Cúcuta Centro'],
    },
    'PUTUMAYO': {
      'Mocoa': ['Mocoa Centro'],
    },
    'QUINDÍO': {
      'Armenia': ['Armenia Centro'],
    },
    'RISARALDA': {
      'Pereira': ['Pereira Centro'],
      'Dosquebradas': ['Dosquebradas Centro'],
    },
    'SAN ANDRÉS Y PROVIDENCIA': {
      'San Andrés': ['San Andrés Centro'],
      'Providencia': ['Providencia Centro'],
    },
    'SANTANDER': {
      'Bucaramanga': ['Bucaramanga Centro'],
      'Floridablanca': ['Floridablanca Centro'],
      'Girón': ['Girón Centro'],
      'Piedecuesta': ['Piedecuesta Centro'],
    },
    'SUCRE': {
      'Sincelejo': ['Sincelejo Centro'],
    },
    'TOLIMA': {
      'Ibagué': ['Ibagué Centro'],
    },
    'VALLE DEL CAUCA': {
      'Cali': [
        'Cali Centro',
        'Aguablanca',
        'Pance',
      ],
      'Palmira': ['Palmira Centro'],
      'Buenaventura': ['Buenaventura Centro'],
      'Tuluá': ['Tuluá Centro'],
      'Jamundí': ['Jamundí Centro'],
    },
    'VAUPÉS': {
      'Mitú': ['Mitú Centro'],
    },
    'VICHADA': {
      'Puerto Carreño': ['Puerto Carreño Centro'],
    },
  };

  @override
  Country getCountry() => config.country;

  @override
  List<AdministrativeLevel2> getLevel2() {
    return _colombiaData.keys
        .map((key) => AdministrativeLevel2(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel3> getLevel3(String level2Code) {
    final level2Data = _colombiaData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    return level2Data.keys
        .map((key) => AdministrativeLevel3(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel4> getLevel4(String level2Code, String level3Code) {
    final level2Data = _colombiaData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    final corregimientos = level2Data[level3Code];
    if (corregimientos == null) return [];

    return corregimientos
        .map((name) => AdministrativeLevel4(code: name, name: name))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
