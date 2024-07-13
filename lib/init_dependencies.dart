
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';
import 'package:meter_app/data/datasources/map/location_data_source_impl.dart';
import 'package:meter_app/data/datasources/projects/projects_isar_data_source.dart';
import 'package:meter_app/data/datasources/projects/projects_supabase_data_source.dart';
import 'package:meter_app/data/repositories/map/location_repository_impl.dart';
import 'package:meter_app/data/repositories/projects/projects_repository_impl.dart';
import 'package:meter_app/domain/datasources/projects/projects_local_data_source.dart';
import 'package:meter_app/domain/datasources/projects/projects_remote_data_source.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';
import 'package:meter_app/domain/repositories/projects/projects_repository.dart';
import 'package:meter_app/domain/usecases/map/save_location.dart';
import 'package:meter_app/domain/usecases/map/get_all_locations.dart';
import 'package:meter_app/domain/usecases/projects/get_all_projects.dart';
import 'package:meter_app/domain/usecases/projects/metrados/result/load_results_use_case.dart';
import 'package:meter_app/domain/usecases/projects/metrados/result/save_results_use_case.dart';
import 'package:meter_app/domain/usecases/projects/save_project.dart';
import 'package:meter_app/presentation/blocs/map/locations_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/metrados_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/result/result_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/projects_bloc.dart';
import 'package:meter_app/services/sync_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/common/cubits/app_user/app_user_cubit.dart';
import 'config/constants/secrets/app_secrets.dart';
import 'config/network/connection_checker.dart';
import 'data/datasources/auth/auth_remote_data_source_impl.dart';
import 'data/datasources/projects/metrado/metrados_isar_data_source.dart';
import 'data/datasources/projects/metrado/result/result_isar_data_source.dart';
import 'data/repositories/auth/auth_repository_impl.dart';
import 'data/repositories/projects/metrados/metrados_local_repository_impl.dart';
import 'data/repositories/projects/metrados/result/result_local_repository_impl.dart';
import 'domain/datasources/auth/auth_remote_data_source.dart';
import 'domain/datasources/map/location_data_source.dart';
import 'domain/datasources/projects/metrados/metrados_local_data_source.dart';
import 'domain/datasources/projects/metrados/result/result_local_data_source.dart';
import 'domain/entities/entities.dart';
import 'domain/repositories/auth/auth_repository.dart';
import 'domain/repositories/projects/metrados/metrados_local_repository.dart';
import 'domain/repositories/projects/metrados/result/result_local_repository.dart';
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

  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isarDirectory = p.join(dir.path, 'isar');
  await Directory(isarDirectory).create(recursive: true);
  final isar = await Isar.open([
    ProjectSchema,
    MetradoSchema,
    BloquetaSchema,
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

  print('Inicializando autenticación...');
  _initAuth();

  print('Inicializando proyectos...');
  _initProjects();

  _initLocations();
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
  // Bloc
    ..registerLazySingleton(
          () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        userLogout: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
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

  // SyncService
  print('Registrando SyncService...');
  serviceLocator.registerLazySingleton(() => SyncService(
    projectsRepository: serviceLocator<ProjectsRepository>(),
    connectionChecker: serviceLocator<ConnectionChecker>(),
  ));

  // Bloc
  print('Registrando ProjectsBloc...');
  serviceLocator.registerLazySingleton(() => ProjectsBloc(
    createProject: serviceLocator<CreateProject>(),
    getAllProjects: serviceLocator<GetAllProjects>(),
    deleteProject: serviceLocator<DeleteProject>(),
    editProject: serviceLocator<EditProject>(),
    syncService: serviceLocator<SyncService>(),
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
    ..registerFactory<LocationDataSource>(
          () => LocationDataSourceImpl(
        serviceLocator(),
      ),
    )
  // Repository
    ..registerFactory<LocationRepository>(
          () => LocationRepositoryImpl(
              serviceLocator(),
              serviceLocator(),
      ),
    )
  // Usecases
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
  // Bloc
    ..registerLazySingleton(
          () => LocationsBloc(
        saveLocation: serviceLocator(),
        getAllLocations: serviceLocator(),
      ),
    );
}