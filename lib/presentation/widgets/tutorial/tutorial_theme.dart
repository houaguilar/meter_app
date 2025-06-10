// lib/presentation/widgets/tutorial/tutorial_theme.dart
import 'package:flutter/material.dart';
import '../../../config/theme/theme.dart';

/// Tema personalizado para los tutoriales
class TutorialTheme {
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const Color accentColor = AppColors.accent;
  static const Color backgroundColor = Colors.black87;
  static const Color surfaceColor = AppColors.white;
  static const Color onSurfaceColor = AppColors.textPrimary;

  // Gradientes
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1E27), // primary
      Color(0xFF0D34FF), // secondary
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white10,
      Colors.white,
    ],
  );

  // Estilos de texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: surfaceColor,
    height: 1.2,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
    height: 1.5,
  );

  static const TextStyle stepIndicatorStyle = TextStyle(
    color: surfaceColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // Sombras
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      spreadRadius: 5,
    ),
  ];

  static List<BoxShadow> get accentShadow => [
    BoxShadow(
      color: accentColor.withOpacity(0.4),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];
}