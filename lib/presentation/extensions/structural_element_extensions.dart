// lib/presentation/extensions/structural_element_extensions.dart
import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import '../../domain/entities/home/estructuras/structural_element.dart';
import '../widgets/dialogs/feature_disabled_dialog.dart';

/// Extensiones para la entidad StructuralElement que añaden funcionalidad
/// específica para la UI sin modificar la entidad del dominio
extension StructuralElementUI on StructuralElement {

  /// Determina si el elemento está disponible para cálculos
  bool get isAvailable {
    // Solo columnas y vigas están disponibles (IDs 1 y 2)
    const availableIds = ['1', '2'];
    return availableIds.contains(id);
  }

  /// Obtiene el mensaje personalizado para elemento no disponible
  String get unavailableMessage {
    switch (id) {
      case '1':
        return 'Los cálculos para columnas están disponibles.';
      case '2':
        return 'Los cálculos para vigas están disponibles.';
      default:
        return 'Este elemento estructural estará disponible próximamente. '
            'Estamos trabajando para incluir más tipos de elementos.';
    }
  }

  /// Obtiene el tipo de elemento para UI
  StructuralElementUIType get uiType {
    switch (id) {
      case '1':
        return StructuralElementUIType.columna;
      case '2':
        return StructuralElementUIType.viga;
      case '3':
        return StructuralElementUIType.losa;
      case '4':
        return StructuralElementUIType.zapata;
      default:
        return StructuralElementUIType.unknown;
    }
  }

  /// Obtiene el color principal asociado al elemento
  Color get primaryColor {
    switch (uiType) {
      case StructuralElementUIType.columna:
        return AppColors.secondary;
      case StructuralElementUIType.viga:
        return AppColors.success;
      case StructuralElementUIType.losa:
        return AppColors.warning;
      case StructuralElementUIType.zapata:
        return AppColors.primary;
      case StructuralElementUIType.unknown:
        return AppColors.neutral400;
    }
  }

  /// Obtiene el icono asociado al elemento
  IconData get iconData {
    switch (uiType) {
      case StructuralElementUIType.columna:
        return Icons.view_column;
      case StructuralElementUIType.viga:
        return Icons.architecture;
      case StructuralElementUIType.losa:
        return Icons.layers;
      case StructuralElementUIType.zapata:
        return Icons.foundation;
      case StructuralElementUIType.unknown:
        return Icons.help_outline;
    }
  }

  /// Obtiene una descripción corta del elemento
  String get shortDescription {
    final lines = details.split('\n');
    if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
      return lines.first.replaceAll('·', '').trim();
    }
    return 'Elemento estructural';
  }

  /// Obtiene las características del elemento como lista
  List<String> get featuresList {
    return details
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll('·', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Valida si el elemento tiene datos mínimos requeridos
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

  /// Obtiene la categoría visual del elemento
  ElementVisualCategory get visualCategory {
    if (isAvailable) {
      return ElementVisualCategory.available;
    } else {
      return ElementVisualCategory.comingSoon;
    }
  }

  /// Obtiene el nivel de complejidad del cálculo
  CalculationComplexity get calculationComplexity {
    switch (uiType) {
      case StructuralElementUIType.columna:
        return CalculationComplexity.medium;
      case StructuralElementUIType.viga:
        return CalculationComplexity.medium;
      case StructuralElementUIType.losa:
        return CalculationComplexity.high;
      case StructuralElementUIType.zapata:
        return CalculationComplexity.high;
      case StructuralElementUIType.unknown:
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
}

/// Enum para tipos de elemento estructural en UI
enum StructuralElementUIType {
  columna,
  viga,
  losa,
  zapata,
  unknown;

  String get displayName {
    switch (this) {
      case StructuralElementUIType.columna:
        return 'Columna';
      case StructuralElementUIType.viga:
        return 'Viga';
      case StructuralElementUIType.losa:
        return 'Losa';
      case StructuralElementUIType.zapata:
        return 'Zapata';
      case StructuralElementUIType.unknown:
        return 'Desconocido';
    }
  }

  String get description {
    switch (this) {
      case StructuralElementUIType.columna:
        return 'Elemento vertical que transmite cargas';
      case StructuralElementUIType.viga:
        return 'Elemento horizontal que resiste flexión';
      case StructuralElementUIType.losa:
        return 'Elemento plano que forma pisos y techos';
      case StructuralElementUIType.zapata:
        return 'Cimentación que transmite cargas al suelo';
      case StructuralElementUIType.unknown:
        return 'Tipo de elemento no identificado';
    }
  }
}

/// Enum para categorías visuales de elemento
enum ElementVisualCategory {
  available,
  comingSoon,
  disabled;

  Color get badgeColor {
    switch (this) {
      case ElementVisualCategory.available:
        return AppColors.success;
      case ElementVisualCategory.comingSoon:
        return AppColors.warning;
      case ElementVisualCategory.disabled:
        return AppColors.neutral400;
    }
  }

  String get badgeText {
    switch (this) {
      case ElementVisualCategory.available:
        return 'Disponible';
      case ElementVisualCategory.comingSoon:
        return 'Próximamente';
      case ElementVisualCategory.disabled:
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
}

/// Extensión para BuildContext con helpers específicos del módulo estructural
extension StructuralModuleContext on BuildContext {

  /// Muestra un dialog de elemento no disponible
  void showElementNotAvailable({
    required String elementName,
    required String elementType,
    String? customMessage,
  }) {
    showDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => FeatureDisabledDialog(
        title: '$elementName no disponible',
        message: customMessage ??
            'Los cálculos para este elemento estructural están en desarrollo.',
        materialType: elementType,
      ),
    );
  }

  /// Muestra un snackbar de error específico del módulo
  void showStructuralModuleError(String message) {
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
  void showStructuralModuleSuccess(String message) {
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

/// Helper class para validaciones específicas del módulo estructural
class StructuralElementValidator {
  StructuralElementValidator._();

  /// Valida que un elemento sea seguro para usar
  static ValidationResult validateElement(StructuralElement element) {
    final errors = <String>[];

    // Validaciones básicas
    if (element.id.isEmpty) {
      errors.add('ID de elemento requerido');
    }

    if (element.name.trim().isEmpty) {
      errors.add('Nombre de elemento requerido');
    }

    if (element.image.trim().isEmpty) {
      errors.add('Imagen de elemento requerida');
    }

    // Validaciones de seguridad
    if (element.name.length > 100) {
      errors.add('Nombre de elemento demasiado largo');
    }

    if (element.details.length > 1000) {
      errors.add('Descripción de elemento demasiado larga');
    }

    // Validación de ID válido
    if (!RegExp(r'^[1-9]\d*$').hasMatch(element.id)) {
      errors.add('ID de elemento inválido');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida que un ID de elemento sea válido y conocido
  static bool isValidElementId(String id) {
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