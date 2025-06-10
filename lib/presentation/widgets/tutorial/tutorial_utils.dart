// lib/presentation/widgets/tutorial/tutorial_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utilidades para el sistema de tutoriales
class TutorialUtils {
  /// Proporciona feedback háptico basado en el tipo de acción
  static void provideFeedback(TutorialFeedbackType type) {
    switch (type) {
      case TutorialFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case TutorialFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case TutorialFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case TutorialFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Valida si un módulo de tutorial es válido
  static bool isValidModuleId(String moduleId) {
    const validModules = [
      'wall',
      'tarrajeo',
      'piso',
      'losa',
      'structural',
    ];
    return validModules.contains(moduleId);
  }

  /// Convierte el ID del módulo a un nombre legible
  static String getModuleDisplayName(String moduleId) {
    switch (moduleId) {
      case 'wall':
        return 'Muros';
      case 'tarrajeo':
        return 'Tarrajeo';
      case 'piso':
        return 'Pisos';
      case 'losa':
        return 'Losas';
      case 'structural':
        return 'Elementos Estructurales';
      default:
        return 'Tutorial';
    }
  }

  /// Obtiene el icono asociado a un módulo
  static IconData getModuleIcon(String moduleId) {
    switch (moduleId) {
      case 'wall':
        return Icons.home_work_outlined;
      case 'tarrajeo':
        return Icons.format_paint_outlined;
      case 'piso':
        return Icons.layers_outlined;
      case 'losa':
        return Icons.grid_view_outlined;
      case 'structural':
        return Icons.account_balance_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

/// Tipos de feedback háptico para tutoriales
enum TutorialFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

// lib/presentation/widgets/tutorial/tutorial_analytics.dart
/// Analytics para trackear el uso de tutoriales
class TutorialAnalytics {
  /// Trackea cuando un tutorial es iniciado
  static void trackTutorialStarted(String moduleId) {
    // Implementar analytics según tu sistema
    // Analytics.track('tutorial_started', {'module': moduleId});
    print('📊 Tutorial iniciado: $moduleId');
  }

  /// Trackea cuando un tutorial es completado
  static void trackTutorialCompleted(String moduleId) {
    // Analytics.track('tutorial_completed', {'module': moduleId});
    print('✅ Tutorial completado: $moduleId');
  }

  /// Trackea cuando un tutorial es omitido
  static void trackTutorialSkipped(String moduleId, int stepIndex) {
    // Analytics.track('tutorial_skipped', {
    //   'module': moduleId,
    //   'step': stepIndex,
    // });
    print('⏭️ Tutorial omitido: $moduleId en paso $stepIndex');
  }

  /// Trackea el progreso en un tutorial
  static void trackTutorialProgress(String moduleId, int stepIndex,
      int totalSteps) {
    final progress = ((stepIndex + 1) / totalSteps * 100).round();
    // Analytics.track('tutorial_progress', {
    //   'module': moduleId,
    //   'step': stepIndex,
    //   'progress_percent': progress,
    // });
    print('📈 Progreso tutorial $moduleId: $progress%');
  }
}