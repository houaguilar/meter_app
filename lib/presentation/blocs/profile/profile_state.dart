part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  final bool notificationsEnabled;
  final bool keepSessionOpen;
  final bool isValid;

  ProfileLoaded({
    required this.userProfile,
    this.notificationsEnabled = false,
    this.keepSessionOpen = false,
    this.isValid = false,
  });

  ProfileLoaded copyWith({
    UserProfile? userProfile,
    bool? notificationsEnabled,
    bool? keepSessionOpen,
    bool? isValid,
  }) {
    return ProfileLoaded(
      userProfile: userProfile ?? this.userProfile,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      keepSessionOpen: keepSessionOpen ?? this.keepSessionOpen,
      isValid: isValid ?? this.isValid,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class ProfileSuccess extends ProfileState {}