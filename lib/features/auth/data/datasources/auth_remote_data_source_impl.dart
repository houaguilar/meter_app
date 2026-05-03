import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meter_app/core/constants/error/exceptions.dart';
import 'package:meter_app/core/constants/secrets/app_secrets.dart';
import 'package:meter_app/features/auth/domain/datasources/auth_remote_data_source.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';
import 'package:meter_app/features/auth/data/models/user_model.dart';
import 'package:meter_app/features/auth/data/models/user_profile_model.dart';

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
        emailRedirectTo: 'com.mts.metrashop:/callback',
      );

      if (response.user == null) {
        throw const ServerException('User is null!');
      }

      // El perfil se crea automáticamente via trigger en Supabase (handle_new_user)

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


        // Verificar que se creó correctamente
        final verifyProfile = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

      } else {
      }
    } catch (e) {
      // Lanzar la excepción para que el flujo de registro falle si no se puede crear el perfil
      throw ServerException('Error al crear perfil de usuario: $e');
    }
  }

  @override
  Future<UserModel?> signInWithApple() async {
    try {

      // 1. Generar nonce: el raw va a Supabase, el hash va a Apple
      final rawNonce = supabaseClient.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // 2. Solicitar credencial a Apple — se pasa el nonce HASHEADO
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null) {
        throw const ServerException('No se pudo obtener el token de Apple');
      }


      // 3. Autenticar con Supabase — se pasa el nonce RAW
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: identityToken,
        nonce: rawNonce,
      );

      if (response.user == null) {
        throw const ServerException('Error al autenticar con Supabase');
      }

      // 4. Apple solo devuelve el nombre en el PRIMER login — guardarlo si está disponible
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

      final name = fullName.isNotEmpty
          ? fullName
          : response.user!.userMetadata?['name'] ??
            response.user!.email?.split('@')[0] ??
            'Usuario';

      if (fullName.isNotEmpty) {
        await supabaseClient.auth.updateUser(
          UserAttributes(data: {'name': name}),
        );
      }


      return UserModel(
        id: response.user!.id,
        name: name,
        email: response.user!.email ?? '',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const ServerException('El usuario canceló el inicio de sesión');
      }
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    // Client IDs de Google Cloud Console (Cuenta Empresa)
    // IMPORTANTE: Estos deben coincidir con los configurados en:
    // 1. Google Cloud Console (OAuth 2.0 Client IDs)
    // 2. Supabase Dashboard (Authentication → Providers → Google)
    final webClientId = AppSecrets.googleWebClientId;
    final iosClientId = AppSecrets.googleIOSClientId;


    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      // Paso 1: Obtener usuario de Google
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const ServerException('El usuario canceló el inicio de sesión');
      }


      // Paso 2: Obtener tokens de autenticación
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ServerException('Error al obtener credenciales de Google');
      }


      // Paso 3: Autenticar con Supabase usando el ID token
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const ServerException('Error al autenticar con Supabase');
      }

      // El perfil se crea/verifica automáticamente via trigger en Supabase (handle_new_user)

      return UserModel(
        id: response.user!.id,
        name: response.user!.userMetadata?['name'] ??
             response.user!.email?.split('@')[0] ??
             'Usuario',
        email: response.user!.email ?? '',
      );
    } on AuthException catch (e) {
      // Errores específicos de Supabase Auth

      if (e.statusCode == '556' || e.statusCode == 556) {
        throw const ServerException(
          'Error de configuración de Google Sign-In. '
          'Por favor, verifica que:\n'
          '1. Los SHA-1 y SHA-256 están actualizados en Google Cloud Console\n'
          '2. El package name "com.mts.metrashop" está configurado correctamente\n'
          '3. Supabase tiene configurado el proveedor de Google\n\n'
          'Consulta GOOGLE_SIGNIN_SETUP.md para más detalles.'
        );
      }

      throw ServerException(e.message);
    } on PlatformException catch (e) {
      // Errores de la plataforma (Android/iOS)

      if (e.code == 'sign_in_failed' || e.code == 'network_error') {
        throw const ServerException(
          'Error al conectar con Google. Verifica tu conexión a internet.'
        );
      }

      throw ServerException(e.message ?? 'Error desconocido de la plataforma');
    } catch (e, stackTrace) {
      // Detectar si es una cancelación del usuario
      final errorMessage = e.toString().toLowerCase();
      final isCancellation = errorMessage.contains('canceló') ||
          errorMessage.contains('canceled') ||
          errorMessage.contains('cancelled');

      if (isCancellation) {
        // No loguear cancelaciones como errores inesperados
        rethrow;
      }

      // Cualquier otro error
      throw ServerException(e.toString());
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

      }

    } on PostgrestException catch (e) {
      throw ServerException('Error de base de datos: ${e.message}');
    } catch (e) {
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


    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al cambiar la contraseña: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      // Paso 1: Verificar que el usuario está autenticado
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw const ServerException('Usuario no autenticado');
      }

      final userId = session.user.id;
      final userEmail = session.user.email;
      final user = session.user;


      // Detectar el proveedor de autenticación
      final isGoogleUser = user.appMetadata['provider'] == 'google' ||
          (user.identities?.any((identity) => identity.provider == 'google') ?? false);


      // Paso 2: Re-autenticar solo si NO es usuario de Google
      if (!isGoogleUser) {
        // Re-autenticar usuarios de email/password
        try {
          await supabaseClient.auth.signInWithPassword(
            email: userEmail ?? '',
            password: password,
          );
        } on AuthException catch (e) {
          throw const ServerException('Contraseña incorrecta');
        }
      } else {
        // Para usuarios de Google, verificar que la sesión es válida y reciente
      }

      // Paso 3: Eliminar el usuario de Supabase Auth
      // IMPORTANTE: Gracias a ON DELETE CASCADE configurado en la base de datos,
      // al eliminar el usuario de auth.users, automáticamente se eliminarán:
      // - Su perfil (profiles)
      // - Sus negocios (locations)
      // - Sus proyectos (projects)
      // - Sus reviews
      // - Los productos de sus locations
      // - Las categorías de sus locations
      // - Sus archivos en storage (via trigger)
      // Por lo tanto, NO es necesario eliminar manualmente cada tabla.


      // Obtener el access token actual para enviarlo explícitamente
      final currentSession = supabaseClient.auth.currentSession;
      if (currentSession == null) {
        throw const ServerException('Sesión expirada. Por favor intenta nuevamente.');
      }
      final accessToken = currentSession.accessToken;

      try {
        final response = await supabaseClient.functions.invoke(
          'delete-user',
          body: {'user_id': userId},
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.status != 200) {
          throw ServerException(
            'Error al eliminar usuario del sistema de autenticación: ${response.data}',
          );
        }

      } catch (e) {
        // Si falla la Edge Function, los datos NO se eliminan (CASCADE no se ejecuta)
        throw ServerException(
          'Error al eliminar la cuenta. Por favor intenta nuevamente. '
          'Si el problema persiste, contacta a soporte.',
        );
      }

      // Paso 4: Cerrar sesión automáticamente
      await supabaseClient.auth.signOut();


    } on ServerException {
      rethrow;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al eliminar la cuenta: $e');
    }
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    try {

      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.mts.metrashop:/callback',
      );

    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al enviar correo de recuperación: $e');
    }
  }

  @override
  Future<void> verifyOTP({required String email, required String token}) async {
    try {

      final response = await supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.user == null) {
        throw const ServerException('Código de verificación inválido');
      }

    } on AuthException catch (e) {

      // Detectar códigos expirados o inválidos
      if (e.message.toLowerCase().contains('expired')) {
        throw const ServerException('El código ha expirado. Solicita uno nuevo.');
      } else if (e.message.toLowerCase().contains('invalid')) {
        throw const ServerException('Código inválido. Verifica e intenta nuevamente.');
      }

      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al verificar código: $e');
    }
  }

  @override
  Future<void> resendOTP(String email) async {
    try {

      await supabaseClient.auth.resend(
        type: OtpType.email,
        email: email,
        emailRedirectTo: 'com.mts.metrashop:/callback',
      );

    } on AuthException catch (e) {

      // Detectar rate limiting (demasiados intentos)
      if (e.message.toLowerCase().contains('rate limit')) {
        throw const ServerException('Demasiados intentos. Por favor espera un momento.');
      }

      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al reenviar código: $e');
    }
  }

  @override
  Future<void> verifyOTPAndUpdatePassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {

      // Paso 1: Verificar el OTP de tipo recovery
      // IMPORTANTE: esto autentica al usuario automáticamente
      final response = await supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      if (response.user == null) {
        throw const ServerException('Código de verificación inválido');
      }


      // Paso 2: Actualizar la contraseña (ya estamos autenticados)
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );


      // Paso 3: Cerrar la sesión para que el usuario deba iniciar sesión con la nueva contraseña
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {

      // Detectar errores específicos
      if (e.message.toLowerCase().contains('expired')) {
        throw const ServerException('El código ha expirado. Solicita uno nuevo.');
      } else if (e.message.toLowerCase().contains('invalid')) {
        throw const ServerException('Código inválido. Verifica e intenta nuevamente.');
      }

      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al actualizar contraseña: $e');
    }
  }
}