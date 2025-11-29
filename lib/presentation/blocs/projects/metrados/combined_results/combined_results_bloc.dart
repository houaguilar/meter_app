// lib/presentation/blocs/projects/metrados/combined_results/combined_results_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../domain/services/shared/UnifiedResultsCombiner.dart';
import '../../../../../domain/services/shared/combined_results_share_service.dart';
import '../../../../../domain/usecases/projects/metrados/result/load_results_use_case.dart';
import '../../../../../domain/usecases/projects/metrados/get_all_metrados.dart';
import '../../../common/error_handler_mixin.dart';

part 'combined_results_event.dart';
part 'combined_results_state.dart';

class CombinedResultsBloc extends Bloc<CombinedResultsEvent, CombinedResultsState>
    with ErrorHandlerMixin {
  final GetAllMetrados _getAllMetrados;
  final LoadResultsUseCase _loadResults;

  @override
  String get blocContext => 'CombinedResultsBloc';

  CombinedResultsBloc({
    required GetAllMetrados getAllMetrados,
    required LoadResultsUseCase loadResults,
  })
      : _getAllMetrados = getAllMetrados,
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
    logInfo('Iniciando carga de resultados combinados');
    logInfo('Proyecto ID: ${event.projectId}, Metrados: ${event.selectedMetradoIds.length}');
    emit(CombinedResultsLoading());

    try {
      // Cargar metrados del proyecto
      final metradosResult = await _getAllMetrados(
        GetAllMetradosParams(projectId: event.projectId),
      );

      await metradosResult.fold(
        (failure) async {
          final message = mapFailureToMessage(failure);
          emit(CombinedResultsError(message: 'Error al cargar metrados: $message'));
        },
        (allMetrados) async {
          logInfo('Metrados cargados: ${allMetrados.length} total');

          // Filtrar solo los metrados seleccionados
          final selectedMetrados = allMetrados
              .where((metrado) => event.selectedMetradoIds.contains(metrado.id))
              .toList();

          logInfo('Metrados seleccionados: ${selectedMetrados.length}');
          for (final m in selectedMetrados) {
            logInfo('  - ${m.name} (ID: ${m.id})');
          }

          if (selectedMetrados.isEmpty) {
            logWarning('No se encontraron metrados seleccionados');
            emit(CombinedResultsError(
              message: 'No se encontraron metrados seleccionados',
            ));
            return;
          }

          // Cargar resultados para cada metrado seleccionado
          final metradosWithResults = <MetradoWithResults>[];

          for (final metrado in selectedMetrados) {
            logInfo('Cargando resultados para: ${metrado.name}');

            final resultsResult = await _loadResults(
              LoadResultsParams(metradoId: metrado.id.toString()),
            );

            await resultsResult.fold(
              (failure) async {
                logWarning('Error al cargar resultados de ${metrado.name}: ${failure.message}');
                // Continuar con otros metrados en caso de error
              },
              (results) async {
                logInfo('Resultados cargados para ${metrado.name}: ${results.length} items');

                if (results.isNotEmpty) {
                  metradosWithResults.add(
                    MetradoWithResults(
                      metrado: metrado,
                      results: results,
                    ),
                  );
                } else {
                  logWarning('Metrado ${metrado.name} no tiene resultados');
                }
              },
            );
          }

          if (metradosWithResults.isEmpty) {
            logWarning('No se encontraron resultados en ningún metrado seleccionado');
            emit(CombinedResultsError(
              message: 'No se encontraron resultados en los metrados seleccionados',
            ));
            return;
          }

          logInfo('Iniciando combinación de ${metradosWithResults.length} metrados');

          // Combinar resultados usando el servicio mejorado
          final combinedResult = UnifiedResultsCombiner.combineMetrados(
            metradosWithResults: metradosWithResults,
            projectName: event.projectName,
          );

          logInfo('Combinación exitosa:');
          logInfo('  - ${combinedResult.combinedMaterials.length} materiales únicos');
          logInfo('  - Área total: ${combinedResult.totalArea.toStringAsFixed(2)} m²');
          logInfo('  - ${combinedResult.metradoCount} metrados procesados');

          emit(CombinedResultsSuccess(
            combinedResult: combinedResult,
            selectedMetradoIds: event.selectedMetradoIds,
            projectId: event.projectId,
            message: 'Resultados combinados exitosamente',
          ));
        },
      );
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      emit(CombinedResultsError(message: message));
    }
  }

  Future<void> _onRefreshCombinedResults(
    RefreshCombinedResultsEvent event,
    Emitter<CombinedResultsState> emit,
  ) async {
    if (state is CombinedResultsSuccess) {
      final currentState = state as CombinedResultsSuccess;
      logInfo('Refrescando resultados combinados');

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
      logInfo('Generando PDF de materiales combinados');

      // Generar PDF usando el servicio
      await CombinedResultsShareService.sharePdf(
        currentState.combinedResult,
        nombreUsuario: event.nombreUsuario,
      );

      logInfo('PDF generado y compartido exitosamente');

      emit(currentState.copyWith(
        isGeneratingPdf: false,
        message: 'PDF generado y compartido exitosamente',
      ));
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      logError('Error al generar PDF', error: e, stackTrace: stackTrace);

      emit(currentState.copyWith(
        isGeneratingPdf: false,
        error: 'Error al generar PDF: $message',
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
      logInfo('Compartiendo resultados en formato ${event.format}');

      switch (event.format) {
        case ShareFormat.pdf:
          await CombinedResultsShareService.sharePdf(
            currentState.combinedResult,
            nombreUsuario: event.nombreUsuario,
          );
          logInfo('PDF compartido exitosamente');
          break;
        case ShareFormat.text:
          await CombinedResultsShareService.shareText(currentState.combinedResult);
          logInfo('Texto compartido exitosamente');
          break;
      }

      emit(currentState.copyWith(
        isSharing: false,
        message: 'Resultados compartidos exitosamente',
      ));
    } catch (e, stackTrace) {
      final message = handleException(e, stackTrace: stackTrace);
      logError('Error al compartir resultados', error: e, stackTrace: stackTrace);

      emit(currentState.copyWith(
        isSharing: false,
        error: 'Error al compartir: $message',
      ));
    }
  }

  Future<void> _onUpdateSelectedMetrados(
    UpdateSelectedMetradosEvent event,
    Emitter<CombinedResultsState> emit,
  ) async {
    if (state is CombinedResultsSuccess) {
      final currentState = state as CombinedResultsSuccess;
      logInfo('Actualizando metrados seleccionados');

      // Recargar con los nuevos metrados seleccionados
      add(LoadCombinedResultsEvent(
        projectId: currentState.projectId,
        selectedMetradoIds: event.newSelectedMetradoIds,
        projectName: currentState.combinedResult.projectName,
      ));
    }
  }
}