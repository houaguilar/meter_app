
import 'package:fpdart/fpdart.dart';

import '../../../../../config/constants/error/failures.dart';

abstract class ResultLocalRepository {

  Future<Either<Failure, void>> saveResults(List<dynamic> results, String metradoId);

  Future<Either<Failure, List<dynamic>>> loadResults(String metradoId);
}