part of 'projects_bloc.dart';

@immutable
sealed class ProjectsState {
  const ProjectsState();
}

final class ProjectInitial extends ProjectsState {}

final class ProjectLoading extends ProjectsState {}

final class ProjectSuccess extends ProjectsState {
  final List<Project> projects;
  const ProjectSuccess(this.projects);
}

class ProjectAdded extends ProjectsState {
  final Project project;

  const ProjectAdded({required this.project});
}
class ProjectNameAlreadyExists extends ProjectsState {
  final String message;
  ProjectNameAlreadyExists(this.message);
}

final class ProjectFailure extends ProjectsState {
  final String message;
  ProjectFailure(this.message);
}
