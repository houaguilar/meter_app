

import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../entities/entities.dart';
import '../../../repositories/projects/metrados/metrados_local_repository.dart';

class GetAllMetrados implements UseCase<List<Metrado>, GetAllMetradosParams> {
  final MetradosLocalRepository repository;

  const GetAllMetrados(this.repository);

  @override
  Future<Either<Failure, List<Metrado>>> call(GetAllMetradosParams params) async {
    return await repository.getAllMetrados(params.projectId);
  }
}

class GetAllMetradosParams {
  final int projectId;

  GetAllMetradosParams({required this.projectId});
}