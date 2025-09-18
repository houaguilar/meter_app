
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/constants/error/exceptions.dart';
import '../../../../config/constants/error/failures.dart';
import '../../../../domain/datasources/home/inicio/article_remote_data_source.dart';
import '../../../models/models.dart';

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final SupabaseClient client;

  ArticleRemoteDataSourceImpl(this.client);

  @override
  Future<Either<Failure, List<ArticleModel>>> fetchArticles() async {
    try {
      print('🔍 Fetching articles from Supabase...');

      final response = await client
          .from('articles')
          .select('''
            id,
            title,
            description,
            image_url,
            article_detail,
            video_id,
            content_images,
            created_at,
            updated_at
          ''')
          .order('created_at', ascending: true);

      print('🔍 Raw Supabase response:');
      print(response);
      print('🔍 Response type: ${response.runtimeType}');
      print('🔍 Response length: ${(response as List).length}');

      final List<ArticleModel> articles = (response as List)
          .map((data) {
        print('🔍 Processing article: ${data['title']}');
        print('🔍 Article ID: ${data['id']}');
        print('🔍 Has content_images: ${data['content_images'] != null}');
        if (data['content_images'] != null) {
          print('🔍 Content images raw: ${data['content_images']}');
          print('🔍 Content images type: ${data['content_images'].runtimeType}');
        }

        final article = ArticleModel.fromMap(data);
        print('🔍 Article ${article.title} hasImageContent: ${article.hasImageContent}');
        print('🔍 Article ${article.title} contentImages count: ${article.contentImages.length}');

        return article;
      })
          .toList();

      print('🔍 Total articles processed: ${articles.length}');
      for (var article in articles) {
        print('🔍 Article: ${article.title} - Images: ${article.contentImages.length}');
      }

      return Right(articles);
    } on PostgrestException catch (e) {
      print('🔥 PostgrestException: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      print('🔥 General Exception: $e');
      return Left(Failure(message: e.toString()));
    }
  }
}