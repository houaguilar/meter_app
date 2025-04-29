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

  @override
  Future<UserModel?> signInWithGoogle() async {

    const webClientId = '194976078807-jn7jhikh5s84tjhplur8j3onsosimpah.apps.googleusercontent.com';

    const iosClientId = '194976078807-6oevpfa8e61mtprl13akdf332rf48edd.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
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

    return UserModel(
      id: response.user!.id,
      name: response.user!.userMetadata?['name'] ?? '',
      email: response.user!.email ?? '',
    );
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient.from('profiles').select().eq(
          'id',
          currentUserSession!.user.id,
        );
        return UserModel.fromJson(userData.first).copyWith(
          email: currentUserSession!.user.email,
        );
      }

      return null;
    } catch (e) {
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
          .single();

      if (response.isEmpty) {
        throw const ServerException('El perfil del usuario no existe.');
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
      final response = await supabaseClient
          .from('profiles')
          .update(userProfile.toJson())
          .eq('id', userProfile.id);

      if (response == null || response.isEmpty) {
        throw ServerException('No se pudo actualizar el perfil.');
      }

    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateProfileImage(String userId, String filePath) async {
    final String imageUrl = await uploadProfileImage(filePath, userId);

    try {
      final response = await supabaseClient
          .from('profiles')
          .update({'profileImageUrl': imageUrl})
          .eq('id', userId);

      if (response.error != null) {
        throw ServerException('Error al actualizar la URL de la imagen: ${response.error!.message}');
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException('Error al guardar la imagen en el perfil: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String filePath, String userId) async {
    final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      final fileBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        quality: 85,
      );

      if (fileBytes == null) {
        throw ServerException('Error al comprimir la imagen.');
      }

      await supabaseClient.storage.from('profile_images').uploadBinary(fileName, fileBytes);

      // Obtener la URL pública de la imagen
      final publicUrl = supabaseClient.storage.from('profile_images').getPublicUrl(fileName);
      return publicUrl;
    } on PostgrestException catch (e) {
      throw ServerException('Error al subir la imagen: ${e}');
    } catch (e) {
      throw ServerException('Error al subir la imagen: $e');
    }
  }



  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}