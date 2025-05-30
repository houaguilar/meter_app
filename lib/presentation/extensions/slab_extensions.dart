// lib/presentation/extensions/slab_extensions.dart
import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import '../../domain/entities/home/losas/slab.dart';
import '../widgets/dialogs/feature_disabled_dialog.dart';

/// Extensiones para la entidad Slab que añaden funcionalidad
/// específica para la UI sin modificar la entidad del dominio
extension SlabUI on Slab {

  /// Determina si la losa está disponible para cálculos
  bool get isAvailable {
    // Solo losas aligeradas están disponibles por ahora (ID 1)
    const availableIds = ['1'];
    return availableIds.contains(id);
  }

  /// Obtiene el mensaje personalizado para losa no disponible
  String get unavailableMessage {
    switch (id) {
      case '1':
        return 'Los cálculos para losas aligeradas están disponibles.';
      case '2':
        return 'Los cálculos para losas macizas estarán disponibles próximamente.';
      default:
        return 'Este tipo de losa estará disponible próximamente. '
            'Estamos trabajando para incluir más tipos de losas.';
    }
  }

  /// Obtiene el tipo de losa para UI
  SlabUIType get uiType {
    switch (id) {
      case '1':
        return SlabUIType.aligerada;
      case '2':
        return SlabUIType.maciza;
      case '3':
        return SlabUIType.nervada;
      case '4':
        return SlabUIType.colaborante;
      default:
        return SlabUIType.unknown;
    }
  }

  /// Obtiene el color principal asociado a la losa
  Color get primaryColor {
    switch (uiType) {
      case SlabUIType.aligerada:
        return AppColors.secondary;
      case SlabUIType.maciza:
        return AppColors.primary;
      case SlabUIType.nervada:
        return AppColors.warning;
      case SlabUIType.colaborante:
        return AppColors.success;
      case SlabUIType.unknown:
        return AppColors.neutral400;
    }
  }

  /// Obtiene el icono asociado a la losa
  IconData get iconData {
    switch (uiType) {
      case SlabUIType.aligerada:
        return Icons.layers;
      case SlabUIType.maciza:
        return Icons.rectangle;
      case SlabUIType.nervada:
        return Icons.view_comfy;
      case SlabUIType.colaborante:
        return Icons.grid_4x4;
      case SlabUIType.unknown:
        return Icons.help_outline;
    }
  }

  /// Obtiene una descripción corta de la losa
  String get shortDescription {
    final lines = details.split('\n');
    if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
      return lines.first.replaceAll('·', '').trim();
    }
    return 'Tipo de losa estructural';
  }

  /// Obtiene las características de la losa como lista
  List<String> get featuresList {
    return details
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll('·', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Valida si la losa tiene datos mínimos requeridos
  bool get hasValidData {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        image.isNotEmpty &&
        details.isNotEmpty;
  }

  /// Obtiene el estado de disponibilidad como texto
  String get availabilityStatus {
    return isAvailable ? 'Disponible' : 'Próximamente';
  }

  /// Obtiene la categoría visual de la losa
  SlabVisualCategory get visualCategory {
    if (isAvailable) {
      return SlabVisualCategory.available;
    } else {
      return SlabVisualCategory.comingSoon;
    }
  }

  /// Obtiene el nivel de complejidad del cálculo
  CalculationComplexity get calculationComplexity {
    switch (uiType) {
      case SlabUIType.aligerada:
        return CalculationComplexity.medium;
      case SlabUIType.maciza:
        return CalculationComplexity.high;
      case SlabUIType.nervada:
        return CalculationComplexity.high;
      case SlabUIType.colaborante:
        return CalculationComplexity.high;
      case SlabUIType.unknown:
        return CalculationComplexity.unknown;
    }
  }

  /// Obtiene la descripción de la complejidad
  String get complexityDescription {
    switch (calculationComplexity) {
      case CalculationComplexity.low:
        return 'Cálculo simple y rápido';
      case CalculationComplexity.medium:
        return 'Cálculo de complejidad media';
      case CalculationComplexity.high:
        return 'Cálculo complejo y detallado';
      case CalculationComplexity.unknown:
        return 'Complejidad por determinar';
    }
  }

  /// Obtiene el uso típico de la losa
  String get typicalUse {
    switch (uiType) {
      case SlabUIType.aligerada:
        return 'Viviendas, edificios de mediana altura';
      case SlabUIType.maciza:
        return 'Estructuras con cargas pesadas';
      case SlabUIType.nervada:
        return 'Grandes luces, centros comerciales';
      case SlabUIType.colaborante:
        return 'Construcción industrializada';
      case SlabUIType.unknown:
        return 'Uso por determinar';
    }
  }

  /// Obtiene las ventajas principales de la losa
  List<String> get mainAdvantages {
    switch (uiType) {
      case SlabUIType.aligerada:
        return [
          'Menor peso propio',
          'Economía en materiales',
          'Facilidad constructiva',
          'Buen aislamiento térmico'
        ];
      case SlabUIType.maciza:
        return [
          'Alta resistencia',
          'Versatilidad en formas',
          'Mejor comportamiento sísmico',
          'Durabilidad superior'
        ];
      case SlabUIType.nervada:
        return [
          'Grandes luces sin apoyos',
          'Flexibilidad arquitectónica',
          'Optimización de materiales',
          'Rapidez constructiva'
        ];
      case SlabUIType.colaborante:
        return [
          'Rapidez de ejecución',
          'No requiere encofrado',
          'Menor mano de obra',
          'Control de calidad'
        ];
      case SlabUIType.unknown:
        return ['Por determinar'];
    }
  }
}

/// Enum para tipos de losa en UI
enum SlabUIType {
  aligerada,
  maciza,
  nervada,
  colaborante,
  unknown;

  String get displayName {
    switch (this) {
      case SlabUIType.aligerada:
        return 'Losa Aligerada';
      case SlabUIType.maciza:
        return 'Losa Maciza';
      case SlabUIType.nervada:
        return 'Losa Nervada';
      case SlabUIType.colaborante:
        return 'Losa Colaborante';
      case SlabUIType.unknown:
        return 'Desconocido';
    }
  }

  String get description {
    switch (this) {
      case SlabUIType.aligerada:
        return 'Losa con viguetas y bloques de alivianamiento';
      case SlabUIType.maciza:
        return 'Losa de concreto armado sin alivianamientos';
      case SlabUIType.nervada:
        return 'Losa con nervios en una o dos direcciones';
      case SlabUIType.colaborante:
        return 'Losa con lámina de acero colaborante';
      case SlabUIType.unknown:
        return 'Tipo de losa no identificado';
    }
  }

  String get technicalDescription {
    switch (this) {
      case SlabUIType.aligerada:
        return 'Sistema estructural formado por viguetas de concreto y bloques de alivianamiento';
      case SlabUIType.maciza:
        return 'Placa continua de concreto armado de espesor constante';
      case SlabUIType.nervada:
        return 'Sistema de losa con nervios que forman una retícula';
      case SlabUIType.colaborante:
        return 'Sistema mixto con lámina de acero y concreto';
      case SlabUIType.unknown:
        return 'Sistema estructural no definido';
    }
  }
}

/// Enum para categorías visuales de losa
enum SlabVisualCategory {
  available,
  comingSoon,
  disabled;

  Color get badgeColor {
    switch (this) {
      case SlabVisualCategory.available:
        return AppColors.success;
      case SlabVisualCategory.comingSoon:
        return AppColors.warning;
      case SlabVisualCategory.disabled:
        return AppColors.neutral400;
    }
  }

  String get badgeText {
    switch (this) {
      case SlabVisualCategory.available:
        return 'Disponible';
      case SlabVisualCategory.comingSoon:
        return 'Próximamente';
      case SlabVisualCategory.disabled:
        return 'No disponible';
    }
  }
}

/// Enum para complejidad de cálculo
enum CalculationComplexity {
  low,
  medium,
  high,
  unknown;

  Color get color {
    switch (this) {
      case CalculationComplexity.low:
        return AppColors.success;
      case CalculationComplexity.medium:
        return AppColors.warning;
      case CalculationComplexity.high:
        return AppColors.error;
      case CalculationComplexity.unknown:
        return AppColors.neutral400;
    }
  }

  IconData get icon {
    switch (this) {
      case CalculationComplexity.low:
        return Icons.speed;
      case CalculationComplexity.medium:
        return Icons.av_timer;
      case CalculationComplexity.high:
        return Icons.precision_manufacturing;
      case CalculationComplexity.unknown:
        return Icons.help_outline;
    }
  }

  String get estimatedTime {
    switch (this) {
      case CalculationComplexity.low:
        return '1-2 minutos';
      case CalculationComplexity.medium:
        return '3-5 minutos';
      case CalculationComplexity.high:
        return '5-10 minutos';
      case CalculationComplexity.unknown:
        return 'Por determinar';
    }
  }
}

/// Extensión para BuildContext con helpers específicos del módulo de losas
extension SlabModuleContext on BuildContext {

  /// Muestra un dialog de losa no disponible
  void showSlabNotAvailable({
    required String slabName,
    required String slabType,
    String? customMessage,
  }) {
    showDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => FeatureDisabledDialog(
        title: '$slabName no disponible',
        message: customMessage ??
            'Los cálculos para este tipo de losa están en desarrollo.',
        materialType: slabType,
      ),
    );
  }

  /// Muestra un snackbar de error específico del módulo
  void showSlabModuleError(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra un snackbar de éxito específico del módulo
  void showSlabModuleSuccess(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Helper class para validaciones específicas del módulo de losas
class SlabValidator {
  SlabValidator._();

  /// Valida que una losa sea segura para usar
  static ValidationResult validateSlab(Slab slab) {
    final errors = <String>[];

    // Validaciones básicas
    if (slab.id.isEmpty) {
      errors.add('ID de losa requerido');
    }

    if (slab.name.trim().isEmpty) {
      errors.add('Nombre de losa requerido');
    }

    if (slab.image.trim().isEmpty) {
      errors.add('Imagen de losa requerida');
    }

    // Validaciones de seguridad
    if (slab.name.length > 100) {
      errors.add('Nombre de losa demasiado largo');
    }

    if (slab.details.length > 1000) {
      errors.add('Descripción de losa demasiado larga');
    }

    // Validación de ID válido
    if (!RegExp(r'^[1-9]\d*$').hasMatch(slab.id)) {
      errors.add('ID de losa inválido');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida que un ID de losa sea válido y conocido
  static bool isValidSlabId(String id) {
    const validIds = ['1', '2', '3', '4']; // Expandir según necesidades
    return validIds.contains(id);
  }

  /// Sanitiza entrada de texto para evitar problemas
  static String sanitizeText(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>]'), '') // Remover caracteres potencialmente problemáticos
        .substring(0, input.length > 200 ? 200 : input.length); // Limitar longitud
  }
}

/// Clase para resultado de validación
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join(', ');

  bool get hasErrors => errors.isNotEmpty;
}