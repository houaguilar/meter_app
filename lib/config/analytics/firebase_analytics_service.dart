import 'package:firebase_analytics/firebase_analytics.dart';
import 'analytics_repository.dart';

class FirebaseAnalyticsService implements AnalyticsRepository {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    await _analytics.logEvent(name: name, parameters: params);
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    await _analytics.setCurrentScreen(screenName: screenName);
  }

  @override
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  @override
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }
}