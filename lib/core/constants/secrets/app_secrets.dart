import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  // Supabase
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Google Maps
  static String get googleApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? '';

  static String get googleApiKeyIOS =>
      dotenv.env['GOOGLE_MAPS_API_KEY_IOS'] ?? '';

  // Google OAuth
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  static String get googleIOSClientId =>
      dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

  static String get googleAndroidClientId =>
      dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '';
}
