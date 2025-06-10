
import 'package:shared_preferences/shared_preferences.dart';

/*
class SharedPreferencesHelper {
  static const String _keyPhone = 'phone';
  static const String _keyPassword = 'password';
  static const String _keyIsFirstTime = 'isFirstTime';
  static const String _keyTutorialShown = 'tutorialShown';

  final SharedPreferences sharedPreferences;

  SharedPreferencesHelper({required this.sharedPreferences});

  Future<void> saveCredentials(String phone, String password) async {
    await sharedPreferences.setString(_keyPhone, phone);
    await sharedPreferences.setString(_keyPassword, password);
  }

  Map<String, String>? getCredentials() {
    final phone = sharedPreferences.getString(_keyPhone);
    final password = sharedPreferences.getString(_keyPassword);
    if (phone != null && password != null) {
      return {'phone': phone, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await sharedPreferences.remove(_keyPhone);
    await sharedPreferences.remove(_keyPassword);
  }

  // isFirstTime
  Future<void> setFirstTimeUser(bool isFirstTime) async {
    await sharedPreferences.setBool(_keyIsFirstTime, isFirstTime);
  }

  bool isFirstTimeUser() {
    return sharedPreferences.getBool(_keyIsFirstTime) ?? true;
  }

  // tutorial
  Future<void> setTutorialShown(bool shown) async {
    await sharedPreferences.setBool(_keyTutorialShown, shown);
  }

  bool isTutorialShown() {
    return sharedPreferences.getBool(_keyTutorialShown) ?? false;
  }
}
*/

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
}