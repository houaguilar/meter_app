

import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/data/models/models.dart';

abstract interface class ArticleRemoteDataSource {
  Future<Either<Failure, List<ArticleModel>>> fetchArticles();
}

