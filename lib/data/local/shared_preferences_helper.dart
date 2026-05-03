
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  final SharedPreferences sharedPreferences;

  SharedPreferencesHelper({required this.sharedPreferences});

  // Métodos existentes
  bool isFirstTimeUser() => sharedPreferences.getBool('first_time_user') ?? true;
  Future<void> setFirstTimeUser(bool value) => sharedPreferences.setBool('first_time_user', value);

  // Tutorial legacy
  bool isTutorialShown() => sharedPreferences.getBool('tutorial_shown') ?? false;
  Future<void> setTutorialShown(bool value) => sharedPreferences.setBool('tutorial_shown', value);

  // Nuevos métodos para tutoriales específicos
  bool isTutorialShownForModule(String moduleId) {
    return sharedPreferences.getBool('tutorial_shown_$moduleId') ?? false;
  }

  Future<void> setTutorialShownForModule(String moduleId, bool value) {
    return sharedPreferences.setBool('tutorial_shown_$moduleId', value);
  }

  Future<void> resetTutorialForModule(String moduleId) {
    return sharedPreferences.setBool('tutorial_shown_$moduleId', false);
  }

  Future<void> resetAllTutorials() async {
    final modules = ['wall', 'tarrajeo', 'piso', 'losa', 'structural'];
    for (final module in modules) {
      await resetTutorialForModule(module);
    }
  }

  // Métodos genéricos para otros tipos de datos
  String? getString(String key) => sharedPreferences.getString(key);
  Future<bool> setString(String key, String value) => sharedPreferences.setString(key, value);

  bool? getBool(String key) => sharedPreferences.getBool(key);
  Future<bool> setBool(String key, bool value) => sharedPreferences.setBool(key, value);

  int? getInt(String key) => sharedPreferences.getInt(key);
  Future<bool> setInt(String key, int value) => sharedPreferences.setInt(key, value);

  double? getDouble(String key) => sharedPreferences.getDouble(key);
  Future<bool> setDouble(String key, double value) => sharedPreferences.setDouble(key, value);

  List<String>? getStringList(String key) => sharedPreferences.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) => sharedPreferences.setStringList(key, value);

  Future<bool> remove(String key) => sharedPreferences.remove(key);
  Future<bool> clear() => sharedPreferences.clear();

  bool containsKey(String key) => sharedPreferences.containsKey(key);

  Set<String> getKeys() => sharedPreferences.getKeys();

  // Email pendiente de verificación (para mostrar EmailVerificationScreen al reabrir la app)
  static const _keyPendingVerificationEmail = 'pending_verification_email';

  Future<void> savePendingVerificationEmail(String email) =>
      sharedPreferences.setString(_keyPendingVerificationEmail, email);

  String? getPendingVerificationEmail() =>
      sharedPreferences.getString(_keyPendingVerificationEmail);

  Future<void> clearPendingVerificationEmail() =>
      sharedPreferences.remove(_keyPendingVerificationEmail);
}