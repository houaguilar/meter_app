import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meter_app/domain/usecases/home/inicio/get_articles_usecase.dart';

import '../../../../domain/entities/entities.dart';

part 'article_event.dart';
part 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetArticlesUseCase getArticlesUseCase;

  // Cache para mantener los artículos en memoria
  List<ArticleEntity> _cachedArticles = [];
  DateTime? _lastFetchTime;

  // Tiempo de cache en minutos
  static const int _cacheExpirationMinutes = 5;

  ArticleBloc({required this.getArticlesUseCase}) : super(ArticleInitial()) {
    on<FetchArticles>(_onFetchArticles);
    on<RefreshArticles>(_onRefreshArticles);
    on<RetryFetchArticles>(_onRetryFetchArticles);
  }

  Future<void> _onFetchArticles(
      FetchArticles event,
      Emitter<ArticleState> emit,
      ) async {
    try {
      // Si tenemos cache válido y no se fuerza refresh, usar cache
      if (!event.forceRefresh && _isCacheValid() && _cachedArticles.isNotEmpty) {
        emit(ArticleLoaded(
          articles: _cachedArticles,
          lastUpdated: _lastFetchTime!,
        ));
        return;
      }

      // Si ya tenemos artículos cacheados, mostrar loading con datos existentes
      if (_cachedArticles.isNotEmpty) {
        emit(ArticleLoading(
          isRefreshing: true,
          currentArticles: _cachedArticles,
        ));
      } else {
        emit(const ArticleLoading());
      }

      final result = await getArticlesUseCase.execute();

      result.fold(
            (failure) {
          emit(ArticleError(
            message: _getErrorMessage(failure.message),
            cachedArticles: _cachedArticles,
            isConnectionError: _isConnectionError(failure.message),
          ));
        },
            (articles) {
          _cachedArticles = articles;
          _lastFetchTime = DateTime.now();

          emit(ArticleLoaded(
            articles: articles,
            lastUpdated: _lastFetchTime!,
          ));
        },
      );
    } catch (e) {
      emit(ArticleError(
        message: 'Error inesperado: ${e.toString()}',
        cachedArticles: _cachedArticles,
        isConnectionError: false,
      ));
    }
  }

  Future<void> _onRefreshArticles(
      RefreshArticles event,
      Emitter<ArticleState> emit,
      ) async {
    add(const FetchArticles(forceRefresh: true));
  }

  Future<void> _onRetryFetchArticles(
      RetryFetchArticles event,
      Emitter<ArticleState> emit,
      ) async {
    add(const FetchArticles(forceRefresh: true));
  }

  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_lastFetchTime!);

    return difference.inMinutes < _cacheExpirationMinutes;
  }

  String _getErrorMessage(String originalMessage) {
    if (_isConnectionError(originalMessage)) {
      return 'Sin conexión a internet. Revisa tu conexión y vuelve a intentar.';
    }

    if (originalMessage.toLowerCase().contains('timeout')) {
      return 'La conexión está tardando demasiado. Inténtalo de nuevo.';
    }

    if (originalMessage.toLowerCase().contains('server')) {
      return 'Problema con el servidor. Inténtalo más tarde.';
    }

    return 'Error al cargar los artículos. Inténtalo de nuevo.';
  }

  bool _isConnectionError(String message) {
    final connectionKeywords = [
      'no internet',
      'connection',
      'network',
      'timeout',
      'unreachable',
    ];

    final lowerMessage = message.toLowerCase();
    return connectionKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  // Método para obtener artículos del cache
  List<ArticleEntity> get cachedArticles => List.unmodifiable(_cachedArticles);

  // Método para verificar si hay cache
  bool get hasCachedData => _cachedArticles.isNotEmpty;

  // Método para limpiar cache
  void clearCache() {
    _cachedArticles.clear();
    _lastFetchTime = null;
  }

  @override
  Future<void> close() {
    // Limpiar recursos si es necesario
    return super.close();
  }
}
