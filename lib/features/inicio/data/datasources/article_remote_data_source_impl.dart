
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meter_app/core/constants/error/exceptions.dart';
import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/features/inicio/domain/datasources/article_remote_data_source.dart';
import 'package:meter_app/features/inicio/data/models/article_model.dart';

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final SupabaseClient client;

  ArticleRemoteDataSourceImpl(this.client);

  @override
  Future<Either<Failure, List<ArticleModel>>> fetchArticles() async {
    try {

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


      final List<ArticleModel> articles = (response as List)
          .map((data) {
        if (data['content_images'] != null) {
        }

        final article = ArticleModel.fromMap(data);

        return article;
      })
          .toList();

      for (var article in articles) {
      }

      return Right(articles);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}