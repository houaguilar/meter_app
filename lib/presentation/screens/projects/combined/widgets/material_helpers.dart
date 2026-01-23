import 'package:flutter/material.dart';
import '../../../../../config/theme/theme.dart';

/// Helpers para obtener iconos y colores de materiales
class MaterialHelpers {
  MaterialHelpers._(); // Private constructor para evitar instanciación

  /// Obtiene el icono apropiado para un material según su nombre
  static IconData getMaterialIcon(String materialName) {
    final name = materialName.toLowerCase();

    if (name.contains('cemento')) return Icons.circle;
    if (name.contains('arena')) return Icons.grain;
    if (name.contains('piedra')) return Icons.scatter_plot;
    if (name.contains('agua')) return Icons.water_drop;
    if (name.contains('ladrillo')) return Icons.rectangle;
    if (name.contains('acero')) return Icons.linear_scale;

    return Icons.category;
  }

  /// Obtiene el color apropiado para un material según su nombre
  static Color getMaterialColor(String materialName) {
    final name = materialName.toLowerCase();

    if (name.contains('cemento')) return const Color(0xFF795548);
    if (name.contains('arena')) return const Color(0xFFFFB74D);
    if (name.contains('piedra')) return const Color(0xFF607D8B);
    if (name.contains('agua')) return const Color(0xFF2196F3);
    if (name.contains('ladrillo')) return const Color(0xFFD32F2F);
    if (name.contains('acero')) return const Color(0xFF424242);

    return AppColors.secondary;
  }
}
