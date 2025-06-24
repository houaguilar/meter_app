// lib/config/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Constructor privado para evitar instanciación
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE MARCA PRINCIPAL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Color principal de la marca MetraShop - Azul marino oscuro
  static const Color primary = Color(0xFF0A1E27);

  /// Color secundario de la marca - Azul brillante
  static const Color secondary = Color(0xFF0D34FF);

  /// Color de acento - Amarillo MetraShop
  static const Color accent = Color(0xFFF5C845);

  /// Blanco puro
  static const Color white = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES SEMÁNTICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verde para estados de éxito
  static const Color success = Color(0xFF10B981);

  /// Amarillo/naranja para advertencias
  static const Color warning = Color(0xFFF59E0B);

  /// Rojo para errores
  static const Color error = Color(0xFFDA1E28);

  /// Azul para información
  static const Color info = Color(0xFF3B82F6);

  // ═══════════════════════════════════════════════════════════════════════════
  // SISTEMA DE GRISES (Neutral Palette)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gris más claro - para fondos sutiles
  static const Color neutral50 = Color(0xFFF9FAFB);

  /// Gris muy claro - para superficies alternativas
  static const Color neutral100 = Color(0xFFF3F4F6);

  /// Gris claro - para bordes y divisores
  static const Color neutral200 = Color(0xFFE5E7EB);

  /// Gris medio claro - para bordes activos
  static const Color neutral300 = Color(0xFFD1D5DB);

  /// Gris medio - para texto placeholder
  static const Color neutral400 = Color(0xFF9CA3AF);

  /// Gris medio oscuro - para texto secundario
  static const Color neutral500 = Color(0xFF6B7280);

  /// Gris oscuro - para texto terciario
  static const Color neutral600 = Color(0xFF4B5563);

  /// Gris muy oscuro - para texto en contraste
  static const Color neutral700 = Color(0xFF374151);

  /// Gris casi negro - para textos destacados
  static const Color neutral800 = Color(0xFF1F2937);

  /// Gris negro - para texto principal alternativo
  static const Color neutral900 = Color(0xFF111827);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE SUPERFICIE Y FONDO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Color de fondo principal de la aplicación
  static const Color background = Color(0xFFF3F6FB);

  /// Color de superficie principal (cards, modals, etc.)
  static const Color surface = white;

  /// Variante de superficie para elementos diferenciados
  static const Color surfaceVariant = Color(0xFFF2F4F8);

  /// Superficie con elevación (dialogs, bottom sheets)
  static const Color surfaceElevated = white;

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE TEXTO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Texto principal - máximo contraste
  static const Color textPrimary = primary;

  /// Texto secundario - para información complementaria
  static const Color textSecondary = Color(0xFF697077);

  /// Texto terciario - para información menos importante
  static const Color textTertiary = neutral400;

  /// Texto sobre fondos de color primario
  static const Color textOnPrimary = white;

  /// Texto sobre fondos de color secundario
  static const Color textOnSecondary = white;

  /// Texto sobre fondos de superficie
  static const Color textOnSurface = primary;

  /// Texto sobre fondos de error
  static const Color textOnError = white;

  /// Texto informativo específico (azul oscuro)
  static const Color textInfo = Color(0xFF002A8D);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE BORDES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Borde por defecto
  static const Color border = neutral200;

  /// Borde cuando el elemento está enfocado
  static const Color borderFocused = Color(0xFFC1C7CD);

  /// Borde para estados de error
  static const Color borderError = error;

  /// Borde para estados de éxito
  static const Color borderSuccess = success;

  /// Borde sutil para separadores
  static const Color borderSubtle = Color(0xFFD0D3D7);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE ESTADO INTERACTIVO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Estado hover para elementos interactivos
  static const Color stateHover = Color(0xFFF0F9FF);

  /// Estado pressed para botones
  static const Color statePressed = Color(0xFFE0F2FE);

  /// Estado disabled para elementos deshabilitados
  static const Color stateDisabled = neutral300;

  /// Overlay para modals y dialogs
  static const Color overlay = Color(0x80000000); // Negro con 50% opacidad

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES ESPECÍFICOS DE COMPONENTES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fondo de cards de bienvenida
  static const Color cardBackground = surfaceVariant;

  /// Fondo de información (info boxes)
  static const Color infoBackground = Color(0xFFEBF4FF);

  /// Color de indicadores de tabs
  static const Color tabIndicator = warning;

  /// Color de switch activo
  static const Color switchActive = secondary;

  /// Borde inferior decorativo
  static const Color bottomBorderAccent = Color(0xFF617294);

  // Colores Metrados
  static const Color cement = Color(0xFF9E9E9E);
  static const Color sand = Color(0xFFFFB74D);
  static const Color fineSand = Color(0xFFFFCC80);
  static const Color stone = Color(0xFF757575);
  static const Color water = Color(0xFF2196F3);
  static const Color brick = Color(0xFFD84315);
  static const Color wire = Color(0xFF424242);
  static const Color nails = Color(0xFF616161);
  static const Color wood = Color(0xFF6D4C41);
  static const Color floor = Color(0xFF8D6E63);
  static const Color plaster = Color(0xFFBDBDBD);
  static const Color slab = Color(0xFF78909C);
  static const Color column = Color(0xFF546E7A);
  static const Color beam = Color(0xFF607D8B);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES LEGACY (MANTENER TEMPORALMENTE PARA COMPATIBILIDAD)
  // ═══════════════════════════════════════════════════════════════════════════

  @Deprecated('Usar AppColors.primary en su lugar')
  static const Color primaryMetraShop = primary;

  @Deprecated('Usar AppColors.secondary en su lugar')
  static const Color blueMetraShop = secondary;

  @Deprecated('Usar AppColors.accent en su lugar')
  static const Color yellowMetraShop = accent;

  @Deprecated('Usar AppColors.background en su lugar')
  static const Color backgroundLight = background;

  @Deprecated('Usar AppColors.error en su lugar')
  static const Color errorGeneralColor = error;

  @Deprecated('Usar AppColors.textSecondary en su lugar')
  static const Color greyTextColor = textSecondary;

  @Deprecated('Usar AppColors.surfaceVariant en su lugar')
  static const Color greyFieldColor = surfaceVariant;

  @Deprecated('Usar AppColors.switchActive en su lugar')
  static const Color switchBlueColor = switchActive;

  @Deprecated('Usar AppColors.textPrimary en su lugar')
  static const Color greyTextSwitchColor = textPrimary;

  @Deprecated('Usar AppColors.textPrimary en su lugar')
  static const Color leadTextColor = textPrimary;

  @Deprecated('Usar AppColors.secondary.withOpacity(0.6) en su lugar')
  static const Color blueLightIndicator = Color(0xFF9AAAFF);

  @Deprecated('Usar AppColors.cardBackground en su lugar')
  static const Color cardWelcomeColor = cardBackground;

  @Deprecated('Usar AppColors.bottomBorderAccent en su lugar')
  static const Color bottomBorderSideWelcomeColor = bottomBorderAccent;

  @Deprecated('Usar AppColors.borderSubtle en su lugar')
  static const Color bottomBorderSideColor = borderSubtle;

  @Deprecated('Usar AppColors.infoBackground en su lugar')
  static const Color backgroundInfoColor = infoBackground;

  @Deprecated('Usar AppColors.textInfo en su lugar')
  static const Color textInfoColor = textInfo;

  @Deprecated('Usar AppColors.tabIndicator en su lugar')
  static const Color indicatorTabBarColor = tabIndicator;

  @Deprecated('Usar AppColors.borderFocused en su lugar')
  static const Color borderTextFormFieldColor = borderFocused;

  // Colores que se eliminan completamente (revisar si se usan)
  @Deprecated('Color legacy - revisar uso y reemplazar por colores semánticos')
  static const Color teal = Color(0xFF317088);

  @Deprecated('Usar AppColors.warning en su lugar')
  static const Color orange = warning;

  @Deprecated('Usar AppColors.neutral300 en su lugar')
  static const Color silver = neutral300;

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS DE UTILIDAD
  // ═══════════════════════════════════════════════════════════════════════════

  /// Obtiene una variación del color primario con opacidad
  static Color primaryWithOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'La opacidad debe estar entre 0.0 y 1.0');
    return primary.withOpacity(opacity);
  }

  /// Obtiene una variación del color secundario con opacidad
  static Color secondaryWithOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'La opacidad debe estar entre 0.0 y 1.0');
    return secondary.withOpacity(opacity);
  }

  /// Obtiene una variación del color de acento con opacidad
  static Color accentWithOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'La opacidad debe estar entre 0.0 y 1.0');
    return accent.withOpacity(opacity);
  }

  /// Obtiene el color de texto apropiado para un fondo dado
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calcula la luminancia del fondo para determinar si usar texto claro u oscuro
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : white;
  }

  /// Valida que un color tenga suficiente contraste para accesibilidad
  static bool hasGoodContrast(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= 4.5; // WCAG AA estándar
  }

  /// Calcula el ratio de contraste entre dos colores
  static double _calculateContrastRatio(Color color1, Color color2) {
    final lum1 = color1.computeLuminance();
    final lum2 = color2.computeLuminance();
    final brightest = lum1 > lum2 ? lum1 : lum2;
    final darkest = lum1 > lum2 ? lum2 : lum1;
    return (brightest + 0.05) / (darkest + 0.05);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PALETAS PREDEFINIDAS PARA CASOS ESPECÍFICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Paleta de colores para gráficos y charts
  static const List<Color> chartColors = [
    secondary,
    accent,
    success,
    warning,
    error,
    info,
    neutral600,
    primary,
  ];

  /// Paleta de colores para badges y tags
  static const Map<String, Color> badgeColors = {
    'primary': secondary,
    'success': success,
    'warning': warning,
    'error': error,
    'info': info,
    'neutral': neutral500,
  };

  /// Paleta de colores para estados de progreso
  static const Map<String, Color> progressColors = {
    'pending': neutral400,
    'inProgress': info,
    'completed': success,
    'failed': error,
    'warning': warning,
  };
}