import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/repositories/projects/metrados/metrados_local_repository.dart';

class CreateMetrado implements UseCase<void, CreateMetradoParams> {
  final MetradosLocalRepository repository;

  const CreateMetrado(this.repository);

  @override
  Future<Either<Failure, int>> call(CreateMetradoParams params) async {
    return await repository.saveMetrado(params.name, params.projectId);
  }
}

class CreateMetradoParams {
  final String name;
  final int projectId;

  CreateMetradoParams({required this.name, required this.projectId});
}