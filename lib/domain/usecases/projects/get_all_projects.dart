

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/domain/repositories/projects/projects_repository.dart';

import '../../../core/constants/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/projects/project.dart';

class GetAllProjects implements UseCase<List<Project>, NoParams> {
  final ProjectsRepository repository;

  const GetAllProjects(this.repository);

  @override
  Future<Either<Failure, List<Project>>> call(NoParams params) async {
    return await repository.getAllProjects();
  }
}
