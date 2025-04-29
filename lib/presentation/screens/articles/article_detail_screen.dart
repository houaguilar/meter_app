import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../domain/entities/entities.dart';
import '../../blocs/home/inicio/article_bloc.dart';

import 'dart:ui';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;
  final String articleName;
  final String articleVideo;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
    required this.articleName,
    required this.articleVideo
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final YoutubePlayerController _youtubeController;
  bool _isFullScreen = false;
  int selectedIndex = 0; // Para cambiar entre detalles y mensajes

  @override
  void initState() {
    super.initState();

    // Convertimos el ID del vídeo o URL en un ID válido
    final videoId = YoutubePlayer.convertUrlToId(
        widget.articleVideo.contains('youtube.com')
            ? widget.articleVideo
            : 'https://www.youtube.com/watch?v=${widget.articleVideo}'
    );

    if (videoId == null) {
      throw Exception('ID de vídeo no válido');
    }

    // Inicializamos el controlador
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        hideControls: false,
        enableCaption: true,
      ),
    )..addListener(_youtubeControllerListener);
  }

  void _youtubeControllerListener() {
    // Detectamos el cambio a pantalla completa
    if (_youtubeController.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _youtubeController.value.isFullScreen;
      });

      // Ajustamos la orientación de la pantalla según el modo
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    }
  }

  @override
  void dispose() {
    // Restauramos la orientación del dispositivo y liberamos recursos
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _youtubeController.removeListener(_youtubeControllerListener);
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si estamos en pantalla completa, solo mostramos el reproductor
    if (_isFullScreen) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
        builder: (context, player) => Scaffold(
          body: Center(child: player),
        ),
      );
    }

    // En modo normal, mostramos la interfaz completa
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onEnded: (metaData) {
          // Puedes manejar el evento cuando el video termina
        },
      ),
      builder: (context, player) {
        return Scaffold(
          body: BlocBuilder<ArticleBloc, ArticleState>(
            builder: (context, state) {
              if (state is ArticleLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ArticleLoaded) {
                final article = state.articles.firstWhere(
                      (a) => a.id == widget.articleId,
                  orElse: () => throw Exception('Artículo no encontrado'),
                );
                return _buildContent(context, article, player);
              } else {
                return const Center(child: Text('No se pudo cargar el artículo'));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ArticleEntity article, Widget player) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 60,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              article.title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reproductor de YouTube
              player,

              // Tabs para cambiar entre detalles y mensajes
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'Detalles',
                        isSelected: selectedIndex == 0,
                        onTap: () => setState(() => selectedIndex = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTabButton(
                        title: 'Mensajes',
                        isSelected: selectedIndex == 1,
                        onTap: () => setState(() => selectedIndex = 1),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido según la pestaña seleccionada
              SizedBox(
                height: MediaQuery.of(context).size.height - 300, // Altura aproximada
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverse: selectedIndex == 0,
                  transitionBuilder: (child, animation, secondaryAnimation) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                  child: selectedIndex == 0
                      ? _buildArticleDetails(article)
                      : _buildMessagesSection(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Contenido de la sección de detalles
  Widget _buildArticleDetails(ArticleEntity article) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            article.articleDetail,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Sección de mensajes simulados
  Widget _buildMessagesSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        final messages = [
          {"message": "Hi Jason! How are you?", "time": "11:04"},
          {"message": "I'm good, thanks! How are you?", "time": "11:04"},
          {"message": "I'm great, are you free today?", "time": "11:05"},
        ];
        return _buildMessageItem(
            messages[index]["message"]!,
            messages[index]["time"]!
        );
      },
    );
  }

  // Item de mensaje simulado
  Widget _buildMessageItem(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}