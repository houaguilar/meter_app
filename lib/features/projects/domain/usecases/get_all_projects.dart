

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/features/projects/domain/repositories/projects_repository.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/projects/project.dart';

class GetAllProjects implements UseCase<List<Project>, NoParams> {
  final ProjectsRepository repository;

  const GetAllProjects(this.repository);

  @override
  Future<Either<Failure, List<Project>>> call(NoParams params) async {
    return await repository.getAllProjects();
  }
}
