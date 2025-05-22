part of 'article_bloc.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object?> get props => [];
}

class FetchArticles extends ArticleEvent {
  final bool forceRefresh;

  const FetchArticles({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class RefreshArticles extends ArticleEvent {}

class RetryFetchArticles extends ArticleEvent {}