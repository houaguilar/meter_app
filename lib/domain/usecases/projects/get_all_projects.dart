

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/domain/repositories/projects/projects_local_repository.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/projects/project.dart';

class GetAllProjects implements UseCase<List<Project>, NoParams> {
  final ProjectsLocalRepository repository;

  const GetAllProjects(this.repository);

  @override
  Future<Either<Failure, List<Project>>> call(NoParams params) async {
    return await repository.getAllProjects();
  }
}
