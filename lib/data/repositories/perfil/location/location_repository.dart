import '../../../models/perfil/location/administrative_level_2.dart';
import '../../../models/perfil/location/administrative_level_3.dart';
import '../../../models/perfil/location/administrative_level_4.dart';
import '../../../models/perfil/location/country.dart';
import '../../../models/perfil/location/location_config.dart';

/// Repositorio base abstracto para datos de ubicación
/// Todas las implementaciones específicas de países deben extender esta clase
abstract class LocationRepository {
  /// Configuración del país (labels, metadata, etc.)
  LocationConfig get config;

  /// Obtiene el país
  Country getCountry();

  /// Obtiene todos los niveles administrativos 2 (Departamentos/Estados)
  List<AdministrativeLevel2> getLevel2();

  /// Obtiene los niveles administrativos 3 para un nivel 2 específico
  List<AdministrativeLevel3> getLevel3(String level2Code);

  /// Obtiene los niveles administrativos 4 para un nivel 3 específico
  List<AdministrativeLevel4> getLevel4(String level2Code, String level3Code);

  /// Busca niveles administrativos 2 por nombre
  List<AdministrativeLevel2> searchLevel2(String query) {
    if (query.isEmpty) return getLevel2();

    return getLevel2()
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Busca niveles administrativos 3 por nombre
  List<AdministrativeLevel3> searchLevel3(String level2Code, String query) {
    if (query.isEmpty) return getLevel3(level2Code);

    return getLevel3(level2Code)
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Busca niveles administrativos 4 por nombre
  List<AdministrativeLevel4> searchLevel4(
      String level2Code,
      String level3Code,
      String query,
      ) {
    if (query.isEmpty) return getLevel4(level2Code, level3Code);

    return getLevel4(level2Code, level3Code)
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Verifica si un nivel 2 existe
  bool level2Exists(String code) {
    return getLevel2().any((item) => item.code == code);
  }

  /// Verifica si un nivel 3 existe
  bool level3Exists(String level2Code, String code) {
    return getLevel3(level2Code).any((item) => item.code == code);
  }

  /// Verifica si un nivel 4 existe
  bool level4Exists(String level2Code, String level3Code, String code) {
    return getLevel4(level2Code, level3Code).any((item) => item.code == code);
  }
}
