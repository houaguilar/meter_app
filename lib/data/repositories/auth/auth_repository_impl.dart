
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/constant.dart';
import '../../../config/constants/error/exceptions.dart';
import '../../../config/constants/error/failures.dart';
import '../../../config/network/connection_checker.dart';
import '../../../domain/datasources/auth/auth_remote_data_source.dart';
import '../../../domain/entities/auth/user.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../models/auth/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(
      this.remoteDataSource,
      this.connectionChecker,
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
            email: session.user.email ?? '',
            name: '',
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
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
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