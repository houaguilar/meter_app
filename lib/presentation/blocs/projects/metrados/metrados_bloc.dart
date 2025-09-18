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
    on<ResetMetradoStateEvent>(_onResetMetradoState);

  }

  void _onCreateMetrado(CreateMetradoEvent event, Emitter<MetradosState> emit) async {
    emit(MetradoLoading());
    final result = await _createMetrado(CreateMetradoParams(name: event.name, projectId: event.projectId));
    result.fold(
            (failure) {
          // MEJORADO: Manejo más específico de errores basado en el tipo
          if (failure.type == FailureType.duplicateName) {
            emit(MetradoNameAlreadyExists(
                'Ya existe un metrado con el nombre "${event.name}" en este proyecto. '
                    'Los nombres deben ser únicos dentro del mismo proyecto.'
            ));
          } else {
            emit(MetradoFailure(_mapFailureToMessage(failure)));
          }
        },
            (metradoId) {
          emit(MetradoAdded(metradoId: metradoId));
          // Cargar metrados actualizados después de crear uno nuevo
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
    emit(MetradoLoading());
    final result = await _editMetrado(EditMetradoParams(metrado: event.metrado));
    result.fold(
            (failure) {
          // MEJORADO: Manejo específico de errores en edición
          if (failure.type == FailureType.duplicateName) {
            emit(MetradoNameAlreadyExists(
                'Ya existe un metrado con el nombre "${event.metrado.name}" en este proyecto. '
                    'Por favor elige un nombre diferente.'
            ));
          } else {
            emit(MetradoFailure(_mapFailureToMessage(failure)));
          }
          // Recargar metrados después del error para mantener consistencia
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

  void _onResetMetradoState(ResetMetradoStateEvent event, Emitter<MetradosState> emit) async {
    emit(MetradoInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.type) {
      case FailureType.duplicateName:
        return failure.message;
      case FailureType.general:
        return failure.message.isNotEmpty ? failure.message : 'Ha ocurrido un error';
      case FailureType.unknown:
        return 'Error inesperado. Por favor intenta nuevamente.';
      default:
        return 'Error del servidor';
    }
  }
}