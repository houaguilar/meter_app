/// Nivel administrativo 2 (Departamento en Perú/Colombia, Estado en Brasil)
/// Representa la división territorial inmediatamente inferior al país
class AdministrativeLevel2 {
  final String code;
  final String name;

  const AdministrativeLevel2({
    required this.code,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdministrativeLevel2 &&
        other.code == code &&
        other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() => 'AdministrativeLevel2(code: $code, name: $name)';

  /// Factory para crear desde Department (backward compatibility)
  factory AdministrativeLevel2.fromDepartment(String code, String name) {
    return AdministrativeLevel2(code: code, name: name);
  }

  /// Factory para crear desde Estado (Brasil)
  factory AdministrativeLevel2.fromState(String code, String name) {
    return AdministrativeLevel2(code: code, name: name);
  }
}
