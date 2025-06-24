
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../domain/services/shared/UnifiedResultsCombiner.dart';
import '../../../../../domain/usecases/projects/metrados/result/load_results_use_case.dart';
import '../../../../../domain/usecases/projects/metrados/get_all_metrados.dart';

part 'combined_results_event.dart';
part 'combined_results_state.dart';

class CombinedResultsBloc extends Bloc<CombinedResultsEvent, CombinedResultsState> {
  final GetAllMetrados _getAllMetrados;
  final LoadResultsUseCase _loadResults;

  CombinedResultsBloc({
    required GetAllMetrados getAllMetrados,
    required LoadResultsUseCase loadResults,
  })  : _getAllMetrados = getAllMetrados,
        _loadResults = loadResults,
        super(CombinedResultsInitial()) {

    on<LoadCombinedResultsEvent>(_onLoadCombinedResults);
    on<RefreshCombinedResultsEvent>(_onRefreshCombinedResults);
    on<GenerateCombinedPdfEvent>(_onGenerateCombinedPdf);
    on<ShareCombinedResultsEvent>(_onShareCombinedResults);
    on<UpdateSelectedMetradosEvent>(_onUpdateSelectedMetrados);
  }

  Future<void> _onLoadCombinedResults(
      LoadCombinedResultsEvent event,
      Emitter<CombinedResultsState> emit,
      ) async {
    emit(CombinedResultsLoading());

    try {
      // Cargar metrados del proyecto
      final metradosResult = await _getAllMetrados(
        GetAllMetradosParams(projectId: event.projectId),
      );

      await metradosResult.fold(
            (failure) async {
          emit(CombinedResultsError(
            message: 'Error al cargar metrados: ${failure.message}',
          ));
        },
            (allMetrados) async {
          // Filtrar solo los metrados seleccionados
          final selectedMetrados = allMetrados
              .where((metrado) => event.selectedMetradoIds.contains(metrado.id))
              .toList();

          if (selectedMetrados.isEmpty) {
            emit(CombinedResultsError(
              message: 'No se encontraron metrados seleccionados',
            ));
            return;
          }

          // Cargar resultados para cada metrado seleccionado
          final metradosWithResults = <MetradoWithResults>[];

          for (final metrado in selectedMetrados) {
            final resultsResult = await _loadResults(
              LoadResultsParams(metradoId: metrado.id.toString()),
            );

            await resultsResult.fold(
                  (failure) async {
                // Log error but continue with other metrados
                print('Error loading results for metrado ${metrado.id}: ${failure.message}');
              },
                  (results) async {
                if (results.isNotEmpty) {
                  metradosWithResults.add(
                    MetradoWithResults(
                      metrado: metrado,
                      results: results,
                    ),
                  );
                }
              },
            );
          }

          if (metradosWithResults.isEmpty) {
            emit(CombinedResultsError(
              message: 'No se encontraron resultados en los metrados seleccionados',
            ));
            return;
          }

          // Combinar resultados usando el servicio
          final combinedResult = UnifiedResultsCombiner.combineMetrados(
            metradosWithResults: metradosWithResults,
            projectName: event.projectName,
          );

          emit(CombinedResultsSuccess(
            combinedResult: combinedResult,
            selectedMetradoIds: event.selectedMetradoIds,
            projectId: event.projectId,
          ));
        },
      );
    } catch (e) {
      emit(CombinedResultsError(
        message: 'Error inesperado: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshCombinedResults(
      RefreshCombinedResultsEvent event,
      Emitter<CombinedResultsState> emit,
      ) async {
    if (state is CombinedResultsSuccess) {
      final currentState = state as CombinedResultsSuccess;

      // Recargar con los mismos parámetros
      add(LoadCombinedResultsEvent(
        projectId: currentState.projectId,
        selectedMetradoIds: currentState.selectedMetradoIds,
        projectName: currentState.combinedResult.projectName,
      ));
    }
  }

  Future<void> _onGenerateCombinedPdf(
      GenerateCombinedPdfEvent event,
      Emitter<CombinedResultsState> emit,
      ) async {
    if (state is! CombinedResultsSuccess) return;

    final currentState = state as CombinedResultsSuccess;
    emit(currentState.copyWith(isGeneratingPdf: true));

    try {
      // TODO: Implementar generación de PDF
      // final pdfFile = await CombinedPdfGenerator.generateCombinedPdf(
      //   currentState.combinedResult,
      // );

      await Future.delayed(const Duration(seconds: 2)); // Simulación

      emit(currentState.copyWith(
        isGeneratingPdf: false,
        message: 'PDF generado exitosamente',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isGeneratingPdf: false,
        error: 'Error al generar PDF: ${e.toString()}',
      ));
    }
  }

  Future<void> _onShareCombinedResults(
      ShareCombinedResultsEvent event,
      Emitter<CombinedResultsState> emit,
      ) async {
    if (state is! CombinedResultsSuccess) return;

    final currentState = state as CombinedResultsSuccess;
    emit(currentState.copyWith(isSharing: true));

    try {
      // TODO: Implementar compartir
      // await ShareService.shareCombinedResults(
      //   currentState.combinedResult,
      //   format: event.format,
      // );

      await Future.delayed(const Duration(seconds: 1)); // Simulación

      emit(currentState.copyWith(
        isSharing: false,
        message: 'Resultados compartidos exitosamente',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSharing: false,
        error: 'Error al compartir: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateSelectedMetrados(
      UpdateSelectedMetradosEvent event,
      Emitter<CombinedResultsState> emit,
      ) async {
    if (state is CombinedResultsSuccess) {
      final currentState = state as CombinedResultsSuccess;

      // Recargar con nuevos metrados seleccionados
      add(LoadCombinedResultsEvent(
        projectId: currentState.projectId,
        selectedMetradoIds: event.newSelectedMetradoIds,
        projectName: currentState.combinedResult.projectName,
      ));
    }
  }
}