import 'package:get_it/get_it.dart';
import 'package:meter_app/config/di/modules/analytics_module.dart';
import 'package:meter_app/config/di/modules/auth_module.dart';
import 'package:meter_app/config/di/modules/core_module.dart';
import 'package:meter_app/config/di/modules/custom_brick_module.dart';
import 'package:meter_app/config/di/modules/home_module.dart';
import 'package:meter_app/config/di/modules/map_module.dart';
import 'package:meter_app/config/di/modules/notifications_module.dart';
import 'package:meter_app/config/di/modules/premium_module.dart';
import 'package:meter_app/config/di/modules/projects_module.dart';

/// Service Locator global
final serviceLocator = GetIt.instance;

/// Inicializa todas las dependencias del proyecto de forma modular
///
/// Cada módulo es responsable de registrar sus propias dependencias:
/// - Core: SharedPreferences, Dio, Isar, Supabase, Cubits base
/// - Analytics: Firebase Analytics (GA4)
/// - Notifications: Firebase Cloud Messaging (Push Notifications)
/// - Auth: Autenticación y perfil de usuario
/// - Projects: Proyectos, metrados y resultados
/// - Map: Mapas, ubicaciones y búsqueda de lugares
/// - Home: Artículos y mediciones
/// - Premium: Sistema de suscripciones
/// - CustomBrick: Ladrillos personalizados
Future<void> initDependencies() async {
  // 1. Core - Dependencias base del sistema
  await registerCoreModule(serviceLocator);

  // 2. Analytics - Firebase Analytics (GA4)
  registerAnalyticsModule(serviceLocator);

  // 3. Notifications - Firebase Cloud Messaging
  registerNotificationsModule(serviceLocator);

  // 4. Auth - Autenticación y perfil
  registerAuthModule(serviceLocator);

  // 5. Projects - Proyectos, metrados y resultados
  registerProjectsModule(serviceLocator);

  // 6. Map - Mapas, ubicaciones y búsqueda
  registerMapModule(serviceLocator);

  // 7. Home - Artículos y mediciones
  registerHomeModule(serviceLocator);

  // 8. Premium - Sistema de suscripciones
  registerPremiumModule(serviceLocator);

  // 9. Custom Brick - Ladrillos personalizados
  registerCustomBrickModule(serviceLocator);
}
