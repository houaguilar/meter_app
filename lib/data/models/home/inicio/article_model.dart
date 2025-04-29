

import '../../../../domain/entities/entities.dart';

class ArticleModel extends ArticleEntity {
  ArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.articleDetail,
    required super.videoId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'],
      articleDetail: map['article_detail'],
      videoId: map['video_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'article_detail': articleDetail,
      'video_id': videoId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
