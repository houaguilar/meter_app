import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import '../../domain/entities/home/tarrajeo/coating.dart';
import '../widgets/dialogs/feature_disabled_dialog.dart';

extension CoatingUI on Coating {

  /// Determina si el revestimiento está disponible para cálculos
  bool get isAvailable {
    // Solo tarrajeo de muro está disponible por ahora (ID 1)
    const availableIds = ['1'];
    return availableIds.contains(id);
  }

  /// Obtiene el mensaje personalizado para revestimiento no disponible
  String get unavailableMessage {
    switch (id) {
      case '1':
        return 'Los cálculos para tarrajeo de muro están disponibles.';
      case '2':
        return 'Los cálculos para tarrajeo de cielorraso estarán disponibles próximamente.';
      case '3':
        return 'Los cálculos para solaqueo estarán disponibles próximamente.';
      default:
        return 'Este tipo de revestimiento estará disponible próximamente. '
            'Estamos trabajando para incluir más tipos de tarrajeo.';
    }
  }

  /// Obtiene el tipo de revestimiento para UI
  CoatingUIType get uiType {
    switch (id) {
      case '1':
        return CoatingUIType.tarrajeoMuro;
      case '2':
        return CoatingUIType.tarrajeoCielorraso;
      case '3':
        return CoatingUIType.solaqueo;
      case '4':
        return CoatingUIType.enlucido;
      default:
        return CoatingUIType.unknown;
    }
  }

  /// Obtiene el color principal asociado al revestimiento
  Color get primaryColor {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return AppColors.secondary;
      case CoatingUIType.tarrajeoCielorraso:
        return AppColors.primary;
      case CoatingUIType.solaqueo:
        return AppColors.warning;
      case CoatingUIType.enlucido:
        return AppColors.success;
      case CoatingUIType.unknown:
        return AppColors.neutral400;
    }
  }

  /// Obtiene el icono asociado al revestimiento
  IconData get iconData {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return Icons.format_paint;
      case CoatingUIType.tarrajeoCielorraso:
        return Icons.horizontal_rule;
      case CoatingUIType.solaqueo:
        return Icons.texture;
      case CoatingUIType.enlucido:
        return Icons.brush;
      case CoatingUIType.unknown:
        return Icons.help_outline;
    }
  }

  /// Obtiene una descripción corta del revestimiento
  String get shortDescription {
    final lines = details.split('\n');
    if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
      return lines.first.replaceAll('·', '').trim();
    }
    return 'Tipo de revestimiento';
  }

  /// Obtiene las características del revestimiento como lista
  List<String> get featuresList {
    return details
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll('·', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Valida si el revestimiento tiene datos mínimos requeridos
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

  /// Obtiene la categoría visual del revestimiento
  CoatingVisualCategory get visualCategory {
    if (isAvailable) {
      return CoatingVisualCategory.available;
    } else {
      return CoatingVisualCategory.comingSoon;
    }
  }

  /// Obtiene el nivel de complejidad del cálculo
  CalculationComplexity get calculationComplexity {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return CalculationComplexity.medium;
      case CoatingUIType.tarrajeoCielorraso:
        return CalculationComplexity.medium;
      case CoatingUIType.solaqueo:
        return CalculationComplexity.low;
      case CoatingUIType.enlucido:
        return CalculationComplexity.low;
      case CoatingUIType.unknown:
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

  /// Obtiene el uso típico del revestimiento
  String get typicalUse {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return 'Protección y acabado de muros interiores y exteriores';
      case CoatingUIType.tarrajeoCielorraso:
        return 'Acabado de la parte inferior de losas y vigas';
      case CoatingUIType.solaqueo:
        return 'Acabado fino sobre tarrajeo primario';
      case CoatingUIType.enlucido:
        return 'Acabado decorativo y protector';
      case CoatingUIType.unknown:
        return 'Uso por determinar';
    }
  }

  /// Obtiene las ventajas principales del revestimiento
  List<String> get mainAdvantages {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return [
          'Protección contra humedad',
          'Superficie uniforme',
          'Base para acabados',
          'Mejora el aspecto estético'
        ];
      case CoatingUIType.tarrajeoCielorraso:
        return [
          'Protección del concreto',
          'Acabado uniforme',
          'Oculta instalaciones',
          'Mejora la acústica'
        ];
      case CoatingUIType.solaqueo:
        return [
          'Acabado muy liso',
          'Fácil mantenimiento',
          'Mejor adherencia de pintura',
          'Superficie impermeable'
        ];
      case CoatingUIType.enlucido:
        return [
          'Acabado decorativo',
          'Protección duradera',
          'Variedad de texturas',
          'Resistencia al clima'
        ];
      case CoatingUIType.unknown:
        return ['Por determinar'];
    }
  }

  /// Obtiene los materiales principales necesarios
  List<String> get mainMaterials {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return [
          'Cemento',
          'Arena fina',
          'Agua',
          'Cal (opcional)'
        ];
      case CoatingUIType.tarrajeoCielorraso:
        return [
          'Cemento',
          'Arena fina',
          'Agua',
          'Aditivos adherentes'
        ];
      case CoatingUIType.solaqueo:
        return [
          'Cemento blanco',
          'Arena muy fina',
          'Agua',
          'Aditivos plastificantes'
        ];
      case CoatingUIType.enlucido:
        return [
          'Cal hidratada',
          'Arena fina',
          'Agua',
          'Pigmentos (opcional)'
        ];
      case CoatingUIType.unknown:
        return ['Por determinar'];
    }
  }

  /// Obtiene el espesor típico en milímetros
  String get typicalThickness {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return '10-15 mm';
      case CoatingUIType.tarrajeoCielorraso:
        return '8-12 mm';
      case CoatingUIType.solaqueo:
        return '2-5 mm';
      case CoatingUIType.enlucido:
        return '3-8 mm';
      case CoatingUIType.unknown:
        return 'Variable';
    }
  }

  /// Obtiene el proceso de aplicación
  List<String> get applicationProcess {
    switch (uiType) {
      case CoatingUIType.tarrajeoMuro:
        return [
          'Preparación de superficie',
          'Humedecimiento del muro',
          'Aplicación de primera capa',
          'Nivelación y acabado'
        ];
      case CoatingUIType.tarrajeoCielorraso:
        return [
          'Limpieza de superficie',
          'Aplicación de adherente',
          'Colocación de mortero',
          'Nivelación y alisado'
        ];
      case CoatingUIType.solaqueo:
        return [
          'Humedecimiento del tarrajeo',
          'Preparación de mezcla fina',
          'Aplicación con llana',
          'Alisado final'
        ];
      case CoatingUIType.enlucido:
        return [
          'Preparación de base',
          'Aplicación de primera mano',
          'Texturizado (opcional)',
          'Acabado final'
        ];
      case CoatingUIType.unknown:
        return ['Por determinar'];
    }
  }
}

/// Enum para tipos de revestimiento en UI
enum CoatingUIType {
  tarrajeoMuro,
  tarrajeoCielorraso,
  solaqueo,
  enlucido,
  unknown;

  String get displayName {
    switch (this) {
      case CoatingUIType.tarrajeoMuro:
        return 'Tarrajeo de Muro';
      case CoatingUIType.tarrajeoCielorraso:
        return 'Tarrajeo de Cielorraso';
      case CoatingUIType.solaqueo:
        return 'Solaqueo';
      case CoatingUIType.enlucido:
        return 'Enlucido';
      case CoatingUIType.unknown:
        return 'Desconocido';
    }
  }

  String get description {
    switch (this) {
      case CoatingUIType.tarrajeoMuro:
        return 'Revestimiento de mortero aplicado en muros';
      case CoatingUIType.tarrajeoCielorraso:
        return 'Revestimiento aplicado en la parte inferior de losas';
      case CoatingUIType.solaqueo:
        return 'Acabado fino y liso sobre tarrajeo primario';
      case CoatingUIType.enlucido:
        return 'Revestimiento decorativo a base de cal';
      case CoatingUIType.unknown:
        return 'Tipo de revestimiento no identificado';
    }
  }

  String get technicalDescription {
    switch (this) {
      case CoatingUIType.tarrajeoMuro:
        return 'Mortero de cemento y arena aplicado sobre muros para protección y acabado';
      case CoatingUIType.tarrajeoCielorraso:
        return 'Revestimiento de mortero aplicado en superficies horizontales superiores';
      case CoatingUIType.solaqueo:
        return 'Capa de acabado muy fina que proporciona una superficie lisa y uniforme';
      case CoatingUIType.enlucido:
        return 'Revestimiento a base de cal que proporciona acabado decorativo y protección';
      case CoatingUIType.unknown:
        return 'Sistema de revestimiento no definido';
    }
  }
}

/// Enum para categorías visuales de revestimiento
enum CoatingVisualCategory {
  available,
  comingSoon,
  disabled;

  Color get badgeColor {
    switch (this) {
      case CoatingVisualCategory.available:
        return AppColors.success;
      case CoatingVisualCategory.comingSoon:
        return AppColors.warning;
      case CoatingVisualCategory.disabled:
        return AppColors.neutral400;
    }
  }

  String get badgeText {
    switch (this) {
      case CoatingVisualCategory.available:
        return 'Disponible';
      case CoatingVisualCategory.comingSoon:
        return 'Próximamente';
      case CoatingVisualCategory.disabled:
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
        return '2-4 minutos';
      case CalculationComplexity.high:
        return '5-8 minutos';
      case CalculationComplexity.unknown:
        return 'Por determinar';
    }
  }
}

/// Extensión para BuildContext con helpers específicos del módulo de tarrajeo
extension CoatingModuleContext on BuildContext {

  /// Muestra un dialog de revestimiento no disponible
  void showCoatingNotAvailable({
    required String coatingName,
    required String coatingType,
    String? customMessage,
  }) {
    showDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => FeatureDisabledDialog(
        title: '$coatingName no disponible',
        message: customMessage ??
            'Los cálculos para este tipo de revestimiento están en desarrollo.',
        materialType: coatingType,
      ),
    );
  }

  /// Muestra un snackbar de error específico del módulo
  void showCoatingModuleError(String message) {
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
  void showCoatingModuleSuccess(String message) {
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

/// Helper class para validaciones específicas del módulo de tarrajeo
class CoatingValidator {
  CoatingValidator._();

  /// Valida que un revestimiento sea seguro para usar
  static ValidationResult validateCoating(Coating coating) {
    final errors = <String>[];

    // Validaciones básicas
    if (coating.id.isEmpty) {
      errors.add('ID de revestimiento requerido');
    }

    if (coating.name.trim().isEmpty) {
      errors.add('Nombre de revestimiento requerido');
    }

    if (coating.image.trim().isEmpty) {
      errors.add('Imagen de revestimiento requerida');
    }

    // Validaciones de seguridad
    if (coating.name.length > 100) {
      errors.add('Nombre de revestimiento demasiado largo');
    }

    if (coating.details.length > 1000) {
      errors.add('Descripción de revestimiento demasiado larga');
    }

    // Validación de ID válido
    if (!RegExp(r'^[1-9]\d*$').hasMatch(coating.id)) {
      errors.add('ID de revestimiento inválido');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida que un ID de revestimiento sea válido y conocido
  static bool isValidCoatingId(String id) {
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