import 'package:flutter/material.dart';

/// Tipos de grid para los módulos
enum GridType {
  standard,
  compact,
  wide,
}

/// Tamaños de espaciado
enum SpacingSize {
  small,
  medium,
  large,
}

/// Tamaños de padding
enum PaddingSize {
  small,
  medium,
  large,
}

/// Tamaños de header
enum HeaderSize {
  h1,
  h2,
  h3,
}

/// Configuración de un módulo de cálculo
class ModuleConfig {
  final GridType gridType;
  final SpacingSize spacingSize;
  final PaddingSize paddingSize;
  final Duration animationDuration;
  final int maxAnimatedItems;

  const ModuleConfig({
    this.gridType = GridType.standard,
    this.spacingSize = SpacingSize.medium,
    this.paddingSize = PaddingSize.medium,
    this.animationDuration = const Duration(milliseconds: 300),
    this.maxAnimatedItems = 10,
  });
}

/// Configuración centralizada para los módulos de cálculo
class GenericModuleConfig {
  GenericModuleConfig._();

  // ── Animaciones ──────────────────────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ── Configuraciones por módulo ────────────────────────────────────────────
  static const ModuleConfig wallModuleConfig = ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 8,
  );

  static const ModuleConfig slabModuleConfig = ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 10,
  );

  static const ModuleConfig floorModuleConfig = ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 8,
  );

  static const ModuleConfig coatingModuleConfig = ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 8,
  );

  static const ModuleConfig steelModuleConfig = ModuleConfig(
    gridType: GridType.compact,
    spacingSize: SpacingSize.small,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 6,
  );

  static const ModuleConfig structuralModuleConfig = ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 8,
  );

  // ── Grid responsivo ───────────────────────────────────────────────────────
  static int getCrossAxisCount(
    double screenWidth, {
    GridType gridType = GridType.standard,
  }) {
    switch (gridType) {
      case GridType.compact:
        if (screenWidth >= 900) return 4;
        if (screenWidth >= 600) return 3;
        return 2;
      case GridType.wide:
        if (screenWidth >= 900) return 2;
        return 1;
      case GridType.standard:
        if (screenWidth >= 900) return 3;
        if (screenWidth >= 600) return 2;
        return 2;
    }
  }

  static double getChildAspectRatio(
    double screenWidth, {
    GridType gridType = GridType.standard,
  }) {
    switch (gridType) {
      case GridType.compact:
        return 0.85;
      case GridType.wide:
        return 2.0;
      case GridType.standard:
        if (screenWidth >= 600) return 0.9;
        return 0.85;
    }
  }

  static double getGridSpacing(
    double screenWidth, {
    SpacingSize size = SpacingSize.medium,
  }) {
    switch (size) {
      case SpacingSize.small:
        return screenWidth >= 600 ? 10.0 : 8.0;
      case SpacingSize.medium:
        return screenWidth >= 600 ? 16.0 : 12.0;
      case SpacingSize.large:
        return screenWidth >= 600 ? 24.0 : 16.0;
    }
  }

  static double getResponsivePadding(
    double screenWidth, {
    PaddingSize size = PaddingSize.medium,
  }) {
    switch (size) {
      case PaddingSize.small:
        return screenWidth >= 600 ? 12.0 : 8.0;
      case PaddingSize.medium:
        return screenWidth >= 600 ? 20.0 : 16.0;
      case PaddingSize.large:
        return screenWidth >= 600 ? 32.0 : 24.0;
    }
  }

  // ── Tipografía responsiva ─────────────────────────────────────────────────
  static double getHeaderFontSize(
    double screenWidth, {
    HeaderSize size = HeaderSize.h2,
  }) {
    switch (size) {
      case HeaderSize.h1:
        return screenWidth >= 600 ? 32.0 : 28.0;
      case HeaderSize.h2:
        return screenWidth >= 600 ? 26.0 : 22.0;
      case HeaderSize.h3:
        return screenWidth >= 600 ? 20.0 : 18.0;
    }
  }

  static double getSubtitleFontSize(double screenWidth) {
    return screenWidth >= 600 ? 16.0 : 14.0;
  }
}
