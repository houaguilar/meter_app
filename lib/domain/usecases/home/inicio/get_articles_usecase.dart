
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/error/failures.dart';
import '../../../entities/entities.dart';
import '../../../repositories/home/inicio/article_repository.dart';

class GetArticlesUseCase {
  final ArticleRepository repository;

  GetArticlesUseCase(this.repository);

  Future<Either<Failure, List<ArticleEntity>>> execute() async {
    return await repository.getArticles();
  }
}