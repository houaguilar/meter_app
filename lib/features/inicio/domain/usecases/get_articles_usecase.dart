
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/features/inicio/domain/repositories/article_repository.dart';

class GetArticlesUseCase {
  final ArticleRepository repository;

  GetArticlesUseCase(this.repository);

  Future<Either<Failure, List<ArticleEntity>>> execute() async {
    return await repository.getArticles();
  }
}