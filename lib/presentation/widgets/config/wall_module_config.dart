/// Clase de configuración para funcionalidades del módulo
class WallModuleConfig {
  /// Configuración de materiales disponibles
  static const List<String> availableMaterialIds = ['1', '2', '3', '4', 'custom'];

  /// Configuración de materiales próximamente
  static const List<String> comingSoonMaterialIds = ['5', '6', '7', '8'];

  /// Configuración de responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 840.0;
  static const double desktopBreakpoint = 1200.0;

  /// Configuración de animaciones
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 600);

  /// Verifica si un material está disponible
  static bool isMaterialAvailable(String materialId) {
    return availableMaterialIds.contains(materialId);
  }

  /// Obtiene el mensaje para materiales no disponibles
  static String getUnavailableMessage(String materialId) {
    if (materialId == '5') {
      return 'El cálculo para Tabicón está en desarrollo y estará disponible próximamente.';
    } else if (comingSoonMaterialIds.contains(materialId)) {
      return 'Los cálculos para Bloquetas están en desarrollo activo.';
    }
    return 'Esta funcionalidad estará disponible próximamente.';
  }
}