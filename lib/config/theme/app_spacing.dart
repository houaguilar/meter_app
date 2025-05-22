import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Espaciado base (múltiplos de 4)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Espaciado específico para componentes
  static const double buttonPadding = md;
  static const double cardPadding = md;
  static const double screenPadding = lg;
  static const double sectionSpacing = xl;

  // Métodos de utilidad
  static EdgeInsets get paddingAll => const EdgeInsets.all(md);
  static EdgeInsets get paddingScreen => const EdgeInsets.all(screenPadding);
  static EdgeInsets get paddingCard => const EdgeInsets.all(cardPadding);

  static EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}