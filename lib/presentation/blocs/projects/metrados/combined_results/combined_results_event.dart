part of 'combined_results_bloc.dart';

@immutable
abstract class CombinedResultsEvent {}

/// Evento para cargar y combinar resultados de metrados seleccionados
class LoadCombinedResultsEvent extends CombinedResultsEvent {
  final int projectId;
  final List<int> selectedMetradoIds;
  final String projectName;

  LoadCombinedResultsEvent({
    required this.projectId,
    required this.selectedMetradoIds,
    required this.projectName,
  });
}

/// Evento para refrescar los resultados combinados actuales
class RefreshCombinedResultsEvent extends CombinedResultsEvent {}

/// Evento para generar PDF de los resultados combinados
class GenerateCombinedPdfEvent extends CombinedResultsEvent {}

/// Evento para compartir los resultados combinados
class ShareCombinedResultsEvent extends CombinedResultsEvent {
  final ShareFormat format;

  ShareCombinedResultsEvent({
    required this.format,
  });
}

/// Evento para actualizar los metrados seleccionados
class UpdateSelectedMetradosEvent extends CombinedResultsEvent {
  final List<int> newSelectedMetradoIds;

  UpdateSelectedMetradosEvent({
    required this.newSelectedMetradoIds,
  });
}

/// Formatos de compartir disponibles
enum ShareFormat {
  pdf,
  excel,
  text,
}