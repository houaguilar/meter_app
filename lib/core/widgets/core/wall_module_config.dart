/// Configuración del módulo de muros: disponibilidad de materiales
class WallModuleConfig {
  WallModuleConfig._();

  /// IDs de materiales disponibles para cálculo
  static const Set<String> _availableMaterialIds = {'1', '2', '3', '4'};

  /// Mensajes para materiales no disponibles
  static const Map<String, String> _unavailableMessages = {
    '5': 'El cálculo con Tabicón estará disponible próximamente.',
    '6': 'El cálculo con Bloqueta de 9cm estará disponible próximamente.',
    '7': 'El cálculo con Bloqueta de 14cm estará disponible próximamente.',
    '8': 'El cálculo con Bloqueta de 19cm estará disponible próximamente.',
  };

  /// Retorna true si el material está habilitado para cálculos
  static bool isMaterialAvailable(String id) {
    return _availableMaterialIds.contains(id);
  }

  /// Retorna el mensaje de no disponibilidad para un material
  static String getUnavailableMessage(String id) {
    return _unavailableMessages[id] ??
        'Esta funcionalidad estará disponible próximamente.';
  }
}
