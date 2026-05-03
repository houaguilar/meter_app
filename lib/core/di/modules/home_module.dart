import 'package:get_it/get_it.dart';
import 'package:meter_app/data/datasources/home/inicio/article_remote_data_source_impl.dart';
import 'package:meter_app/data/repositories/home/inicio/article_repository_impl.dart';
import 'package:meter_app/data/repositories/home/inicio/measurement_repository_impl.dart';
import 'package:meter_app/features/losas/data/repositories/slab_repository_impl.dart';
import 'package:meter_app/features/muro/data/repositories/wall_material_repository_impl.dart';
import 'package:meter_app/features/pisos/data/repositories/floor_repository_impl.dart';
import 'package:meter_app/features/tarrajeo/data/repositories/coating_repository_impl.dart';
import 'package:meter_app/domain/datasources/home/inicio/article_remote_data_source.dart';
import 'package:meter_app/domain/repositories/home/inicio/article_repository.dart';
import 'package:meter_app/domain/repositories/home/inicio/measurement_repository.dart';
import 'package:meter_app/features/losas/domain/repositories/slab_repository.dart';
import 'package:meter_app/features/muro/domain/repositories/wall_material_repository.dart';
import 'package:meter_app/features/pisos/domain/repositories/floor_repository.dart';
import 'package:meter_app/features/tarrajeo/domain/repositories/coating_repository.dart';
import 'package:meter_app/domain/usecases/home/inicio/get_articles_usecase.dart';
import 'package:meter_app/domain/usecases/home/inicio/get_measurement_items.dart';
import 'package:meter_app/presentation/blocs/home/inicio/article_bloc.dart';
import 'package:meter_app/presentation/blocs/home/inicio/measurement_bloc.dart';

/// Módulo de inyección de dependencias para artículos y mediciones del home
void registerHomeModule(GetIt sl) {
  // ==================== REPOSITORIES (sin dependencias externas) ====================
  sl.registerLazySingleton<SlabRepository>(() => SlabRepositoryImpl());
  sl.registerLazySingleton<CoatingRepository>(() => CoatingRepositoryImpl());
  sl.registerLazySingleton<FloorRepository>(() => FloorRepositoryImpl());
  sl.registerLazySingleton<WallMaterialRepository>(() => WallMaterialRepositoryImpl());

  // ==================== DATASOURCES ====================
  sl.registerFactory<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSourceImpl(sl()),
  );

  // ==================== REPOSITORIES ====================
  sl.registerFactory<ArticleRepository>(
    () => ArticleRepositoryImpl(
      sl<ArticleRemoteDataSource>(),
      sl(), // ConnectionChecker
    ),
  );

  sl.registerLazySingleton<MeasurementRepository>(
    () => MeasurementRepositoryImpl(),
  );

  // ==================== USE CASES ====================
  sl.registerFactory(() => GetArticlesUseCase(sl<ArticleRepository>()));
  sl.registerLazySingleton(
    () => GetMeasurementItems(sl<MeasurementRepository>()),
  );

  // ==================== BLOCS ====================
  sl.registerLazySingleton(
    () => ArticleBloc(getArticlesUseCase: sl()),
  );

  sl.registerFactory(
    () => MeasurementBloc(sl<GetMeasurementItems>()),
  );
}
