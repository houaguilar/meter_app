import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../config/constants/error/failures.dart';
import '../../../../../domain/usecases/projects/metrados/result/load_results_use_case.dart';
import '../../../../../domain/usecases/projects/metrados/result/save_results_use_case.dart';

part 'result_event.dart';
part 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final SaveResultsUseCase saveResultsUseCase;
  final LoadResultsUseCase loadResultsUseCase;

  ResultBloc({
    required this.saveResultsUseCase,
    required this.loadResultsUseCase,
  }) : super(ResultInitial()) {
    on<SaveResultEvent>(_onSaveResult);
    on<LoadResultsEvent>(_onLoadResults);
    on<ResetResultStateEvent>(_onResetResultState);
  }

  void _onSaveResult(SaveResultEvent event, Emitter<ResultState> emit) async {
    emit(ResultLoading());
    final result = await saveResultsUseCase(SaveResultParams(results: event.results, metradoId: event.metradoId));
    result.fold(
          (failure) => emit(ResultFailure(_mapFailureToMessage(failure))),
          (_) => emit(ResultSuccess(event.results)),
    );
  }

  void _onLoadResults(LoadResultsEvent event, Emitter<ResultState> emit) async {
    emit(ResultLoading());
    final result = await loadResultsUseCase(LoadResultsParams(metradoId: event.metradoId));
    result.fold(
          (failure) => emit(ResultFailure(failure.message)),
          (results) => emit(ResultSuccess(results)),
    );
  }

  void _onResetResultState(ResetResultStateEvent event, Emitter<ResultState> emit) async {
    emit(ResultInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.type) {
      case FailureType.duplicateName:
        return failure.message;
      case FailureType.general:
        return failure.message.isNotEmpty ? failure.message : 'Error al guardar resultados';
      case FailureType.unknown:
        return 'Error inesperado al procesar los resultados';
      default:
        return 'Error del servidor al guardar resultados';
    }
  }
}
