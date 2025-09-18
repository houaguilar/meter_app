
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/domain/repositories/home/inicio/article_repository.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../../config/network/connection_checker.dart';
import '../../../../domain/datasources/home/inicio/article_remote_data_source.dart';
import '../../../../domain/entities/entities.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  ArticleRepositoryImpl(
      this.remoteDataSource,
      this.connectionChecker,
      );

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticles() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: "No internet connection"));
      }

      final result = await remoteDataSource.fetchArticles();
      return result.fold(
            (failure) => Left(failure),
            (models) => Right(models.map((model) {
          print('🔍 Repository mapping: ${model.title} has ${model.contentImages.length} images');
          return ArticleEntity(
            id: model.id,
            title: model.title,
            description: model.description,
            imageUrl: model.imageUrl,
            articleDetail: model.articleDetail,
            contentImages: model.contentImages, // ✅ AGREGAR ESTA LÍNEA
            videoId: model.videoId,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
          );
        }).toList()),
      );

    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}