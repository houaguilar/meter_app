
import 'dart:convert';
import '../../../../domain/entities/article/article_content_image.dart';
import '../../../../domain/entities/entities.dart';

class ArticleModel extends ArticleEntity {
  ArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.articleDetail,
    super.contentImages = const [],
    required super.videoId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map) {

    // Parsear content_images
    List<ArticleContentImage> contentImages = [];
    if (map['content_images'] != null) {
      try {
        // Si es una lista directamente (como viene de Supabase)
        final List<dynamic> imagesJson = map['content_images'] is List
            ? map['content_images']
            : (map['content_images'] is String
            ? json.decode(map['content_images'])
            : map['content_images']);


        contentImages = imagesJson
            .map((imageMap) {
          return ArticleContentImageModel.fromMap(imageMap);
        })
            .toList();

        // Ordenar por order_index
        contentImages.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

        for (var img in contentImages) {
        }
      } catch (e) {
        contentImages = [];
      }
    } else {
    }

    final article = ArticleModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'],
      articleDetail: map['article_detail'] ?? '',
      contentImages: contentImages,
      videoId: map['video_id'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );

    return article;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'article_detail': articleDetail,
      'content_images': contentImages.isNotEmpty
          ? json.encode(contentImages.map((img) => (img as ArticleContentImageModel).toMap()).toList())
          : null,
      'video_id': videoId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ArticleContentImageModel extends ArticleContentImage {
  ArticleContentImageModel({
    required super.imageUrl,
    super.caption,
    required super.orderIndex,
  });

  factory ArticleContentImageModel.fromMap(Map<String, dynamic> map) {
    return ArticleContentImageModel(
      imageUrl: map['image_url'] ?? '',
      caption: map['caption'],
      orderIndex: map['order_index'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image_url': imageUrl,
      'caption': caption,
      'order_index': orderIndex,
    };
  }
}