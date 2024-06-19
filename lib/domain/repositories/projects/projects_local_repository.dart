
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/domain/entities/entities.dart';

abstract interface class ProjectsLocalRepository {
  Future<Either<Failure, void>> saveProject(String name);

  Future<Either<Failure, List<Project>>> getAllProjects();

  Future<Either<Failure, void>> deleteProject(Project project);

  Future<Either<Failure, void>> editProject(Project project);

}