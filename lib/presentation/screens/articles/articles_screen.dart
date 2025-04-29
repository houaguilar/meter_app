import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../config/constants/constants.dart';
import '../../../domain/entities/entities.dart';
import '../../assets/images.dart';
import '../../blocs/home/inicio/article_bloc.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Artículos',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state is ArticleLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ArticleLoaded) {
            return _buildArticlesGrid(context, state.articles);
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('No se pudieron cargar los artículos',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildArticlesGrid(BuildContext context, List<ArticleEntity> articles) {
    // Si no hay artículos, mostramos un mensaje
    if (articles.isEmpty) {
      return const Center(
        child: Text('No hay artículos disponibles',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

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
                alignment: AlignmentDirectional.centerEnd
            ),
          ],
        ),
        childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
            final article = articles[index];
            return _buildArticleCard(context, article);
          },
          childCount: articles.length,
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleEntity article) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, _) => ArticleDetailScreen(
        articleId: article.id,
        articleName: article.title,
        articleVideo: article.videoId,
      ),
      closedElevation: 2,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      closedColor: Theme.of(context).cardColor,
      closedBuilder: (context, openContainer) => Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero, // Quitamos margen para que no haya doble margen con el OpenContainer
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0, // Sin elevación para evitar sombras duplicadas
        child: InkWell(
          onTap: openContainer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildArticleImage(article),
              _buildGradientOverlay(),
              _buildTitleOverlay(article.title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage(ArticleEntity article) {
    return Hero(
      tag: article.id,
      child: FadeInImage.assetNetwork(
        placeholder: AppImages.placeholder, // Asegúrate de tener este archivo
        image: article.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        imageErrorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 40),
            ),
          );
        },
      ),
    );
  }

  // Añadimos un gradiente para mejorar la legibilidad del texto sobre la imagen
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
}