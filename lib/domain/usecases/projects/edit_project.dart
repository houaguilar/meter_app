import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/config/usecase/usecase.dart';
import 'package:meter_app/domain/repositories/projects/projects_repository.dart';
import 'package:meter_app/domain/entities/projects/project.dart';

class EditProject implements UseCase<void, EditProjectParams> {
  final ProjectsRepository repository;

  const EditProject(this.repository);

  @override
  Future<Either<Failure, void>> call(EditProjectParams params) async {
    return await repository.editProject(params.project);
  }
}

class EditProjectParams {
  final Project project;

  EditProjectParams({required this.project});
}
