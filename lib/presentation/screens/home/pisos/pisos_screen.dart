import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/piso/floor.dart';
import '../../../providers/home/piso/floor_providers.dart';
import '../../../providers/providers.dart';
import '../../../widgets/cards/generic_item_card.dart';
import '../../../widgets/config/generic_module_config.dart';
import '../../../widgets/dialogs/unified_feature_disabled_dialog.dart';
import '../../../widgets/shared/responsive_grid_builder.dart';
import '../../../widgets/widgets.dart';

/// PisosScreen unificada usando componentes genéricos reutilizables
///
/// Esta implementación demuestra cómo usar los componentes unificados
/// para crear una pantalla consistente y mantenible para el módulo de pisos.
class PisosScreen extends ConsumerStatefulWidget {
  const PisosScreen({super.key});

  static const String routeName = 'pisos';

  @override
  ConsumerState<PisosScreen> createState() => _PisosScreenState();
}

class _PisosScreenState extends ConsumerState<PisosScreen>
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
      appBar: AppBarWidget(titleAppBar: 'Pisos'),
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
    return FloorGridBuilder<Floor>(
      asyncValue: ref.watch(floorsProvider),
      itemBuilder: _buildFloorCard,
      onRetry: () => ref.invalidate(floorsProvider),
      header: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return ResponsiveHeader(
      title: 'Tipo de revestimiento',
      subtitle: 'Selecciona el tipo de piso que necesitas para tu proyecto',
      headerSize: HeaderSize.h2,
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
    );
  }

  Widget _buildFloorCard(Floor floor, int index) {
    return FloorCard(
      floor: floor,
      onTap: () => _handleFloorSelection(floor),
      enabled: true,
    );
  }

  /// Maneja la selección de pisos con validación y navegación
  void _handleFloorSelection(Floor floor) {
    try {
      // Validar piso
      if (!_isValidFloor(floor)) {
        _showErrorMessage('Piso no válido');
        return;
      }

      // Actualizar selección
      ref.read(selectedFloorProvider.notifier).state = floor;

      // Determinar navegación basada en el tipo de piso
      if (_isFloorAvailable(floor.id)) {
        _navigateToAvailableFloor(floor);
      } else {
        _showFloorNotAvailable(floor);
      }
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega a piso disponible
  void _navigateToAvailableFloor(Floor floor) {
    try {
      final floorType = _getFloorType(floor.id);
      ref.read(tipoPisoProvider.notifier).selectPiso(floorType);

      switch (floor.id) {
        case '1': // Falso piso
          context.pushNamed('falso-piso');
          break;
        case '2': // Contrapiso
          context.pushNamed('contrapiso');
          break;
        default:
          context.pushNamed('falso-piso'); // Fallback
      }
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Muestra dialog para piso no disponible
  void _showFloorNotAvailable(Floor floor) {
    showFloorNotAvailable(
      context,
      floorName: floor.name,
      customMessage: _getUnavailableMessage(floor),
      onContactSupport: () => _contactSupport(),
    );
  }

  /// Determina si un piso está disponible
  bool _isFloorAvailable(String floorId) {
    const availableIds = ['1', '2']; // Falso piso y contrapiso
    return availableIds.contains(floorId);
  }

  /// Obtiene el tipo de piso para el provider
  String _getFloorType(String floorId) {
    switch (floorId) {
      case '1':
        return 'falso';
      case '2':
        return 'contrapiso';
      default:
        return 'falso';
    }
  }

  /// Obtiene mensaje personalizado para piso no disponible
  String _getUnavailableMessage(Floor floor) {
    switch (floor.id) {
      case '3': // Ejemplo de piso no disponible
        return 'Los cálculos para este tipo de piso están siendo desarrollados por nuestro equipo de ingenieros.';
      case '4': // Otro ejemplo
        return 'Este revestimiento requiere fórmulas especializadas que estamos validando.';
      default:
        return 'Este tipo de piso está en desarrollo y estará disponible próximamente.';
    }
  }

  /// Validaciones de seguridad
  bool _isValidFloor(Floor? floor) {
    return floor != null &&
        floor.id.isNotEmpty &&
        floor.name.isNotEmpty &&
        floor.image.isNotEmpty;
  }

  /// Manejo de errores de selección
  void _handleSelectionError(dynamic error, StackTrace stackTrace) {
    _logError('Error en selección de piso: $error', stackTrace);
    _showErrorMessage('Error al seleccionar piso. Inténtalo de nuevo.');
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
      debugPrint('❌ PisosScreen Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      return true;
    }());
  }
}

/// Extensión específica para Floor que proporciona información para la UI
extension FloorUI on Floor {
  /// Determina si el piso está disponible
  bool get isAvailable {
    const availableIds = ['1', '2'];
    return availableIds.contains(id);
  }

  /// Obtiene el color asociado al piso
  Color get primaryColor {
    if (isAvailable) {
      return AppColors.blueMetraShop;
    } else {
      return AppColors.warning;
    }
  }

  /// Obtiene la categoría del piso
  FloorCategory get category {
    switch (id) {
      case '1':
        return FloorCategory.falsoPiso;
      case '2':
        return FloorCategory.contrapiso;
      case '3':
        return FloorCategory.pisoEstructural;
      case '4':
        return FloorCategory.pisoDecorado;
      default:
        return FloorCategory.unknown;
    }
  }

  /// Obtiene el estado de disponibilidad como texto
  String get availabilityStatus {
    return isAvailable ? 'Disponible' : 'Próximamente';
  }

  /// Obtiene la dificultad de instalación
  InstallationDifficulty get installationDifficulty {
    switch (category) {
      case FloorCategory.falsoPiso:
        return InstallationDifficulty.medium;
      case FloorCategory.contrapiso:
        return InstallationDifficulty.high;
      case FloorCategory.pisoEstructural:
        return InstallationDifficulty.high;
      case FloorCategory.pisoDecorado:
        return InstallationDifficulty.low;
      case FloorCategory.unknown:
        return InstallationDifficulty.unknown;
    }
  }

  /// Obtiene información detallada del piso
  FloorInfo get detailedInfo {
    return FloorInfo(
      id: id,
      name: name,
      category: category,
      isAvailable: isAvailable,
      primaryColor: primaryColor,
      description: _getDetailedDescription(),
      technicalSpecs: _getTechnicalSpecs(),
      installationDifficulty: installationDifficulty,
    );
  }

  String _getDetailedDescription() {
    switch (category) {
      case FloorCategory.falsoPiso:
        return 'Base nivelada de concreto pobre para recibir el piso final.';
      case FloorCategory.contrapiso:
        return 'Capa de mortero que nivela y regulariza la superficie.';
      case FloorCategory.pisoEstructural:
        return 'Piso que forma parte de la estructura del edificio.';
      case FloorCategory.pisoDecorado:
        return 'Revestimiento final con propiedades estéticas.';
      case FloorCategory.unknown:
        return 'Tipo de piso especializado.';
    }
  }

  List<String> _getTechnicalSpecs() {
    final lines = details.split('\n');
    return lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll('·', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

/// Enum para categorías de pisos
enum FloorCategory {
  falsoPiso,
  contrapiso,
  pisoEstructural,
  pisoDecorado,
  unknown;

  String get displayName {
    switch (this) {
      case FloorCategory.falsoPiso:
        return 'Falso Piso';
      case FloorCategory.contrapiso:
        return 'Contrapiso';
      case FloorCategory.pisoEstructural:
        return 'Piso Estructural';
      case FloorCategory.pisoDecorado:
        return 'Piso Decorado';
      case FloorCategory.unknown:
        return 'Desconocido';
    }
  }

  IconData get icon {
    switch (this) {
      case FloorCategory.falsoPiso:
        return Icons.layers;
      case FloorCategory.contrapiso:
        return Icons.straighten;
      case FloorCategory.pisoEstructural:
        return Icons.foundation;
      case FloorCategory.pisoDecorado:
        return Icons.palette;
      case FloorCategory.unknown:
        return Icons.help_outline;
    }
  }

  String get description {
    switch (this) {
      case FloorCategory.falsoPiso:
        return 'Base de preparación para el piso final';
      case FloorCategory.contrapiso:
        return 'Capa de nivelación y regularización';
      case FloorCategory.pisoEstructural:
        return 'Elemento estructural del edificio';
      case FloorCategory.pisoDecorado:
        return 'Acabado final decorativo';
      case FloorCategory.unknown:
        return 'Categoría no definida';
    }
  }
}

/// Enum para dificultad de instalación
enum InstallationDifficulty {
  low,
  medium,
  high,
  unknown;

  String get displayName {
    switch (this) {
      case InstallationDifficulty.low:
        return 'Básica';
      case InstallationDifficulty.medium:
        return 'Intermedia';
      case InstallationDifficulty.high:
        return 'Avanzada';
      case InstallationDifficulty.unknown:
        return 'No definida';
    }
  }

  Color get color {
    switch (this) {
      case InstallationDifficulty.low:
        return AppColors.success;
      case InstallationDifficulty.medium:
        return AppColors.warning;
      case InstallationDifficulty.high:
        return AppColors.error;
      case InstallationDifficulty.unknown:
        return AppColors.neutral400;
    }
  }

  IconData get icon {
    switch (this) {
      case InstallationDifficulty.low:
        return Icons.star_border;
      case InstallationDifficulty.medium:
        return Icons.star_half;
      case InstallationDifficulty.high:
        return Icons.star;
      case InstallationDifficulty.unknown:
        return Icons.help_outline;
    }
  }

  String get description {
    switch (this) {
      case InstallationDifficulty.low:
        return 'Requiere herramientas básicas y conocimientos mínimos';
      case InstallationDifficulty.medium:
        return 'Necesita experiencia y herramientas especializadas';
      case InstallationDifficulty.high:
        return 'Requiere mano de obra especializada y técnicas avanzadas';
      case InstallationDifficulty.unknown:
        return 'Dificultad de instalación no determinada';
    }
  }
}

/// Clase de información detallada del piso
class FloorInfo {
  final String id;
  final String name;
  final FloorCategory category;
  final bool isAvailable;
  final Color primaryColor;
  final String description;
  final List<String> technicalSpecs;
  final InstallationDifficulty installationDifficulty;

  const FloorInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.isAvailable,
    required this.primaryColor,
    required this.description,
    required this.technicalSpecs,
    required this.installationDifficulty,
  });

  /// Convierte a JSON para logging o debugging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.displayName,
      'isAvailable': isAvailable,
      'description': description,
      'technicalSpecs': technicalSpecs,
      'installationDifficulty': installationDifficulty.displayName,
    };
  }
}

/// Widget de información del piso seleccionado
class SelectedFloorInfo extends ConsumerWidget {
  const SelectedFloorInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFloor = ref.watch(selectedFloorProvider);

    if (selectedFloor == null) {
      return const SizedBox.shrink();
    }

    final info = selectedFloor.detailedInfo;

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
                  'Piso seleccionado: ${info.name}',
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
                info.installationDifficulty.icon,
                color: info.installationDifficulty.color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Instalación: ${info.installationDifficulty.displayName}',
                style: TextStyle(
                  fontSize: 12,
                  color: info.installationDifficulty.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget de comparación de pisos (ejemplo de extensibilidad)
class FloorComparisonWidget extends StatelessWidget {
  final List<Floor> floors;

  const FloorComparisonWidget({
    super.key,
    required this.floors,
  });

  @override
  Widget build(BuildContext context) {
    if (floors.isEmpty) return const SizedBox.shrink();

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
          const Text(
            'Comparación de Pisos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...floors.map((floor) => _buildComparisonItem(floor)),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(Floor floor) {
    final info = floor.detailedInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: info.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  info.category.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            info.installationDifficulty.icon,
            color: info.installationDifficulty.color,
            size: 16,
          ),
        ],
      ),
    );
  }
}