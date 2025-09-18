
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
    print('🔍 ========== PARSING ARTICLE ==========');
    print('🔍 Article title: ${map['title']}');
    print('🔍 Article ID: ${map['id']}');
    print('🔍 Raw content_images: ${map['content_images']}');
    print('🔍 Content_images type: ${map['content_images'].runtimeType}');
    print('🔍 Content_images is null: ${map['content_images'] == null}');

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

        print('🔍 Parsed images JSON: $imagesJson');
        print('🔍 Images JSON length: ${imagesJson.length}');

        contentImages = imagesJson
            .map((imageMap) {
          print('🔍 Processing image: $imageMap');
          return ArticleContentImageModel.fromMap(imageMap);
        })
            .toList();

        // Ordenar por order_index
        contentImages.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

        print('🔍 Final content images count: ${contentImages.length}');
        for (var img in contentImages) {
          print('🔍 Image: ${img.imageUrl}');
          print('🔍 Caption: ${img.caption}');
          print('🔍 Order: ${img.orderIndex}');
        }
      } catch (e) {
        print('🔥 Error parsing content_images: $e');
        print('🔥 Stack trace: ${StackTrace.current}');
        contentImages = [];
      }
    } else {
      print('🔍 No content_images found for ${map['title']}');
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

    print('🔍 Article hasImageContent: ${article.hasImageContent}');
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
    print('🔍 Parsing image: ${map['image_url']}');
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