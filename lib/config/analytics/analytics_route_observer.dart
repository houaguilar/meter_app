
import 'package:flutter/material.dart';
import 'analytics_repository.dart';

class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final AnalyticsRepository _analytics;

  AnalyticsRouteObserver(this._analytics);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreen(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _trackScreen(newRoute);
  }

  void _trackScreen(Route<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null) {
      _analytics.setCurrentScreen(screenName);
    }
  }
}