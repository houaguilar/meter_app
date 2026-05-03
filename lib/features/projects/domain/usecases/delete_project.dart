import 'package:fpdart/fpdart.dart';
import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/projects/domain/repositories/projects_repository.dart';
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
