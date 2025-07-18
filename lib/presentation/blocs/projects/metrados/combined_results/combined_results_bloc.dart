// lib/presentation/blocs/projects/metrados/combined_results/combined_results_bloc.dart

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

  Future<void> _onLoadCombinedResults(LoadCombinedResultsEvent event,
      Emitter<CombinedResultsState> emit,) async {
    print('🔄 Iniciando carga de resultados combinados...');
    emit(CombinedResultsLoading());

    try {
      print('📂 Cargando metrados del proyecto ${event.projectId}...');

      // Cargar metrados del proyecto
      final metradosResult = await _getAllMetrados(
        GetAllMetradosParams(projectId: event.projectId),
      );

      await metradosResult.fold(
            (failure) async {
          print('❌ Error al cargar metrados: ${failure.message}');
          emit(CombinedResultsError(
            message: 'Error al cargar metrados: ${failure.message}',
          ));
        },
            (allMetrados) async {
          print('✅ Metrados cargados: ${allMetrados.length} total');

          // Filtrar solo los metrados seleccionados
          final selectedMetrados = allMetrados
              .where((metrado) => event.selectedMetradoIds.contains(metrado.id))
              .toList();

          print('🎯 Metrados seleccionados: ${selectedMetrados.length}');
          selectedMetrados.forEach((m) =>
              print('   - ${m.name} (ID: ${m.id})'));

          if (selectedMetrados.isEmpty) {
            emit(CombinedResultsError(
              message: 'No se encontraron metrados seleccionados',
            ));
            return;
          }

          // Cargar resultados para cada metrado seleccionado
          final metradosWithResults = <MetradoWithResults>[];

          for (final metrado in selectedMetrados) {
            print('📊 Cargando resultados para: ${metrado.name}...');

            final resultsResult = await _loadResults(
              LoadResultsParams(metradoId: metrado.id.toString()),
            );

            await resultsResult.fold(
                  (failure) async {
                print('⚠️ Error loading results for metrado ${metrado
                    .name}: ${failure.message}');
                // Continuar con otros metrados en caso de error
              },
                  (results) async {
                print('✅ Resultados cargados para ${metrado.name}: ${results
                    .length} items');

                if (results.isNotEmpty) {
                  metradosWithResults.add(
                    MetradoWithResults(
                      metrado: metrado,
                      results: results,
                    ),
                  );
                } else {
                  print('⚠️ Metrado ${metrado.name} no tiene resultados');
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

          print('🔗 Iniciando combinación de ${metradosWithResults
              .length} metrados con resultados...');
          print('📋 Metrados a combinar:');
          metradosWithResults.forEach((mwr) {
            print('   🏗️ ${mwr.metrado.name}: ${mwr.results.length} elementos');
          });

          // Combinar resultados usando el servicio mejorado
          final combinedResult = UnifiedResultsCombiner.combineMetrados(
            metradosWithResults: metradosWithResults,
            projectName: event.projectName,
          );

          print('🎉 Combinación exitosa:');
          print('   📦 ${combinedResult.combinedMaterials
              .length} tipos de materiales únicos');
          print('   📏 Área total: ${combinedResult.totalArea.toStringAsFixed(
              2)} m²');
          print('   🏗️ ${combinedResult.metradoCount} metrados procesados');

          emit(CombinedResultsSuccess(
            combinedResult: combinedResult,
            selectedMetradoIds: event.selectedMetradoIds,
            projectId: event.projectId,
            message: 'Resultados combinados exitosamente',
          ));
        },
      );
    } catch (e, stackTrace) {
      print('❌ Error inesperado en combinación: $e');
      print('Stack trace: $stackTrace');

      emit(CombinedResultsError(
        message: 'Error inesperado al combinar resultados: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshCombinedResults(RefreshCombinedResultsEvent event,
      Emitter<CombinedResultsState> emit,) async {
    if (state is CombinedResultsSuccess) {
      final currentState = state as CombinedResultsSuccess;

      print('🔄 Refrescando resultados combinados...');

      // Recargar con los mismos parámetros
      add(LoadCombinedResultsEvent(
        projectId: currentState.projectId,
        selectedMetradoIds: currentState.selectedMetradoIds,
        projectName: currentState.combinedResult.projectName,
      ));
    }
  }

  Future<void> _onGenerateCombinedPdf(GenerateCombinedPdfEvent event,
      Emitter<CombinedResultsState> emit,) async {
    if (state is! CombinedResultsSuccess) return;

    final currentState = state as CombinedResultsSuccess;
    emit(currentState.copyWith(isGeneratingPdf: true));

    try {
      print('📄 Generando PDF de materiales combinados...');

      // TODO: Implementar generación de PDF con materiales combinados
      // final pdfFile = await CombinedPdfGenerator.generateMaterialsPdf(
      //   currentState.combinedResult,
      // );

      // Simulación por ahora
      await Future.delayed(const Duration(seconds: 2));

      print('✅ PDF generado exitosamente');

      emit(currentState.copyWith(
        isGeneratingPdf: false,
        message: 'PDF de materiales generado exitosamente',
      ));
    } catch (e) {
      print('❌ Error al generar PDF: $e');

      emit(currentState.copyWith(
        isGeneratingPdf: false,
        error: 'Error al generar PDF: ${e.toString()}',
      ));
    }
  }

  Future<void> _onShareCombinedResults(ShareCombinedResultsEvent event,
      Emitter<CombinedResultsState> emit,) async {
    if (state is! CombinedResultsSuccess) return;

    final currentState = state as CombinedResultsSuccess;
    emit(currentState.copyWith(isSharing: true));

    try {
      print('📤 Compartiendo resultados en formato ${event.format}...');

      // TODO: Implementar compartir según el formato
      switch (event.format) {
        case ShareFormat.pdf:
        // await ShareService.sharePdf(currentState.combinedResult);
          break;
        case ShareFormat.excel:
        // await ShareService.shareExcel(currentState.combinedResult);
          break;
        case ShareFormat.text:
        // await ShareService.shareText(currentState.combinedResult);
          break;
      }

      // Simulación por ahora
      await Future.delayed(const Duration(seconds: 1));

      print('✅ Resultados compartidos exitosamente');

      emit(currentState.copyWith(
        isSharing: false,
        message: 'Resultados compartidos exitosamente',
      ));
    } catch (e) {
      print('❌ Error al compartir: $e');

      emit(currentState.copyWith(
        isSharing: false,
        error: 'Error al compartir resultados: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateSelectedMetrados(UpdateSelectedMetradosEvent event,
      Emitter<CombinedResultsState> emit,) async {
    if (state is CombinedResultsSuccess) {
      final currentState = state as CombinedResultsSuccess;

      print('🔄 Actualizando metrados seleccionados...');

      // Recargar con los nuevos metrados seleccionados
      add(LoadCombinedResultsEvent(
        projectId: currentState.projectId,
        selectedMetradoIds: event.newSelectedMetradoIds,
        projectName: currentState.combinedResult.projectName,
      ));
    }
  }
}