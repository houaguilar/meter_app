part of 'tutorial_bloc.dart';

@immutable
sealed class TutorialEvent {}

class TutorialNext extends TutorialEvent {}

class TutorialPrevious extends TutorialEvent {}

class TutorialSkip extends TutorialEvent {}