// lib/presentation/extensions/material_extensions.dart
import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import '../../domain/entities/home/muro/wall_material.dart';
import '../widgets/config/wall_module_config.dart';
import '../widgets/dialogs/feature_disabled_dialog.dart';

/// Extensiones para la entidad WallMaterial que añaden funcionalidad
/// específica para la UI sin modificar la entidad del dominio
extension WallMaterialUI on WallMaterial {

  /// Determina si el material está disponible para cálculos
  bool get isAvailable => WallModuleConfig.isMaterialAvailable(id);

  /// Obtiene el mensaje personalizado para material no disponible
  String get unavailableMessage => WallModuleConfig.getUnavailableMessage(id);

  /// Obtiene el tipo de material para UI
  WallMaterialUIType get uiType {
    switch (id) {
      case '1':
      case '2':
      case '3':
      case '4':
        return WallMaterialUIType.ladrillo;
      case '5':
        return WallMaterialUIType.tabicon;
      case '6':
      case '7':
      case '8':
        return WallMaterialUIType.bloqueta;
      default:
        return WallMaterialUIType.unknown;
    }
  }

  /// Obtiene el color principal asociado al material
  Color get primaryColor {
    switch (uiType) {
      case WallMaterialUIType.ladrillo:
        return AppColors.success;
      case WallMaterialUIType.tabicon:
        return AppColors.warning;
      case WallMaterialUIType.bloqueta:
        return AppColors.secondary;
      case WallMaterialUIType.unknown:
        return AppColors.neutral400;
    }
  }

  /// Obtiene el icono asociado al material
  IconData get iconData {
    switch (uiType) {
      case WallMaterialUIType.ladrillo:
        return Icons.crop_square;
      case WallMaterialUIType.tabicon:
        return Icons.construction;
      case WallMaterialUIType.bloqueta:
        return Icons.view_module;
      case WallMaterialUIType.unknown:
        return Icons.help_outline;
    }
  }

  /// Obtiene una descripción corta del material
  String get shortDescription {
    final lines = details.split('\n');
    if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
      return lines.first.replaceAll('·', '').trim();
    }
    return 'Material de construcción';
  }

  /// Obtiene las características del material como lista
  List<String> get featuresList {
    return details
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll('·', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Valida si el material tiene datos mínimos requeridos
  bool get hasValidData {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        image.isNotEmpty &&
        size.isNotEmpty &&
        details.isNotEmpty;
  }

  /// Obtiene el estado de disponibilidad como texto
  String get availabilityStatus {
    return isAvailable ? 'Disponible' : 'Próximamente';
  }

  /// Obtiene la categoría visual del material
  MaterialVisualCategory get visualCategory {
    if (isAvailable) {
      return MaterialVisualCategory.available;
    } else {
      return MaterialVisualCategory.comingSoon;
    }
  }
}

/// Enum para tipos de material en UI
enum WallMaterialUIType {
  ladrillo,
  tabicon,
  bloqueta,
  unknown;

  String get displayName {
    switch (this) {
      case WallMaterialUIType.ladrillo:
        return 'Ladrillo';
      case WallMaterialUIType.tabicon:
        return 'Tabicón';
      case WallMaterialUIType.bloqueta:
        return 'Bloqueta';
      case WallMaterialUIType.unknown:
        return 'Desconocido';
    }
  }
}

/// Enum para categorías visuales de material
enum MaterialVisualCategory {
  available,
  comingSoon,
  disabled;

  Color get badgeColor {
    switch (this) {
      case MaterialVisualCategory.available:
        return AppColors.success;
      case MaterialVisualCategory.comingSoon:
        return AppColors.warning;
      case MaterialVisualCategory.disabled:
        return AppColors.neutral400;
    }
  }

  String get badgeText {
    switch (this) {
      case MaterialVisualCategory.available:
        return 'Disponible';
      case MaterialVisualCategory.comingSoon:
        return 'Próximamente';
      case MaterialVisualCategory.disabled:
        return 'No disponible';
    }
  }
}

/// Extensión para BuildContext con helpers específicos del módulo de muros
extension WallModuleContext on BuildContext {

  /// Muestra un dialog de función no disponible
  void showMaterialNotAvailable({
    required String materialName,
    required String materialType,
    String? customMessage,
  }) {
    showDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => FeatureDisabledDialog(
        title: '$materialName no disponible',
        message: customMessage ??
            'Esta funcionalidad está en desarrollo y estará disponible próximamente.',
        materialType: materialType,
      ),
    );
  }

  /// Muestra un snackbar de error específico del módulo
  void showWallModuleError(String message) {
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
  void showWallModuleSuccess(String message) {
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

/// Helper class para validaciones específicas del módulo
class WallMaterialValidator {
  WallMaterialValidator._();

  /// Valida que un material sea seguro para usar
  static ValidationResult validateMaterial(WallMaterial material) {
    final errors = <String>[];

    // Validaciones básicas
    if (material.id.isEmpty) {
      errors.add('ID de material requerido');
    }

    if (material.name.trim().isEmpty) {
      errors.add('Nombre de material requerido');
    }

    if (material.image.trim().isEmpty) {
      errors.add('Imagen de material requerida');
    }

    if (material.size.trim().isEmpty) {
      errors.add('Tamaño de material requerido');
    }

    // Validaciones de seguridad
    if (material.name.length > 100) {
      errors.add('Nombre de material demasiado largo');
    }

    if (material.details.length > 1000) {
      errors.add('Descripción de material demasiado larga');
    }

    // Validación de ID válido
    if (!RegExp(r'^[1-8]$').hasMatch(material.id)) {
      errors.add('ID de material inválido');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida que un ID de material sea válido y conocido
  static bool isValidMaterialId(String id) {
    const validIds = ['1', '2', '3', '4', '5', '6', '7', '8'];
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