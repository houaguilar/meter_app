

import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/domain/entities/entities.dart';

abstract interface class ArticleRepository {

  Future<Either<Failure, List<ArticleEntity>>> getArticles();
}