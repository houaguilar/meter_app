

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/usecase/usecase.dart';
import 'package:meter_app/domain/repositories/projects/projects_local_repository.dart';

import '../../../config/constants/error/failures.dart';

class CreateProject implements UseCase<void, CreateProjectParams> {
  final ProjectsLocalRepository repository;

  const CreateProject(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateProjectParams params) async {
    return await repository.saveProject(params.name);
  }
}

class CreateProjectParams {
  final String name;

  CreateProjectParams({required this.name});
}