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

          // Combinar resultados usando el servicio (sin precios)
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
      // TODO: Implementar generación de PDF con materiales sin precios
      // final pdfFile = await CombinedPdfGenerator.generateMaterialsPdf(
      //   currentState.combinedResult,
      // );

      await Future.delayed(const Duration(seconds: 2)); // Simulación

      emit(currentState.copyWith(
        isGeneratingPdf: false,
        message: 'PDF de materiales generado exitosamente',
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
      // Generar contenido según el formato solicitado
      String shareContent;

      switch (event.format) {
        case ShareFormat.pdf:
          shareContent = _generatePdfContent(currentState.combinedResult);
          break;
        case ShareFormat.excel:
          shareContent = _generateExcelContent(currentState.combinedResult);
          break;
        case ShareFormat.text:
          shareContent = _generateTextContent(currentState.combinedResult);
          break;
      }

      // TODO: Implementar compartir real
      // await ShareService.shareCombinedResults(
      //   content: shareContent,
      //   format: event.format,
      // );

      await Future.delayed(const Duration(seconds: 1)); // Simulación

      emit(currentState.copyWith(
        isSharing: false,
        message: 'Materiales compartidos exitosamente como ${event.format.name.toUpperCase()}',
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

  /// Genera contenido para PDF (solo materiales)
  String _generatePdfContent(CombinedCalculationResult result) {
    final buffer = StringBuffer();

    buffer.writeln('LISTA DE MATERIALES COMBINADOS');
    buffer.writeln('Proyecto: ${result.projectName}');
    buffer.writeln('Fecha: ${_formatDate(result.combinationDate)}');
    buffer.writeln('Metrados incluidos: ${result.metradoCount}');
    buffer.writeln('Área total: ${result.totalArea.toStringAsFixed(2)} m²');
    buffer.writeln('');

    buffer.writeln('MATERIALES:');
    buffer.writeln('═══════════════════════════════════════');

    for (int i = 0; i < result.sortedMaterials.length; i++) {
      final material = result.sortedMaterials[i];
      buffer.writeln('${i + 1}. ${material.name}');
      buffer.writeln('   Cantidad: ${material.totalQuantity < 1 ? material.totalQuantity.toStringAsFixed(3) : material.totalQuantity.toStringAsFixed(0)} ${material.unit}');

      if (material.contributions.isNotEmpty) {
        buffer.writeln('   Aportes por metrado:');
        material.contributions.forEach((metrado, cantidad) {
          final porcentaje = material.getContributionPercentage(metrado);
          buffer.writeln('   - $metrado: ${cantidad < 1 ? cantidad.toStringAsFixed(3) : cantidad.toStringAsFixed(0)} ${material.unit} (${porcentaje.toStringAsFixed(1)}%)');
        });
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Genera contenido para Excel (CSV)
  String _generateExcelContent(CombinedCalculationResult result) {
    final buffer = StringBuffer();

    // Encabezados
    buffer.writeln('Material,Cantidad,Unidad,Metrado Principal,% Principal');

    // Datos de materiales
    for (final material in result.sortedMaterials) {
      final topContributor = material.topContributor;
      final topPercentage = material.getContributionPercentage(topContributor);

      buffer.writeln('${material.name},${material.totalQuantity < 1 ? material.totalQuantity.toStringAsFixed(3) : material.totalQuantity.toStringAsFixed(0)},${material.unit},$topContributor,${topPercentage.toStringAsFixed(1)}%');
    }

    return buffer.toString();
  }

  /// Genera contenido para texto plano
  String _generateTextContent(CombinedCalculationResult result) {
    final buffer = StringBuffer();

    buffer.writeln('📋 MATERIALES COMBINADOS - ${result.projectName.toUpperCase()}');
    buffer.writeln('');
    buffer.writeln('🏗️ INFORMACIÓN GENERAL:');
    buffer.writeln('• Metrados incluidos: ${result.metradoCount}');
    buffer.writeln('• Área total: ${result.totalArea.toStringAsFixed(2)} m²');
    buffer.writeln('• Tipos de materiales: ${result.combinedMaterials.length}');
    buffer.writeln('• Fecha de combinación: ${_formatDate(result.combinationDate)}');
    buffer.writeln('');

    buffer.writeln('📊 LISTA DE MATERIALES:');
    buffer.writeln('─────────────────────────────────────');

    for (int i = 0; i < result.sortedMaterials.length; i++) {
      final material = result.sortedMaterials[i];
      buffer.writeln('${i + 1}. ${material.name}');
      buffer.writeln('   📦 Cantidad: ${material.totalQuantity < 1 ? material.totalQuantity.toStringAsFixed(3) : material.totalQuantity.toStringAsFixed(0)} ${material.unit}');

      if (material.contributions.isNotEmpty) {
        buffer.writeln('   🔍 Principal contribuyente: ${material.topContributor}');
      }
      buffer.writeln('');
    }

    buffer.writeln('📋 RESUMEN POR METRADO:');
    buffer.writeln('─────────────────────────────────────');

    for (final summary in result.metradoSummaries) {
      buffer.writeln('• ${summary.metradoName}');
      buffer.writeln('  - Área: ${summary.area.toStringAsFixed(2)} m²');
      buffer.writeln('  - Items: ${summary.itemCount}');
      buffer.writeln('  - Tipos: ${summary.resultTypes.join(', ')}');
      buffer.writeln('');
    }

    buffer.writeln('📱 Generado con MetraShop');

    return buffer.toString();
  }

  /// Formatea una fecha para mostrar
  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}