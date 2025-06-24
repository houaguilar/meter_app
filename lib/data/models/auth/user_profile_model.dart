import '../../../domain/entities/auth/user_profile.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String employment;
  final String nationality;
  final String city;
  final String province;
  final String district;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.employment,
    required this.nationality,
    required this.city,
    required this.province,
    required this.district,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      employment: json['employment'] ?? '',
      nationality: json['nationality'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      employment: employment,
      nationality: nationality,
      city: city,
      province: province,
      district: district,
    );
  }

  factory UserProfileModel.fromDomain(UserProfile userProfile) {
    return UserProfileModel(
      id: userProfile.id,
      name: userProfile.name,
      email: userProfile.email,
      phone: userProfile.phone,
      employment: userProfile.employment,
      nationality: userProfile.nationality,
      city: userProfile.city,
      province: userProfile.province,
      district: userProfile.district,
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? employment,
    String? nationality,
    String? city,
    String? province,
    String? district,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employment: employment ?? this.employment,
      nationality: nationality ?? this.nationality,
      city: city ?? this.city,
      province: province ?? this.province,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel(id: $id, name: $name, email: $email, phone: $phone, employment: $employment, nationality: $nationality, city: $city, province: $province, district: $district)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileModel &&
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