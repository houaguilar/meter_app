part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final bool forceReload;

  LoadProfile({this.forceReload = false});
}

class RetryLoadProfile extends ProfileEvent {}

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
  final String filePath;

  UpdateProfileImageEvent(this.filePath);
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}