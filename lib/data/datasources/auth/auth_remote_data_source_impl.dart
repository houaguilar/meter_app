import 'package:flutter/services.dart';
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
    // Client IDs de Google Cloud Console
    // IMPORTANTE: Estos deben coincidir con los configurados en:
    // 1. Google Cloud Console (OAuth 2.0 Client IDs)
    // 2. Supabase Dashboard (Authentication → Providers → Google)
    const webClientId = '194976078807-jn7jhikh5s84tjhplur8j3onsosimpah.apps.googleusercontent.com';
    const iosClientId = '194976078807-6oevpfa8e61mtprl13akdf332rf48edd.apps.googleusercontent.com';

    print('🔐 Iniciando Google Sign-In...');
    print('📱 Package: com.jrd.metrashop');

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      // Paso 1: Obtener usuario de Google
      print('Paso 1: Solicitando inicio de sesión de Google...');
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Usuario canceló el inicio de sesión');
        throw const ServerException('El usuario canceló el inicio de sesión');
      }

      print('✅ Usuario de Google obtenido: ${googleUser.email}');

      // Paso 2: Obtener tokens de autenticación
      print('Paso 2: Obteniendo tokens de autenticación...');
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print('❌ No se pudo obtener el ID token');
        throw const ServerException('Error al obtener credenciales de Google');
      }

      print('✅ Tokens obtenidos correctamente');

      // Paso 3: Autenticar con Supabase usando el ID token
      print('Paso 3: Autenticando con Supabase...');
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        print('❌ Supabase no devolvió un usuario');
        throw const ServerException('Error al autenticar con Supabase');
      }

      print('✅ Usuario autenticado con Supabase: ${response.user!.email}');

      // Paso 4: Crear o actualizar perfil del usuario
      // NOTA: En Supabase, no hay diferencia entre "login" y "register" con Google.
      // Si el usuario no existe, se crea automáticamente. Si existe, se autentica.
      print('Paso 4: Creando/actualizando perfil...');
      await _createInitialUserProfile(
        userId: response.user!.id,
        name: response.user!.userMetadata?['name'] ??
              response.user!.email?.split('@')[0] ??
              'Usuario',
        email: response.user!.email ?? '',
      );

      print('✅ Google Sign-In completado exitosamente');

      return UserModel(
        id: response.user!.id,
        name: response.user!.userMetadata?['name'] ??
             response.user!.email?.split('@')[0] ??
             'Usuario',
        email: response.user!.email ?? '',
      );
    } on AuthException catch (e) {
      // Errores específicos de Supabase Auth
      print('❌ Error de Supabase Auth: ${e.message}');
      print('   Status Code: ${e.statusCode}');

      if (e.statusCode == '556' || e.statusCode == 556) {
        throw const ServerException(
          'Error de configuración de Google Sign-In. '
          'Por favor, verifica que:\n'
          '1. Los SHA-1 y SHA-256 están actualizados en Google Cloud Console\n'
          '2. El package name "com.jrd.metrashop" está configurado correctamente\n'
          '3. Supabase tiene configurado el proveedor de Google\n\n'
          'Consulta GOOGLE_SIGNIN_SETUP.md para más detalles.'
        );
      }

      throw ServerException(e.message);
    } on PlatformException catch (e) {
      // Errores de la plataforma (Android/iOS)
      print('❌ Error de plataforma: ${e.message}');
      print('   Code: ${e.code}');

      if (e.code == 'sign_in_failed' || e.code == 'network_error') {
        throw const ServerException(
          'Error al conectar con Google. Verifica tu conexión a internet.'
        );
      }

      throw ServerException(e.message ?? 'Error desconocido de la plataforma');
    } catch (e, stackTrace) {
      // Cualquier otro error
      print('❌ Error inesperado en signInWithGoogle: $e');
      print('   Stack trace: $stackTrace');
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