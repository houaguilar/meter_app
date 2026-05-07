

import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/features/inicio/data/models/article_model.dart';

abstract interface class ArticleRemoteDataSource {
  Future<Either<Failure, List<ArticleModel>>> fetchArticles();
}

