

import 'package:fpdart/fpdart.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../entities/entities.dart';

abstract interface class MetradosLocalRepository {
  Future<Either<Failure, int>> saveMetrado(String name, int projectId);
  Future<Either<Failure, List<Metrado>>> getAllMetrados(int projectId);
  Future<Either<Failure, void>> deleteMetrado(Metrado metrado);
  Future<Either<Failure, void>> updateMetrado(Metrado metrado);
}

