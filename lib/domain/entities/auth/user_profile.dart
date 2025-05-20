
import '../entities.dart';

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String employment;
  final String nationality;
  final String city;
  final String province;
  final String district;
  final String? profileImageUrl;

  // Make all fields final to ensure immutability
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.employment = '',
    this.nationality = '',
    this.city = '',
    this.province = '',
    this.district = '',
    this.profileImageUrl,
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
      profileImageUrl: additionalData['profile_image_url'],
    );
  }

  // Add validation method to improve security
  bool get isValid {
    return id.isNotEmpty && name.isNotEmpty && email.isNotEmpty;
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
    String? profileImageUrl,
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

  // Add equality operator for easy comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserProfile &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              phone == other.phone &&
              email == other.email &&
              employment == other.employment &&
              nationality == other.nationality &&
              city == other.city &&
              province == other.province &&
              district == other.district &&
              profileImageUrl == other.profileImageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      employment.hashCode ^
      nationality.hashCode ^
      city.hashCode ^
      province.hashCode ^
      district.hashCode ^
      (profileImageUrl?.hashCode ?? 0);
}