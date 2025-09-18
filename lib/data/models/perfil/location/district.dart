class District {
  final String name;

  const District({
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is District && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'District(name: $name)';
}