import 'package:get_it/get_it.dart';
import 'package:meter_app/config/di/modules/auth_module.dart';
import 'package:meter_app/config/di/modules/core_module.dart';
import 'package:meter_app/config/di/modules/custom_brick_module.dart';
import 'package:meter_app/config/di/modules/home_module.dart';
import 'package:meter_app/config/di/modules/map_module.dart';
import 'package:meter_app/config/di/modules/premium_module.dart';
import 'package:meter_app/config/di/modules/projects_module.dart';

/// Service Locator global
final serviceLocator = GetIt.instance;

/// Inicializa todas las dependencias del proyecto de forma modular
///
/// Cada módulo es responsable de registrar sus propias dependencias:
/// - Core: SharedPreferences, Dio, Isar, Supabase, Cubits base
/// - Auth: Autenticación y perfil de usuario
/// - Projects: Proyectos, metrados y resultados
/// - Map: Mapas, ubicaciones y búsqueda de lugares
/// - Home: Artículos y mediciones
/// - Premium: Sistema de suscripciones
/// - CustomBrick: Ladrillos personalizados
Future<void> initDependencies() async {
  // 1. Core - Dependencias base del sistema
  await registerCoreModule(serviceLocator);

  // 2. Auth - Autenticación y perfil
  registerAuthModule(serviceLocator);

  // 3. Projects - Proyectos, metrados y resultados
  registerProjectsModule(serviceLocator);

  // 4. Map - Mapas, ubicaciones y búsqueda
  registerMapModule(serviceLocator);

  // 5. Home - Artículos y mediciones
  registerHomeModule(serviceLocator);

  // 6. Premium - Sistema de suscripciones
  registerPremiumModule(serviceLocator);

  // 7. Custom Brick - Ladrillos personalizados
  registerCustomBrickModule(serviceLocator);
}
