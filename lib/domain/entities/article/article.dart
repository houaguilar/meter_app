import 'article_content_image.dart';

class ArticleEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String articleDetail;
  final List<ArticleContentImage> contentImages;
  final String videoId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.articleDetail,
    this.contentImages = const [],
    required this.videoId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasImageContent => contentImages.isNotEmpty;
}
