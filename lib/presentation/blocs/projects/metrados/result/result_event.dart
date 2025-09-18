part of 'result_bloc.dart';

@immutable
sealed class ResultEvent {}

class SaveResultEvent extends ResultEvent {
  final List<dynamic> results;
  final String metradoId;

  SaveResultEvent({required this.results, required this.metradoId});
}

class LoadResultsEvent extends ResultEvent {
  final String metradoId;

  LoadResultsEvent({required this.metradoId});
}

class ResetResultStateEvent extends ResultEvent {}