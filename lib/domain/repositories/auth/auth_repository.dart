
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../entities/auth/user.dart';
import '../../entities/auth/user_profile.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithPhonePassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> loginWithPhonePassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, UserProfile>> getUserProfile();

  Future<Either<Failure, void>> updateUserProfile(UserProfile userProfile);

  Future<Either<Failure, String>> uploadProfileImage(String userId, String filePath);

  Future<Either<Failure, void>> updateProfileImage(String userId, String filePath);

  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);

  Future<Either<Failure, void>> logout();

}