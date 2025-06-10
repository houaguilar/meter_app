import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.custom(
        gridDelegate: SliverWovenGridDelegate.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          pattern: [
            const WovenGridTile(1),
            const WovenGridTile(
              5 / 7,
              crossAxisRatio: 0.9,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
        childrenDelegate: SliverChildBuilderDelegate(
              (context, index) => _buildShimmerCard(),
          childCount: 6, // Mostrar 6 shimmer cards
        ),
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.custom(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverWovenGridDelegate.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          pattern: [
            const WovenGridTile(1),
            const WovenGridTile(
              5 / 7,
              crossAxisRatio: 0.9,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
        childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
            final article = articles[index];
            return _buildArticleCard(context, article, index);
          },
          childCount: articles.length,
        ),
      ),
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildArticleImage(article),
          _buildGradientOverlay(),
          _buildTitleOverlay(article.title),
        ],
      ),
    );
  }

  Widget _buildArticleImage(ArticleEntity article) {
    return Hero(
      tag: 'article_${article.id}',
      child: CachedNetworkImage(
        imageUrl: article.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
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
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleOverlay(String title) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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