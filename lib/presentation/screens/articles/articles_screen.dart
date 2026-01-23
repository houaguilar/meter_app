import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/theme.dart';
import '../../../domain/entities/entities.dart';
import '../../blocs/home/inicio/article_bloc.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeArticles();
  }

  void _initializeArticles() {
    if (!_isInitialized) {
      final articleBloc = context.read<ArticleBloc>();
      if (articleBloc.state is! ArticleLoaded) {
        articleBloc.add(const FetchArticles());
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Usa el color primario de tu tema automáticamente
        statusBarColor: AppColors.yellowMetraShop,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: BlocConsumer<ArticleBloc, ArticleState>(
            listener: (context, state) {
              if (state is ArticleError) {
                _showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildBody(state),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Artículos',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryMetraShop,
      elevation: 2,
      shadowColor: Colors.black26,
    );
  }

  Widget _buildBody(ArticleState state) {
    switch (state.runtimeType) {
      case ArticleLoading:
        return _buildLoadingState();
      case ArticleLoaded:
        final articles = (state as ArticleLoaded).articles;
        return _buildLoadedState(articles);
      case ArticleError:
        final error = (state as ArticleError).message;
        return _buildErrorState(error);
      default:
        return _buildInitialState();
    }
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildArticleCard(context, article, index),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay artículos disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desliza hacia abajo para actualizar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar artículos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<ArticleBloc>().add(const FetchArticles()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueMetraShop,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleEntity article, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 375 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 50),
            child: GestureDetector(
              onTap: () {
                context.pushNamed(
                  'detail',
                  pathParameters: {
                    'id': article.id,
                    'title': article.title,
                    'videoId': article.videoId,
                  },
                );
              },
              child: _buildCardContent(context, article),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(
      BuildContext context,
      ArticleEntity article,
      ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildArticleImage(article),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (article.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage(ArticleEntity article) {
    return Hero(
      tag: 'article_${article.id}',
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: article.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar imagen',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 200),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    context.read<ArticleBloc>().add(const FetchArticles());

    // Esperar un poco para dar feedback visual al usuario
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => context.read<ArticleBloc>().add(const FetchArticles()),
          ),
        ),
      );
    }
  }
}