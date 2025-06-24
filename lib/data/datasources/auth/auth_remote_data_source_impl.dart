import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constants/error/exceptions.dart';
import '../../../domain/datasources/auth/auth_remote_data_source.dart';
import '../../../domain/entities/auth/user_profile.dart';
import '../../models/auth/user_model.dart';
import '../../models/auth/user_profile_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw const ServerException('User is null!');
      }

      return UserModel(
        id: response.user!.id,
        name: response.user!.userMetadata?['name'] ?? '',
        email: response.user!.email ?? '',
      );

    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'name': name,
        },
      );
      if (response.user == null) {
        throw const ServerException('User is null!');
      }

      // Crear un perfil para el usuario recién registrado
      await _createInitialUserProfile(
        userId: response.user!.id,
        name: name,
        email: email,
      );

      return UserModel(
        id: response.user!.id,
        name: name,
        email: email,
      );

    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Método para crear el perfil inicial del usuario
  Future<void> _createInitialUserProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      // Verificar si ya existe un perfil para este usuario
      final existingProfiles = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId);

      if (existingProfiles.isEmpty) {
        // Crear un nuevo perfil si no existe
        await supabaseClient.from('profiles').insert({
          'id': userId,
          'name': name,
          'email': email,
          'phone': '',
          'employment': '',
          'nationality': '',
          'city': '',
          'province': '',
          'district': '',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error al crear perfil inicial: $e');
      // No lanzamos excepción para no interrumpir el flujo de registro
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    const webClientId = '194976078807-jn7jhikh5s84tjhplur8j3onsosimpah.apps.googleusercontent.com';
    const iosClientId = '194976078807-6oevpfa8e61mtprl13akdf332rf48edd.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: accessToken,
      );

      if (response.user == null) {
        return null;
      }

      // Crear un perfil para el usuario si es su primera vez
      await _createInitialUserProfile(
        userId: response.user!.id,
        name: response.user!.userMetadata?['name'] ?? response.user!.email ?? '',
        email: response.user!.email ?? '',
      );

      return UserModel(
        id: response.user!.id,
        name: response.user!.userMetadata?['name'] ?? '',
        email: response.user!.email ?? '',
      );
    } catch (e) {
      print('Error en signInWithGoogle: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient.from('profiles').select().eq(
          'id',
          currentUserSession!.user.id,
        );

        if (userData != null && userData.isNotEmpty) {
          return UserModel.fromJson(userData.first).copyWith(
            email: currentUserSession!.user.email,
          );
        } else {
          // Si no hay datos de perfil pero hay sesión, intentamos crear el perfil
          await _createInitialUserProfile(
            userId: currentUserSession!.user.id,
            name: currentUserSession!.user.userMetadata?['name'] ?? '',
            email: currentUserSession!.user.email ?? '',
          );

          // Volvemos a intentar obtener el perfil
          final newUserData = await supabaseClient.from('profiles').select().eq(
            'id',
            currentUserSession!.user.id,
          );

          if (newUserData != null && newUserData.isNotEmpty) {
            return UserModel.fromJson(newUserData.first).copyWith(
              email: currentUserSession!.user.email,
            );
          }
        }
      }

      return null;
    } catch (e) {
      print('Error en getCurrentUserData: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserProfileModel?> getUserProfileData(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Si no existe el perfil, intentamos crearlo
        await _createInitialUserProfile(
          userId: userId,
          name: currentUserSession?.user.userMetadata?['name'] ?? '',
          email: currentUserSession?.user.email ?? '',
        );

        // Volvemos a intentar obtener el perfil
        final newResponse = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (newResponse == null) {
          throw const ServerException('El perfil del usuario no existe.');
        }

        return UserProfileModel.fromJson(newResponse);
      }

      return UserProfileModel.fromJson(response);

    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateUserProfileData(UserProfile userProfile) async {
    try {
      // Crear un mapa solo con los campos que existen en la base de datos
      final updateData = <String, dynamic>{};

      // Solo agregar campos que no sean nulos o vacíos
      if (userProfile.name.isNotEmpty) {
        updateData['name'] = userProfile.name;
      }
      if (userProfile.phone.isNotEmpty) {
        updateData['phone'] = userProfile.phone;
      }
      if (userProfile.employment.isNotEmpty) {
        updateData['employment'] = userProfile.employment;
      }
      if (userProfile.nationality.isNotEmpty) {
        updateData['nationality'] = userProfile.nationality;
      }
      if (userProfile.city.isNotEmpty) {
        updateData['city'] = userProfile.city;
      }
      if (userProfile.province.isNotEmpty) {
        updateData['province'] = userProfile.province;
      }
      if (userProfile.district.isNotEmpty) {
        updateData['district'] = userProfile.district;
      }

      // Agregar timestamp de actualización
      updateData['updated_at'] = DateTime.now().toIso8601String();

      // Realizar la actualización solo si hay datos para actualizar
      if (updateData.isNotEmpty) {
        final result = await supabaseClient
            .from('profiles')
            .update(updateData)
            .eq('id', userProfile.id)
            .select(); // Importante: agregar .select() para obtener respuesta

        // Verificar que la actualización fue exitosa
        if (result.isEmpty) {
          throw const ServerException('No se encontró el perfil para actualizar.');
        }

        print('Perfil actualizado exitosamente: ${result.first}');
      }

    } on PostgrestException catch (e) {
      print('Error PostgrestException: ${e.message}');
      throw ServerException('Error de base de datos: ${e.message}');
    } catch (e) {
      print('Error general en updateUserProfileData: $e');
      throw ServerException('Error al actualizar el perfil: $e');
    }
  }
  
  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      // Validate user is logged in
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw const ServerException('Usuario no autenticado');
      }

      // Change password with Supabase
      final response = await supabaseClient.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      // Verificar que la actualización fue exitosa
      if (response.user == null) {
        throw const ServerException('Error al actualizar la contraseña');
      }

      print('Contraseña actualizada exitosamente para usuario: ${response.user!.id}');

    } on AuthException catch (e) {
      print('Error AuthException: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      print('Error general en changePassword: $e');
      throw ServerException('Error al cambiar la contraseña: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      print('Error en logout: $e');
      throw ServerException('Error al cerrar sesión: $e');
    }
  }
}