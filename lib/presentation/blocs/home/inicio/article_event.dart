part of 'article_bloc.dart';

@immutable
sealed class ArticleEvent {}

class FetchArticles extends ArticleEvent {}
