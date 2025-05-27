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

  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar problemas de construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _initializeArticles();
        _hasInitialized = true;
      }
    });
  }

  void _initializeArticles() {
    final articleBloc = context.read<ArticleBloc>();
    final currentState = articleBloc.state;

    // Solo cargar si es necesario
    if (currentState is ArticleInitial ||
        (currentState is ArticleError && currentState.cachedArticles.isEmpty)) {
      articleBloc.add(const FetchArticles());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(ArticleState state) {
    if (state is ArticleLoading) {
      final loadingState = state;
      if (loadingState.currentArticles.isNotEmpty) {
        return _buildArticlesList(loadingState.currentArticles, isRefreshing: true);
      }
      return _buildLoadingCarousel();
    } else if (state is ArticleLoaded) {
      return _buildArticlesList(state.articles);
    } else if (state is ArticleError) {
      if (state.cachedArticles.isNotEmpty) {
        return _buildArticlesList(state.cachedArticles, hasError: true);
      }
      return _buildErrorCarousel(state.message);
    } else {
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
      mainAxisSize: MainAxisSize.min,
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ArticleCard(article: article),
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
        itemCount: 3,
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
      ),
    );
  }

  Widget _buildErrorCarousel(String message) {
    return GestureDetector(
      onTap: () {
        context.read<ArticleBloc>().add(const FetchArticles(forceRefresh: true));
      },
      child: Container(
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
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
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
        margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
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
}