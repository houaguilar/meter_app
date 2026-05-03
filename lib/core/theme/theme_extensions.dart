import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

extension ThemeExtensions on BuildContext {
  // Acceso rápido al tema
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // Acceso directo a colores personalizados
  AppColorsExtension get colors => AppColorsExtension();

  // Acceso directo a tipografía
  AppTypographyExtension get typography => AppTypographyExtension();

  // Acceso directo a espaciado
  AppSpacingExtension get spacing => AppSpacingExtension();

  // Utilidades de responsive design
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  bool get isLargeScreen => screenWidth >= 1200;
}

class AppColorsExtension {
  Color get primary => AppColors.primaryMetraShop;
  Color get blue => AppColors.blueMetraShop;
  Color get yellow => AppColors.yellowMetraShop;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get error => AppColors.error;
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get surface => AppColors.surface;
  Color get background => AppColors.background;
}

class AppTypographyExtension {
  TextStyle get h1 => AppTypography.h1;
  TextStyle get h2 => AppTypography.h2;
  TextStyle get h3 => AppTypography.h3;
  TextStyle get h4 => AppTypography.h4;
  TextStyle get h5 => AppTypography.h5;
  TextStyle get h6 => AppTypography.h6;
  TextStyle get bodyLarge => AppTypography.bodyLarge;
  TextStyle get bodyMedium => AppTypography.bodyMedium;
  TextStyle get bodySmall => AppTypography.bodySmall;
  TextStyle get buttonLarge => AppTypography.buttonLarge;
  TextStyle get buttonMedium => AppTypography.buttonMedium;
}

class AppSpacingExtension {
  double get xs => AppSpacing.xs;
  double get sm => AppSpacing.sm;
  double get md => AppSpacing.md;
  double get lg => AppSpacing.lg;
  double get xl => AppSpacing.xl;
  EdgeInsets get paddingAll => AppSpacing.paddingAll;
  EdgeInsets get paddingScreen => AppSpacing.paddingScreen;
}