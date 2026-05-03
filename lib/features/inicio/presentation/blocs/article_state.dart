part of 'article_bloc.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object?> get props => [];
}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {
  final bool isRefreshing;
  final List<ArticleEntity> currentArticles;

  const ArticleLoading({
    this.isRefreshing = false,
    this.currentArticles = const [],
  });

  @override
  List<Object?> get props => [isRefreshing, currentArticles];
}

class ArticleLoaded extends ArticleState {
  final List<ArticleEntity> articles;
  final DateTime lastUpdated;

  const ArticleLoaded({
    required this.articles,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [articles, lastUpdated];

  ArticleLoaded copyWith({
    List<ArticleEntity>? articles,
    DateTime? lastUpdated,
  }) {
    return ArticleLoaded(
      articles: articles ?? this.articles,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ArticleError extends ArticleState {
  final String message;
  final List<ArticleEntity> cachedArticles;
  final bool isConnectionError;

  const ArticleError({
    required this.message,
    this.cachedArticles = const [],
    this.isConnectionError = false,
  });

  @override
  List<Object?> get props => [message, cachedArticles, isConnectionError];
}