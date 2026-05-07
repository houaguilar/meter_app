import 'package:get_it/get_it.dart';
import 'package:meter_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:meter_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:meter_app/features/auth/domain/datasources/auth_remote_data_source.dart';
import 'package:meter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:meter_app/features/auth/domain/usecases/change_password.dart';
import 'package:meter_app/features/auth/domain/usecases/get_user_profile.dart';
import 'package:meter_app/features/auth/domain/usecases/update_user_profile.dart';
import 'package:meter_app/features/auth/domain/usecases/current_user.dart';
import 'package:meter_app/features/auth/domain/usecases/user_login.dart';
import 'package:meter_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:meter_app/features/auth/domain/usecases/user_logout.dart';
import 'package:meter_app/features/auth/domain/usecases/user_sign_in_with_google.dart';
import 'package:meter_app/features/auth/domain/usecases/user_sign_in_with_apple.dart';
import 'package:meter_app/features/auth/domain/usecases/delete_account.dart';
import 'package:meter_app/features/auth/domain/usecases/reset_password_for_email.dart';
import 'package:meter_app/features/auth/domain/usecases/verify_otp.dart';
import 'package:meter_app/features/auth/domain/usecases/resend_otp.dart';
import 'package:meter_app/features/auth/domain/usecases/verify_otp_and_update_password.dart';
import 'package:meter_app/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:meter_app/features/perfil/presentation/blocs/profile_bloc.dart';

/// Módulo de inyección de dependencias para autenticación y perfil
void registerAuthModule(GetIt sl) {
  // ==================== DATASOURCES ====================
  sl.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // ==================== REPOSITORIES ====================
  sl.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      sl(), // AuthRemoteDataSource
      sl(), // ConnectionChecker
      sl(), // SharedPreferencesHelper
    ),
  );

  // ==================== USE CASES - Auth ====================
  sl.registerFactory(() => UserSignUp(sl()));
  sl.registerFactory(() => UserLogin(sl()));
  sl.registerFactory(() => UserLogout(sl()));
  sl.registerFactory(() => CurrentUser(sl()));
  sl.registerFactory(() => UserSignInWithGoogle(sl()));
  sl.registerFactory(() => UserSignInWithApple(sl()));
  sl.registerFactory(() => DeleteAccount(sl()));
  sl.registerFactory(() => ResetPasswordForEmail(sl()));
  sl.registerFactory(() => VerifyOTP(sl()));
  sl.registerFactory(() => ResendOTP(sl()));
  sl.registerFactory(() => VerifyOTPAndUpdatePassword(sl()));

  // ==================== USE CASES - Profile ====================
  sl.registerFactory(() => GetUserProfile(sl<AuthRepository>()));
  sl.registerFactory(() => UpdateUserProfile(sl<AuthRepository>()));
  sl.registerFactory(() => ChangePassword(sl<AuthRepository>()));

  // ==================== BLOCS ====================
  sl.registerLazySingleton(
    () => AuthBloc(
      userSignUp: sl(),
      userLogin: sl(),
      currentUser: sl(),
      userLogout: sl(),
      userSignInWithGoogle: sl(),
      userSignInWithApple: sl(),
      deleteAccount: sl(),
      changePassword: sl<ChangePassword>(),
      resendOTP: sl<ResendOTP>(),
      resetPasswordForEmail: sl<ResetPasswordForEmail>(),
      appUserCubit: sl(),
      sharedPrefs: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ProfileBloc(
      getUserProfile: sl<GetUserProfile>(),
      updateUserProfile: sl<UpdateUserProfile>(),
      changePassword: sl<ChangePassword>(),
    ),
  );
}
