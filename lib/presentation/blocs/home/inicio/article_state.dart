part of 'article_bloc.dart';

@immutable
sealed class ArticleState {}

final class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<ArticleEntity> articles;

  ArticleLoaded(this.articles);
}

class ArticleError extends ArticleState {
  final String message;

  ArticleError(this.message);
}