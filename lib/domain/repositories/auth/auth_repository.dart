
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../entities/auth/user.dart';
import '../../entities/auth/user_profile.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, UserProfile>> getUserProfile();

  Future<Either<Failure, void>> updateUserProfile(UserProfile userProfile);

  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> deleteAccount({required String password});

  Future<Either<Failure, void>> resetPasswordForEmail(String email);

  Future<Either<Failure, void>> verifyOTP({required String email, required String token});

  Future<Either<Failure, void>> resendOTP(String email);

  Future<Either<Failure, void>> verifyOTPAndUpdatePassword({
    required String email,
    required String token,
    required String newPassword,
  });

}