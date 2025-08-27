
class AppConfig {
  // Toggle principal para modo mock
  static const bool useMockPremium = true; // Cambiar a false para producción

  // Configuración de productos
  static const String premiumProductId = 'com.meterapp.premium.monthly';
  static const String premiumEntitlement = 'premium';
  static const String defaultOffering = 'default';

  // Revenue Cat
  static const String revenueCatApiKey = 'your_revenuecat_api_key_here';

  // Configuración de mock
  static const int mockTrialDays = 7;
  static const Duration mockPurchaseDelay = Duration(seconds: 2);
  static const Duration mockErrorDelay = Duration(seconds: 1);

  // Getters de utilidad
  static bool get isDevelopment => useMockPremium;
  static bool get isProduction => !useMockPremium;

  // URLs para términos y política
  static const String termsOfServiceUrl = 'https://your-app.com/terms';
  static const String privacyPolicyUrl = 'https://your-app.com/privacy';
}