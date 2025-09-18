import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/article/article_content_image.dart';
import '../../../../domain/entities/entities.dart';

class ArticleContentViewer extends StatelessWidget {
  final ArticleEntity article;

  const ArticleContentViewer({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 ArticleContentViewer - Article: ${article.title}');
    print('🔍 ArticleContentViewer - hasImageContent: ${article.hasImageContent}');
    print('🔍 ArticleContentViewer - contentImages count: ${article.contentImages.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          article.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryMetraShop,
          ),
        ),
        const SizedBox(height: 16),

        // Descripción
        if (article.description.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              article.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Contenido - Imágenes o texto
        if (article.hasImageContent)
          _buildImageContent()
        else
          _buildTextContent(),
      ],
    );
  }

  Widget _buildImageContent() {
    return Column(
      children: article.contentImages
          .asMap()
          .entries
          .map((entry) => Padding(
        padding: EdgeInsets.only(
          bottom: entry.key < article.contentImages.length - 1 ? 24 : 0,
        ),
        child: ArticleImageWidget(
          contentImage: entry.value,
        ),
      ))
          .toList(),
    );
  }

  Widget _buildTextContent() {
    return Text(
      article.articleDetail,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: AppColors.primaryMetraShop,
      ),
    );
  }
}

// Widget individual para cada imagen
class ArticleImageWidget extends StatelessWidget {
  final ArticleContentImage contentImage;

  const ArticleImageWidget({
    super.key,
    required this.contentImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen
        GestureDetector(
          onTap: () => _showImageZoom(context),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: contentImage.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMetraShop),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error al cargar imagen',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Indicador de zoom
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Caption si existe
        if (contentImage.caption?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              contentImage.caption!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showImageZoom(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: ImageZoomViewer(
              imageUrl: contentImage.imageUrl,
              caption: contentImage.caption,
            ),
          );
        },
      ),
    );
  }
}

// Visor de imagen con zoom
class ImageZoomViewer extends StatelessWidget {
  final String imageUrl;
  final String? caption;

  const ImageZoomViewer({
    super.key,
    required this.imageUrl,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Imagen con zoom
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),

            // Botón de cerrar
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Caption
            if (caption?.isNotEmpty == true)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}