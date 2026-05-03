import 'package:get_it/get_it.dart';
import 'package:meter_app/core/app_config.dart';
import 'package:meter_app/features/premium/data/datasources/mock_premium_service_impl.dart';
import 'package:meter_app/features/premium/data/datasources/premium_local_data_source_impl.dart';
import 'package:meter_app/features/premium/data/datasources/premium_remote_data_source_impl.dart';
import 'package:meter_app/features/premium/data/datasources/revenuecat_service_impl.dart';
import 'package:meter_app/features/premium/data/repositories/premium_repository_impl.dart';
import 'package:meter_app/features/premium/domain/datasources/premium_local_data_source.dart';
import 'package:meter_app/features/premium/domain/datasources/premium_remote_data_source.dart';
import 'package:meter_app/features/premium/domain/datasources/premium_service_data_source.dart';
import 'package:meter_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:meter_app/features/premium/presentation/blocs/premium_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Módulo de inyección de dependencias para funcionalidad premium
void registerPremiumModule(GetIt sl) {
  // ==================== DATASOURCES ====================
  sl.registerLazySingleton<PremiumLocalDataSource>(
    () => PremiumLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PremiumRemoteDataSource>(
    () => PremiumRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Service DataSource Factory (Mock o RevenueCat según configuración)
  sl.registerLazySingleton<PremiumServiceDataSource>(
    () {
      if (AppConfig.useMockPremium) {
        return MockPremiumServiceImpl(sl<SupabaseClient>());
      } else {
        return RevenueCatServiceImpl(sl<SupabaseClient>());
      }
    },
  );

  // ==================== REPOSITORIES ====================
  sl.registerLazySingleton<PremiumRepository>(
    () {
      final repository = PremiumRepositoryImpl(
        serviceDataSource: sl<PremiumServiceDataSource>(),
        remoteDataSource: sl<PremiumRemoteDataSource>(),
        localDataSource: sl<PremiumLocalDataSource>(),
        connectionChecker: sl(),
      );

      // Configurar userId dinámicamente basado en autenticación
      final supabaseClient = sl<SupabaseClient>();

      // Listener para cambios de autenticación
      supabaseClient.auth.onAuthStateChange.listen((authChangeEvent) {
        final event = authChangeEvent.event;
        final session = authChangeEvent.session;

        if (event == AuthChangeEvent.signedIn && session?.user != null) {
          repository.setCurrentUserId(session!.user.id);
        }
      });

      // Configurar inmediatamente si ya hay un usuario autenticado
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null) {
        repository.setCurrentUserId(currentUser.id);
      }

      return repository;
    },
  );

  // ==================== BLOCS ====================
  sl.registerFactory(
    () => PremiumBloc(premiumRepository: sl<PremiumRepository>()),
  );
}
