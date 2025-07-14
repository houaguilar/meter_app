part of 'combined_results_bloc.dart';

@immutable
abstract class CombinedResultsState {}

/// Estado inicial
class CombinedResultsInitial extends CombinedResultsState {}

/// Estado de carga
class CombinedResultsLoading extends CombinedResultsState {}

/// Estado de éxito con resultados combinados (sin precios)
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

/// Estadísticas de rendimiento de la combinación
class CombinationPerformanceStats {
  final Duration processingTime;
  final int totalCalculations;
  final int successfulCalculations;
  final int failedCalculations;
  final List<String> warnings;

  const CombinationPerformanceStats({
    required this.processingTime,
    required this.totalCalculations,
    required this.successfulCalculations,
    required this.failedCalculations,
    required this.warnings,
  });

  /// Porcentaje de éxito en los cálculos
  double get successRate {
    if (totalCalculations == 0) return 0.0;
    return (successfulCalculations / totalCalculations) * 100;
  }

  /// Indica si hubo problemas durante el procesamiento
  bool get hasIssues => failedCalculations > 0 || warnings.isNotEmpty;

  /// Resumen textual del rendimiento
  String get summaryText {
    if (successRate == 100.0 && warnings.isEmpty) {
      return 'Procesamiento exitoso sin problemas';
    } else if (successRate >= 80.0) {
      return 'Procesamiento completado con advertencias menores';
    } else {
      return 'Procesamiento completado con errores significativos';
    }
  }
}

/// Estado de configuración para la combinación
class CombinationConfiguration {
  final bool includeAllMaterials;
  final bool groupSimilarMaterials;
  final bool applyTolerances;
  final double materialTolerance;
  final List<String> excludedMaterialTypes;

  const CombinationConfiguration({
    this.includeAllMaterials = true,
    this.groupSimilarMaterials = true,
    this.applyTolerances = false,
    this.materialTolerance = 0.05, // 5% por defecto
    this.excludedMaterialTypes = const [],
  });

  CombinationConfiguration copyWith({
    bool? includeAllMaterials,
    bool? groupSimilarMaterials,
    bool? applyTolerances,
    double? materialTolerance,
    List<String>? excludedMaterialTypes,
  }) {
    return CombinationConfiguration(
      includeAllMaterials: includeAllMaterials ?? this.includeAllMaterials,
      groupSimilarMaterials: groupSimilarMaterials ?? this.groupSimilarMaterials,
      applyTolerances: applyTolerances ?? this.applyTolerances,
      materialTolerance: materialTolerance ?? this.materialTolerance,
      excludedMaterialTypes: excludedMaterialTypes ?? this.excludedMaterialTypes,
    );
  }
}

/// Información de metrado para UI
class MetradoUIInfo {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? lastModified;
  final int resultCount;
  final double estimatedArea;
  final List<String> resultTypes;
  final bool isValid;
  final String? validationError;

  const MetradoUIInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.lastModified,
    required this.resultCount,
    required this.estimatedArea,
    required this.resultTypes,
    required this.isValid,
    this.validationError,
  });

  /// Tiempo transcurrido desde la última modificación
  Duration get timeSinceLastModified {
    final reference = lastModified ?? createdAt;
    return DateTime.now().difference(reference);
  }

  /// Texto descriptivo del estado del metrado
  String get statusText {
    if (!isValid) return 'Error: ${validationError ?? "Metrado inválido"}';
    if (resultCount == 0) return 'Sin resultados';
    return '${resultCount} resultado${resultCount != 1 ? 's' : ''}';
  }

  /// Icono recomendado para el tipo de metrado
  String get recommendedIcon {
    if (resultTypes.contains('Columna') || resultTypes.contains('Viga')) {
      return 'structural';
    } else if (resultTypes.contains('Losa')) {
      return 'slab';
    } else if (resultTypes.contains('Ladrillo')) {
      return 'brick';
    } else if (resultTypes.contains('Tarrajeo')) {
      return 'plaster';
    } else if (resultTypes.contains('Piso')) {
      return 'floor';
    }
    return 'construction';
  }
}