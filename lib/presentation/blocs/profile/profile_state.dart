part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  final bool isValid;
  final bool isLoading;

  ProfileLoaded({
    required this.userProfile,
    this.isValid = false,
    this.isLoading = false,
  });

  ProfileLoaded copyWith({
    UserProfile? userProfile,
    bool? isValid,
    bool? isLoading,
  }) {
    return ProfileLoaded(
      userProfile: userProfile ?? this.userProfile,
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [userProfile, isValid, isLoading];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class ProfileSuccess extends ProfileState {}

class PasswordChangeLoading extends ProfileState {}

class PasswordChangeSuccess extends ProfileState {}

class PasswordChangeError extends ProfileState {
  final String message;

  PasswordChangeError(this.message);
}