
import '../entities.dart';

class UserProfile {
  late String id;
  late String name;
  late String phone;
  late String email;
  late String employment;
  late String nationality;
  late String city;
  late String province;
  late String district;
  late String? profileImageUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.employment = '',
    this.nationality = '',
    this.city = '',
    this.province = '',
    this.district = '',
    this.profileImageUrl = '',
  });

  factory UserProfile.fromUser(User user, Map<String, dynamic> additionalData) {
    return UserProfile(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: additionalData['phone'] ?? '',
      employment: additionalData['employment'] ?? '',
      nationality: additionalData['nationality'] ?? '',
      city: additionalData['city'] ?? '',
      province: additionalData['province'] ?? '',
      district: additionalData['district'] ?? '',
      profileImageUrl: additionalData['profile_image_url'] ?? '',
    );
  }

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

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? employment,
    String? nationality,
    String? city,
    String? province,
    String? district,
    String? profileImageUrl
  }) {
    return UserProfile(
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
}
