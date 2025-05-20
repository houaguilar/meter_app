import '../../../domain/entities/auth/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    super.employment,
    super.nationality,
    super.city,
    super.province,
    super.district,
    super.profileImageUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      employment: map['employment'] ?? '',
      nationality: map['nationality'] ?? '',
      city: map['city'] ?? '',
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      profileImageUrl: map['profile_image_url'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'employment': employment,
      'nationality': nationality,
      'city': city,
      'province': province,
      'district': district,
      'profile_image_url': profileImageUrl,
    };
  }

  @override
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? employment,
    String? nationality,
    String? city,
    String? province,
    String? district,
    String? profileImageUrl,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      employment: employment ?? this.employment,
      nationality: nationality ?? this.nationality,
      city: city ?? this.city,
      province: province ?? this.province,
      district: district ?? this.district,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Convert from domain entity to data model
  factory UserProfileModel.fromDomain(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      phone: profile.phone,
      email: profile.email,
      employment: profile.employment,
      nationality: profile.nationality,
      city: profile.city,
      province: profile.province,
      district: profile.district,
      profileImageUrl: profile.profileImageUrl,
    );
  }
}