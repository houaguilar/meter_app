// lib/presentation/extensions/floor_extensions.dart
import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import '../../domain/entities/home/piso/floor.dart';
import '../widgets/dialogs/feature_disabled_dialog.dart';

/// Extensiones para la entidad Floor que añaden funcionalidad
/// específica para la UI sin modificar la entidad del dominio
extension FloorUI on Floor {

  /// Determina si el piso está disponible para cálculos
  bool get isAvailable {
    // Falso piso y contrapiso están disponibles (IDs 1 y 2)
    const availableIds = ['1', '2'];
    return availableIds.contains(id);
  }

  /// Obtiene el mensaje personalizado para piso no disponible
  String get unavailableMessage {
    switch (id) {
      case '1':
        return 'Los cálculos para falso piso están disponibles.';
      case '2':
        return 'Los cálculos para contrapiso están disponibles.';
      case '3':
        return 'Los cálculos para piso terminado estarán disponibles próximamente.';
      default:
        return 'Este tipo de piso estará disponible próximamente. '
            'Estamos trabajando para incluir más tipos de pisos.';
    }
  }

  /// Obtiene el tipo de piso para UI
  FloorUIType get uiType {
    switch (id) {
      case '1':
        return FloorUIType.falsoPiso;
      case '2':
        return FloorUIType.contrapiso;
      case '3':
        return FloorUIType.pisoTerminado;
      case '4':
        return FloorUIType.sobrepiso;
      default:
        return FloorUIType.unknown;
    }
  }

  /// Obtiene el color principal asociado al piso
  Color get primaryColor {
    switch (uiType) {
      case FloorUIType.falsoPiso:
        return AppColors.secondary;
      case FloorUIType.contrapiso:
        return AppColors.primary;
      case FloorUIType.pisoTerminado:
        return AppColors.warning;
      case FloorUIType.sobrepiso:
        return AppColors.success;
      case FloorUIType.unknown:
        return AppColors.neutral400;
    }
  }

  /// Obtiene el icono asociado al piso
  IconData get iconData {
    switch (uiType) {
      case FloorUIType.falsoPiso:
        return Icons.layers_outlined;
      case FloorUIType.contrapiso:
        return Icons.foundation;
      case FloorUIType.pisoTerminado:
        return Icons.texture;
      case FloorUIType.sobrepiso:
        return Icons.layers;
      case FloorUIType.unknown:
        return Icons.help_outline;
    }
  }

  /// Obtiene una descripción corta del piso
  String get shortDescription {
    final lines = details.split('\n');
    if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
      return lines.first.replaceAll('·', '').trim();
    }
    return 'Tipo de revestimiento de piso';
  }

  /// Obtiene las características del piso como lista
  List<String> get featuresList {
    return details
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll('·', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Valida si el piso tiene datos mínimos requeridos
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

  /// Obtiene la categoría visual del piso
  FloorVisualCategory get visualCategory {
    if (isAvailable) {
      return FloorVisualCategory.available;
    } else {
      return FloorVisualCategory.comingSoon;
    }
  }

  /// Obtiene el nivel de complejidad del cálculo
  CalculationComplexity get calculationComplexity {
    switch (uiType) {
      case FloorUIType.falsoPiso:
        return CalculationComplexity.medium;
      case FloorUIType.contrapiso:
        return CalculationComplexity.medium;
      case FloorUIType.pisoTerminado:
        return CalculationComplexity.low;
      case FloorUIType.sobrepiso:
        return CalculationComplexity.low;
      case FloorUIType.unknown:
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

  /// Obtiene el uso típico del piso
  String get typicalUse {
    switch (uiType) {
      case FloorUIType.falsoPiso:
        return 'Nivelación y preparación de superficie';
      case FloorUIType.contrapiso:
        return 'Base estructural para acabados';
      case FloorUIType.pisoTerminado:
        return 'Acabado final decorativo y funcional';
      case FloorUIType.sobrepiso:
        return 'Revestimiento sobre piso existente';
      case FloorUIType.unknown:
        return 'Uso por determinar';
    }
  }

  /// Obtiene las ventajas principales del piso
  List<String> get mainAdvantages {
    switch (uiType) {
      case FloorUIType.falsoPiso:
        return [
          'Nivelación perfecta',
          'Aislamiento térmico',
          'Fácil instalación',
          'Economía en materiales'
        ];
      case FloorUIType.contrapiso:
        return [
          'Base sólida y resistente',
          'Nivelación de superficie',
          'Durabilidad superior',
          'Soporte para cargas'
        ];
      case FloorUIType.pisoTerminado:
        return [
          'Acabado decorativo',
          'Fácil mantenimiento',
          'Variedad de diseños',
          'Confort al caminar'
        ];
      case FloorUIType.sobrepiso:
        return [
          'Renovación sin demoler',
          'Instalación rápida',
          'Menor costo',
          'Flexibilidad de diseño'
        ];
      case FloorUIType.unknown:
        return ['Por determinar'];
    }
  }

  /// Obtiene los materiales principales necesarios
  List<String> get mainMaterials {
    switch (uiType) {
      case FloorUIType.falsoPiso:
        return [
          'Cemento',
          'Arena fina',
          'Agua',
          'Aditivos opcionales'
        ];
      case FloorUIType.contrapiso:
        return [
          'Cemento',
          'Arena gruesa',
          'Agua',
          'Malla metálica (opcional)'
        ];
      case FloorUIType.pisoTerminado:
        return [
          'Material de acabado',
          'Adhesivo',
          'Fragua',
          'Selladores'
        ];
      case FloorUIType.sobrepiso:
        return [
          'Material de revestimiento',
          'Mortero nivelador',
          'Imprimante',
          'Perfiles de transición'
        ];
      case FloorUIType.unknown:
        return ['Por determinar'];
    }
  }

  /// Obtiene el espesor típico en centímetros
  String get typicalThickness {
    switch (uiType) {
      case FloorUIType.falsoPiso:
        return '2-5 cm';
      case FloorUIType.contrapiso:
        return '3-7 cm';
      case FloorUIType.pisoTerminado:
        return '0.5-2 cm';
      case FloorUIType.sobrepiso:
        return '0.3-1.5 cm';
      case FloorUIType.unknown:
        return 'Variable';
    }
  }
}

/// Enum para tipos de piso en UI
enum FloorUIType {
  falsoPiso,
  contrapiso,
  pisoTerminado,
  sobrepiso,
  unknown;

  String get displayName {
    switch (this) {
      case FloorUIType.falsoPiso:
        return 'Falso Piso';
      case FloorUIType.contrapiso:
        return 'Contrapiso';
      case FloorUIType.pisoTerminado:
        return 'Piso Terminado';
      case FloorUIType.sobrepiso:
        return 'Sobrepiso';
      case FloorUIType.unknown:
        return 'Desconocido';
    }
  }

  String get description {
    switch (this) {
      case FloorUIType.falsoPiso:
        return 'Capa de nivelación sobre la superficie existente';
      case FloorUIType.contrapiso:
        return 'Base estructural para el acabado final';
      case FloorUIType.pisoTerminado:
        return 'Acabado final decorativo del pavimento';
      case FloorUIType.sobrepiso:
        return 'Revestimiento aplicado sobre piso existente';
      case FloorUIType.unknown:
        return 'Tipo de piso no identificado';
    }
  }

  String get technicalDescription {
    switch (this) {
      case FloorUIType.falsoPiso:
        return 'Capa de mortero para nivelar y preparar la superficie base';
      case FloorUIType.contrapiso:
        return 'Capa estructural de concreto que sirve como base para acabados';
      case FloorUIType.pisoTerminado:
        return 'Material de acabado final que proporciona la superficie de uso';
      case FloorUIType.sobrepiso:
        return 'Sistema de revestimiento que se instala sobre pavimento existente';
      case FloorUIType.unknown:
        return 'Sistema de pavimento no definido';
    }
  }
}

/// Enum para categorías visuales de piso
enum FloorVisualCategory {
  available,
  comingSoon,
  disabled;

  Color get badgeColor {
    switch (this) {
      case FloorVisualCategory.available:
        return AppColors.success;
      case FloorVisualCategory.comingSoon:
        return AppColors.warning;
      case FloorVisualCategory.disabled:
        return AppColors.neutral400;
    }
  }

  String get badgeText {
    switch (this) {
      case FloorVisualCategory.available:
        return 'Disponible';
      case FloorVisualCategory.comingSoon:
        return 'Próximamente';
      case FloorVisualCategory.disabled:
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

/// Extensión para BuildContext con helpers específicos del módulo de pisos
extension FloorModuleContext on BuildContext {

  /// Muestra un dialog de piso no disponible
  void showFloorNotAvailable({
    required String floorName,
    required String floorType,
    String? customMessage,
  }) {
    showDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => FeatureDisabledDialog(
        title: '$floorName no disponible',
        message: customMessage ??
            'Los cálculos para este tipo de piso están en desarrollo.',
        materialType: floorType,
      ),
    );
  }

  /// Muestra un snackbar de error específico del módulo
  void showFloorModuleError(String message) {
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
  void showFloorModuleSuccess(String message) {
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

/// Helper class para validaciones específicas del módulo de pisos
class FloorValidator {
  FloorValidator._();

  /// Valida que un piso sea seguro para usar
  static ValidationResult validateFloor(Floor floor) {
    final errors = <String>[];

    // Validaciones básicas
    if (floor.id.isEmpty) {
      errors.add('ID de piso requerido');
    }

    if (floor.name.trim().isEmpty) {
      errors.add('Nombre de piso requerido');
    }

    if (floor.image.trim().isEmpty) {
      errors.add('Imagen de piso requerida');
    }

    // Validaciones de seguridad
    if (floor.name.length > 100) {
      errors.add('Nombre de piso demasiado largo');
    }

    if (floor.details.length > 1000) {
      errors.add('Descripción de piso demasiado larga');
    }

    // Validación de ID válido
    if (!RegExp(r'^[1-9]\d*$').hasMatch(floor.id)) {
      errors.add('ID de piso inválido');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida que un ID de piso sea válido y conocido
  static bool isValidFloorId(String id) {
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