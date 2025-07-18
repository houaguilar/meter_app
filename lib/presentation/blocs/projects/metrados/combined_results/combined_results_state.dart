// lib/presentation/blocs/projects/metrados/combined_results/combined_results_state.dart

part of 'combined_results_bloc.dart';

@immutable
abstract class CombinedResultsState {}

/// Estado inicial
class CombinedResultsInitial extends CombinedResultsState {}

/// Estado de carga con mensaje específico
class CombinedResultsLoading extends CombinedResultsState {
  final String? message;

  CombinedResultsLoading({this.message});
}

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

  /// Resumen rápido de los resultados
  String get quickSummary {
    final materialCount = combinedResult.combinedMaterials.length;
    final metradoCount = combinedResult.metradoCount;
    return '$materialCount materiales de $metradoCount metrados';
  }

  /// Información detallada de la combinación
  String get detailedInfo {
    final stats = combinedResult.stats;
    return '''
Proyecto: ${combinedResult.projectName}
Metrados combinados: ${stats.totalMetrados}
Materiales únicos: ${stats.totalMaterials}
Área total: ${stats.totalArea.toStringAsFixed(2)} m²
Fecha de combinación: ${_formatDate(combinedResult.combinationDate)}
''';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Estado de error
class CombinedResultsError extends CombinedResultsState {
  final String message;
  final String? technicalDetails;

  CombinedResultsError({
    required this.message,
    this.technicalDetails,
  });

  /// Mensaje completo del error
  String get fullMessage {
    if (technicalDetails != null) {
      return '$message\n\nDetalles técnicos: $technicalDetails';
    }
    return message;
  }
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
    return null;
  }

  /// Obtiene el mensaje de carga si está disponible
  String? get loadingMessage {
    if (this is CombinedResultsLoading) {
      return (this as CombinedResultsLoading).message;
    }
    return null;
  }

  /// Indica si se puede interactuar con la UI
  bool get canInteract {
    if (this is CombinedResultsSuccess) {
      return !(this as CombinedResultsSuccess).isProcessing;
    }
    return this is! CombinedResultsLoading;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONFIGURACIÓN PARA COMBINACIÓN AVANZADA (FUTURO)
// ═══════════════════════════════════════════════════════════════════════════

/// Configuración para la combinación de resultados
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
    this.materialTolerance = 0.05, // 5% de tolerancia
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

  /// Categoría principal del metrado
  String get primaryCategory {
    if (resultTypes.contains('Columna') || resultTypes.contains('Viga')) {
      return 'Estructural';
    } else if (resultTypes.contains('Losa')) {
      return 'Losas';
    } else if (resultTypes.contains('Ladrillo')) {
      return 'Albañilería';
    } else if (resultTypes.contains('Tarrajeo')) {
      return 'Acabados';
    } else if (resultTypes.contains('Piso')) {
      return 'Pisos';
    }
    return 'General';
  }
}