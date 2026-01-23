/// Enumeración de tipos de ladrillos disponibles en el sistema
///
/// Esta enumeración centraliza toda la información de los tipos de ladrillos:
/// - IDs del repositorio
/// - Nombres para el provider
/// - Nombres de display
/// - Dimensiones físicas
enum TipoLadrillo {
  pandereta1(
    repositoryId: '1',
    providerKey: 'Pandereta',
    displayName: 'Pandereta',
    resultName: 'Ladrillos Pandereta',
    largo: 23.0,
    ancho: 11.0,
    alto: 9.0,
  ),
  kingkong1(
    repositoryId: '3',
    providerKey: 'Kingkong',
    displayName: 'King Kong 18H',
    resultName: 'Ladrillos King Kong',
    largo: 23.0,
    ancho: 12.5,
    alto: 9.0,
  ),
  tabique(
    repositoryId: '5',
    providerKey: 'Tabique',
    displayName: 'Tabique',
    resultName: 'Ladrillos Tabique',
    largo: 25.0,
    ancho: 8.0,
    alto: 15.0,
  ),
  artesanal(
    repositoryId: 'artesanal',
    providerKey: 'Artesanal',
    displayName: 'Ladrillo Artesanal',
    resultName: 'Ladrillos Artesanal',
    largo: 22.0,
    ancho: 12.5,
    alto: 7.5,
  ),
  custom(
    repositoryId: 'custom',
    providerKey: 'Custom',
    displayName: 'Ladrillo Personalizado',
    resultName: 'Ladrillo Personalizado',
    largo: 0.0,  // Las dimensiones se obtienen dinámicamente
    ancho: 0.0,
    alto: 0.0,
  );

  /// ID usado en el repositorio de materiales
  final String repositoryId;

  /// Key usada en el provider (tipoLadrilloNotifierProvider)
  final String providerKey;

  /// Nombre para mostrar en la UI
  final String displayName;

  /// Nombre para mostrar en la pantalla de resultados
  final String resultName;

  /// Largo del ladrillo en centímetros
  final double largo;

  /// Ancho del ladrillo en centímetros
  final double ancho;

  /// Alto del ladrillo en centímetros
  final double alto;

  const TipoLadrillo({
    required this.repositoryId,
    required this.providerKey,
    required this.displayName,
    required this.resultName,
    required this.largo,
    required this.ancho,
    required this.alto,
  });

  /// Obtiene el tipo de ladrillo desde el ID del repositorio
  static TipoLadrillo? fromRepositoryId(String id) {
    try {
      return TipoLadrillo.values.firstWhere(
        (tipo) => tipo.repositoryId == id,
      );
    } catch (_) {
      return null;
    }
  }

  /// Obtiene el tipo de ladrillo desde el provider key
  static TipoLadrillo? fromProviderKey(String key) {
    try {
      return TipoLadrillo.values.firstWhere(
        (tipo) => tipo.providerKey == key,
      );
    } catch (_) {
      return null;
    }
  }

  /// Normaliza un nombre de ladrillo a su tipo correspondiente
  /// Útil para convertir nombres variados del usuario
  static TipoLadrillo? fromNombre(String nombre) {
    final nombreLower = nombre.toLowerCase();

    // Detectar custom/personalizado
    if (nombreLower.contains('custom') || nombreLower.contains('personalizado')) {
      return TipoLadrillo.custom;
    }

    // Detectar tabicón
    if (nombreLower.contains('tabi')) {
      return TipoLadrillo.tabique;
    }

    // Detectar king kong
    if (nombreLower.contains('king') || nombreLower.contains('kong')) {
      // Intentar detectar si es kingkong1 o kingkong2 por el ID
      if (nombreLower.contains('18h')) {
        return TipoLadrillo.kingkong1; // Por defecto el primero
      }
      return TipoLadrillo.kingkong1;
    }

    // Detectar pandereta
    if (nombreLower.contains('pandereta')) {
      return TipoLadrillo.pandereta1; // Por defecto el primero
    }

    // Detectar artesanal/común
    if (nombreLower.contains('artesanal') ||
        nombreLower.contains('común') ||
        nombreLower.contains('comun')) {
      return TipoLadrillo.artesanal;
    }

    return null;
  }

  /// Retorna las dimensiones como un Map para compatibilidad con código existente
  Map<String, double> get dimensiones => {
    'largo': largo,
    'ancho': ancho,
    'alto': alto,
  };

  /// Verifica si este tipo requiere dimensiones dinámicas (Custom)
  bool get esDinamico => this == TipoLadrillo.custom;

  /// Formato de tamaño para display (ej: "23×11×9 cm")
  String get sizeDisplay => '${largo.toStringAsFixed(0)}×${ancho.toStringAsFixed(0)}×${alto.toStringAsFixed(0)} cm';
}
