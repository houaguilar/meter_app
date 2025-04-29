
import 'package:shared_preferences/shared_preferences.dart';

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
