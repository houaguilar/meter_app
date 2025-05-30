// lib/presentation/screens/home/losas/losas_screen_unified.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/losas/slab.dart';
import '../../../providers/home/losa/slab_providers.dart';
import '../../../widgets/cards/generic_item_card.dart';
import '../../../widgets/config/generic_module_config.dart';
import '../../../widgets/dialogs/unified_feature_disabled_dialog.dart';
import '../../../widgets/shared/responsive_grid_builder.dart';
import '../../../widgets/widgets.dart';

/// LosasScreen unificada usando componentes genéricos reutilizables
///
/// Esta implementación utiliza los componentes unificados para crear
/// una pantalla consistente, mantenible y escalable.
class LosasScreen extends ConsumerStatefulWidget {
  const LosasScreen({super.key});

  static const String routeName = 'losas';

  @override
  ConsumerState<LosasScreen> createState() => _LosasScreenState();
}

class _LosasScreenState extends ConsumerState<LosasScreen>
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
      appBar: AppBarWidget(titleAppBar: 'Losas'),
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
    return SlabGridBuilder<Slab>(
      asyncValue: ref.watch(slabProvider),
      itemBuilder: _buildSlabCard,
      onRetry: () => ref.invalidate(slabProvider),
      header: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return ResponsiveHeader(
      title: 'Tipo de Losa',
      subtitle: 'Selecciona el tipo de losa que necesitas para tu proyecto',
      headerSize: HeaderSize.h2,
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
    );
  }

  Widget _buildSlabCard(Slab slab, int index) {
    return SlabCard(
      slab: slab,
      onTap: () => _handleSlabSelection(slab),
      enabled: true,
    );
  }

  /// Maneja la selección de losas con validación y navegación
  void _handleSlabSelection(Slab slab) {
    try {
      // Validar losa
      if (!_isValidSlab(slab)) {
        _showErrorMessage('Losa no válida');
        return;
      }

      // Actualizar selección
      ref.read(selectedSlabProvider.notifier).state = slab;

      // Determinar navegación basada en disponibilidad y tipo
      if (_isSlabAvailable(slab.id)) {
        _navigateToAvailableSlab(slab);
      } else {
        _showSlabNotAvailable(slab);
      }
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega a losa disponible
  void _navigateToAvailableSlab(Slab slab) {
    try {
      switch (slab.id) {
        case '1': // Losa aligerada
          context.pushNamed('losas-aligeradas');
          break;
        case '2': // Losa maciza (si se añade en el futuro)
          context.pushNamed('losas-macizas');
          break;
        default:
          _showErrorMessage('Tipo de losa no reconocido');
          _logError('Losa ID no reconocida: ${slab.id}');
      }
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Muestra dialog para losa no disponible
  void _showSlabNotAvailable(Slab slab) {
    showSlabNotAvailable(
      context,
      slabName: slab.name,
      customMessage: _getUnavailableMessage(slab),
      onContactSupport: () => _contactSupport(),
    );
  }

  /// Determina si una losa está disponible
  bool _isSlabAvailable(String slabId) {
    const availableIds = ['1']; // Solo losa aligerada por ahora
    return availableIds.contains(slabId);
  }

  /// Obtiene mensaje personalizado para losa no disponible
  String _getUnavailableMessage(Slab slab) {
    switch (slab.id) {
      case '2': // Losa maciza (ejemplo futuro)
        return 'Las losas macizas requieren cálculos estructurales especializados que estamos desarrollando.';
      case '3': // Losa pretensada (ejemplo futuro)
        return 'Los cálculos para losas pretensadas necesitan validaciones adicionales de ingeniería.';
      default:
        return 'Esta losa está en desarrollo y estará disponible próximamente.';
    }
  }

  /// Validaciones de seguridad
  bool _isValidSlab(Slab? slab) {
    return slab != null &&
        slab.id.isNotEmpty &&
        slab.name.isNotEmpty &&
        slab.image.isNotEmpty &&
        slab.details.isNotEmpty;
  }

  /// Manejo de errores de selección
  void _handleSelectionError(dynamic error, StackTrace stackTrace) {
    _logError('Error en selección de losa: $error', stackTrace);
    _showErrorMessage('Error al seleccionar losa. Inténtalo de nuevo.');
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
      debugPrint('❌ LosasScreen Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      return true;
    }());
  }
}

/// Extensión específica para Slab que proporciona información para la UI
extension SlabUI on Slab {
  /// Determina si la losa está disponible
  bool get isAvailable {
    const availableIds = ['1']; // Solo losa aligerada disponible
    return availableIds.contains(id);
  }

  /// Obtiene el color asociado a la losa
  Color get primaryColor {
    switch (uiType) {
      case SlabUIType.aligerada:
        return AppColors.secondary;
      case SlabUIType.maciza:
        return AppColors.primary;
      case SlabUIType.pretensada:
        return AppColors.blueMetraShop;
      case SlabUIType.unknown:
        return AppColors.neutral400;
    }
  }

  /// Obtiene el tipo de losa para UI
  SlabUIType get uiType {
    switch (id) {
      case '1':
        return SlabUIType.aligerada;
      case '2':
        return SlabUIType.maciza;
      case '3':
        return SlabUIType.pretensada;
      default:
        return SlabUIType.unknown;
    }
  }

  /// Obtiene la categoría de la losa
  SlabCategory get category {
    switch (id) {
      case '1':
        return SlabCategory.aligerada;
      case '2':
        return SlabCategory.maciza;
      case '3':
        return SlabCategory.pretensada;
      default:
        return SlabCategory.unknown;
    }
  }

  /// Obtiene el estado de disponibilidad como texto
  String get availabilityStatus {
    return isAvailable ? 'Disponible' : 'Próximamente';
  }

  /// Obtiene información detallada de la losa
  SlabInfo get detailedInfo {
    return SlabInfo(
      id: id,
      name: name,
      category: category,
      isAvailable: isAvailable,
      primaryColor: primaryColor,
      description: _getDetailedDescription(),
      technicalSpecs: _getTechnicalSpecs(),
      structuralType: _getStructuralType(),
      complexity: _getComplexity(),
    );
  }

  String _getDetailedDescription() {
    switch (category) {
      case SlabCategory.aligerada:
        return 'Losa con elementos aligerantes (ladrillos huecos) para reducir peso manteniendo resistencia.';
      case SlabCategory.maciza:
        return 'Losa de concreto sólido de alta resistencia para cargas pesadas.';
      case SlabCategory.pretensada:
        return 'Losa con cables pretensados para mayor resistencia y menores deflexiones.';
      case SlabCategory.unknown:
        return 'Elemento estructural horizontal especializado.';
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

  StructuralType _getStructuralType() {
    switch (category) {
      case SlabCategory.aligerada:
        return StructuralType.light;
      case SlabCategory.maciza:
        return StructuralType.heavy;
      case SlabCategory.pretensada:
        return StructuralType.specialized;
      case SlabCategory.unknown:
        return StructuralType.unknown;
    }
  }

  ConstructionComplexity _getComplexity() {
    switch (category) {
      case SlabCategory.aligerada:
        return ConstructionComplexity.medium;
      case SlabCategory.maciza:
        return ConstructionComplexity.low;
      case SlabCategory.pretensada:
        return ConstructionComplexity.high;
      case SlabCategory.unknown:
        return ConstructionComplexity.unknown;
    }
  }
}

/// Enum para tipos de losa en UI
enum SlabUIType {
  aligerada,
  maciza,
  pretensada,
  unknown;

  String get displayName {
    switch (this) {
      case SlabUIType.aligerada:
        return 'Losa Aligerada';
      case SlabUIType.maciza:
        return 'Losa Maciza';
      case SlabUIType.pretensada:
        return 'Losa Pretensada';
      case SlabUIType.unknown:
        return 'Desconocido';
    }
  }

  String get description {
    switch (this) {
      case SlabUIType.aligerada:
        return 'Con elementos aligerantes para menor peso';
      case SlabUIType.maciza:
        return 'Concreto sólido de alta resistencia';
      case SlabUIType.pretensada:
        return 'Con cables de acero pretensados';
      case SlabUIType.unknown:
        return 'Tipo de losa no identificado';
    }
  }
}

/// Enum para categorías de losas
enum SlabCategory {
  aligerada,
  maciza,
  pretensada,
  unknown;

  String get displayName {
    switch (this) {
      case SlabCategory.aligerada:
        return 'Aligerada';
      case SlabCategory.maciza:
        return 'Maciza';
      case SlabCategory.pretensada:
        return 'Pretensada';
      case SlabCategory.unknown:
        return 'Desconocida';
    }
  }

  IconData get icon {
    switch (this) {
      case SlabCategory.aligerada:
        return Icons.grid_view;
      case SlabCategory.maciza:
        return Icons.crop_square;
      case SlabCategory.pretensada:
        return Icons.linear_scale;
      case SlabCategory.unknown:
        return Icons.help_outline;
    }
  }
}

/// Enum para tipos estructurales
enum StructuralType {
  light,
  heavy,
  specialized,
  unknown;

  String get displayName {
    switch (this) {
      case StructuralType.light:
        return 'Ligera';
      case StructuralType.heavy:
        return 'Pesada';
      case StructuralType.specialized:
        return 'Especializada';
      case StructuralType.unknown:
        return 'No definida';
    }
  }

  Color get color {
    switch (this) {
      case StructuralType.light:
        return AppColors.success;
      case StructuralType.heavy:
        return AppColors.warning;
      case StructuralType.specialized:
        return AppColors.secondary;
      case StructuralType.unknown:
        return AppColors.neutral400;
    }
  }
}

/// Enum para complejidad de construcción
enum ConstructionComplexity {
  low,
  medium,
  high,
  unknown;

  String get displayName {
    switch (this) {
      case ConstructionComplexity.low:
        return 'Básica';
      case ConstructionComplexity.medium:
        return 'Intermedia';
      case ConstructionComplexity.high:
        return 'Avanzada';
      case ConstructionComplexity.unknown:
        return 'No definida';
    }
  }

  Color get color {
    switch (this) {
      case ConstructionComplexity.low:
        return AppColors.success;
      case ConstructionComplexity.medium:
        return AppColors.warning;
      case ConstructionComplexity.high:
        return AppColors.error;
      case ConstructionComplexity.unknown:
        return AppColors.neutral400;
    }
  }

  IconData get icon {
    switch (this) {
      case ConstructionComplexity.low:
        return Icons.star_border;
      case ConstructionComplexity.medium:
        return Icons.star_half;
      case ConstructionComplexity.high:
        return Icons.star;
      case ConstructionComplexity.unknown:
        return Icons.help_outline;
    }
  }
}

/// Clase de información detallada de la losa
class SlabInfo {
  final String id;
  final String name;
  final SlabCategory category;
  final bool isAvailable;
  final Color primaryColor;
  final String description;
  final List<String> technicalSpecs;
  final StructuralType structuralType;
  final ConstructionComplexity complexity;

  const SlabInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.isAvailable,
    required this.primaryColor,
    required this.description,
    required this.technicalSpecs,
    required this.structuralType,
    required this.complexity,
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
      'structuralType': structuralType.displayName,
      'complexity': complexity.displayName,
    };
  }
}

/// Widget de información de la losa seleccionada
class SelectedSlabInfo extends ConsumerWidget {
  const SelectedSlabInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSlab = ref.watch(selectedSlabProvider);

    if (selectedSlab == null) {
      return const SizedBox.shrink();
    }

    final info = selectedSlab.detailedInfo;

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
                  'Losa seleccionada: ${info.name}',
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
              _buildInfoChip(
                'Tipo: ${info.structuralType.displayName}',
                info.structuralType.color,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                'Complejidad: ${info.complexity.displayName}',
                info.complexity.color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}