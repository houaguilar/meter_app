import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class _ArticleDetailScreenState extends State<ArticleDetailScreen>
    with TickerProviderStateMixin {
  late YoutubePlayerController? _youtubeController;
  bool _isFullScreen = false;
  bool _isVideoLoading = true;
  bool _hasVideoError = false;
  int _selectedIndex = 0;
  late TabController _tabController;
  ArticleEntity? _currentArticle;

  // Mensajes simulados para la demostración
  final List<Map<String, String>> _simulatedMessages = [
    {
      "message": "¡Excelente artículo! Me ayudó mucho a entender el tema.",
      "author": "María González",
      "time": "Hace 2 horas"
    },
    {
      "message": "¿Podrían hacer un video sobre este tema específico?",
      "author": "Carlos Ruiz",
      "time": "Hace 4 horas"
    },
    {
      "message": "Muy bien explicado, gracias por compartir el conocimiento.",
      "author": "Ana López",
      "time": "Hace 1 día"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      articleBloc.add(FetchArticles());
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
          ),
        );

        _youtubeController?.addListener(_youtubeControllerListener);

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

  void _youtubeControllerListener() {
    if (_youtubeController?.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _youtubeController?.value.isFullScreen ?? false;
      });

      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _youtubeController?.removeListener(_youtubeControllerListener);
    _youtubeController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return _buildFullScreenPlayer();
    }

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
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildFullScreenPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _youtubeController != null
            ? YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.blueMetraShop,
          progressColors: ProgressBarColors(
            playedColor: AppColors.blueMetraShop,
            handleColor: AppColors.yellowMetraShop,
            bufferedColor: AppColors.blueMetraShop.withOpacity(0.3),
            backgroundColor: Colors.grey.withOpacity(0.3),
          ),
        )
            : _buildVideoErrorWidget(),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasVideoError) {
      return _buildVideoErrorWidget();
    }

    if (_isVideoLoading) {
      return _buildVideoLoadingWidget();
    }

    if (_youtubeController == null) {
      return _buildVideoErrorWidget();
    }

    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: AppColors.blueMetraShop,
      progressColors: ProgressBarColors(
        playedColor: AppColors.blueMetraShop,
        handleColor: AppColors.yellowMetraShop,
        bufferedColor: AppColors.blueMetraShop.withOpacity(0.3),
        backgroundColor: Colors.grey.withOpacity(0.3),
      ),
      onReady: () {
        setState(() {
          _isVideoLoading = false;
        });
      },
      onEnded: (metaData) {
        // Opcional: manejar cuando el video termina
      },
    );
  }

  Widget _buildVideoLoadingWidget() {
    return Container(
      height: 200,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellowMetraShop),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando video...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoErrorWidget() {
    return Container(
      height: 200,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasVideoError = false;
                  _isVideoLoading = true;
                });
                _initializeVideo();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueMetraShop,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArticleState state) {
    final player = _buildVideoPlayer();

    if (state is ArticleLoading && _currentArticle == null) {
      return _buildLoadingState(player);
    }

    if (state is ArticleError && _currentArticle == null) {
      return _buildErrorState(state.message, player);
    }

    if (_currentArticle == null) {
      return _buildNotFoundState(player);
    }

    return _buildLoadedContent(_currentArticle!, player);
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
              _buildTabBar(),
              SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildArticleDetails(article),
                    _buildMessagesSection(),
                  ],
                ),
              ),
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.blueMetraShop,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColors.blueMetraShop,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.article),
            text: 'Detalles',
          ),
          Tab(
            icon: Icon(Icons.chat_bubble_outline),
            text: 'Comentarios',
          ),
        ],
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
            Container(height: 24, width: double.infinity, color: Colors.white),
            const SizedBox(height: 12),
            Container(height: 16, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 16, width: 200, color: Colors.white),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del artículo (si está disponible)
          if (article.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Título
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMetraShop,
            ),
          ),
          const SizedBox(height: 8),

          // Descripción corta
          if (article.description.isNotEmpty) ...[
            Text(
              article.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Contenido principal
          Text(
            article.articleDetail,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppColors.primaryMetraShop,
            ),
          ),

          const SizedBox(height: 24),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Publicado: ${_formatDate(article.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (article.updatedAt != article.createdAt) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.update, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Actualizado: ${_formatDate(article.updatedAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _simulatedMessages.length + 1, // +1 para el header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildMessagesHeader();
        }

        final messageIndex = index - 1;
        final message = _simulatedMessages[messageIndex];
        return _buildMessageItem(
          message["message"]!,
          message["author"]!,
          message["time"]!,
          messageIndex,
        );
      },
    );
  }

  Widget _buildMessagesHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comentarios (${_simulatedMessages.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMetraShop,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comparte tu opinión sobre este artículo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildCommentInput(),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.blueMetraShop,
            child: Text(
              'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              maxLines: null,
              enabled: false, // Deshabilitado para la demo
            ),
          ),
          IconButton(
            onPressed: null, // Deshabilitado para la demo
            icon: Icon(
              Icons.send,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
      String message,
      String author,
      String time,
      int index,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getAvatarColor(index),
                child: Text(
                  author[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryMetraShop,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                onSelected: (value) {
                  _handleMessageAction(value, index);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reply',
                    child: Row(
                      children: [
                        Icon(Icons.reply, size: 16),
                        SizedBox(width: 8),
                        Text('Responder'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 16),
                        SizedBox(width: 8),
                        Text('Reportar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.primaryMetraShop,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _handleLike(index),
                icon: Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                label: Text(
                  'Me gusta',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
              ),
              TextButton.icon(
                onPressed: () => _handleReply(index),
                icon: Icon(
                  Icons.reply,
                  size: 16,
                  color: Colors.grey[600],
                ),
                label: Text(
                  'Responder',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      AppColors.blueMetraShop,
      AppColors.yellowMetraShop,
      AppColors.primaryMetraShop,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  void _handleMessageAction(String action, int index) {
    switch (action) {
      case 'reply':
        _handleReply(index);
        break;
      case 'report':
        _handleReport(index);
        break;
    }
  }

  void _handleLike(int index) {
    // Implementar lógica de like
    _showSuccessSnackBar(context, '¡Te gusta este comentario!');
  }

  void _handleReply(int index) {
    // Implementar lógica de respuesta
    _showInfoSnackBar(context, 'Función de respuesta próximamente disponible');
  }

  void _handleReport(int index) {
    // Implementar lógica de reporte
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar comentario'),
        content: const Text('¿Estás seguro de que quieres reportar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessSnackBar(context, 'Comentario reportado');
            },
            child: const Text('Reportar'),
          ),
        ],
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

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.blueMetraShop,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}