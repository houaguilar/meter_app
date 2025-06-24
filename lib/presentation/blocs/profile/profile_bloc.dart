import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../config/usecase/usecase.dart';
import '../../../domain/entities/auth/user_profile.dart';
import '../../../domain/usecases/auth/change_password.dart';
import '../../../domain/usecases/use_cases.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final ChangePassword _changePassword;
  UserProfile? _cachedProfile;

  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required ChangePassword changePassword,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        _changePassword = changePassword,
      super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<SubmitProfile>(_onSubmitProfile);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    if (event.forceReload) {
      _cachedProfile = null;
    }
    // If we already have the profile in cache, don't make the request again
    if (_cachedProfile != null) {
      emit(ProfileLoaded(userProfile: _cachedProfile!));
      return;
    }

    // If no cached data, make the request to backend
    emit(ProfileLoading());
    final result = await _getUserProfile(NoParams());
    result.fold(
          (failure) => emit(ProfileError(failure.message)),
          (profile) {
        _cachedProfile = profile; // Cache the profile
        emit(ProfileLoaded(userProfile: profile));
      },
    );
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final loadedState = state as ProfileLoaded;
      final updatedProfile = loadedState.userProfile.copyWith(
        name: event.name ?? loadedState.userProfile.name,
        phone: event.phone ?? loadedState.userProfile.phone,
        employment: event.employment ?? loadedState.userProfile.employment,
        nationality: event.nationality ?? loadedState.userProfile.nationality,
        city: event.city ?? loadedState.userProfile.city,
        province: event.province ?? loadedState.userProfile.province,
        district: event.district ?? loadedState.userProfile.district,
      );

      _cachedProfile = updatedProfile;

      emit(loadedState.copyWith(userProfile: updatedProfile, isValid: true));
    }
  }

  void _onSubmitProfile(SubmitProfile event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final loadedState = state as ProfileLoaded;
      emit(ProfileLoading());
      final result = await _updateUserProfile(
          UpdateUserProfileParams(profile: loadedState.userProfile));
      result.fold(
            (failure) => emit(ProfileError(failure.message)),
            (_) {
          _cachedProfile = loadedState.userProfile;
          emit(ProfileSuccess());
          // Emitir un ProfileLoaded después para mostrar la UI actualizada
          Future.delayed(Duration(milliseconds: 300), () {
            if (!isClosed) {
              emit(ProfileLoaded(userProfile: _cachedProfile!));
            }
          });
        },
      );
    }
  }

  void _onChangePassword(ChangePasswordEvent event, Emitter<ProfileState> emit) async {
    emit(PasswordChangeLoading());

    // Validate passwords match client-side first
    if (event.newPassword != event.confirmPassword) {
      emit(PasswordChangeError('Las contraseñas no coinciden'));
      // Return to loaded state after error
      if (_cachedProfile != null) {
        emit(ProfileLoaded(userProfile: _cachedProfile!));
      }
      return;
    }

    final result = await _changePassword(ChangePasswordParams(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    ));

    result.fold(
          (failure) {
        emit(PasswordChangeError(failure.message));
        // Return to loaded state after error
        if (_cachedProfile != null) {
          emit(ProfileLoaded(userProfile: _cachedProfile!));
        }
      },
          (_) {
        emit(PasswordChangeSuccess());
        // Return to loaded state after success
        if (_cachedProfile != null) {
          emit(ProfileLoaded(userProfile: _cachedProfile!));
        }
      },
    );
  }

  // Método público para limpiar el perfil
  void clearProfile() {
    _cachedProfile = null;
    emit(ProfileInitial());
  }

  /// Fuerza la recarga del perfil
  void forceReload() {
    add(LoadProfile(forceReload: true));
  }
}