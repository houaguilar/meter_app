part of 'metrados_bloc.dart';

@immutable
sealed class MetradosEvent {}

class CreateMetradoEvent extends MetradosEvent {
  final String name;
  final int projectId;

  CreateMetradoEvent({required this.name, required this.projectId});
}

class LoadMetradosEvent extends MetradosEvent {
  final int projectId;

  LoadMetradosEvent({required this.projectId});
}

class EditMetradoEvent extends MetradosEvent {
  final Metrado metrado;

  EditMetradoEvent({required this.metrado});
}

class DeleteMetradoEvent extends MetradosEvent {
  final Metrado metrado;

  DeleteMetradoEvent({required this.metrado});
}
