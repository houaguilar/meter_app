// lib/data/repositories/location/peru_location_repository_v2.dart

import '../../../models/perfil/location/administrative_level_2.dart';
import '../../../models/perfil/location/administrative_level_3.dart';
import '../../../models/perfil/location/administrative_level_4.dart';
import '../../../models/perfil/location/country.dart';
import '../../../models/perfil/location/location_config.dart';
import 'location_repository.dart';

/// Repositorio de ubicaciones de Perú con arquitectura genérica
/// Implementa LocationRepository con los datos completos de Perú
class PeruLocationRepositoryV2 extends LocationRepository {
  @override
  LocationConfig get config => LocationConfig.peru;

  /// Datos completos de Perú con todos los departamentos, provincias y distritos
  /// Datos completos de Perú con todos los departamentos, provincias y distritos
  static const Map<String, Map<String, List<String>>> _peruData = {
    'AMAZONAS': {
      'Chachapoyas': [
        'Chachapoyas',
        'Asunción',
        'Balsas',
        'Cheto',
        'Chiliquín',
        'Chuquibamba',
        'Granada',
        'Huancas',
        'La Jalca',
        'Leimebamba',
        'Levanto',
        'Magdalena',
        'Mariscal Castilla',
        'Molinopampa',
        'Montevideo',
        'Olleros',
        'Quinjalca',
        'San Francisco de Daguas',
        'San Isidro de Maino',
        'Soloco',
        'Sonche'
      ],
      'Bagua': [
        'Bagua',
        'Aramango',
        'Copallin',
        'El Parco',
        'Imaza',
        'La Peca'
      ],
      'Bongará': [
        'Jumbilla',
        'Chisquilla',
        'Churuja',
        'Corosha',
        'Cuispes',
        'Florida',
        'Jazan',
        'Recta',
        'San Carlos',
        'Shipasbamba',
        'Valera',
        'Yambrasbamba'
      ],
      'Condorcanqui': [
        'Nieva',
        'El Cenepa',
        'Río Santiago'
      ],
      'Luya': [
        'Lamud',
        'Camporredondo',
        'Cocabamba',
        'Colcamar',
        'Conila',
        'Inguilpata',
        'Longuita',
        'Lonya Chico',
        'Luya',
        'Luya Viejo',
        'María',
        'Ocalli',
        'Ocumal',
        'Pisuquia',
        'Providencia',
        'San Cristóbal',
        'San Francisco del Yeso',
        'San Jerónimo',
        'San Juan de Lopecancha',
        'Santa Catalina',
        'Santo Tomas',
        'Tingo',
        'Trita'
      ],
      'Rodríguez de Mendoza': [
        'San Nicolás',
        'Chirimoto',
        'Cochamal',
        'Huambo',
        'Limabamba',
        'Longar',
        'Mariscal Benavides',
        'Milpuc',
        'Omia',
        'Santa Rosa',
        'Totora',
        'Vista Alegre'
      ],
      'Utcubamba': [
        'Bagua Grande',
        'Cajaruro',
        'Cumba',
        'El Milagro',
        'Jamalca',
        'Lonya Grande',
        'Yamon'
      ]
    },
    'ÁNCASH': {
      'Huaraz': [
        'Huaraz',
        'Cochabamba',
        'Colcabamba',
        'Huanchay',
        'Independencia',
        'Jangas',
        'La Libertad',
        'Olleros',
        'Pampas Grande',
        'Pariacoto',
        'Pira',
        'Tarica'
      ],
      'Aija': [
        'Aija',
        'Coris',
        'Huacllán',
        'La Merced',
        'Succha'
      ],
      'Antonio Raymondi': [
        'Llamellin',
        'Aczo',
        'Chaccho',
        'Chingas',
        'Mirgas',
        'San Juan de Rontoy'
      ]
    },
    'APURÍMAC': {
      'Abancay': [
        'Abancay',
        'Chikla',
        'Circa',
        'Curahuasi',
        'Huanipaca',
        'Lambrama',
        'Pichirhua',
        'San Pedro de Cachora',
        'Tamburco'
      ],
      'Andahuaylas': [
        'Andahuaylas',
        'Andarapa',
        'Chiara',
        'Huancarama',
        'Huancaray',
        'Huayana',
        'Kishuara',
        'Pacobamba',
        'Pacucha',
        'Pampachiri',
        'Pomacocha',
        'San Antonio de Cachi',
        'San Jerónimo',
        'San Miguel de Chaccrampa',
        'Santa María de Chicmo',
        'Talavera',
        'Tumay Huaraca',
        'Turpo',
        'Kaquiabamba',
        'José María Arguedas'
      ]
    },
    'AREQUIPA': {
      'Arequipa': [
        'Arequipa',
        'Alto Selva Alegre',
        'Cayma',
        'Cerro Colorado',
        'Characato',
        'Chiguata',
        'Jacobo Hunter',
        'José Luis Bustamante y Rivero',
        'Mariano Melgar',
        'Miraflores',
        'Mollebaya',
        'Paucarpata',
        'Pocsi',
        'Polobaya',
        'Quequeña',
        'Sabandia',
        'Sachaca',
        'San Juan de Siguas',
        'San Juan de Tarucani',
        'Santa Isabel de Siguas',
        'Santa Rita de Siguas',
        'Socabaya',
        'Tiabaya',
        'Uchumayo',
        'Vitor',
        'Yanahuara',
        'Yarabamba',
        'Yura'
      ],
      'Camaná': [
        'Camaná',
        'José María Quimper',
        'Mariano Nicolás Valcárcel',
        'Mariscal Cáceres',
        'Nicolás de Piérola',
        'Ocoña',
        'Quilca',
        'Samuel Pastor'
      ],
      'Caravelí': [
        'Caravelí',
        'Acarí',
        'Atico',
        'Atiquipa',
        'Bella Unión',
        'Cahuacho',
        'Chala',
        'Chaparra',
        'Huanuhuanu',
        'Jaqui',
        'Lomas',
        'Quicacha',
        'Yauca'
      ]
    },
    'AYACUCHO': {
      'Huamanga': [
        'Ayacucho',
        'Acocro',
        'Acos Vinchos',
        'Carmen Alto',
        'Chiara',
        'Ocros',
        'Pacaycasa',
        'Quinua',
        'San José de Ticllas',
        'San Juan Bautista',
        'Santiago de Pischa',
        'Socos',
        'Tambillo',
        'Vinchos',
        'Jesús Nazareno'
      ]
    },
    'CAJAMARCA': {
      'Cajamarca': [
        'Cajamarca',
        'Asunción',
        'Chetilla',
        'Cospan',
        'Encañada',
        'Jesús',
        'Llacanora',
        'Los Baños del Inca',
        'Magdalena',
        'Matara',
        'Namora',
        'San Juan'
      ]
    },
    'CALLAO': {
      'Callao': [
        'Callao',
        'Bellavista',
        'Carmen de la Legua Reynoso',
        'La Perla',
        'La Punta',
        'Mi Perú',
        'Ventanilla'
      ]
    },
    'CUSCO': {
      'Cusco': [
        'Cusco',
        'Ccorca',
        'Poroy',
        'San Jerónimo',
        'San Sebastián',
        'Santiago',
        'Saylla',
        'Wanchaq'
      ]
    },
    'HUANCAVELICA': {
      'Huancavelica': [
        'Huancavelica',
        'Acobambilla',
        'Acoria',
        'Conayca',
        'Cuenca',
        'Huachocolpa',
        'Huayllahuara',
        'Izcuchaca',
        'Laria',
        'Manta',
        'Mariscal Cáceres',
        'Moya',
        'Nuevo Occoro',
        'Palca',
        'Pilchaca',
        'Vilca',
        'Yauli',
        'Ascensión',
        'Huando'
      ]
    },
    'HUÁNUCO': {
      'Huánuco': [
        'Huánuco',
        'Amarilis',
        'Chinchao',
        'Churubamba',
        'Margos',
        'Quisqui',
        'San Francisco de Cayrán',
        'San Pedro de Chaulán',
        'Santa María del Valle',
        'Yarumayo',
        'Pillco Marca'
      ]
    },
    'ICA': {
      'Ica': [
        'Ica',
        'La Tinguiña',
        'Los Aquijes',
        'Ocucaje',
        'Pachacutec',
        'Parcona',
        'Pueblo Nuevo',
        'Salas',
        'San José de Los Molinos',
        'San Juan Bautista',
        'Santiago',
        'Subtanjalla',
        'Tate',
        'Yauca del Rosario'
      ]
    },
    'JUNÍN': {
      'Huancayo': [
        'Huancayo',
        'Carhuacallanga',
        'Chacapampa',
        'Chicche',
        'Chilca',
        'Chongos Alto',
        'Chupuro',
        'Colca',
        'Cullhuas',
        'El Tambo',
        'Huacrapuquio',
        'Hualhuas',
        'Huancan',
        'Huasicancha',
        'Huayucachi',
        'Ingenio',
        'Pariahuanca',
        'Pilcomayo',
        'Pucará',
        'Quichuay',
        'Quilcas',
        'San Agustín',
        'San Jerónimo de Tunán',
        'Saño',
        'Sapallanga',
        'Sicaya',
        'Santo Domingo de Acobamba',
        'Viques'
      ]
    },
    'LA LIBERTAD': {
      'Trujillo': [
        'Trujillo',
        'El Porvenir',
        'Florencia de Mora',
        'Huanchaco',
        'La Esperanza',
        'Laredo',
        'Moche',
        'Poroto',
        'Salaverry',
        'Simbal',
        'Víctor Larco Herrera'
      ]
    },
    'LAMBAYEQUE': {
      'Chiclayo': [
        'Chiclayo',
        'Chongoyape',
        'Eten',
        'Eten Puerto',
        'José Leonardo Ortiz',
        'La Victoria',
        'Lagunas',
        'Monsefu',
        'Nueva Arica',
        'Oyotun',
        'Picsi',
        'Pimentel',
        'Reque',
        'Santa Rosa',
        'Saña',
        'Cayalti',
        'Patapo',
        'Pomalca',
        'Pucala',
        'Tuman'
      ]
    },
    'LIMA': {
      'Lima': [
        'Lima',
        'Ancón',
        'Ate',
        'Barranco',
        'Breña',
        'Carabayllo',
        'Chaclacayo',
        'Chorrillos',
        'Cieneguilla',
        'Comas',
        'El Agustino',
        'Independencia',
        'Jesús María',
        'La Molina',
        'La Victoria',
        'Lince',
        'Los Olivos',
        'Lurigancho',
        'Lurín',
        'Magdalena del Mar',
        'Miraflores',
        'Pachacámac',
        'Pucusana',
        'Pueblo Libre',
        'Puente Piedra',
        'Punta Hermosa',
        'Punta Negra',
        'Rímac',
        'San Bartolo',
        'San Borja',
        'San Isidro',
        'San Juan de Lurigancho',
        'San Juan de Miraflores',
        'San Luis',
        'San Martín de Porres',
        'San Miguel',
        'Santa Anita',
        'Santa María del Mar',
        'Santa Rosa',
        'Santiago de Surco',
        'Surquillo',
        'Villa El Salvador',
        'Villa María del Triunfo'
      ],
      'Barranca': [
        'Barranca',
        'Paramonga',
        'Pativilca',
        'Supe',
        'Supe Puerto'
      ],
      'Cajatambo': [
        'Cajatambo',
        'Copa',
        'Gorgor',
        'Huancapón',
        'Manas'
      ],
      'Canta': [
        'Canta',
        'Arahuay',
        'Huamantanga',
        'Huaros',
        'Lachaqui',
        'San Buenaventura',
        'Santa Rosa de Quives'
      ],
      'Cañete': [
        'San Vicente de Cañete',
        'Asia',
        'Calango',
        'Cerro Azul',
        'Chilca',
        'Coayllo',
        'Imperial',
        'Lunahuaná',
        'Mala',
        'Nuevo Imperial',
        'Pacarán',
        'Quilmaná',
        'San Antonio',
        'San Luis',
        'Santa Cruz de Flores',
        'Zúñiga'
      ],
      'Huaral': [
        'Huaral',
        'Atavillos Alto',
        'Atavillos Bajo',
        'Aucallama',
        'Chancay',
        'Ihuari',
        'Lampian',
        'Pacaraos',
        'San Miguel de Acos',
        'Santa Cruz de Andamarca',
        'Sumbilca',
        'Veintisiete de Noviembre'
      ],
      'Huarochirí': [
        'Matucana',
        'Antioquia',
        'Callahuanca',
        'Carampoma',
        'Chicla',
        'Cuenca',
        'Huachupampa',
        'Huanza',
        'Huarochirí',
        'Lahuaytambo',
        'Langa',
        'Laraos',
        'Mariatana',
        'Ricardo Palma',
        'San Andrés de Tupicocha',
        'San Antonio',
        'San Bartolomé',
        'San Damián',
        'San Juan de Iris',
        'San Juan de Tantaranche',
        'San Lorenzo de Quinti',
        'San Mateo',
        'San Mateo de Otao',
        'San Pedro de Casta',
        'San Pedro de Huancayre',
        'Sangallaya',
        'Santa Cruz de Cocachacra',
        'Santa Eulalia',
        'Santiago de Anchucaya',
        'Santiago de Tuna',
        'Santo Domingo de Los Olleros',
        'Surco'
      ],
      'Huaura': [
        'Huacho',
        'Ambar',
        'Caleta de Carquin',
        'Checras',
        'Hualmay',
        'Huaura',
        'Leoncio Prado',
        'Paccho',
        'Santa Leonor',
        'Santa María',
        'Sayán',
        'Vegueta'
      ],
      'Oyón': [
        'Oyón',
        'Andajes',
        'Caujul',
        'Cochamarca',
        'Navan',
        'Pachangara'
      ],
      'Yauyos': [
        'Yauyos',
        'Alis',
        'Ayauca',
        'Ayaviri',
        'Azángaro',
        'Cacra',
        'Carania',
        'Catahuasi',
        'Chocos',
        'Cochas',
        'Colonia',
        'Hongos',
        'Huampara',
        'Huancaya',
        'Huangascar',
        'Huantán',
        'Huañec',
        'Laraos',
        'Lincha',
        'Madean',
        'Miraflores',
        'Omas',
        'Putinza',
        'Quinches',
        'Quinocay',
        'San Joaquín',
        'San Pedro de Pilas',
        'Tanta',
        'Tauripampa',
        'Tomas',
        'Tupe',
        'Viñac',
        'Vitis'
      ]
    },
    'LORETO': {
      'Maynas': [
        'Iquitos',
        'Alto Nanay',
        'Fernando Lores',
        'Indiana',
        'Las Amazonas',
        'Mazan',
        'Napo',
        'Punchana',
        'Torres Causana',
        'Belén',
        'San Juan Bautista'
      ]
    },
    'MADRE DE DIOS': {
      'Tambopata': [
        'Tambopata',
        'Inambari',
        'Las Piedras',
        'Laberinto'
      ]
    },
    'MOQUEGUA': {
      'Mariscal Nieto': [
        'Moquegua',
        'Carumas',
        'Cuchumbaya',
        'Samegua',
        'San Cristóbal',
        'Torata'
      ]
    },
    'PASCO': {
      'Pasco': [
        'Chaupimarca',
        'Huachón',
        'Huariaca',
        'Huayllay',
        'Ninacaca',
        'Pallanchacra',
        'Paucartambo',
        'San Francisco de Asís de Yarusyacán',
        'Simón Bolívar',
        'Ticlacayán',
        'Tinyahuarco',
        'Vicco',
        'Yanacancha'
      ]
    },
    'PIURA': {
      'Piura': [
        'Piura',
        'Castilla',
        'Catacaos',
        'Cura Mori',
        'El Tallán',
        'La Arena',
        'La Unión',
        'Las Lomas',
        'Tambo Grande',
        'Veintiséis de Octubre'
      ]
    },
    'PUNO': {
      'Puno': [
        'Puno',
        'Acora',
        'Amantani',
        'Atuncolla',
        'Capachica',
        'Chucuito',
        'Coata',
        'Huata',
        'Mañazo',
        'Paucarcolla',
        'Pichacani',
        'Platería',
        'San Antonio',
        'Tiquillaca',
        'Vilque'
      ]
    },
    'SAN MARTÍN': {
      'Moyobamba': [
        'Moyobamba',
        'Calzada',
        'Habana',
        'Jepelacio',
        'Soritor',
        'Yantalo'
      ]
    },
    'TACNA': {
      'Tacna': [
        'Tacna',
        'Alto de la Alianza',
        'Calana',
        'Ciudad Nueva',
        'Inclan',
        'Pachia',
        'Palca',
        'Pocollay',
        'Sama',
        'Coronel Gregorio Albarracín Lanchipa'
      ]
    },
    'TUMBES': {
      'Tumbes': [
        'Tumbes',
        'Corrales',
        'La Cruz',
        'Pampas de Hospital',
        'San Jacinto',
        'San Juan de la Virgen'
      ]
    },
    'UCAYALI': {
      'Coronel Portillo': [
        'Callería',
        'Campoverde',
        'Iparia',
        'Masisea',
        'Yarinacocha',
        'Nueva Requena',
        'Manantay'
      ]
    }
  };

  @override
  Country getCountry() => config.country;

  @override
  List<AdministrativeLevel2> getLevel2() {
    return _peruData.keys
        .map((key) => AdministrativeLevel2(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel3> getLevel3(String level2Code) {
    final level2Data = _peruData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    return level2Data.keys
        .map((key) => AdministrativeLevel3(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel4> getLevel4(String level2Code, String level3Code) {
    final level2Data = _peruData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    final districts = level2Data[level3Code];
    if (districts == null) return [];

    return districts
        .map((name) => AdministrativeLevel4(code: name, name: name))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
