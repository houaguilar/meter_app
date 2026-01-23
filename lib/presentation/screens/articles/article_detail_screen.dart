import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/screens/articles/widgets/article_content_viewer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../config/theme/theme.dart';
import '../../../domain/entities/entities.dart';
import '../../blocs/home/inicio/article_bloc.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;
  final String articleName;
  final String articleVideo;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
    required this.articleName,
    required this.articleVideo,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  YoutubePlayerController? _youtubeController;
  bool _isVideoLoading = true;
  bool _hasVideoError = false;
  ArticleEntity? _currentArticle;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadArticleData();
  }

  void _loadArticleData() {
    final articleBloc = context.read<ArticleBloc>();
    if (articleBloc.state is ArticleLoaded) {
      final articles = (articleBloc.state as ArticleLoaded).articles;
      _currentArticle = articles.where((a) => a.id == widget.articleId).firstOrNull;
    }

    if (_currentArticle == null) {
      articleBloc.add(const FetchArticles());
    }
  }

  void _initializeVideo() {
    try {
      String? videoId;

      // Validar y extraer el ID del video
      if (widget.articleVideo.contains('youtube.com') ||
          widget.articleVideo.contains('youtu.be')) {
        videoId = YoutubePlayer.convertUrlToId(widget.articleVideo);
      } else {
        // Asumir que es solo el ID del video
        videoId = widget.articleVideo;
      }

      if (videoId != null && videoId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            hideControls: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
            forceHD: false,
          ),
        );

        // Simular que el video terminó de cargar después de un breve delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _isVideoLoading = false;
            });
          }
        });
      } else {
        setState(() {
          _hasVideoError = true;
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() {
        _hasVideoError = true;
        _isVideoLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController ?? YoutubePlayerController(
          initialVideoId: '',
          flags: const YoutubePlayerFlags(autoPlay: false),
        ),
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.blueMetraShop,
        progressColors: ProgressBarColors(
          playedColor: AppColors.blueMetraShop,
          handleColor: AppColors.yellowMetraShop,
          bufferedColor: AppColors.blueMetraShop.withOpacity(0.3),
          backgroundColor: Colors.grey.withOpacity(0.3),
        ),
        onReady: () {
          if (mounted) {
            setState(() {
              _isVideoLoading = false;
            });
          }
        },
      ),
      builder: (context, player) {
        return Scaffold(
          body: BlocConsumer<ArticleBloc, ArticleState>(
            listener: (context, state) {
              if (state is ArticleError) {
                _showErrorSnackBar(context, state.message);
              } else if (state is ArticleLoaded) {
                final article = state.articles.where((a) => a.id == widget.articleId).firstOrNull;
                if (article != null) {
                  setState(() {
                    _currentArticle = article;
                  });
                }
              }
            },
            builder: (context, state) {
              return _buildContent(context, state, player);
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(Widget player) {
    // Siempre mostramos el player, pero con overlays si hay error o está cargando
    return SizedBox(
      height: 220, // Altura fija para evitar saltos visuales
      child: Stack(
        alignment: Alignment.center,
        children: [
          player,
          if (_isVideoLoading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellowMetraShop),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Preparando video...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasVideoError)
            Container(
              color: Colors.grey.shade900,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Error al cargar el video',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _hasVideoError = false;
                                _isVideoLoading = true;
                              });
                              _initializeVideo();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueMetraShop,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArticleState state, Widget player) {
    final videoPlayer = _buildVideoPlayer(player);

    if (state is ArticleLoading && _currentArticle == null) {
      return _buildLoadingState(videoPlayer);
    }

    if (state is ArticleError && _currentArticle == null) {
      return _buildErrorState(state.message, videoPlayer);
    }

    if (_currentArticle == null) {
      return _buildNotFoundState(videoPlayer);
    }

    return _buildLoadedContent(_currentArticle!, videoPlayer);
  }

  Widget _buildLoadingState(Widget player) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(widget.articleName),
        SliverToBoxAdapter(
          child: Column(
            children: [
              player,
              _buildShimmerContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, Widget player) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(widget.articleName),
        SliverToBoxAdapter(
          child: Column(
            children: [
              player,
              _buildErrorContent(error),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundState(Widget player) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(widget.articleName),
        SliverToBoxAdapter(
          child: Column(
            children: [
              player,
              _buildNotFoundContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedContent(ArticleEntity article, Widget player) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(article.title),
        SliverToBoxAdapter(
          child: Column(
            children: [
              player,
              _buildArticleDetails(article),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(String title) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primaryMetraShop,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Container(height: 24, width: double.infinity, color: Colors.white),
            const SizedBox(height: 12),

            // Descripción
            Container(height: 16, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 16, width: 200, color: Colors.white),
            const SizedBox(height: 24),

            // Imagen placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),

            // Caption placeholder
            Container(height: 14, width: 150, color: Colors.white),
            const SizedBox(height: 24),

            // Segunda imagen
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el artículo',
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ArticleBloc>().add(FetchArticles()),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundContent() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Artículo no encontrado',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleDetails(ArticleEntity article) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ArticleContentViewer(
        article: article,
      ),
    );
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
            onPressed: () => context.read<ArticleBloc>().add(FetchArticles()),
          ),
        ),
      );
    }
  }

}