
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/auth/user_model.dart';
import '../../../data/models/auth/user_profile_model.dart';
import '../../entities/auth/user_profile.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel?> signInWithGoogle();
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
  Future<UserProfileModel?> getUserProfileData(String userId);
  Future<void> updateUserProfileData(UserProfile userProfile);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> logout();
}