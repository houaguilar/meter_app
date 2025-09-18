class Department {
  final String code;
  final String name;

  const Department({
    required this.code,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Department && other.code == code && other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() => 'Department(code: $code, name: $name)';
}