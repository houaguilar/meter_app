part of 'tutorial_bloc.dart';

@immutable
sealed class TutorialState {}

class TutorialInitial extends TutorialState {}

class TutorialStep extends TutorialState {
  final int stepIndex;
  TutorialStep(this.stepIndex);
}

class TutorialCompleted extends TutorialState {}