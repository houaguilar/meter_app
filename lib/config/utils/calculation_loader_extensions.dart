import 'package:flutter/material.dart';
import 'package:meter_app/presentation/assets/icons.dart';

import '../theme/theme.dart';
import 'calculator_loader.dart';

/// Extensiones para simplificar el uso del loader desde cualquier BuildContext
extension CalculationLoaderExtensionss on BuildContext {
  /// Muestra un loader de cálculo
  void showCalculationLoader({
    String message = 'Calculando...',
    String? description,
    bool showCancelButton = false,
    VoidCallback? onCancel,
  }) {
    CalculationLoader.show(
      this,
      svgAssetPath: AppIcons.archiveProjectIcon,
      message: message,
      description: description,
      color: AppColors.blueMetraShop,
      showCancelButton: showCancelButton,
      onCancel: onCancel,
    );
  }

  /// Muestra un loader de carga de datos
  void showDataLoader({
    String message = 'Cargando datos...',
    String? description,
    bool showCancelButton = false,
    VoidCallback? onCancel,
  }) {
    CalculationLoader.show(
      this,
      svgAssetPath: AppIcons.infoIcon,
      message: message,
      description: description,
      color: AppColors.yellowMetraShop,
      showCancelButton: showCancelButton,
      onCancel: onCancel,
    );
  }

  /// Muestra un loader de guardado
  void showSavingLoader({
    String message = 'Guardando...',
    String? description,
    bool showCancelButton = false,
    VoidCallback? onCancel,
  }) {
    CalculationLoader.show(
      this,
      svgAssetPath: AppIcons.checkmarkCircleIcon,
      message: message,
      description: description,
      color: AppColors.primaryMetraShop,
      showCancelButton: showCancelButton,
      onCancel: onCancel,
    );
  }

  /// Oculta el loader
  void hideLoader() {
    CalculationLoader.hide();
  }

  /// Muestra un loader por un tiempo determinado
  Future<void> showLoaderFor(
      Duration duration, {
        String message = 'Procesando...',
        String? description,
        required String svgAssetPath,
        Color color = AppColors.blueMetraShop,
      }) async {
    await CalculationLoader.showFor(
      this,
      duration,
      svgAssetPath: svgAssetPath,
      message: message,
      description: description,
      color: color,
    );
  }
}