// lib/presentation/screens/home/tarrajeo/tarrajeo_screen_unified.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/tarrajeo/coating.dart';
import '../../../providers/home/tarrajeo/coating_providers.dart';
import '../../../providers/tarrajeo/tarrajeo_providers.dart';
import '../../../widgets/cards/generic_item_card.dart';
import '../../../widgets/config/generic_module_config.dart';
import '../../../widgets/dialogs/unified_feature_disabled_dialog.dart';
import '../../../widgets/shared/responsive_grid_builder.dart';
import '../../../widgets/widgets.dart';

/// TarrajeoScreen unificada usando componentes genéricos reutilizables
///
/// Esta implementación demuestra cómo usar los componentes unificados
/// para crear una pantalla consistente y mantenible para revestimientos.
class TarrajeoScreen extends ConsumerStatefulWidget {
  const TarrajeoScreen({super.key});

  static const String routeName = 'tarrajeo';

  @override
  ConsumerState<TarrajeoScreen> createState() => _TarrajeoScreenState();
}

class _TarrajeoScreenState extends ConsumerState<TarrajeoScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  /// Mantiene el estado activo para optimizar rendimiento
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: GenericModuleConfig.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Tarrajeo'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return CoatingGridBuilder<Coating>(
      asyncValue: ref.watch(coatingsProvider),
      itemBuilder: _buildCoatingCard,
      onRetry: () => ref.invalidate(coatingsProvider),
      header: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return ResponsiveHeader(
      title: 'Tipo de revestimiento',
      subtitle: 'Selecciona el tipo de tarrajeo que necesitas para tu proyecto',
      headerSize: HeaderSize.h2,
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
    );
  }

  Widget _buildCoatingCard(Coating coating, int index) {
    return CoatingCard(
      coating: coating,
      onTap: () => _handleCoatingSelection(coating),
      enabled: true,
    );
  }

  /// Maneja la selección de revestimientos con validación y navegación
  void _handleCoatingSelection(Coating coating) {
    try {
      // Validar revestimiento
      if (!_isValidCoating(coating)) {
        _showErrorMessage('Revestimiento no válido');
        return;
      }

      // Actualizar selección
      ref.read(selectedCoatingProvider.notifier).state = coating;

      // Determinar navegación basada en disponibilidad
      if (_isCoatingAvailable(coating.id)) {
        _navigateToAvailableCoating(coating);
      } else {
        _showCoatingNotAvailable(coating);
      }
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega a revestimiento disponible
  void _navigateToAvailableCoating(Coating coating) {
    try {
      final coatingType = _getCoatingType(coating.id);
      ref.read(tipoTarrajeoProvider.notifier).selectTarrajeo(coatingType);

      switch (coating.id) {
        case '1': // Tarrajeo normal
          context.pushNamed('tarrajeo-muro');
          break;
        default:
          context.pushNamed('tarrajeo-muro');
      }
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Muestra dialog para revestimiento no disponible
  void _showCoatingNotAvailable(Coating coating) {
    showCoatingNotAvailable(
      context,
      coatingName: coating.name,
      customMessage: _getUnavailableMessage(coating),
      onContactSupport: () => _contactSupport(),
    );
  }

  /// Determina si un revestimiento está disponible
  bool _isCoatingAvailable(String coatingId) {
    const availableIds = ['1']; // Tarrajeo normal y Yeso
    return availableIds.contains(coatingId);
  }

  /// Obtiene el tipo de revestimiento para el provider
  String _getCoatingType(String coatingId) {
    switch (coatingId) {
      case '1':
        return 'Tarrajeo Normal';
      default:
        return 'Tarrajeo Normal';
    }
  }

  /// Obtiene mensaje personalizado para revestimiento no disponible
  String _getUnavailableMessage(Coating coating) {
    switch (coating.id) {
      case '3': // Estuco (ejemplo futuro)
        return 'Los cálculos para Estuco requieren fórmulas especializadas que estamos desarrollando.';
      case '4': // Textura (ejemplo futuro)
        return 'Las texturas decorativas necesitan validaciones adicionales de aplicación.';
      default:
        return 'Este revestimiento está en desarrollo y estará disponible próximamente.';
    }
  }

  /// Validaciones de seguridad
  bool _isValidCoating(Coating? coating) {
    return coating != null &&
        coating.id.isNotEmpty &&
        coating.name.isNotEmpty &&
        coating.image.isNotEmpty &&
        coating.details.isNotEmpty;
  }

  /// Manejo de errores de selección
  void _handleSelectionError(dynamic error, StackTrace stackTrace) {
    _logError('Error en selección de revestimiento: $error', stackTrace);
    _showErrorMessage('Error al seleccionar revestimiento. Inténtalo de nuevo.');
  }

  /// Manejo de errores de navegación
  void _handleNavigationError(dynamic error, StackTrace stackTrace) {
    _logError('Error de navegación: $error', stackTrace);
    _showErrorMessage('Error de navegación. Inténtalo de nuevo.');
  }

  /// Muestra mensaje de error al usuario
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: AppColors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Contactar soporte técnico
  void _contactSupport() {
    // Implementar lógica de contacto
    _showErrorMessage('Funcionalidad de soporte próximamente disponible');
  }

  /// Sistema de logging para debugging
  void _logError(String message, [StackTrace? stackTrace]) {
    assert(() {
      debugPrint('❌ TarrajeoScreen Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      return true;
    }());
  }
}

/// Extensión específica para Coating que proporciona información para la UI
extension CoatingUI on Coating {
  /// Determina si el revestimiento está disponible
  bool get isAvailable {
    const availableIds = ['1']; // Tarrajeo normal y Yeso
    return availableIds.contains(id);
  }

  /// Obtiene el color asociado al revestimiento
  Color get primaryColor {
    switch (id) {
      case '1': // Tarrajeo normal
        return AppColors.blueMetraShop;
      default:
        if (isAvailable) {
          return AppColors.success;
        } else {
          return AppColors.warning;
        }
    }
  }

  /// Obtiene la categoría del revestimiento
  CoatingCategory get category {
    switch (id) {
      case '1':
        return CoatingCategory.tarrajeoNormal;
      case '2':
        return CoatingCategory.yeso;
      case '3':
        return CoatingCategory.estuco;
      case '4':
        return CoatingCategory.textura;
      default:
        return CoatingCategory.unknown;
    }
  }

  /// Obtiene el estado de disponibilidad como texto
  String get availabilityStatus {
    return isAvailable ? 'Disponible' : 'Próximamente';
  }

  /// Obtiene la dificultad de aplicación
  ApplicationDifficulty get applicationDifficulty {
    switch (category) {
      case CoatingCategory.tarrajeoNormal:
        return ApplicationDifficulty.basic;
      case CoatingCategory.yeso:
        return ApplicationDifficulty.intermediate;
      case CoatingCategory.estuco:
        return ApplicationDifficulty.advanced;
      case CoatingCategory.textura:
        return ApplicationDifficulty.expert;
      case CoatingCategory.unknown:
        return ApplicationDifficulty.unknown;
    }
  }

  /// Obtiene información detallada del revestimiento
  CoatingInfo get detailedInfo {
    return CoatingInfo(
      id: id,
      name: name,
      category: category,
      isAvailable: isAvailable,
      primaryColor: primaryColor,
      description: _getDetailedDescription(),
      applicationTips: _getApplicationTips(),
      difficulty: applicationDifficulty,
    );
  }

  String _getDetailedDescription() {
    switch (category) {
      case CoatingCategory.tarrajeoNormal:
        return 'Revestimiento estándar con mortero de cemento y arena para protección y acabado.';
      case CoatingCategory.yeso:
        return 'Acabado fino con yeso para interiores, proporciona superficie lisa y uniforme.';
      case CoatingCategory.estuco:
        return 'Revestimiento decorativo de alta calidad con acabados especiales.';
      case CoatingCategory.textura:
        return 'Acabados texturizados con efectos decorativos y patrones únicos.';
      case CoatingCategory.unknown:
        return 'Revestimiento especializado para aplicaciones específicas.';
    }
  }

  List<String> _getApplicationTips() {
    final lines = details.split('\n');
    return lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll('·', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

/// Enum para categorías de revestimientos
enum CoatingCategory {
  tarrajeoNormal,
  yeso,
  estuco,
  textura,
  unknown;

  String get displayName {
    switch (this) {
      case CoatingCategory.tarrajeoNormal:
        return 'Tarrajeo Normal';
      case CoatingCategory.yeso:
        return 'Yeso';
      case CoatingCategory.estuco:
        return 'Estuco';
      case CoatingCategory.textura:
        return 'Textura';
      case CoatingCategory.unknown:
        return 'Desconocido';
    }
  }

  IconData get icon {
    switch (this) {
      case CoatingCategory.tarrajeoNormal:
        return Icons.format_paint;
      case CoatingCategory.yeso:
        return Icons.brush;
      case CoatingCategory.estuco:
        return Icons.palette;
      case CoatingCategory.textura:
        return Icons.texture;
      case CoatingCategory.unknown:
        return Icons.help_outline;
    }
  }

  String get description {
    switch (this) {
      case CoatingCategory.tarrajeoNormal:
        return 'Revestimiento básico con mortero';
      case CoatingCategory.yeso:
        return 'Acabado fino para interiores';
      case CoatingCategory.estuco:
        return 'Revestimiento decorativo premium';
      case CoatingCategory.textura:
        return 'Acabados con efectos especiales';
      case CoatingCategory.unknown:
        return 'Revestimiento especializado';
    }
  }
}

/// Enum para dificultad de aplicación
enum ApplicationDifficulty {
  basic,
  intermediate,
  advanced,
  expert,
  unknown;

  String get displayName {
    switch (this) {
      case ApplicationDifficulty.basic:
        return 'Básica';
      case ApplicationDifficulty.intermediate:
        return 'Intermedia';
      case ApplicationDifficulty.advanced:
        return 'Avanzada';
      case ApplicationDifficulty.expert:
        return 'Experto';
      case ApplicationDifficulty.unknown:
        return 'No definida';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationDifficulty.basic:
        return AppColors.success;
      case ApplicationDifficulty.intermediate:
        return AppColors.yellowMetraShop;
      case ApplicationDifficulty.advanced:
        return AppColors.warning;
      case ApplicationDifficulty.expert:
        return AppColors.error;
      case ApplicationDifficulty.unknown:
        return AppColors.neutral400;
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationDifficulty.basic:
        return Icons.star_border;
      case ApplicationDifficulty.intermediate:
        return Icons.star_half;
      case ApplicationDifficulty.advanced:
        return Icons.star;
      case ApplicationDifficulty.expert:
        return Icons.stars;
      case ApplicationDifficulty.unknown:
        return Icons.help_outline;
    }
  }

  String get description {
    switch (this) {
      case ApplicationDifficulty.basic:
        return 'Aplicación sencilla, ideal para principiantes';
      case ApplicationDifficulty.intermediate:
        return 'Requiere conocimientos básicos de construcción';
      case ApplicationDifficulty.advanced:
        return 'Necesita experiencia en acabados';
      case ApplicationDifficulty.expert:
        return 'Solo para profesionales experimentados';
      case ApplicationDifficulty.unknown:
        return 'Dificultad no determinada';
    }
  }
}

/// Clase de información detallada del revestimiento
class CoatingInfo {
  final String id;
  final String name;
  final CoatingCategory category;
  final bool isAvailable;
  final Color primaryColor;
  final String description;
  final List<String> applicationTips;
  final ApplicationDifficulty difficulty;

  const CoatingInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.isAvailable,
    required this.primaryColor,
    required this.description,
    required this.applicationTips,
    required this.difficulty,
  });

  /// Convierte a JSON para logging o debugging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.displayName,
      'isAvailable': isAvailable,
      'description': description,
      'applicationTips': applicationTips,
      'difficulty': difficulty.displayName,
    };
  }
}

/// Widget de ejemplo para mostrar información del revestimiento seleccionado
class SelectedCoatingInfo extends ConsumerWidget {
  const SelectedCoatingInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCoating = ref.watch(selectedCoatingProvider);

    if (selectedCoating == null) {
      return const SizedBox.shrink();
    }

    final info = selectedCoating.detailedInfo;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                info.category.icon,
                color: info.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Revestimiento seleccionado: ${info.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: info.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  info.isAvailable ? 'Disponible' : 'Próximamente',
                  style: TextStyle(
                    fontSize: 12,
                    color: info.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            info.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                info.difficulty.icon,
                color: info.difficulty.color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Dificultad: ${info.difficulty.displayName}',
                style: TextStyle(
                  fontSize: 12,
                  color: info.difficulty.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar tips de aplicación
class CoatingApplicationTips extends StatelessWidget {
  final List<String> tips;
  final Color? accentColor;

  const CoatingApplicationTips({
    super.key,
    required this.tips,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (accentColor ?? AppColors.blueMetraShop).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (accentColor ?? AppColors.blueMetraShop).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: accentColor ?? AppColors.blueMetraShop,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips de aplicación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor ?? AppColors.blueMetraShop,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: accentColor ?? AppColors.blueMetraShop,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}