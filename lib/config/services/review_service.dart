import 'package:flutter/foundation.dart';
import 'package:meter_app/data/local/shared_preferences_helper.dart';

/// Servicio que gestiona el timing del requestReview() nativo.
///
/// Reglas (conforme a políticas de Apple y Google):
/// - Solo se dispara al retornar de una pantalla de resultados (acción de valor)
/// - Máximo en los hitos: sesión 5, 15 y 35 (≤3 veces/año como pide Apple)
/// - Mínimo 30 días entre cada prompt
/// - Nunca se muestra un pre-screen de satisfacción (prohibido por Google/FTC)
class ReviewService extends ChangeNotifier {
  static const String _sessionsKey = 'review_sessions_count';
  static const String _lastPromptKey = 'review_last_prompt_ms';
  static const List<int> _milestones = [5, 15, 35];

  final SharedPreferencesHelper _prefs;

  bool _pendingReview = false;
  bool get pendingReview => _pendingReview;

  ReviewService(this._prefs);

  /// Llamado desde AppBarWidget cuando el usuario confirma ir al home
  /// desde una pantalla de resultados.
  void markReturnedFromResult() {
    _incrementSession();
    if (_shouldShowReview()) {
      _pendingReview = true;
      notifyListeners();
    }
  }

  /// Llamado desde HomeView después de disparar requestReview().
  /// Registra la fecha del último prompt para respetar el cooldown de 30 días.
  void consumePendingReview() {
    _pendingReview = false;
    _prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
  }

  void _incrementSession() {
    final count = _prefs.getInt(_sessionsKey) ?? 0;
    _prefs.setInt(_sessionsKey, count + 1);
  }

  bool _shouldShowReview() {
    final sessions = _prefs.getInt(_sessionsKey) ?? 0;
    final lastPromptMs = _prefs.getInt(_lastPromptKey) ?? 0;

    if (lastPromptMs > 0) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastPromptMs;
      final days = elapsed / (1000 * 60 * 60 * 24);
      if (days < 30) return false;
    }

    return _milestones.contains(sessions);
  }

}
