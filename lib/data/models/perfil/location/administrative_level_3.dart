/// Nivel administrativo 3 (Provincia en Perú, Municipio en Colombia, Município en Brasil)
/// Representa la división territorial de nivel 3
class AdministrativeLevel3 {
  final String code;
  final String name;

  const AdministrativeLevel3({
    required this.code,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdministrativeLevel3 &&
        other.code == code &&
        other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() => 'AdministrativeLevel3(code: $code, name: $name)';

  /// Factory para crear desde Province (Perú)
  factory AdministrativeLevel3.fromProvince(String code, String name) {
    return AdministrativeLevel3(code: code, name: name);
  }

  /// Factory para crear desde Municipio (Colombia)
  factory AdministrativeLevel3.fromMunicipio(String code, String name) {
    return AdministrativeLevel3(code: code, name: name);
  }

  /// Factory para crear desde Município (Brasil)
  factory AdministrativeLevel3.fromMunicipioBR(String code, String name) {
    return AdministrativeLevel3(code: code, name: name);
  }
}
