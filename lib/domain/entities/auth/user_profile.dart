class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String employment;
  final String nationality;
  final String city;
  final String province;
  final String district;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.employment,
    required this.nationality,
    required this.city,
    required this.province,
    required this.district,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? employment,
    String? nationality,
    String? city,
    String? province,
    String? district,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employment: employment ?? this.employment,
      nationality: nationality ?? this.nationality,
      city: city ?? this.city,
      province: province ?? this.province,
      district: district ?? this.district,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'employment': employment,
      'nationality': nationality,
      'city': city,
      'province': province,
      'district': district,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      employment: json['employment'] ?? '',
      nationality: json['nationality'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
    );
  }

  /// Calcula el porcentaje de completitud del perfil
  double get completionPercentage {
    final fields = [
      name,
      phone,
      employment,
      nationality,
      city,
      province,
      district,
    ];

    final filledFields = fields.where((field) => field.isNotEmpty).length;
    return (filledFields / fields.length) * 100;
  }

  /// Verifica si el perfil está completo
  bool get isComplete {
    return name.isNotEmpty &&
        phone.isNotEmpty &&
        employment.isNotEmpty &&
        nationality.isNotEmpty &&
        city.isNotEmpty &&
        province.isNotEmpty &&
        district.isNotEmpty;
  }

  /// Obtiene los campos faltantes del perfil
  List<String> get missingFields {
    final Map<String, String> fieldNames = {
      'name': 'Nombre',
      'phone': 'Teléfono',
      'employment': 'Ocupación',
      'nationality': 'Nacionalidad',
      'city': 'Ciudad',
      'province': 'Provincia',
      'district': 'Distrito',
    };

    final Map<String, String> fieldValues = {
      'name': name,
      'phone': phone,
      'employment': employment,
      'nationality': nationality,
      'city': city,
      'province': province,
      'district': district,
    };

    return fieldValues.entries
        .where((entry) => entry.value.isEmpty)
        .map((entry) => fieldNames[entry.key]!)
        .toList();
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, phone: $phone, employment: $employment, nationality: $nationality, city: $city, province: $province, district: $district)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.employment == employment &&
        other.nationality == nationality &&
        other.city == city &&
        other.province == province &&
        other.district == district;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      phone,
      employment,
      nationality,
      city,
      province,
      district,
    );
  }
}