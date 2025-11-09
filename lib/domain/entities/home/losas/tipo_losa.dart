/// Enumeración de tipos de losa soportados
enum TipoLosa {
  /// Losa aligerada con viguetas prefabricadas y bovedillas
  viguetasPrefabricadas,

  /// Losa aligerada tradicional con ladrillos (hueco o casetón)
  tradicional,

  /// Losa maciza de concreto sólido
  maciza;

  /// Obtiene el nombre display del tipo de losa
  String get displayName {
    switch (this) {
      case TipoLosa.viguetasPrefabricadas:
        return 'Losa Aligerada con Viguetas Prefabricadas';
      case TipoLosa.tradicional:
        return 'Losa Aligerada Tradicional';
      case TipoLosa.maciza:
        return 'Losa Maciza';
    }
  }

  /// Obtiene el nombre corto del tipo de losa
  String get shortName {
    switch (this) {
      case TipoLosa.viguetasPrefabricadas:
        return 'Viguetas PRE';
      case TipoLosa.tradicional:
        return 'Tradicional';
      case TipoLosa.maciza:
        return 'Maciza';
    }
  }

  /// Obtiene la ruta para navegación
  String get routePath {
    switch (this) {
      case TipoLosa.viguetasPrefabricadas:
        return 'viguetas';
      case TipoLosa.tradicional:
        return 'tradicional';
      case TipoLosa.maciza:
        return 'maciza';
    }
  }

  /// Determina si el tipo de losa tiene material aligerante
  bool get tieneMaterialAligerante {
    switch (this) {
      case TipoLosa.viguetasPrefabricadas:
      case TipoLosa.tradicional:
        return true;
      case TipoLosa.maciza:
        return false;
    }
  }

  /// Obtiene las alturas válidas para este tipo de losa
  List<String> get alturasValidas {
    switch (this) {
      case TipoLosa.viguetasPrefabricadas:
      case TipoLosa.tradicional:
        return ['17 cm', '20 cm', '25 cm'];
      case TipoLosa.maciza:
        return ['15 cm', '20 cm', '25 cm'];
    }
  }

  /// Parse desde String
  static TipoLosa fromString(String value) {
    switch (value.toLowerCase()) {
      case 'viguetas':
      case 'viguetasprefabricadas':
      case 'viguetas_prefabricadas':
        return TipoLosa.viguetasPrefabricadas;
      case 'tradicional':
        return TipoLosa.tradicional;
      case 'maciza':
        return TipoLosa.maciza;
      default:
        return TipoLosa.tradicional;
    }
  }

  /// Convierte a String para persistencia
  String toStorageString() {
    return name;
  }
}
