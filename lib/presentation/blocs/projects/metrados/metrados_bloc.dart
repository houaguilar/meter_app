import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../../domain/entities/entities.dart';
import '../../../../domain/usecases/projects/metrados/create_metrado.dart';
import '../../../../domain/usecases/projects/metrados/delete_metrado.dart';
import '../../../../domain/usecases/projects/metrados/edit_metrado.dart';
import '../../../../domain/usecases/projects/metrados/get_all_metrados.dart';

part 'metrados_event.dart';
part 'metrados_state.dart';

class MetradosBloc extends Bloc<MetradosEvent, MetradosState> {
  final CreateMetrado _createMetrado;
  final GetAllMetrados _getAllMetrados;
  final DeleteMetrado _deleteMetrado;
  final EditMetrado _editMetrado;

  MetradosBloc({
    required CreateMetrado createMetrado,
    required GetAllMetrados getAllMetrados,
    required DeleteMetrado deleteMetrado,
    required EditMetrado editMetrado,
  })  : _createMetrado = createMetrado,
        _getAllMetrados = getAllMetrados,
        _deleteMetrado = deleteMetrado,
        _editMetrado = editMetrado,
        super(MetradoInitial()) {
    on<CreateMetradoEvent>(_onCreateMetrado);
    on<LoadMetradosEvent>(_onLoadMetrados);
    on<EditMetradoEvent>(_onEditMetrado);
    on<DeleteMetradoEvent>(_onDeleteMetrado);
  }

  void _onCreateMetrado(CreateMetradoEvent event, Emitter<MetradosState> emit) async {
    emit(MetradoLoading());
    final result = await _createMetrado(CreateMetradoParams(name: event.name, projectId: event.projectId));
    result.fold(
          (failure) {
        if (failure.message.contains('already exists')) {
          emit(MetradoNameAlreadyExists('El metrado con el nombre "${event.name}" ya existe.'));
        } else {
          emit(MetradoFailure(_mapFailureToMessage(failure)));
        }
      },
        (metradoId) {
          emit(MetradoAdded(metradoId: metradoId));
          add(LoadMetradosEvent(projectId: event.projectId));
        }
    );
  }

  void _onLoadMetrados(LoadMetradosEvent event, Emitter<MetradosState> emit) async {
    emit(MetradoLoading());
    final result = await _getAllMetrados(GetAllMetradosParams(projectId: event.projectId));
    result.fold(
          (failure) => emit(MetradoFailure(_mapFailureToMessage(failure))),
          (metrados) => emit(MetradoSuccess(metrados)),
    );
  }

  void _onEditMetrado(EditMetradoEvent event, Emitter<MetradosState> emit) async {
    final result = await _editMetrado(EditMetradoParams(metrado: event.metrado));
    result.fold(
          (failure) {
          emit(MetradoFailure(_mapFailureToMessage(failure)));
          add(LoadMetradosEvent(projectId: event.metrado.projectId));
          },
          (_) {
            emit(MetradoEdited());
            add(LoadMetradosEvent(projectId: event.metrado.projectId));
          }
    );
  }

  void _onDeleteMetrado(DeleteMetradoEvent event, Emitter<MetradosState> emit) async {
    emit(MetradoLoading());
    final result = await _deleteMetrado(DeleteMetradoParams(metrado: event.metrado));
    result.fold(
          (failure) => emit(MetradoFailure(_mapFailureToMessage(failure))),
          (_) => emit(MetradoDeleted()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return 'Server Failure';
  }
}