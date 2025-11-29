import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../config/constants/error/failures.dart';
import '../../../../../domain/usecases/projects/metrados/result/load_results_use_case.dart';
import '../../../../../domain/usecases/projects/metrados/result/save_results_use_case.dart';
import '../../../common/error_handler_mixin.dart';

part 'result_event.dart';
part 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> with ErrorHandlerMixin {
  final SaveResultsUseCase saveResultsUseCase;
  final LoadResultsUseCase loadResultsUseCase;

  @override
  String get blocContext => 'ResultBloc';

  ResultBloc({
    required this.saveResultsUseCase,
    required this.loadResultsUseCase,
  }) : super(ResultInitial()) {
    on<SaveResultEvent>(_onSaveResult);
    on<LoadResultsEvent>(_onLoadResults);
    on<ResetResultStateEvent>(_onResetResultState);
  }

  void _onSaveResult(SaveResultEvent event, Emitter<ResultState> emit) async {
    logInfo('Iniciando guardado de resultados para metrado ${event.metradoId}');
    emit(ResultLoading());

    try {
      final result = await saveResultsUseCase(SaveResultParams(
          results: event.results,
          metradoId: event.metradoId
      ));

      result.fold(
        (failure) {
          final message = mapFailureToMessage(failure);
          emit(ResultFailure(message));
        },
        (_) {
          logInfo('Resultados guardados exitosamente');
          emit(ResultSuccess(event.results));
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(ResultFailure(message));
    }
  }

  void _onLoadResults(LoadResultsEvent event, Emitter<ResultState> emit) async {
    logInfo('Cargando resultados para metrado ${event.metradoId}');
    emit(ResultLoading());

    try {
      final result = await loadResultsUseCase(
        LoadResultsParams(metradoId: event.metradoId),
      );

      result.fold(
        (failure) {
          final message = mapFailureToMessage(failure);
          emit(ResultFailure(message));
        },
        (results) {
          logInfo('Resultados cargados exitosamente: ${results.length} items');
          emit(ResultSuccess(results));
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(ResultFailure(message));
    }
  }

  void _onResetResultState(ResetResultStateEvent event, Emitter<ResultState> emit) async {
    logInfo('Reseteando estado del BLoC');

    // Forzar emisión de estado inicial
    if (!emit.isDone) {
      emit(ResultInitial());
    }

    // Limpiar cualquier cache interno
    await Future.delayed(const Duration(milliseconds: 50));

    logInfo('Estado reseteado a inicial');
  }
}
