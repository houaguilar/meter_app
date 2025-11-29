import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../../domain/entities/entities.dart';
import '../../../../domain/usecases/projects/metrados/create_metrado.dart';
import '../../../../domain/usecases/projects/metrados/delete_metrado.dart';
import '../../../../domain/usecases/projects/metrados/edit_metrado.dart';
import '../../../../domain/usecases/projects/metrados/get_all_metrados.dart';
import '../../common/error_handler_mixin.dart';

part 'metrados_event.dart';
part 'metrados_state.dart';

class MetradosBloc extends Bloc<MetradosEvent, MetradosState> with ErrorHandlerMixin {
  final CreateMetrado _createMetrado;
  final GetAllMetrados _getAllMetrados;
  final DeleteMetrado _deleteMetrado;
  final EditMetrado _editMetrado;

  @override
  String get blocContext => 'MetradosBloc';

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
    logInfo('Creando metrado: ${event.name} en proyecto ${event.projectId}');
    emit(MetradoLoading());

    try {
      final result = await _createMetrado(
        CreateMetradoParams(name: event.name, projectId: event.projectId),
      );

      result.fold(
        (failure) {
          if (failure.type == FailureType.duplicateName) {
            logWarning('Nombre de metrado duplicado en proyecto ${event.projectId}: ${event.name}');
            emit(MetradoNameAlreadyExists(
              'Ya existe un metrado con el nombre "${event.name}" en este proyecto. '
              'Los nombres deben ser únicos dentro del mismo proyecto.'
            ));
          } else {
            final message = mapFailureToMessage(failure);
            emit(MetradoFailure(message));
          }
        },
        (metradoId) {
          logInfo('Metrado creado exitosamente con ID: $metradoId');
          emit(MetradoAdded(metradoId: metradoId));
          add(LoadMetradosEvent(projectId: event.projectId));
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(MetradoFailure(message));
    }
  }

  void _onLoadMetrados(LoadMetradosEvent event, Emitter<MetradosState> emit) async {
    logInfo('Cargando metrados del proyecto ${event.projectId}');
    emit(MetradoLoading());

    try {
      final result = await _getAllMetrados(GetAllMetradosParams(projectId: event.projectId));
      result.fold(
        (failure) {
          final message = mapFailureToMessage(failure);
          emit(MetradoFailure(message));
        },
        (metrados) {
          logInfo('Metrados cargados exitosamente: ${metrados.length} items');
          emit(MetradoSuccess(metrados));
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(MetradoFailure(message));
    }
  }

  void _onEditMetrado(EditMetradoEvent event, Emitter<MetradosState> emit) async {
    logInfo('Editando metrado: ${event.metrado.name} (ID: ${event.metrado.id})');
    emit(MetradoLoading());

    try {
      final result = await _editMetrado(EditMetradoParams(metrado: event.metrado));
      result.fold(
        (failure) {
          if (failure.type == FailureType.duplicateName) {
            logWarning('Nombre de metrado duplicado al editar: ${event.metrado.name}');
            emit(MetradoNameAlreadyExists(
              'Ya existe un metrado con el nombre "${event.metrado.name}" en este proyecto. '
              'Por favor elige un nombre diferente.'
            ));
          } else {
            final message = mapFailureToMessage(failure);
            emit(MetradoFailure(message));
          }
          // Recargar metrados después del error para mantener consistencia
          add(LoadMetradosEvent(projectId: event.metrado.projectId));
        },
        (_) {
          logInfo('Metrado editado exitosamente: ${event.metrado.name}');
          emit(MetradoEdited());
          add(LoadMetradosEvent(projectId: event.metrado.projectId));
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(MetradoFailure(message));
      add(LoadMetradosEvent(projectId: event.metrado.projectId));
    }
  }

  void _onDeleteMetrado(DeleteMetradoEvent event, Emitter<MetradosState> emit) async {
    logInfo('Eliminando metrado: ${event.metrado.name} (ID: ${event.metrado.id})');
    emit(MetradoLoading());

    try {
      final result = await _deleteMetrado(DeleteMetradoParams(metrado: event.metrado));
      result.fold(
        (failure) {
          final message = mapFailureToMessage(failure);
          emit(MetradoFailure(message));
        },
        (_) {
          logInfo('Metrado eliminado exitosamente: ${event.metrado.name}');
          emit(MetradoDeleted());
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(MetradoFailure(message));
    }
  }

  void _onResetMetradoState(ResetMetradoStateEvent event, Emitter<MetradosState> emit) async {
    logInfo('Reseteando estado del BLoC');
    emit(MetradoInitial());
  }
}