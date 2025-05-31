import 'package:flutter/material.dart';

/// Extensión de colores para la aplicación con colores adicionales
class AppColorsExtended {
// Colores base existentes
  static const Color primary = Color(0xFF003366);
  static const Color secondary = Color(0xFF0066CC);
  static const Color accent = Color(0xFFF5C845);

// Colores de superficie mejorados
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFF1F3F4);

// Colores de borde mejorados
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);

// Colores de texto mejorados
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

// Colores de estado mejorados
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

// Colores neutrales
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

// Gradientes para botones y cards
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF003366), Color(0xFF0066CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF5C845), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// lib/config/theme/app_text_styles.dart
/// Estilos de texto mejorados para la aplicación
class AppTextStyles {
// Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColorsExtended.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColorsExtended.textPrimary,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColorsExtended.textPrimary,
    height: 1.4,
  );

// Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColorsExtended.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColorsExtended.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColorsExtended.textTertiary,
    height: 1.3,
  );

// Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColorsExtended.textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColorsExtended.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColorsExtended.textTertiary,
    letterSpacing: 0.5,
  );

// Button text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
  );
}

// lib/config/theme/app_dimensions.dart
/// Dimensiones y espaciado consistente para la aplicación
class AppDimensions {
// Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacing2xl = 24.0;
  static const double spacing3xl = 32.0;
  static const double spacing4xl = 40.0;

// Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 20.0;
  static const double radius3xl = 24.0;
  static const double radiusRound = 9999.0;

// Elevation
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 12.0;
  static const double elevation2xl = 16.0;

// Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double icon2xl = 40.0;
  static const double icon3xl = 48.0;

// Component sizes
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;

  static const double textFieldHeight = 56.0;
  static const double cardMinHeight = 80.0;
  static const double listItemHeight = 64.0;

// Layout
  static const double maxContentWidth = 1200.0;
  static const double sidebarWidth = 280.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;

// Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}

// lib/config/theme/app_shadows.dart
/// Sombras predefinidas para la aplicación
class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> extraLarge = [
    BoxShadow(
      color: Color(0x26000000), // 15% opacity
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

// Sombras específicas para estados
  static const List<BoxShadow> focused = [
    BoxShadow(
      color: Color(0x330066CC), // Primary color with 20% opacity
      blurRadius: 8,
      offset: Offset(0, 0),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> pressed = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
}

// lib/presentation/widgets/shared/responsive_helper.dart
/// Helper para diseño responsivo
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return AppDimensions.spacingLg;
    if (isTablet(context)) return AppDimensions.spacingXl;
    return AppDimensions.spacing2xl;
  }

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize * 0.9;
    if (isTablet(context)) return baseFontSize;
    return baseFontSize * 1.1;
  }
}

// lib/presentation/widgets/shared/loading_states.dart
/// Estados de carga modernos y consistentes
class ModernLoadingStates {

  /// Shimmer para cards
  static Widget shimmerCard({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height ?? 120,
      decoration: BoxDecoration(
        color: AppColorsExtended.neutral200,
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusLg),
      ),
    );
  }

  /// Loading circular con tema
  static Widget circularProgress({
    Color? color,
    double? size,
  }) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColorsExtended.primary,
        ),
      ),
    );
  }

  /// Loading skeleton para texto
  static Widget textSkeleton({
    double? width,
    double height = 16,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColorsExtended.neutral200,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }

  /// Loading para botones
  static Widget buttonLoading({
    Color? color,
    double size = 20,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColorsExtended.surface,
        ),
      ),
    );
  }
}

// lib/presentation/widgets/shared/feedback_widgets.dart
/// Widgets de feedback mejorados
class FeedbackWidgets {

  /// Toast/Snackbar moderno
  static void showModernSnackbar(
      BuildContext context, {
        required String message,
        SnackbarType type = SnackbarType.info,
        Duration? duration,
        VoidCallback? action,
        String? actionLabel,
      }) {
    final color = _getSnackbarColor(type);
    final icon = _getSnackbarIcon(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColorsExtended.surface, size: 20),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColorsExtended.surface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        margin: const EdgeInsets.all(AppDimensions.spacingLg),
        duration: duration ?? const Duration(seconds: 4),
        action: action != null && actionLabel != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: AppColorsExtended.surface,
          onPressed: action,
        )
            : null,
      ),
    );
  }

  /// Dialog de confirmación moderno
  static Future<bool?> showModernConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirmar',
        String cancelText = 'Cancelar',
        IconData? icon,
        Color? iconColor,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.spacing2xl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColorsExtended.warning).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColorsExtended.warning,
                  size: AppDimensions.icon2xl,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
            ],
            Text(
              title,
              style: AppTextStyles.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing2xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingLg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      side: BorderSide(color: AppColorsExtended.border),
                    ),
                    child: Text(
                      cancelText,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColorsExtended.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingLg),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor ?? AppColorsExtended.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingLg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmText,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColorsExtended.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _getSnackbarColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColorsExtended.success;
      case SnackbarType.error:
        return AppColorsExtended.error;
      case SnackbarType.warning:
        return AppColorsExtended.warning;
      case SnackbarType.info:
        return AppColorsExtended.info;
    }
  }

  static IconData _getSnackbarIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
    }
  }
}

enum SnackbarType { success, error, warning, info }

// lib/presentation/widgets/shared/empty_states.dart
/// Estados vacíos modernos y consistentes
class ModernEmptyStates {

  /// Estado vacío genérico
  static Widget generic({
    required String title,
    required String message,
    IconData? icon,
    Widget? action,
    String? imagePath,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing2xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              )
            else
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing2xl),
                decoration: BoxDecoration(
                  color: AppColorsExtended.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.inbox,
                  size: AppDimensions.icon3xl,
                  color: AppColorsExtended.neutral400,
                ),
              ),
            const SizedBox(height: AppDimensions.spacing2xl),
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(
                color: AppColorsExtended.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppDimensions.spacing2xl),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Estado vacío para listas
  static Widget emptyList({
    required String title,
    required String message,
    VoidCallback? onRefresh,
    String refreshButtonText = 'Actualizar',
  }) {
    return generic(
      title: title,
      message: message,
      icon: Icons.list_alt,
      action: onRefresh != null
          ? OutlinedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
        label: Text(refreshButtonText),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
            vertical: AppDimensions.spacingLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
      )
          : null,
    );
  }

  /// Estado sin conexión
  static Widget noConnection({
    VoidCallback? onRetry,
    String retryButtonText = 'Reintentar',
  }) {
    return generic(
      title: 'Sin conexión',
      message: 'Verifica tu conexión a internet e inténtalo de nuevo',
      icon: Icons.wifi_off,
      action: onRetry != null
          ? ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(retryButtonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsExtended.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
            vertical: AppDimensions.spacingLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
      )
          : null,
    );
  }
}

// lib/presentation/widgets/shared/error_states.dart
/// Estados de error modernos y consistentes
class ModernErrorStates {

  /// Error genérico
  static Widget generic({
    required String title,
    required String message,
    VoidCallback? onRetry,
    String retryButtonText = 'Reintentar',
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing2xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing2xl),
              decoration: BoxDecoration(
                color: AppColorsExtended.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: AppDimensions.icon3xl,
                color: AppColorsExtended.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing2xl),
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(
                color: AppColorsExtended.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacing2xl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsExtended.error,
                  foregroundColor: AppColorsExtended.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXl,
                    vertical: AppDimensions.spacingLg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// lib/config/theme/theme_config.dart
/// Configuración principal del tema
class ThemeConfig {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsExtended.primary,
        brightness: Brightness.light,
        surface: AppColorsExtended.surface,
        onSurface: AppColorsExtended.textPrimary,
      ),
      scaffoldBackgroundColor: AppColorsExtended.surfaceVariant,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsExtended.primary,
        foregroundColor: AppColorsExtended.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headline3,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsExtended.primary,
          foregroundColor: AppColorsExtended.surface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
            vertical: AppDimensions.spacingLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsExtended.primary,
          side: BorderSide(color: AppColorsExtended.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
            vertical: AppDimensions.spacingLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsExtended.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColorsExtended.surface,
        elevation: AppDimensions.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsExtended.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: AppColorsExtended.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: AppColorsExtended.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: AppColorsExtended.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: AppColorsExtended.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingLg,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColorsExtended.textTertiary,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headline1,
        displayMedium: AppTextStyles.headline2,
        displaySmall: AppTextStyles.headline3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      dividerTheme: DividerThemeData(
        color: AppColorsExtended.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}