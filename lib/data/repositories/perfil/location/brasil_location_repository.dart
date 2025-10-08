// lib/data/repositories/location/brasil_location_repository.dart

import '../../../models/perfil/location/administrative_level_2.dart';
import '../../../models/perfil/location/administrative_level_3.dart';
import '../../../models/perfil/location/administrative_level_4.dart';
import '../../../models/perfil/location/country.dart';
import '../../../models/perfil/location/location_config.dart';
import 'location_repository.dart';

/// Repositorio de ubicaciones de Brasil 🇧🇷
/// Brasil tiene 26 estados + 1 Distrito Federal, 5,570 municípios
class BrasilLocationRepository extends LocationRepository {
  @override
  LocationConfig get config => LocationConfig.brasil;

  /// Datos de Brasil con estados, municípios y distritos
  /// Estructura: {Estado: {Município: [Distritos]}}
  /// NOTA: Los datos aquí son de ejemplo. Debes reemplazarlos con datos reales completos.
  static const Map<String, Map<String, List<String>>> _brasilData = {
    'ACRE': {
      'Rio Branco': ['Centro', 'Aviário', 'Cadeia Velha'],
      'Cruzeiro do Sul': ['Centro'],
      'Sena Madureira': ['Centro'],
    },
    'ALAGOAS': {
      'Maceió': ['Centro', 'Pajuçara', 'Ponta Verde'],
      'Arapiraca': ['Centro'],
    },
    'AMAPÁ': {
      'Macapá': ['Centro', 'Fazendinha'],
      'Santana': ['Centro'],
    },
    'AMAZONAS': {
      'Manaus': [
        'Centro',
        'Adrianópolis',
        'Aleixo',
        'Alvorada',
        'Cachoeirinha',
        'Centro',
        'Chapada',
        'Cidade de Deus',
        'Cidade Nova',
        'Colônia Oliveira Machado',
        'Compensa',
        'Coroado',
        'Crespo',
        'Da Paz',
        'Distrito Industrial I',
        'Distrito Industrial II',
        'Dom Pedro',
        'Educandos',
        'Flores',
        'Gilberto Mestrinho',
        'Glória',
        'Japiim',
        'Jorge Teixeira',
        'Lírio do Vale',
        'Mauazinho',
        'Monte das Oliveiras',
        'Morro da Liberdade',
        'Nova Cidade',
        'Nova Esperança',
        'Novo Aleixo',
        'Novo Israel',
        'Novo Reino',
        'Nossa Senhora Aparecida',
        'Nossa Senhora das Graças',
        'Parque 10 de Novembro',
        'Petrópolis',
        'Planalto',
        'Ponta Negra',
        'Praça 14 de Janeiro',
        'Presidente Vargas',
        'Puraquequara',
        'Raiz',
        'Redencao',
        'Redenção',
        'Santa Etelvina',
        'Santa Luzia',
        'Santo Agostinho',
        'Santo Antônio',
        'São Francisco',
        'São Geraldo',
        'São Jorge',
        'São José',
        'São José Operário',
        'São Lázaro',
        'São Raimundo',
        'Tarumã',
        'Tarumã-Açu',
        'Tancredo Neves',
        'Zumbi dos Palmares'
      ],
      'Parintins': ['Centro'],
      'Itacoatiara': ['Centro'],
    },
    'BAHIA': {
      'Salvador': ['Centro', 'Barra', 'Itapuã', 'Pelourinho'],
      'Feira de Santana': ['Centro'],
      'Vitória da Conquista': ['Centro'],
      'Camaçari': ['Centro'],
      'Itabuna': ['Centro'],
    },
    'CEARÁ': {
      'Fortaleza': ['Centro', 'Aldeota', 'Meireles', 'Praia de Iracema'],
      'Caucaia': ['Centro'],
      'Juazeiro do Norte': ['Centro'],
      'Maracanaú': ['Centro'],
    },
    'DISTRITO FEDERAL': {
      'Brasília': [
        'Plano Piloto',
        'Asa Sul',
        'Asa Norte',
        'Lago Sul',
        'Lago Norte',
        'Gama',
        'Taguatinga',
        'Brazlândia',
        'Sobradinho',
        'Planaltina',
        'Paranoá',
        'Núcleo Bandeirante',
        'Ceilândia',
        'Guará',
        'Cruzeiro',
        'Samambaia',
        'Santa Maria',
        'São Sebastião',
        'Recanto das Emas',
        'Riacho Fundo',
        'Candangolândia',
        'Águas Claras',
        'Vicente Pires',
        'Sudoeste/Octogonal',
        'Varjão',
        'Park Way',
        'SCIA',
        'Sobradinho II',
        'Jardim Botânico',
        'Itapoã',
        'SIA',
        'Fercal',
        'Sol Nascente/Pôr do Sol',
        'Arniqueira',
      ],
    },
    'ESPÍRITO SANTO': {
      'Vitória': ['Centro', 'Praia do Canto'],
      'Vila Velha': ['Centro'],
      'Serra': ['Centro'],
      'Cariacica': ['Centro'],
    },
    'GOIÁS': {
      'Goiânia': ['Centro', 'Setor Bueno', 'Setor Oeste'],
      'Aparecida de Goiânia': ['Centro'],
      'Anápolis': ['Centro'],
    },
    'MARANHÃO': {
      'São Luís': ['Centro', 'Renascença'],
      'Imperatriz': ['Centro'],
      'São José de Ribamar': ['Centro'],
    },
    'MATO GROSSO': {
      'Cuiabá': ['Centro', 'Jardim Aclimação'],
      'Várzea Grande': ['Centro'],
      'Rondonópolis': ['Centro'],
    },
    'MATO GROSSO DO SUL': {
      'Campo Grande': ['Centro', 'Jardim dos Estados'],
      'Dourados': ['Centro'],
      'Três Lagoas': ['Centro'],
    },
    'MINAS GERAIS': {
      'Belo Horizonte': ['Centro', 'Savassi', 'Pampulha'],
      'Uberlândia': ['Centro'],
      'Contagem': ['Centro'],
      'Juiz de Fora': ['Centro'],
      'Betim': ['Centro'],
    },
    'PARÁ': {
      'Belém': ['Centro', 'Nazaré', 'Batista Campos'],
      'Ananindeua': ['Centro'],
      'Santarém': ['Centro'],
      'Marabá': ['Centro'],
    },
    'PARAÍBA': {
      'João Pessoa': ['Centro', 'Manaíra', 'Cabo Branco'],
      'Campina Grande': ['Centro'],
      'Santa Rita': ['Centro'],
    },
    'PARANÁ': {
      'Curitiba': ['Centro', 'Batel', 'Água Verde'],
      'Londrina': ['Centro'],
      'Maringá': ['Centro'],
      'Ponta Grossa': ['Centro'],
      'Cascavel': ['Centro'],
      'São José dos Pinhais': ['Centro'],
      'Foz do Iguaçu': ['Centro'],
    },
    'PERNAMBUCO': {
      'Recife': ['Centro', 'Boa Viagem', 'Pina'],
      'Jaboatão dos Guararapes': ['Centro'],
      'Olinda': ['Centro Histórico'],
      'Caruaru': ['Centro'],
      'Petrolina': ['Centro'],
    },
    'PIAUÍ': {
      'Teresina': ['Centro', 'Fátima'],
      'Parnaíba': ['Centro'],
    },
    'RIO DE JANEIRO': {
      'Rio de Janeiro': [
        'Centro',
        'Copacabana',
        'Ipanema',
        'Leblon',
        'Barra da Tijuca',
        'Botafogo',
        'Flamengo',
        'Tijuca',
        'Méier',
        'Campo Grande',
      ],
      'São Gonçalo': ['Centro'],
      'Duque de Caxias': ['Centro'],
      'Nova Iguaçu': ['Centro'],
      'Niterói': ['Centro', 'Icaraí'],
      'Belford Roxo': ['Centro'],
    },
    'RIO GRANDE DO NORTE': {
      'Natal': ['Centro', 'Ponta Negra'],
      'Mossoró': ['Centro'],
      'Parnamirim': ['Centro'],
    },
    'RIO GRANDE DO SUL': {
      'Porto Alegre': ['Centro', 'Moinhos de Vento', 'Bom Fim'],
      'Caxias do Sul': ['Centro'],
      'Pelotas': ['Centro'],
      'Canoas': ['Centro'],
      'Santa Maria': ['Centro'],
      'Gravataí': ['Centro'],
    },
    'RONDÔNIA': {
      'Porto Velho': ['Centro'],
      'Ji-Paraná': ['Centro'],
      'Ariquemes': ['Centro'],
    },
    'RORAIMA': {
      'Boa Vista': ['Centro'],
    },
    'SANTA CATARINA': {
      'Florianópolis': ['Centro', 'Lagoa da Conceição'],
      'Joinville': ['Centro'],
      'Blumenau': ['Centro'],
      'São José': ['Centro'],
      'Criciúma': ['Centro'],
      'Chapecó': ['Centro'],
    },
    'SÃO PAULO': {
      'São Paulo': [
        'Centro',
        'Pinheiros',
        'Vila Mariana',
        'Mooca',
        'Tatuapé',
        'Itaim Bibi',
        'Morumbi',
        'Vila Madalena',
        'Santana',
        'Lapa',
      ],
      'Guarulhos': ['Centro'],
      'Campinas': ['Centro', 'Cambuí'],
      'São Bernardo do Campo': ['Centro'],
      'Santo André': ['Centro'],
      'Osasco': ['Centro'],
      'São José dos Campos': ['Centro'],
      'Ribeirão Preto': ['Centro'],
      'Sorocaba': ['Centro'],
      'Santos': ['Centro', 'Gonzaga'],
    },
    'SERGIPE': {
      'Aracaju': ['Centro', 'Atalaia'],
      'Nossa Senhora do Socorro': ['Centro'],
    },
    'TOCANTINS': {
      'Palmas': ['Centro'],
      'Araguaína': ['Centro'],
    },
  };

  @override
  Country getCountry() => config.country;

  @override
  List<AdministrativeLevel2> getLevel2() {
    return _brasilData.keys
        .map((key) => AdministrativeLevel2(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel3> getLevel3(String level2Code) {
    final level2Data = _brasilData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    return level2Data.keys
        .map((key) => AdministrativeLevel3(code: key, name: key))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<AdministrativeLevel4> getLevel4(String level2Code, String level3Code) {
    final level2Data = _brasilData[level2Code.toUpperCase()];
    if (level2Data == null) return [];

    final distritos = level2Data[level3Code];
    if (distritos == null) return [];

    return distritos
        .map((name) => AdministrativeLevel4(code: name, name: name))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
