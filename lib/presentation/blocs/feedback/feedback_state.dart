part of 'feedback_bloc.dart';

sealed class FeedbackState {}

final class FeedbackInitial extends FeedbackState {}

final class FeedbackLoading extends FeedbackState {}

final class FeedbackSuccess extends FeedbackState {}

final class FeedbackFailure extends FeedbackState {
  final String message;
  FeedbackFailure(this.message);
}
