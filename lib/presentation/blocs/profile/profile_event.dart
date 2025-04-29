part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? phone;
  final String? employment;
  final String? nationality;
  final String? city;
  final String? province;
  final String? district;
  final String? profileImageUrl;


  UpdateProfile({
    this.name,
    this.phone,
    this.employment,
    this.nationality,
    this.city,
    this.province,
    this.district,
    this.profileImageUrl,
  });
}

class SubmitProfile extends ProfileEvent {}

class UpdateProfileImageEvent extends ProfileEvent {
  final String filePath; // Ruta del archivo local seleccionado por el usuario.

  UpdateProfileImageEvent(this.filePath);
}