
import 'package:meter_app/domain/entities/tutorial/tutorial_step.dart';

/// Configuración para diferentes tipos de tutorial
class TutorialConfig {
  final String moduleId;
  final String title;
  final List<TutorialStepData> steps;
  final String infoMessage;
  final bool showInfoBox;
  final String nextButtonText;
  final String skipButtonText;
  final String completeButtonText;

  const TutorialConfig({
    required this.moduleId,
    required this.title,
    required this.steps,
    required this.infoMessage,
    this.showInfoBox = true,
    this.nextButtonText = 'Siguiente',
    this.skipButtonText = 'Omitir tutorial',
    this.completeButtonText = 'Empezar',
  });

  TutorialConfig copyWith({
    String? moduleId,
    String? title,
    List<TutorialStepData>? steps,
    String? infoMessage,
    bool? showInfoBox,
    String? nextButtonText,
    String? skipButtonText,
    String? completeButtonText,
  }) {
    return TutorialConfig(
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      steps: steps ?? this.steps,
      infoMessage: infoMessage ?? this.infoMessage,
      showInfoBox: showInfoBox ?? this.showInfoBox,
      nextButtonText: nextButtonText ?? this.nextButtonText,
      skipButtonText: skipButtonText ?? this.skipButtonText,
      completeButtonText: completeButtonText ?? this.completeButtonText,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TutorialConfig &&
        other.moduleId == moduleId &&
        other.title == title &&
        other.steps == steps &&
        other.infoMessage == infoMessage &&
        other.showInfoBox == showInfoBox &&
        other.nextButtonText == nextButtonText &&
        other.skipButtonText == skipButtonText &&
        other.completeButtonText == completeButtonText;
  }

  @override
  int get hashCode {
    return moduleId.hashCode ^
    title.hashCode ^
    steps.hashCode ^
    infoMessage.hashCode ^
    showInfoBox.hashCode ^
    nextButtonText.hashCode ^
    skipButtonText.hashCode ^
    completeButtonText.hashCode;
  }

  @override
  String toString() {
    return 'TutorialConfig(moduleId: $moduleId, title: $title, steps: ${steps.length} steps)';
  }
}