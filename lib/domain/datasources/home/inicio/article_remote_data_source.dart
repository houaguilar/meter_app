

import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/error/failures.dart';
import '../../../../data/models/models.dart';

abstract interface class ArticleRemoteDataSource {
  Future<Either<Failure, List<ArticleModel>>> fetchArticles();
}

