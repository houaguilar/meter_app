
abstract class AnalyticsRepository {
  Future<void> logEvent(String name, [Map<String, Object>? params]);
  Future<void> setCurrentScreen(String screenName);
  Future<void> logLogin(String method);
  Future<void> logSignUp(String method);
}