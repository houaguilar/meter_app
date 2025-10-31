
enum AppEnvironment {
  development, // Modo mock para desarrollo local
  sandbox,     // RevenueCat sandbox (testflight/pruebas)
  production,  // RevenueCat producción (App Store/Play Store)
}

class AppConfig {
  // ===================== CONFIGURACIÓN DE ENTORNO =====================
  // Cambia esto según el entorno que quieras usar:
  // - development: Usa MockPremiumService (no necesitas RevenueCat)
  // - sandbox: Usa RevenueCat en modo sandbox (para pruebas con StoreKit Sandbox)
  // - production: Usa RevenueCat en producción (para App Store/Play Store real)
  static const AppEnvironment currentEnvironment = AppEnvironment.development;

  // ===================== CONFIGURACIÓN DE PRODUCTOS =====================
  static const String premiumProductId = 'com.meterapp.premium.monthly';
  static const String premiumEntitlement = 'premium';
  static const String defaultOffering = 'default';

  // ===================== REVENUE CAT API KEYS =====================
  // IMPORTANTE: Obtén estas keys de tu dashboard de RevenueCat
  // https://app.revenuecat.com/apps

  // iOS API Keys
  static const String revenueCatApiKeyIosSandbox = 'appl_XXXXXXXXXXXXXXXXXXXXXX'; // Sandbox key
  static const String revenueCatApiKeyIosProduction = 'appl_XXXXXXXXXXXXXXXXXXXXXX'; // Production key

  // Android API Keys
  static const String revenueCatApiKeyAndroidSandbox = 'goog_XXXXXXXXXXXXXXXXXXXXXX'; // Sandbox key
  static const String revenueCatApiKeyAndroidProduction = 'goog_XXXXXXXXXXXXXXXXXXXXXX'; // Production key

  // ===================== CONFIGURACIÓN DE MOCK =====================
  static const int mockTrialDays = 7;
  static const Duration mockPurchaseDelay = Duration(seconds: 2);
  static const Duration mockErrorDelay = Duration(seconds: 1);

  // ===================== RETRY & SYNC CONFIGURATION =====================
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration cacheValidityDuration = Duration(hours: 1);

  // ===================== GETTERS DE UTILIDAD =====================
  static bool get useMockPremium => currentEnvironment == AppEnvironment.development;
  static bool get isDevelopment => currentEnvironment == AppEnvironment.development;
  static bool get isSandbox => currentEnvironment == AppEnvironment.sandbox;
  static bool get isProduction => currentEnvironment == AppEnvironment.production;
  static bool get useRevenueCat => isSandbox || isProduction;

  // Obtener la API key correcta según plataforma y entorno
  static String getRevenueCatApiKey() {
    if (currentEnvironment == AppEnvironment.development) {
      throw Exception('RevenueCat no debe usarse en modo development. Usa Mock.');
    }

    // Detectar plataforma
    const bool isIOS = bool.fromEnvironment('dart.library.io') &&
                       !bool.fromEnvironment('dart.vm.product');

    if (currentEnvironment == AppEnvironment.sandbox) {
      return isIOS ? revenueCatApiKeyIosSandbox : revenueCatApiKeyAndroidSandbox;
    } else {
      return isIOS ? revenueCatApiKeyIosProduction : revenueCatApiKeyAndroidProduction;
    }
  }

  // ===================== URLs =====================
  static const String termsOfServiceUrl = 'https://your-app.com/terms';
  static const String privacyPolicyUrl = 'https://your-app.com/privacy';

  // ===================== DEBUGGING =====================
  static bool get enableRevenueCatDebugLogs => !isProduction;
}