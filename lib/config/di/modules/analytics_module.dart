import 'package:get_it/get_it.dart';
import 'package:meter_app/config/analytics/analytics_repository.dart';
import 'package:meter_app/config/analytics/firebase_analytics_service.dart';

/// Módulo para gestión de analytics (GA4)
void registerAnalyticsModule(GetIt sl) {
  // Analytics Service
  sl.registerLazySingleton<AnalyticsRepository>(
    () => FirebaseAnalyticsService(),
  );
}
