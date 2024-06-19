part of 'result_bloc.dart';

@immutable
sealed class ResultState {}

class ResultInitial extends ResultState {}

class ResultLoading extends ResultState {}

class ResultSuccess extends ResultState {
  final List<dynamic> results;

  ResultSuccess(this.results);
}

class ResultFailure extends ResultState {
  final String message;

  ResultFailure(this.message);
}
