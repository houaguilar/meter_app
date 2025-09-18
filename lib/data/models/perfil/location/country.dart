class Country {
  final String code;
  final String name;
  final String flag;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country &&
        other.code == code &&
        other.name == name &&
        other.flag == flag;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ flag.hashCode;

  @override
  String toString() => 'Country(code: $code, name: $name, flag: $flag)';
}