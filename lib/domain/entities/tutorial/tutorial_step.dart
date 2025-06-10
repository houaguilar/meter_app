// lib/domain/entities/tutorial/tutorial_step.dart
/// Entidad que representa un paso del tutorial
class TutorialStepData {
  final String title;
  final String description;
  final String imagePath;
  final String? additionalInfo;

  const TutorialStepData({
    required this.title,
    required this.description,
    required this.imagePath,
    this.additionalInfo,
  });

  TutorialStepData copyWith({
    String? title,
    String? description,
    String? imagePath,
    String? additionalInfo,
  }) {
    return TutorialStepData(
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TutorialStepData &&
        other.title == title &&
        other.description == description &&
        other.imagePath == imagePath &&
        other.additionalInfo == additionalInfo;
  }

  @override
  int get hashCode {
    return title.hashCode ^
    description.hashCode ^
    imagePath.hashCode ^
    additionalInfo.hashCode;
  }

  @override
  String toString() {
    return 'TutorialStepData(title: $title, description: $description, imagePath: $imagePath, additionalInfo: $additionalInfo)';
  }
}
