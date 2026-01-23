import 'package:get_it/get_it.dart';
import 'package:meter_app/data/datasources/auth/auth_remote_data_source_impl.dart';
import 'package:meter_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:meter_app/domain/datasources/auth/auth_remote_data_source.dart';
import 'package:meter_app/domain/repositories/auth/auth_repository.dart';
import 'package:meter_app/domain/usecases/auth/change_password.dart';
import 'package:meter_app/domain/usecases/auth/get_user_profile.dart';
import 'package:meter_app/domain/usecases/auth/update_user_profile.dart';
import 'package:meter_app/domain/usecases/use_cases.dart';
import 'package:meter_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

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
      deleteAccount: sl(),
      appUserCubit: sl(),
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
