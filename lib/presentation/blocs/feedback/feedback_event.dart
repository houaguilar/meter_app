part of 'feedback_bloc.dart';

sealed class FeedbackEvent {}

final class FeedbackSubmitted extends FeedbackEvent {
  final int rating;
  final String message;
  final String screenName;

  FeedbackSubmitted({
    required this.rating,
    required this.message,
    required this.screenName,
  });
}

final class FeedbackReset extends FeedbackEvent {}
