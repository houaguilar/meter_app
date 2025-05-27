
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';

import 'package:meter_app/config/analytics/analytics_repository.dart';
import 'package:meter_app/config/analytics/firebase_analytics_service.dart';
import 'package:meter_app/data/datasources/map/location_data_source_impl.dart';
import 'package:meter_app/data/datasources/map/place_remote_data_source_impl.dart';
import 'package:meter_app/data/datasources/projects/projects_isar_data_source.dart';
import 'package:meter_app/data/datasources/projects/projects_supabase_data_source.dart';
import 'package:meter_app/data/repositories/map/location_repository_impl.dart';
import 'package:meter_app/data/repositories/projects/projects_repository_impl.dart';
import 'package:meter_app/domain/datasources/map/place_remote_data_source.dart';
import 'package:meter_app/domain/datasources/projects/projects_local_data_source.dart';
import 'package:meter_app/domain/datasources/projects/projects_remote_data_source.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';
import 'package:meter_app/domain/repositories/projects/projects_repository.dart';
import 'package:meter_app/domain/usecases/auth/update_profile_image.dart';
import 'package:meter_app/domain/usecases/map/save_location.dart';
import 'package:meter_app/domain/usecases/map/get_all_locations.dart';
import 'package:meter_app/domain/usecases/projects/get_all_projects.dart';
import 'package:meter_app/domain/usecases/projects/metrados/result/load_results_use_case.dart';
import 'package:meter_app/domain/usecases/projects/metrados/result/save_results_use_case.dart';
import 'package:meter_app/domain/usecases/projects/save_project.dart';
import 'package:meter_app/presentation/blocs/home/inicio/article_bloc.dart';
import 'package:meter_app/presentation/blocs/home/inicio/measurement_bloc.dart';
import 'package:meter_app/presentation/blocs/map/locations_bloc.dart';
import 'package:meter_app/presentation/blocs/map/place/place_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/metrados_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/result/result_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/projects_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/common/cubits/app_user/app_user_cubit.dart';
import 'config/common/cubits/shimmer/loader_cubit.dart';
import 'config/constants/secrets/app_secrets.dart';
import 'config/network/connection_checker.dart';
import 'data/datasources/auth/auth_remote_data_source_impl.dart';
import 'data/datasources/home/inicio/article_remote_data_source_impl.dart';
import 'data/datasources/projects/metrado/metrados_isar_data_source.dart';
import 'data/datasources/projects/metrado/result/result_isar_data_source.dart';
import 'data/local/shared_preferences_helper.dart';
import 'data/repositories/auth/auth_repository_impl.dart';
import 'data/repositories/home/inicio/article_repository_impl.dart';
import 'data/repositories/home/inicio/measurement_repository_impl.dart';
import 'data/repositories/map/place_repository_impl.dart';
import 'data/repositories/projects/metrados/metrados_local_repository_impl.dart';
import 'data/repositories/projects/metrados/result/result_local_repository_impl.dart';
import 'domain/datasources/auth/auth_remote_data_source.dart';
import 'domain/datasources/home/inicio/article_remote_data_source.dart';
import 'domain/datasources/map/location_data_source.dart';
import 'domain/datasources/projects/metrados/metrados_local_data_source.dart';
import 'domain/datasources/projects/metrados/result/result_local_data_source.dart';
import 'domain/entities/entities.dart';
import 'domain/repositories/auth/auth_repository.dart';
import 'domain/repositories/home/inicio/article_repository.dart';
import 'domain/repositories/home/inicio/measurement_repository.dart';
import 'domain/repositories/map/place_repository.dart';
import 'domain/repositories/projects/metrados/metrados_local_repository.dart';
import 'domain/repositories/projects/metrados/result/result_local_repository.dart';
import 'domain/usecases/auth/change_password.dart';
import 'domain/usecases/home/inicio/get_articles_usecase.dart';
import 'domain/usecases/home/inicio/get_measurement_items.dart';
import 'domain/usecases/map/get_place_details.dart';
import 'domain/usecases/map/get_place_suggestions.dart';
import 'domain/usecases/map/upload_image.dart';
import 'domain/usecases/projects/delete_project.dart';
import 'domain/usecases/projects/edit_project.dart';
import 'domain/usecases/projects/metrados/create_metrado.dart';
import 'domain/usecases/projects/metrados/delete_metrado.dart';
import 'domain/usecases/projects/metrados/edit_metrado.dart';
import 'domain/usecases/projects/metrados/get_all_metrados.dart';
import 'domain/usecases/use_cases.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'package:path/path.dart' as p;


final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  print('Inicializando dependencias...');
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Initialize SharedPreferencesHelper
  serviceLocator.registerLazySingleton<SharedPreferencesHelper>(
        () => SharedPreferencesHelper(sharedPreferences: serviceLocator()),
  );

 /* serviceLocator.registerLazySingleton<AnalyticsRepository>(
        () => FirebaseAnalyticsService(),
  );*/

  // Initialize Dio
  final dio = Dio();
  serviceLocator.registerLazySingleton<Dio>(() => dio);

  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isarDirectory = p.join(dir.path, 'isar');
  await Directory(isarDirectory).create(recursive: true);
  final isar = await Isar.open([
    ProjectSchema,
    MetradoSchema,
    PisoSchema,
    LadrilloSchema,
  ],
    directory: isarDirectory,
    inspector: true,
  );

  print('Registrando Isar...');
  serviceLocator.registerLazySingleton<Isar>(() => isar);

  // Initialize Supabase
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  print('Registrando SupabaseClient...');
  serviceLocator.registerLazySingleton(() => supabase.client);

  // Register other dependencies
  print('Registrando InternetConnection...');
  serviceLocator.registerFactory(() => InternetConnection());

  print('Registrando AppUserCubit...');
  serviceLocator.registerLazySingleton(() => AppUserCubit());

  print('Registrando ConnectionChecker...');
  serviceLocator.registerFactory<ConnectionChecker>(() => ConnectionCheckerImpl(serviceLocator()));

  serviceLocator.registerLazySingleton<LoaderCubit>(() => LoaderCubit());

  print('Inicializando autenticación...');
  _initAuth();
  _initProfile();

  _initMeasurementItems();
  _initArticles();

  print('Inicializando proyectos...');
  _initProjects();

  _initLocations();

  await _initMapAndSearch();

}

Future<void> _initAuth() async {
  print('Inicializando autenticación...');

  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
          () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
  // Repository
    ..registerFactory<AuthRepository>(
          () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
  // Usecases
    ..registerFactory(
          () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
          () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
          () => UserLogout(
        serviceLocator(),
      ),
    )
    ..registerFactory(
          () => CurrentUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
          () => UserSignInWithGoogle(
        serviceLocator(),
      ),
    )
  // Bloc
    ..registerLazySingleton(
          () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        userLogout: serviceLocator(),
        userSignInWithGoogle: serviceLocator(),
        appUserCubit: serviceLocator(),
 //       analytics: serviceLocator<AnalyticsRepository>(),
      ),
    );
}

void _initProfile() {
  print('Inicializando perfil...');

  serviceLocator.registerFactory(
        () => ChangePassword(serviceLocator<AuthRepository>()),
  );
  // UseCases
  serviceLocator
    ..registerFactory(
          () => GetUserProfile(serviceLocator<AuthRepository>()),
    )
    ..registerFactory(
          () => UpdateUserProfile(serviceLocator<AuthRepository>()),
    )
    ..registerFactory(
          () => UpdateProfileImage(serviceLocator<AuthRepository>()),
    );

  // Bloc
  serviceLocator.registerLazySingleton(
        () => ProfileBloc(
      getUserProfile: serviceLocator<GetUserProfile>(),
      updateUserProfile: serviceLocator<UpdateUserProfile>(),
      updateProfileImage: serviceLocator<UpdateProfileImage>(),
          changePassword: serviceLocator<ChangePassword>(),
        ),
  );
}

void _initMeasurementItems() {
  // Repositorio
  serviceLocator.registerLazySingleton<MeasurementRepository>(
          () => MeasurementRepositoryImpl());

  // Caso de Uso
  serviceLocator.registerLazySingleton(
          () => GetMeasurementItems(serviceLocator<MeasurementRepository>()));

  // Bloc
  serviceLocator.registerFactory(
          () => MeasurementBloc(serviceLocator<GetMeasurementItems>()));
}

void _initArticles() {
  // DataSource
  serviceLocator.registerFactory<ArticleRemoteDataSource>(
        () => ArticleRemoteDataSourceImpl(serviceLocator<SupabaseClient>()),
  );
  // Repository
  serviceLocator.registerFactory<ArticleRepository>(
        () => ArticleRepositoryImpl(
      serviceLocator<ArticleRemoteDataSource>(),
      serviceLocator<ConnectionChecker>(),
    ),
  );
  // UseCase
  serviceLocator.registerFactory(() => GetArticlesUseCase(serviceLocator<ArticleRepository>()));
  // Bloc
  serviceLocator.registerLazySingleton(() => ArticleBloc(getArticlesUseCase: serviceLocator()));
}

void _initProjects() {
  // Datasource
  serviceLocator.registerFactory<ProjectsRemoteDataSource>(
        () => ProjectsSupabaseDataSource(serviceLocator<SupabaseClient>()),
  );
  print('Registrando ProjectsLocalDataSource...');
  serviceLocator.registerFactory<ProjectsLocalDataSource>(
        () => ProjectsIsarDataSource(serviceLocator<Isar>()),
  );

  print('Registrando MetradosLocalDataSource...');
  serviceLocator.registerFactory<MetradosLocalDataSource>(
        () => MetradosIsarDataSource(serviceLocator<Isar>()),
  );

  print('Registrando ResultLocalDataSource...');
  serviceLocator.registerLazySingleton<ResultLocalDataSource>(
        () => ResultIsarDataSource(serviceLocator<Isar>()),
  );

  // Repository
  print('Registrando ProjectsLocalRepository...');
  serviceLocator.registerFactory<ProjectsRepository>(
          () => ProjectsRepositoryImpl(
          serviceLocator<ProjectsLocalDataSource>(),
          serviceLocator<ProjectsRemoteDataSource>(),
          serviceLocator<ConnectionChecker>()
      )
  );

  print('Registrando MetradosLocalRepository...');
  serviceLocator.registerFactory<MetradosLocalRepository>(
        () => MetradosLocalRepositoryImpl(serviceLocator<MetradosLocalDataSource>()),
  );

  print('Registrando ResultLocalRepository...');
  serviceLocator.registerLazySingleton<ResultLocalRepository>(
        () => ResultLocalRepositoryImpl(serviceLocator<ResultLocalDataSource>()),
  );

  // Usecases
  print('Registrando CreateProject...');
  serviceLocator.registerFactory(() => CreateProject(serviceLocator<ProjectsRepository>()));
  print('Registrando GetAllProjects...');
  serviceLocator.registerFactory(() => GetAllProjects(serviceLocator<ProjectsRepository>()));
  print('Registrando DeleteProject...');
  serviceLocator.registerFactory(() => DeleteProject(serviceLocator<ProjectsRepository>()));
  print('Registrando EditProject...');
  serviceLocator.registerFactory(() => EditProject(serviceLocator<ProjectsRepository>()));

  // Usecases para Metrados
  print('Registrando CreateMetrado...');
  serviceLocator.registerFactory(() => CreateMetrado(serviceLocator<MetradosLocalRepository>()));
  print('Registrando GetAllMetrados...');
  serviceLocator.registerFactory(() => GetAllMetrados(serviceLocator<MetradosLocalRepository>()));
  print('Registrando DeleteMetrado...');
  serviceLocator.registerFactory(() => DeleteMetrado(serviceLocator<MetradosLocalRepository>()));
  print('Registrando EditMetrado...');
  serviceLocator.registerFactory(() => EditMetrado(serviceLocator<MetradosLocalRepository>()));

  // Usecases para Result
  print('Registrando SaveResult...');
  serviceLocator.registerFactory(() => SaveResultsUseCase(serviceLocator<ResultLocalRepository>()));
  print('Registrando LoadResults...');
  serviceLocator.registerFactory(() => LoadResultsUseCase(serviceLocator<ResultLocalRepository>()));

  // Bloc
  print('Registrando ProjectsBloc...');
  serviceLocator.registerLazySingleton(() => ProjectsBloc(
    createProject: serviceLocator<CreateProject>(),
    getAllProjects: serviceLocator<GetAllProjects>(),
    deleteProject: serviceLocator<DeleteProject>(),
    editProject: serviceLocator<EditProject>(),
  ));

  print('Registrando MetradosBloc...');
  serviceLocator.registerLazySingleton(() => MetradosBloc(
    createMetrado: serviceLocator<CreateMetrado>(),
    getAllMetrados: serviceLocator<GetAllMetrados>(),
    deleteMetrado: serviceLocator<DeleteMetrado>(),
    editMetrado: serviceLocator<EditMetrado>(),
  ));

  print('Registrando ResultBloc...');
  serviceLocator.registerLazySingleton(() => ResultBloc(
    saveResultsUseCase: serviceLocator<SaveResultsUseCase>(),
    loadResultsUseCase: serviceLocator<LoadResultsUseCase>(),
  ));
}

Future<void> _initLocations() async {
  print('Inicializando locations...');

  // Datasource
  serviceLocator
      .registerFactory<LocationDataSource>(
        () => LocationDataSourceImpl(
      serviceLocator(),
    ),
  );
  // Repository
  serviceLocator
      .registerFactory<LocationRepository>(
        () => LocationRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
    ),
  );

  // Usecases
  serviceLocator
    ..registerFactory(
          () => SaveLocation(
        serviceLocator(),
      ),
    )
    ..registerFactory(
          () => GetAllLocations(
        serviceLocator(),
      ),
    )
    ..registerFactory(
            () => UploadImage(
          serviceLocator(),
        )
    );

  // Bloc
  serviceLocator
      .registerLazySingleton(
        () => LocationsBloc(
      saveLocation: serviceLocator(),
      getAllLocations: serviceLocator(),
      uploadImage: serviceLocator(),
    ),
  );
}

Future<void> _initMapAndSearch() async {
  print('Inicializando Mapas y Búsquedas...');

  // Data Source
  serviceLocator.registerFactory<PlaceRemoteDataSource>(
        () => PlaceRemoteDataSourceImpl(
      dio: serviceLocator(),
      apiKey: AppSecrets.googleApiKey,
    ),
  );

  // Repository
  serviceLocator.registerFactory<PlaceRepository>(
          () => PlaceRepositoryImpl(serviceLocator())
  );

  // UseCases
  serviceLocator
    ..registerFactory(() => GetPlaceSuggestions(serviceLocator()))
    ..registerFactory(() => GetPlaceDetails(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(() => PlaceBloc(
    getPlaceSuggestions: serviceLocator(),
    getPlaceDetails: serviceLocator(),
  ));
}