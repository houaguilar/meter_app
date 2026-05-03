import 'package:get_it/get_it.dart';
import 'package:meter_app/features/projects/data/datasources/metrado/metrados_isar_data_source.dart';
import 'package:meter_app/features/projects/data/datasources/metrado/result/result_isar_data_source.dart';
import 'package:meter_app/features/projects/data/datasources/projects_isar_data_source.dart';
import 'package:meter_app/features/projects/data/datasources/projects_supabase_data_source.dart';
import 'package:meter_app/features/projects/data/repositories/metrados/metrados_local_repository_impl.dart';
import 'package:meter_app/features/projects/data/repositories/metrados/result/result_local_repository_impl.dart';
import 'package:meter_app/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:meter_app/features/projects/domain/datasources/metrados/metrados_local_data_source.dart';
import 'package:meter_app/features/projects/domain/datasources/metrados/result/result_local_data_source.dart';
import 'package:meter_app/features/projects/domain/datasources/projects_local_data_source.dart';
import 'package:meter_app/features/projects/domain/datasources/projects_remote_data_source.dart';
import 'package:meter_app/features/projects/domain/repositories/metrados/metrados_local_repository.dart';
import 'package:meter_app/features/projects/domain/repositories/metrados/result/result_local_repository.dart';
import 'package:meter_app/features/projects/domain/repositories/projects_repository.dart';
import 'package:meter_app/features/projects/domain/usecases/delete_project.dart';
import 'package:meter_app/features/projects/domain/usecases/edit_project.dart';
import 'package:meter_app/features/projects/domain/usecases/get_all_projects.dart';
import 'package:meter_app/features/projects/domain/usecases/metrados/create_metrado.dart';
import 'package:meter_app/features/projects/domain/usecases/metrados/delete_metrado.dart';
import 'package:meter_app/features/projects/domain/usecases/metrados/edit_metrado.dart';
import 'package:meter_app/features/projects/domain/usecases/metrados/get_all_metrados.dart';
import 'package:meter_app/features/projects/domain/usecases/metrados/result/load_results_use_case.dart';
import 'package:meter_app/features/projects/domain/usecases/metrados/result/save_results_use_case.dart';
import 'package:meter_app/features/projects/domain/usecases/save_project.dart';
import 'package:meter_app/features/projects/presentation/blocs/metrados/combined_results/combined_results_bloc.dart';
import 'package:meter_app/features/projects/presentation/blocs/metrados/metrados_bloc.dart';
import 'package:meter_app/features/projects/presentation/blocs/metrados/result/result_bloc.dart';
import 'package:meter_app/features/projects/presentation/blocs/projects_bloc.dart';

/// Módulo de inyección de dependencias para proyectos y metrados
void registerProjectsModule(GetIt sl) {
  // ==================== DATASOURCES ====================
  sl.registerFactory<ProjectsRemoteDataSource>(
    () => ProjectsSupabaseDataSource(sl()),
  );

  sl.registerFactory<ProjectsLocalDataSource>(
    () => ProjectsIsarDataSource(sl()),
  );

  sl.registerFactory<MetradosLocalDataSource>(
    () => MetradosIsarDataSource(sl()),
  );

  sl.registerFactory<ResultLocalDataSource>(
    () => ResultIsarDataSource(sl()),
  );

  // ==================== REPOSITORIES ====================
  sl.registerFactory<ProjectsRepository>(
    () => ProjectsRepositoryImpl(
      sl<ProjectsLocalDataSource>(),
      sl<ProjectsRemoteDataSource>(),
      sl(), // ConnectionChecker
    ),
  );

  sl.registerFactory<MetradosLocalRepository>(
    () => MetradosLocalRepositoryImpl(sl<MetradosLocalDataSource>()),
  );

  sl.registerFactory<ResultLocalRepository>(
    () => ResultLocalRepositoryImpl(sl<ResultLocalDataSource>()),
  );

  // ==================== USE CASES - Projects ====================
  sl.registerFactory(() => CreateProject(sl<ProjectsRepository>()));
  sl.registerFactory(() => GetAllProjects(sl<ProjectsRepository>()));
  sl.registerFactory(() => DeleteProject(sl<ProjectsRepository>()));
  sl.registerFactory(() => EditProject(sl<ProjectsRepository>()));

  // ==================== USE CASES - Metrados ====================
  sl.registerFactory(() => CreateMetrado(sl<MetradosLocalRepository>()));
  sl.registerFactory(() => GetAllMetrados(sl<MetradosLocalRepository>()));
  sl.registerFactory(() => DeleteMetrado(sl<MetradosLocalRepository>()));
  sl.registerFactory(() => EditMetrado(sl<MetradosLocalRepository>()));

  // ==================== USE CASES - Results ====================
  sl.registerFactory(() => SaveResultsUseCase(sl<ResultLocalRepository>()));
  sl.registerFactory(() => LoadResultsUseCase(sl<ResultLocalRepository>()));

  // ==================== BLOCS ====================
  sl.registerLazySingleton(
    () => ProjectsBloc(
      createProject: sl<CreateProject>(),
      getAllProjects: sl<GetAllProjects>(),
      deleteProject: sl<DeleteProject>(),
      editProject: sl<EditProject>(),
    ),
  );

  sl.registerLazySingleton(
    () => MetradosBloc(
      createMetrado: sl<CreateMetrado>(),
      getAllMetrados: sl<GetAllMetrados>(),
      deleteMetrado: sl<DeleteMetrado>(),
      editMetrado: sl<EditMetrado>(),
    ),
  );

  sl.registerLazySingleton(
    () => ResultBloc(
      saveResultsUseCase: sl<SaveResultsUseCase>(),
      loadResultsUseCase: sl<LoadResultsUseCase>(),
    ),
  );

  sl.registerFactory(
    () => CombinedResultsBloc(
      getAllMetrados: sl<GetAllMetrados>(),
      loadResults: sl<LoadResultsUseCase>(),
    ),
  );
}
