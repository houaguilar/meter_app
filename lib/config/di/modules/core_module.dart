import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';
import 'package:meter_app/config/common/cubits/app_user/app_user_cubit.dart';
import 'package:meter_app/config/common/cubits/shimmer/loader_cubit.dart';
import 'package:meter_app/config/constants/secrets/app_secrets.dart';
import 'package:meter_app/config/network/connection_checker.dart';
import 'package:meter_app/data/local/shared_preferences_helper.dart';
import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/domain/entities/home/acero/viga/steel_beam.dart';
import 'package:meter_app/domain/entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import 'package:meter_app/domain/entities/home/estructuras/columna/columna.dart';
import 'package:meter_app/domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import 'package:meter_app/domain/entities/home/estructuras/solado/solado.dart';
import 'package:meter_app/domain/entities/home/estructuras/viga/viga.dart';
import 'package:meter_app/domain/entities/home/losas/losas.dart';
import 'package:meter_app/domain/entities/home/muro/custom_brick.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/premium/premium_status_model.dart';
import '../../../domain/entities/home/acero/columna/steel_column.dart';
import '../../../domain/entities/home/acero/losa_maciza/steel_slab.dart';
import '../../../domain/entities/home/acero/zapata/steel_footing.dart';

/// Módulo de inyección de dependencias core (base del sistema)
/// Contiene: SharedPreferences, Dio, Isar, Supabase, y utilidades base
Future<void> registerCoreModule(GetIt sl) async {
  // ==================== SHARED PREFERENCES ====================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(sharedPreferences: sl()),
  );

  // ==================== DIO ====================
  final dio = Dio();
  sl.registerLazySingleton<Dio>(() => dio);

  // ==================== ISAR ====================
  final dir = await getApplicationDocumentsDirectory();
  final isarDirectory = p.join(dir.path, 'isar');
  await Directory(isarDirectory).create(recursive: true);

  final isar = await Isar.open(
    [
      ProjectSchema,
      MetradoSchema,
      PisoSchema,
      LadrilloSchema,
      TarrajeoSchema,
      LosaAligeradaSchema,
      ColumnaSchema,
      VigaSchema,
      SteelBeamSchema,
      SteelColumnSchema,
      SteelFootingSchema,
      SteelSlabSchema,
      CustomBrickSchema,
      SobrecimientoSchema,
      CimientoCorridoSchema,
      SoladoSchema,
      PremiumStatusModelSchema,
    ],
    directory: isarDirectory,
    inspector: true,
  );

  sl.registerLazySingleton<Isar>(() => isar);

  // ==================== SUPABASE ====================
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  sl.registerLazySingleton(() => supabase.client);

  // ==================== NETWORK & CONNECTIVITY ====================
  sl.registerFactory(() => InternetConnection());

  sl.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(sl()),
  );

  // ==================== CUBITS ====================
  sl.registerLazySingleton(() => AppUserCubit());
  sl.registerLazySingleton<LoaderCubit>(() => LoaderCubit());
}
