import 'package:get_it/get_it.dart';
import 'package:meter_app/data/datasources/home/muro/custom_brick_isar_data_source.dart';
import 'package:meter_app/data/repositories/home/muro/custom_brick_repository_impl.dart';
import 'package:meter_app/domain/datasources/home/muro/custom_brick_local_data_source.dart';
import 'package:meter_app/domain/repositories/home/muro/custom_brick_repository.dart';
import 'package:meter_app/domain/usecases/home/muro/custom_brick/check_custom_brick_name.dart';
import 'package:meter_app/domain/usecases/home/muro/custom_brick/delete_custom_brick.dart';
import 'package:meter_app/domain/usecases/home/muro/custom_brick/get_all_custom_bricks.dart';
import 'package:meter_app/domain/usecases/home/muro/custom_brick/save_custom_brick.dart';
import 'package:meter_app/domain/usecases/home/muro/custom_brick/update_custom_brick.dart';

/// Módulo de inyección de dependencias para ladrillos personalizados
void registerCustomBrickModule(GetIt sl) {
  // ==================== DATASOURCES ====================
  sl.registerFactory<CustomBrickLocalDataSource>(
    () => CustomBrickIsarDataSource(sl()),
  );

  // ==================== REPOSITORIES ====================
  sl.registerFactory<CustomBrickRepository>(
    () => CustomBrickRepositoryImpl(sl<CustomBrickLocalDataSource>()),
  );

  // ==================== USE CASES ====================
  sl.registerFactory(
    () => GetAllCustomBricks(sl<CustomBrickRepository>()),
  );

  sl.registerFactory(
    () => SaveCustomBrick(sl<CustomBrickRepository>()),
  );

  sl.registerFactory(
    () => UpdateCustomBrick(sl<CustomBrickRepository>()),
  );

  sl.registerFactory(
    () => DeleteCustomBrick(sl<CustomBrickRepository>()),
  );

  sl.registerFactory(
    () => CheckCustomBrickName(sl<CustomBrickRepository>()),
  );
}
