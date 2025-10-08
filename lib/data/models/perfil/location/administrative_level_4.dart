/// Nivel administrativo 4 (Distrito en Perú/Brasil, Corregimiento en Colombia)
/// Representa la división territorial más granular (opcional en algunos países)
class AdministrativeLevel4 {
  final String code;
  final String name;

  const AdministrativeLevel4({
    required this.code,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdministrativeLevel4 &&
        other.code == code &&
        other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() => 'AdministrativeLevel4(code: $code, name: $name)';

  /// Factory para crear desde District (Perú/Brasil)
  factory AdministrativeLevel4.fromDistrict(String code, String name) {
    return AdministrativeLevel4(code: code, name: name);
  }

  /// Factory para crear desde Corregimiento (Colombia)
  factory AdministrativeLevel4.fromCorregimiento(String code, String name) {
    return AdministrativeLevel4(code: code, name: name);
  }
}
