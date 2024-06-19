part of 'metrados_bloc.dart';

@immutable
sealed class MetradosState {
  const MetradosState();
}

class MetradoInitial extends MetradosState {}

class MetradoLoading extends MetradosState {}

class MetradoSuccess extends MetradosState {
  final List<Metrado> metrados;
  const MetradoSuccess(this.metrados);
}

class MetradoAdded extends MetradosState {
  final int metradoId;
  const MetradoAdded({required this.metradoId});
}

class MetradoDeleted extends MetradosState {}

class MetradoEdited extends MetradosState {}

class MetradoNameAlreadyExists extends MetradosState {
  final String message;
  const MetradoNameAlreadyExists(this.message);
}

class MetradoFailure extends MetradosState {
  final String message;
  const MetradoFailure(this.message);
}