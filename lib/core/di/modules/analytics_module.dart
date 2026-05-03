import 'package:get_it/get_it.dart';
import 'package:meter_app/core/analytics/analytics_repository.dart';
import 'package:meter_app/core/analytics/firebase_analytics_service.dart';

/// Módulo para gestión de analytics (GA4)
void registerAnalyticsModule(GetIt sl) {
  // Analytics Service
  sl.registerLazySingleton<AnalyticsRepository>(
    () => FirebaseAnalyticsService(),
  );
}
