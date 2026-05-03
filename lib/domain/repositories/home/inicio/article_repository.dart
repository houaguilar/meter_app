

import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/error/failures.dart';
import '../../../entities/entities.dart';

abstract interface class ArticleRepository {

  Future<Either<Failure, List<ArticleEntity>>> getArticles();
}