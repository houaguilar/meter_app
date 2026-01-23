/// Configuración unificada para todos los módulos de la aplicación
///
/// Centraliza breakpoints, animaciones, espaciado y configuraciones
/// responsivas que pueden ser reutilizadas en cualquier módulo.
class GenericModuleConfig {
  /// Private constructor para evitar instanciación
  GenericModuleConfig._();

  // ========== BREAKPOINTS RESPONSIVOS ==========

  /// Breakpoint para dispositivos móviles pequeños
  static const double mobileBreakpoint = 600.0;

  /// Breakpoint para tablets y móviles grandes
  static const double tabletBreakpoint = 840.0;

  /// Breakpoint para desktop
  static const double desktopBreakpoint = 1200.0;

  /// Breakpoint para pantallas muy grandes
  static const double largeDesktopBreakpoint = 1600.0;

  // ========== DURACIONES DE ANIMACIÓN ==========

  /// Animación rápida para micro-interacciones
  static const Duration fastAnimation = Duration(milliseconds: 100);

  /// Animación corta para feedback inmediato
  static const Duration shortAnimation = Duration(milliseconds: 150);

  /// Animación media para transiciones
  static const Duration mediumAnimation = Duration(milliseconds: 300);

  /// Animación larga para cambios de estado
  static const Duration longAnimation = Duration(milliseconds: 600);

  /// Animación muy larga para transformaciones complejas
  static const Duration extraLongAnimation = Duration(milliseconds: 900);

  // ========== CONFIGURACIÓN DE GRID ==========

  /// Obtiene el número de columnas para un grid basado en el ancho de pantalla
  static int getCrossAxisCount(double screenWidth, {GridType gridType = GridType.standard}) {
    switch (gridType) {
      case GridType.compact:
        return _getCompactCrossAxisCount(screenWidth);
      case GridType.standard:
        return _getStandardCrossAxisCount(screenWidth);
      case GridType.expanded:
        return _getExpandedCrossAxisCount(screenWidth);
      case GridType.dense:
        return _getDenseCrossAxisCount(screenWidth);
    }
  }

  static int _getCompactCrossAxisCount(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 1;
    if (screenWidth < tabletBreakpoint) return 2;
    if (screenWidth < desktopBreakpoint) return 3;
    return 4;
  }

  static int _getStandardCrossAxisCount(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 2;
    if (screenWidth < tabletBreakpoint) return 3;
    if (screenWidth < desktopBreakpoint) return 4;
    if (screenWidth < largeDesktopBreakpoint) return 5;
    return 6;
  }

  static int _getExpandedCrossAxisCount(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 2;
    if (screenWidth < tabletBreakpoint) return 4;
    if (screenWidth < desktopBreakpoint) return 5;
    if (screenWidth < largeDesktopBreakpoint) return 6;
    return 8;
  }

  static int _getDenseCrossAxisCount(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 3;
    if (screenWidth < tabletBreakpoint) return 4;
    if (screenWidth < desktopBreakpoint) return 6;
    if (screenWidth < largeDesktopBreakpoint) return 8;
    return 10;
  }

  /// Obtiene el aspect ratio para items del grid
  static double getChildAspectRatio(double screenWidth, {GridType gridType = GridType.standard}) {
    switch (gridType) {
      case GridType.compact:
        return screenWidth < mobileBreakpoint ? 1.2 : 1.0;
      case GridType.standard:
        return screenWidth < mobileBreakpoint ? 0.8 : 0.7;
      case GridType.expanded:
        return screenWidth < mobileBreakpoint ? 0.9 : 0.8;
      case GridType.dense:
        return screenWidth < mobileBreakpoint ? 0.6 : 0.5;
    }
  }

  /// Obtiene el spacing entre elementos del grid
  static double getGridSpacing(double screenWidth, {SpacingSize size = SpacingSize.medium}) {
    final baseSpacing = _getBaseSpacing(screenWidth);

    switch (size) {
      case SpacingSize.small:
        return baseSpacing * 0.5;
      case SpacingSize.medium:
        return baseSpacing;
      case SpacingSize.large:
        return baseSpacing * 1.5;
      case SpacingSize.extraLarge:
        return baseSpacing * 2.0;
    }
  }

  static double _getBaseSpacing(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 12.0;
    if (screenWidth < desktopBreakpoint) return 16.0;
    return 20.0;
  }

  // ========== PADDING Y MARGINS ==========

  /// Obtiene el padding responsivo para contenedores
  static double getResponsivePadding(double screenWidth, {PaddingSize size = PaddingSize.medium}) {
    final basePadding = _getBasePadding(screenWidth);

    switch (size) {
      case PaddingSize.small:
        return basePadding * 0.5;
      case PaddingSize.medium:
        return basePadding;
      case PaddingSize.large:
        return basePadding * 1.5;
      case PaddingSize.extraLarge:
        return basePadding * 2.0;
    }
  }

  static double _getBasePadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 16.0;
    if (screenWidth < desktopBreakpoint) return 24.0;
    return 32.0;
  }

  /// Obtiene margins responsivos
  static double getResponsiveMargin(double screenWidth, {MarginSize size = MarginSize.medium}) {
    final baseMargin = _getBaseMargin(screenWidth);

    switch (size) {
      case MarginSize.small:
        return baseMargin * 0.5;
      case MarginSize.medium:
        return baseMargin;
      case MarginSize.large:
        return baseMargin * 1.5;
      case MarginSize.extraLarge:
        return baseMargin * 2.0;
    }
  }

  static double _getBaseMargin(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 8.0;
    if (screenWidth < desktopBreakpoint) return 12.0;
    return 16.0;
  }

  // ========== TIPOGRAFÍA RESPONSIVA ==========

  /// Obtiene el tamaño de fuente para títulos
  static double getHeaderFontSize(double screenWidth, {HeaderSize size = HeaderSize.h2}) {
    final scaleFactor = _getFontScaleFactor(screenWidth);

    switch (size) {
      case HeaderSize.h1:
        return 32.0 * scaleFactor;
      case HeaderSize.h2:
        return 24.0 * scaleFactor;
      case HeaderSize.h3:
        return 20.0 * scaleFactor;
      case HeaderSize.h4:
        return 18.0 * scaleFactor;
      case HeaderSize.h5:
        return 16.0 * scaleFactor;
      case HeaderSize.h6:
        return 14.0 * scaleFactor;
    }
  }

  /// Obtiene el tamaño de fuente para subtítulos
  static double getSubtitleFontSize(double screenWidth) {
    final scaleFactor = _getFontScaleFactor(screenWidth);
    return 16.0 * scaleFactor;
  }

  /// Obtiene el tamaño de fuente para texto del cuerpo
  static double getBodyFontSize(double screenWidth) {
    final scaleFactor = _getFontScaleFactor(screenWidth);
    return 14.0 * scaleFactor;
  }

  /// Obtiene el tamaño de fuente para texto pequeño
  static double getCaptionFontSize(double screenWidth) {
    final scaleFactor = _getFontScaleFactor(screenWidth);
    return 12.0 * scaleFactor;
  }

  static double _getFontScaleFactor(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 0.9;
    if (screenWidth < desktopBreakpoint) return 1.0;
    return 1.1;
  }

  // ========== UTILIDADES DE DISPOSITIVO ==========

  /// Verifica si es un dispositivo móvil
  static bool isMobile(double screenWidth) {
    return screenWidth < mobileBreakpoint;
  }

  /// Verifica si es una tablet
  static bool isTablet(double screenWidth) {
    return screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;
  }

  /// Verifica si es desktop
  static bool isDesktop(double screenWidth) {
    return screenWidth >= desktopBreakpoint;
  }

  /// Verifica si es una pantalla grande
  static bool isLargeScreen(double screenWidth) {
    return screenWidth >= largeDesktopBreakpoint;
  }

  // ========== CONFIGURACIONES ESPECÍFICAS POR MÓDULO ==========

  /// Configuración optimizada para módulo de muros
  static ModuleConfig get wallModuleConfig => ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 20,
  );

  /// Configuración optimizada para módulo de losas
  static ModuleConfig get slabModuleConfig => ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 8,
  );

  /// Configuración optimizada para módulo de pisos
  static ModuleConfig get floorModuleConfig => ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 4,
  );

  /// Configuración optimizada para módulo de tarrajeo
  static ModuleConfig get coatingModuleConfig => ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 6,
  );

  /// Configuración optimizada para módulo de elementos estructurales
  static ModuleConfig get structuralModuleConfig => ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 8,
  );

  static ModuleConfig get steelModuleConfig => ModuleConfig(
    gridType: GridType.standard,
    spacingSize: SpacingSize.medium,
    paddingSize: PaddingSize.medium,
    animationDuration: mediumAnimation,
    maxAnimatedItems: 10,
  );
}

// ========== ENUMS PARA CONFIGURACIÓN ==========

/// Tipos de grid disponibles
enum GridType {
  /// Grid compacto con menos columnas
  compact,
  /// Grid estándar balanceado
  standard,
  /// Grid expandido con más columnas
  expanded,
  /// Grid denso con muchas columnas pequeñas
  dense,
}

/// Tamaños de spacing
enum SpacingSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Tamaños de padding
enum PaddingSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Tamaños de margin
enum MarginSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Tamaños de headers
enum HeaderSize {
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
}

// ========== CLASE DE CONFIGURACIÓN DE MÓDULO ==========

/// Configuración específica para un módulo
class ModuleConfig {
  final GridType gridType;
  final SpacingSize spacingSize;
  final PaddingSize paddingSize;
  final Duration animationDuration;
  final int maxAnimatedItems;

  const ModuleConfig({
    required this.gridType,
    required this.spacingSize,
    required this.paddingSize,
    required this.animationDuration,
    required this.maxAnimatedItems,
  });

  /// Crea una copia con modificaciones
  ModuleConfig copyWith({
    GridType? gridType,
    SpacingSize? spacingSize,
    PaddingSize? paddingSize,
    Duration? animationDuration,
    int? maxAnimatedItems,
  }) {
    return ModuleConfig(
      gridType: gridType ?? this.gridType,
      spacingSize: spacingSize ?? this.spacingSize,
      paddingSize: paddingSize ?? this.paddingSize,
      animationDuration: animationDuration ?? this.animationDuration,
      maxAnimatedItems: maxAnimatedItems ?? this.maxAnimatedItems,
    );
  }
}