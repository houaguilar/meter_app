
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/constant.dart';
import '../../../config/constants/error/exceptions.dart';
import '../../../config/constants/error/failures.dart';
import '../../../config/network/connection_checker.dart';
import '../../../domain/datasources/auth/auth_remote_data_source.dart';
import '../../../domain/entities/auth/user.dart';
import '../../../domain/entities/auth/user_profile.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../local/shared_preferences_helper.dart';
import '../../models/auth/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  final SharedPreferencesHelper sharedPreferencesHelper;
  const AuthRepositoryImpl(
      this.remoteDataSource,
      this.connectionChecker,
      this.sharedPreferencesHelper,
      );

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;

        if (session == null) {
          return left(Failure(message:'User not logged in!'));
        }

        return right(
          UserModel(
            id: session.user.id,
            name: session.user.userMetadata?['name'] ?? '', // Obtener el nombre de los metadatos, si está presente
            email: session.user.email ?? '',
          ),
        );
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure(message:'User not logged in!'));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final session = remoteDataSource.currentUserSession;
      if (session == null) {
        return left(Failure(message: 'User not logged in!'));
      }

      final profileModel = await remoteDataSource.getUserProfileData(session.user.id);

      if (profileModel == null) {
        // Si no hay perfil, crear uno vacío con los datos de la sesión
        final emptyProfile = UserProfile(
          id: session.user.id,
          name: session.user.userMetadata?['name'] ?? '',
          email: session.user.email ?? '',
          phone: '',
          employment: '',
          nationality: '',
          city: '',
          province: '',
          district: '',
        );
        return right(emptyProfile);
      }

      // Convertir el modelo a entidad de dominio
      final profile = profileModel.toDomain();
      return right(profile);

    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
      UserProfile userProfile) async {
    try {
      await remoteDataSource.updateUserProfileData(userProfile);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return _getUser(
          () async => await remoteDataSource.loginWithEmailPassword(
            email: email,
            password: password,
          ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
          () async => await remoteDataSource.signUpWithEmailPassword(
            name: name,
            email: email,
            password: password,
          ),
    );
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: "No internet connection"));
      }

      final userModel = await remoteDataSource.signInWithGoogle();

      if (userModel == null) {
        return left(Failure(message: "Google sign-in failed"));
      }

      return right(userModel);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, User>> _getUser(
      Future<User> Function() fn,
      ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(message: Constants.noConnectionErrorMessage));
      }
      final user = await fn();

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(message: Constants.noConnectionErrorMessage));
      }
      await remoteDataSource.changePassword(currentPassword, newPassword);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return right(await remoteDataSource.logout(),);
      }
      return right(await remoteDataSource.logout(),);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}