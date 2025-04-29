import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../config/usecase/usecase.dart';
import '../../../domain/entities/auth/user_profile.dart';
import '../../../domain/usecases/auth/update_profile_image.dart';
import '../../../domain/usecases/use_cases.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final UpdateProfileImage _updateUserProfileImage;
  UserProfile? _cachedProfile;

  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required UpdateProfileImage updateProfileImage,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        _updateUserProfileImage = updateProfileImage,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<SubmitProfile>(_onSubmitProfile);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    // Si ya tenemos el perfil en caché, no hacemos la petición nuevamente
    if (_cachedProfile != null) {
      emit(ProfileLoaded(userProfile: _cachedProfile!));
      return;
    }

    // Si no hay datos en caché, hacemos la solicitud al backend
    emit(ProfileLoading());
    final result = await _getUserProfile(NoParams());
    result.fold(
          (failure) => emit(ProfileError(failure.message)),
          (profile) {
        _cachedProfile = profile; // Guardamos el perfil en caché
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
        profileImageUrl: event.profileImageUrl ?? loadedState.userProfile.profileImageUrl,
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
            },
      );
    }
  }

  void _onUpdateProfileImage(UpdateProfileImageEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final loadedState = state as ProfileLoaded;

      emit(ProfileLoading()); // Mostrar loader mientras se procesa la imagen

      try {
        // Llama al caso de uso para subir la imagen y obtener la URL pública
        final result = await _updateUserProfileImage(
          UpdateProfileImageParams(
            userId: loadedState.userProfile.id,
            filePath: event.filePath,
          ),
        );

        // Verifica si el manejador sigue activo antes de llamar a emit
        if (emit.isDone) return;

        await result.fold(
              (failure) async {
            if (!emit.isDone) emit(ProfileError(failure.message));
          },
              (imageUrl) async {
            // Actualizar el perfil con la nueva URL
            final updatedProfile = loadedState.userProfile.copyWith(profileImageUrl: imageUrl);

            // Usar el caso de uso para guardar los datos en la base de datos
            final updateResult = await _updateUserProfile(
              UpdateUserProfileParams(profile: updatedProfile),
            );

            if (emit.isDone) return;

            await updateResult.fold(
                  (failure) async {
                if (!emit.isDone) emit(ProfileError(failure.message));
              },
                  (_) {
                if (!emit.isDone) {
                  _cachedProfile = updatedProfile; // Actualizar el caché local
                  emit(ProfileLoaded(userProfile: updatedProfile));
                }
              },
            );
          },
        );
      } catch (e) {
        if (!emit.isDone) emit(ProfileError('Error al actualizar la imagen de perfil.'));
      }
    }
  }

}
