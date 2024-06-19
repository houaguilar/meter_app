part of 'projects_bloc.dart';

@immutable
sealed class ProjectsEvent {}

final class CreateProjectEvent extends ProjectsEvent {
  final String name;

  CreateProjectEvent({required this.name});
}

final class LoadProjectsEvent extends ProjectsEvent {}

final class SaveProject extends ProjectsEvent {
  final Project project;

  SaveProject({required this.project});
}

final class DeleteProjectEvent extends ProjectsEvent {
  final Project project;

  DeleteProjectEvent({required this.project});
}

final class EditProjectEvent extends ProjectsEvent {
  final Project project;

  EditProjectEvent({required this.project});
}
