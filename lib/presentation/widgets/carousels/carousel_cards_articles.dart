import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../config/theme/theme.dart';
import '../../blocs/home/inicio/article_bloc.dart';
import '../cards/article_card.dart';

class CarouselCardsArticles extends StatefulWidget {
  const CarouselCardsArticles({super.key});

  @override
  State<CarouselCardsArticles> createState() => _CarouselCardsArticlesState();
}

class _CarouselCardsArticlesState extends State<CarouselCardsArticles>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeArticles();
  }

  void _initializeArticles() {
    final articleBloc = context.read<ArticleBloc>();

    // Solo cargar si no hay datos o si hay un error
    if (articleBloc.state is ArticleInitial ||
        articleBloc.state is ArticleError) {
      articleBloc.add(const FetchArticles());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<ArticleBloc, ArticleState>(
      listener: (context, state) {
        // Manejar errores silenciosamente o mostrar un mensaje discreto
        if (state is ArticleError && state.cachedArticles.isEmpty) {
          // Solo mostrar error si no hay datos en cache
          _showErrorMessage(context, state.message);
        }
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(ArticleState state) {
    switch (state.runtimeType) {
      case ArticleLoading:
        final loadingState = state as ArticleLoading;
        if (loadingState.currentArticles.isNotEmpty) {
          // Mostrar datos existentes mientras se actualiza
          return _buildArticlesList(loadingState.currentArticles, isRefreshing: true);
        }
        return _buildLoadingCarousel();

      case ArticleLoaded:
        final loadedState = state as ArticleLoaded;
        return _buildArticlesList(loadedState.articles);

      case ArticleError:
        final errorState = state as ArticleError;
        if (errorState.cachedArticles.isNotEmpty) {
          // Mostrar datos en cache con indicador de error
          return _buildArticlesList(errorState.cachedArticles, hasError: true);
        }
        return _buildErrorCarousel(errorState.message);

      default:
        return _buildLoadingCarousel();
    }
  }

  Widget _buildArticlesList(
      List<dynamic> articles, {
        bool isRefreshing = false,
        bool hasError = false,
      }) {
    if (articles.isEmpty) {
      return _buildEmptyCarousel();
    }

    return Column(
      children: [
        if (isRefreshing) _buildRefreshIndicator(),
        if (hasError) _buildErrorIndicator(),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 375 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset((1 - value) * 50, 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ArticleCard(article: article),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCarousel() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3, // Mostrar 3 shimmer cards
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildShimmerCard(),
          );
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCarousel(String message) {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Error al cargar artículos',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Toca para reintentar',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCarousel() {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              color: Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay artículos disponibles',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.blueMetraShop.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Actualizando...',
            style: TextStyle(
              color: AppColors.blueMetraShop,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return GestureDetector(
      onTap: () {
        context.read<ArticleBloc>().add(const FetchArticles(forceRefresh: true));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              'Error de conexión - Toca para reintentar',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () {
              context.read<ArticleBloc>().add(const FetchArticles(forceRefresh: true));
            },
          ),
        ),
      );
    }
  }
}