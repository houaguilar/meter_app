import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:meter_app/domain/usecases/projects/get_all_projects.dart';
import 'package:meter_app/domain/usecases/projects/save_project.dart';
import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/projects/delete_project.dart';
import '../../../domain/usecases/projects/edit_project.dart';
import '../common/error_handler_mixin.dart';

part 'projects_event.dart';
part 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> with ErrorHandlerMixin {
  final CreateProject _createProject;
  final GetAllProjects _getAllProjects;
  final DeleteProject _deleteProject;
  final EditProject _editProject;

  @override
  String get blocContext => 'ProjectsBloc';

  ProjectsBloc({
    required CreateProject createProject,
    required GetAllProjects getAllProjects,
    required DeleteProject deleteProject,
    required EditProject editProject,
  })  : _createProject = createProject,
        _getAllProjects = getAllProjects,
        _deleteProject = deleteProject,
        _editProject = editProject,
      super(ProjectInitial()) {
    on<CreateProjectEvent>(_onCreateProject);
    on<LoadProjectsEvent>(_onLoadProjects);
    on<SaveProject>(_onSaveProject);
    on<DeleteProjectEvent>(_onDeleteProject);
    on<EditProjectEvent>(_onEditProject);
  }

  void _onCreateProject(CreateProjectEvent event, Emitter<ProjectsState> emit) async {
    logInfo('Creando proyecto: ${event.name}');
    emit(ProjectLoading());

    try {
      final result = await _createProject(CreateProjectParams(name: event.name));
      result.fold(
        (failure) {
          if (failure.type == FailureType.duplicateName) {
            logWarning('Nombre de proyecto duplicado: ${event.name}');
            emit(ProjectNameAlreadyExists(failure.message));
          } else {
            final message = mapFailureToMessage(failure);
            emit(ProjectFailure(message));
          }
        },
        (_) {
          logInfo('Proyecto creado exitosamente: ${event.name}');
          add(LoadProjectsEvent());
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(ProjectFailure(message));
    }
  }

  void _onLoadProjects(
    LoadProjectsEvent event,
    Emitter<ProjectsState> emit,
  ) async {
    logInfo('Cargando proyectos');
    emit(ProjectLoading());

    try {
      final result = await _getAllProjects(NoParams());
      result.fold(
        (failure) {
          final message = mapFailureToMessage(failure);
          emit(ProjectFailure(message));
        },
        (projects) {
          logInfo('Proyectos cargados exitosamente: ${projects.length} items');
          emit(ProjectSuccess(projects));
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(ProjectFailure(message));
    }
  }

  void _onSaveProject(
    SaveProject event,
    Emitter<ProjectsState> emit,
  ) async {
    logInfo('Guardando proyecto: ${event.project.name}');
    emit(ProjectLoading());

    try {
      final result = await _createProject(CreateProjectParams(name: event.project.name));
      result.fold(
        (failure) {
          if (failure.type == FailureType.duplicateName) {
            logWarning('Nombre de proyecto duplicado al guardar: ${event.project.name}');
            emit(ProjectNameAlreadyExists(failure.message));
          } else {
            final message = mapFailureToMessage(failure);
            emit(ProjectFailure(message));
          }
        },
        (_) {
          logInfo('Proyecto guardado exitosamente: ${event.project.name}');
          emit(ProjectAdded(project: event.project));
          add(LoadProjectsEvent());
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(ProjectFailure(message));
    }
  }

  void _onDeleteProject(
    DeleteProjectEvent event,
    Emitter<ProjectsState> emit,
  ) async {
    logInfo('Eliminando proyecto: ${event.project.name}');
    emit(ProjectLoading());

    try {
      final result = await _deleteProject(DeleteProjectParams(project: event.project));
      result.fold(
        (failure) {
          final message = mapFailureToMessage(failure);
          emit(ProjectFailure(message));
        },
        (_) {
          logInfo('Proyecto eliminado exitosamente: ${event.project.name}');
          add(LoadProjectsEvent());
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(ProjectFailure(message));
    }
  }

  void _onEditProject(EditProjectEvent event, Emitter<ProjectsState> emit) async {
    logInfo('Editando proyecto: ${event.project.name}');
    emit(ProjectLoading());

    try {
      final result = await _editProject(EditProjectParams(project: event.project));
      result.fold(
        (failure) {
          if (failure.type == FailureType.duplicateName) {
            logWarning('Nombre de proyecto duplicado al editar: ${event.project.name}');
            emit(ProjectNameAlreadyExists(failure.message));
          } else {
            final message = mapFailureToMessage(failure);
            emit(ProjectFailure(message));
          }
        },
        (_) {
          logInfo('Proyecto editado exitosamente: ${event.project.name}');
          add(LoadProjectsEvent());
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(ProjectFailure(message));
    }
  }
}