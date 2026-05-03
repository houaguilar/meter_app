// lib/data/repositories/location/mexico_location_repository.dart

import '../../../../domain/entities/perfil/location/administrative_level_2.dart';
import '../../../../domain/entities/perfil/location/administrative_level_3.dart';
import '../../../../domain/entities/perfil/location/administrative_level_4.dart';
import '../../../../domain/entities/perfil/location/country.dart';
import '../../../../domain/entities/perfil/location/location_config.dart';
import '../../../../domain/repositories/perfil/location/location_repository.dart';

/// Repositorio de ubicaciones de México 🇲🇽
/// México tiene 32 estados (31 estados + Ciudad de México), 2,469 municipios
class MexicoLocationRepository extends LocationRepository {
  @override
  LocationConfig get config => LocationConfig.mexico;

  /// Datos de México con estados, municipios y colonias
  /// Estructura: {Estado: {Municipio: [Colonias]}}
  /// NOTA: Los datos aquí son de ejemplo. Debes reemplazarlos con datos reales completos.
  static const Map<String, Map<String, List<String>>> _mexicoData = {
    'AGUASCALIENTES': {
      'Aguascalientes': ['Centro', 'Zona Dorada', 'Ferronales'],
      'Calvillo': ['Centro'],
      'Jesús María': ['Centro'],
    },
    'BAJA CALIFORNIA': {
      'Tijuana': ['Centro', 'Zona Río', 'Playas de Tijuana'],
      'Mexicali': ['Centro', 'Nueva Mexicali'],
      'Ensenada': ['Centro'],
      'Tecate': ['Centro'],
    },
    'BAJA CALIFORNIA SUR': {
      'La Paz': ['Centro', 'El Manglito'],
      'Los Cabos': ['Centro', 'San José del Cabo'],
      'Loreto': ['Centro'],
    },
    'CAMPECHE': {
      'Campeche': ['Centro Histórico', 'Área Ah Kim Pech'],
      'Ciudad del Carmen': ['Centro'],
      'Champotón': ['Centro'],
    },
    'CHIAPAS': {
      'Tuxtla Gutiérrez': ['Centro', 'Terán', 'Las Palmas'],
      'San Cristóbal de las Casas': ['Centro', 'La Merced'],
      'Tapachula': ['Centro'],
      'Comitán de Domínguez': ['Centro'],
    },
    'CHIHUAHUA': {
      'Chihuahua': ['Centro', 'San Felipe', 'Nombre de Dios'],
      'Ciudad Juárez': ['Centro', 'Partido Romero'],
      'Delicias': ['Centro'],
      'Cuauhtémoc': ['Centro'],
    },
    'CIUDAD DE MÉXICO': {
      'Cuauhtémoc': ['Centro Histórico', 'Condesa', 'Roma Norte', 'Juárez'],
      'Miguel Hidalgo': ['Polanco', 'Anzures', 'Lomas de Chapultepec'],
      'Benito Juárez': ['Del Valle', 'Narvarte', 'Portales'],
      'Coyoacán': ['Villa Coyoacán', 'Del Carmen'],
      'Álvaro Obregón': ['San Ángel'],
      'Tlalpan': ['Tlalpan Centro'],
      'Iztapalapa': ['Iztapalapa Centro'],
      'Gustavo A. Madero': ['Lindavista', 'La Villa'],
      'Venustiano Carranza': ['Moctezuma'],
      'Azcapotzalco': ['Azcapotzalco Centro'],
    },
    'COAHUILA': {
      'Saltillo': ['Centro', 'República Oriente'],
      'Torreón': ['Centro', 'Torreón Jardín'],
      'Monclova': ['Centro'],
      'Piedras Negras': ['Centro'],
    },
    'COLIMA': {
      'Colima': ['Centro', 'Las Víboras'],
      'Manzanillo': ['Centro', 'Las Brisas'],
      'Tecomán': ['Centro'],
    },
    'DURANGO': {
      'Durango': ['Centro', 'Zona Dorada'],
      'Gómez Palacio': ['Centro'],
      'Lerdo': ['Centro'],
    },
    'GUANAJUATO': {
      'León': ['Centro', 'Jardines del Moral'],
      'Guanajuato': ['Centro Histórico', 'Marfil'],
      'Celaya': ['Centro'],
      'Irapuato': ['Centro'],
      'Salamanca': ['Centro'],
      'San Miguel de Allende': ['Centro'],
    },
    'GUERRERO': {
      'Acapulco de Juárez': ['Centro', 'Costera Miguel Alemán', 'Icacos'],
      'Chilpancingo de los Bravo': ['Centro'],
      'Zihuatanejo de Azueta': ['Centro', 'Zihuatanejo'],
      'Iguala de la Independencia': ['Centro'],
    },
    'HIDALGO': {
      'Pachuca de Soto': ['Centro', 'Zona Plateada'],
      'Tulancingo de Bravo': ['Centro'],
      'Tula de Allende': ['Centro'],
    },
    'JALISCO': {
      'Guadalajara': ['Centro', 'Americana', 'Providencia', 'Chapultepec'],
      'Zapopan': ['Zapopan Centro', 'Andares'],
      'Tlaquepaque': ['Centro'],
      'Tonalá': ['Centro'],
      'Puerto Vallarta': ['Centro', 'Zona Romántica'],
    },
    'ESTADO DE MÉXICO': {
      'Toluca': ['Centro', 'Universidad'],
      'Ecatepec de Morelos': ['Centro'],
      'Naucalpan de Juárez': ['Naucalpan Centro'],
      'Nezahualcóyotl': ['Centro'],
      'Tlalnepantla de Baz': ['Centro'],
      'Cuautitlán Izcalli': ['Centro Urbano'],
    },
    'MICHOACÁN': {
      'Morelia': ['Centro Histórico', 'Altozano'],
      'Uruapan': ['Centro'],
      'Zamora': ['Centro'],
      'Lázaro Cárdenas': ['Centro'],
    },
    'MORELOS': {
      'Cuernavaca': ['Centro', 'Vista Hermosa'],
      'Jiutepec': ['Centro'],
      'Cuautla': ['Centro'],
    },
    'NAYARIT': {
      'Tepic': ['Centro', 'Ciudad del Valle'],
      'Bahía de Banderas': ['Bucerías'],
      'Santiago Ixcuintla': ['Centro'],
    },
    'NUEVO LEÓN': {
      'Monterrey': ['Centro', 'San Pedro Garza García', 'Del Valle'],
      'Guadalupe': ['Guadalupe Centro'],
      'San Nicolás de los Garza': ['Centro'],
      'Apodaca': ['Centro'],
    },
    'OAXACA': {
      'Oaxaca de Juárez': ['Centro Histórico', 'Reforma'],
      'Salina Cruz': ['Centro'],
      'San Juan Bautista Tuxtepec': ['Centro'],
    },
    'PUEBLA': {
      'Puebla': ['Centro Histórico', 'Angelópolis'],
      'Tehuacán': ['Centro'],
      'San Martín Texmelucan': ['Centro'],
    },
    'QUERÉTARO': {
      'Santiago de Querétaro': ['Centro Histórico', 'Juriquilla'],
      'San Juan del Río': ['Centro'],
      'Corregidora': ['Centro'],
    },
    'QUINTANA ROO': {
      'Cancún': ['Centro', 'Zona Hotelera'],
      'Playa del Carmen': ['Centro', 'Playacar'],
      'Chetumal': ['Centro'],
      'Cozumel': ['Centro'],
    },
    'SAN LUIS POTOSÍ': {
      'San Luis Potosí': ['Centro Histórico', 'Lomas'],
      'Soledad de Graciano Sánchez': ['Centro'],
      'Ciudad Valles': ['Centro'],
    },
    'SINALOA': {
      'Culiacán': ['Centro', 'Tres Ríos'],
      'Mazatlán': ['Centro', 'Zona Dorada'],
      'Los Mochis': ['Centro'],
      'Ahome': ['Centro'],
    },
    'SONORA': {
      'Hermosillo': ['Centro', 'Villa de Seris'],
      'Cajeme': ['Ciudad Obregón'],
      'Nogales': ['Centro'],
      'San Luis Río Colorado': ['Centro'],
    },
    'TABASCO': {
      'Villahermosa': ['Centro', 'Tabasco 2000'],
      'Cárdenas': ['Centro'],
      'Comalcalco': ['Centro'],
    },
    'TAMAULIPAS': {
      'Reynosa': ['Centro', 'Zona Centro'],
      'Matamoros': ['Centro'],
      'Nuevo Laredo': ['Centro'],
      'Tampico': ['Centro', 'Zona Dorada'],
      'Ciudad Victoria': ['Centro'],
    },
    'TLAXCALA': {
      'Tlaxcala': ['Centro'],
      'Apizaco': ['Centro'],
      'Huamantla': ['Centro'],
    },
    'VERACRUZ': {
      'Veracruz': ['Centro Histórico', 'Boca del Río'],
      'Xalapa': ['Centro', 'Zona Universitaria'],
      'Coatzacoalcos': ['Centro'],
      'Poza Rica': ['Centro'],
      'Córdoba': ['Centro'],
    },
    'YUCATÁN': {
      'Mérida': ['Centro Histórico', 'Norte'],
      'Kanasín': ['Centro'],
      'Valladolid': ['Centro'],
    },
    'ZACATECAS': {
      'Zacatecas': ['Centro Histórico'],
      'Fresnillo': ['Centro'],
      'Guadalupe': ['Centro'],
    },
  };

  @override
  Country getCountry() => config.country;

  @override
  List<AdministrativeLevel2> getLevel2() {
    return _mexicoData.keys
        .map((key) => AdministrativeLevel2(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel3> getLevel3(String level2Code) {
    final level2Data = _mexicoData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    return level2Data.keys
        .map((key) => AdministrativeLevel3(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel4> getLevel4(String level2Code, String level3Code) {
    final level2Data = _mexicoData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    final colonias = level2Data[level3Code];
    if (colonias == null) return [];

    return colonias
        .map((name) => AdministrativeLevel4(code: name, name: name))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
