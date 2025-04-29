

import 'package:fpdart/fpdart.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../entities/entities.dart';

abstract interface class ArticleRepository {

  Future<Either<Failure, List<ArticleEntity>>> getArticles();
}