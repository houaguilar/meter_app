

import 'package:fpdart/fpdart.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../../data/models/models.dart';

abstract interface class ArticleRemoteDataSource {
  Future<Either<Failure, List<ArticleModel>>> fetchArticles();
}

