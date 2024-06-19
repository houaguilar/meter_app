import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:meter_app/domain/usecases/projects/get_all_projects.dart';
import 'package:meter_app/domain/usecases/projects/save_project.dart';
import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/projects/delete_project.dart';
import '../../../domain/usecases/projects/edit_project.dart';

part 'projects_event.dart';
part 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final CreateProject _createProject;
  final GetAllProjects _getAllProjects;
  final DeleteProject _deleteProject;
  final EditProject _editProject;

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
    emit(ProjectLoading());
    final result = await _createProject(CreateProjectParams(name: event.name));
    result.fold(
          (failure) {
        if (failure.type == FailureType.duplicateName) {
          print('ProjectNameAlreadyExists create failure');
          emit(ProjectNameAlreadyExists(failure.message));
          add(LoadProjectsEvent());
        } else {
          print('ProjectFailure create failure');
          emit(ProjectFailure(failure.message));
        }
      },
          (_) => add(LoadProjectsEvent()),
    );
  }

  void _onLoadProjects(
      LoadProjectsEvent event,
      Emitter<ProjectsState> emit,
      ) async {
    print('LoadProjectsEvent called');
    emit(ProjectLoading());
    final result = await _getAllProjects(NoParams());
    result.fold(
          (failure) => emit(ProjectFailure(failure.message)),
          (projects) => emit(ProjectSuccess(projects)),
    );
  }

  void _onSaveProject(
      SaveProject event,
      Emitter<ProjectsState> emit,
      ) async {
    print('SaveProject called with project: ${event.project.name}');
    emit(ProjectLoading());
    final result = await _createProject(CreateProjectParams(name: event.project.name));
    result.fold(
          (failure) {
        if (failure.type == FailureType.duplicateName) {
          print('ProjectNameAlreadyExists save failure');
          emit(ProjectNameAlreadyExists(failure.message));
          add(LoadProjectsEvent());

        } else {
          print('ProjectFailure save failure');
          emit(ProjectFailure(failure.message));
        }
      },
          (_) {
        print('SaveProject succeeded');
        emit(ProjectAdded(project: event.project));
      },
    );
  }

  void _onDeleteProject(
      DeleteProjectEvent event,
      Emitter<ProjectsState> emit
      ) async {
    emit(ProjectLoading());
    final result = await _deleteProject(DeleteProjectParams(project: event.project));
    result.fold(
          (failure) => emit(ProjectFailure(failure.message)),
          (_) => add(LoadProjectsEvent()),
    );
  }

  void _onEditProject(EditProjectEvent event, Emitter<ProjectsState> emit) async {
    print('EditProjectEvent called');
    final result = await _editProject(EditProjectParams(project: event.project));
    result.fold(
          (failure) {
        print('EditProjectEvent failure');
        if (failure.type == FailureType.duplicateName) {
          print('ProjectNameAlreadyExists failure');

          emit(ProjectNameAlreadyExists(failure.message));
          add(LoadProjectsEvent());

        } else {
          print('ProjectFailure failure');

          emit(ProjectFailure(failure.message));
        }
      },
          (_) => add(LoadProjectsEvent()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    // Puedes mapear los mensajes de fallo a mensajes específicos aquí.
    return 'Server Failure';
  }
}