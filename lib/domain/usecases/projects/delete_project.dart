import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/config/usecase/usecase.dart';
import 'package:meter_app/domain/repositories/projects/projects_repository.dart';
import 'package:meter_app/domain/entities/projects/project.dart';

class DeleteProject implements UseCase<void, DeleteProjectParams> {
  final ProjectsRepository repository;

  const DeleteProject(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) async {
    return await repository.deleteProject(params.project);
  }
}

class DeleteProjectParams {
  final Project project;

  DeleteProjectParams({required this.project});
}
