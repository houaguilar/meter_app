

import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/domain/entities/entities.dart';

abstract interface class MetradosLocalRepository {
  Future<Either<Failure, int>> saveMetrado(String name, int projectId);
  Future<Either<Failure, List<Metrado>>> getAllMetrados(int projectId);
  Future<Either<Failure, void>> deleteMetrado(Metrado metrado);
  Future<Either<Failure, void>> updateMetrado(Metrado metrado);
}

