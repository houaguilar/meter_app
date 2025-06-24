part of 'combined_results_bloc.dart';

@immutable
abstract class CombinedResultsState {}

/// Estado inicial
class CombinedResultsInitial extends CombinedResultsState {}

/// Estado de carga
class CombinedResultsLoading extends CombinedResultsState {}

/// Estado de éxito con resultados combinados
class CombinedResultsSuccess extends CombinedResultsState {
  final CombinedCalculationResult combinedResult;
  final List<int> selectedMetradoIds;
  final int projectId;
  final bool isGeneratingPdf;
  final bool isSharing;
  final String? message;
  final String? error;

  CombinedResultsSuccess({
    required this.combinedResult,
    required this.selectedMetradoIds,
    required this.projectId,
    this.isGeneratingPdf = false,
    this.isSharing = false,
    this.message,
    this.error,
  });

  CombinedResultsSuccess copyWith({
    CombinedCalculationResult? combinedResult,
    List<int>? selectedMetradoIds,
    int? projectId,
    bool? isGeneratingPdf,
    bool? isSharing,
    String? message,
    String? error,
  }) {
    return CombinedResultsSuccess(
      combinedResult: combinedResult ?? this.combinedResult,
      selectedMetradoIds: selectedMetradoIds ?? this.selectedMetradoIds,
      projectId: projectId ?? this.projectId,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
      isSharing: isSharing ?? this.isSharing,
      message: message,
      error: error,
    );
  }

  /// Indica si hay alguna operación en progreso
  bool get isProcessing => isGeneratingPdf || isSharing;

  /// Obtiene el mensaje de estado actual
  String? get statusMessage {
    if (isGeneratingPdf) return 'Generando PDF...';
    if (isSharing) return 'Compartiendo resultados...';
    return message;
  }
}

/// Estado de error
class CombinedResultsError extends CombinedResultsState {
  final String message;

  CombinedResultsError({
    required this.message,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSIONES Y UTILIDADES
// ═══════════════════════════════════════════════════════════════════════════

/// Extensión para obtener información del estado
extension CombinedResultsStateExtensions on CombinedResultsState {
  /// Indica si el estado es de éxito
  bool get isSuccess => this is CombinedResultsSuccess;

  /// Indica si el estado es de carga
  bool get isLoading => this is CombinedResultsLoading;

  /// Indica si el estado es de error
  bool get isError => this is CombinedResultsError;

  /// Obtiene el resultado combinado si está disponible
  CombinedCalculationResult? get combinedResult {
    if (this is CombinedResultsSuccess) {
      return (this as CombinedResultsSuccess).combinedResult;
    }
    return null;
  }

  /// Obtiene el mensaje de error si está disponible
  String? get errorMessage {
    if (this is CombinedResultsError) {
      return (this as CombinedResultsError).message;
    }
    if (this is CombinedResultsSuccess) {
      return (this as CombinedResultsSuccess).error;
    }
    return null;
  }
}

/// Parámetros para cargar resultados combinados
class LoadCombinedResultsParams {
  final int projectId;
  final List<int> selectedMetradoIds;
  final String projectName;

  const LoadCombinedResultsParams({
    required this.projectId,
    required this.selectedMetradoIds,
    required this.projectName,
  });
}

/// Resultado de validación de metrados
class MetradoValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<int> validMetradoIds;
  final List<int> invalidMetradoIds;

  const MetradoValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.validMetradoIds,
    required this.invalidMetradoIds,
  });

  /// Crea un resultado válido
  factory MetradoValidationResult.valid(List<int> metradoIds) {
    return MetradoValidationResult(
      isValid: true,
      validMetradoIds: metradoIds,
      invalidMetradoIds: [],
    );
  }

  /// Crea un resultado inválido
  factory MetradoValidationResult.invalid(String message) {
    return MetradoValidationResult(
      isValid: false,
      errorMessage: message,
      validMetradoIds: [],
      invalidMetradoIds: [],
    );
  }

  /// Crea un resultado parcialmente válido
  factory MetradoValidationResult.partial({
    required List<int> validIds,
    required List<int> invalidIds,
    required String message,
  }) {
    return MetradoValidationResult(
      isValid: validIds.isNotEmpty,
      errorMessage: message,
      validMetradoIds: validIds,
      invalidMetradoIds: invalidIds,
    );
  }
}