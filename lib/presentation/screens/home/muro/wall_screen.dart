import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/muro/wall_material.dart';
import '../../../providers/home/muro/wall_material_providers_improved.dart';
import '../../../providers/providers.dart';
import '../../../widgets/cards/generic_item_card.dart';
import '../../../widgets/config/generic_module_config.dart';
import '../../../widgets/dialogs/unified_feature_disabled_dialog.dart';
import '../../../widgets/shared/responsive_grid_builder.dart';
import '../../../widgets/widgets.dart';

class WallScreen extends ConsumerStatefulWidget {
  const WallScreen({super.key});

  static const String routeName = 'muro';

  @override
  ConsumerState<WallScreen> createState() => _WallScreenState();
}

class _WallScreenState extends ConsumerState<WallScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

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
    super.build(context);

    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Tipos de Muro'),
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
    return WallMaterialGridBuilder<WallMaterial>(
      asyncValue: ref.watch(wallMaterialsProvider),
      itemBuilder: _buildMaterialCard,
      onRetry: () => ref.invalidate(wallMaterialsProvider),
      header: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return ResponsiveHeader(
      title: 'Selecciona el tipo de material',
      subtitle: 'Elige el material que utilizarás para tu proyecto',
      headerSize: HeaderSize.h2,
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
    );
  }

  Widget _buildMaterialCard(WallMaterial material, int index) {
    return WallMaterialCard(
      wallMaterial: material,
      onTap: () => _handleMaterialSelection(material),
      enabled: _isMaterialAvailable(material.id),
    );
  }

  /// Maneja la selección de materiales con validación y navegación
  void _handleMaterialSelection(WallMaterial material) {
    try {
      // Validar material
      if (!_isValidMaterial(material)) {
        _showErrorMessage('Material no válido');
        return;
      }

      // Actualizar selección
      ref.read(selectedMaterialProvider.notifier).state = material;

      // Determinar navegación basada en disponibilidad
      if (_isMaterialAvailable(material.id)) {
        _navigateToAvailableMaterial(material);
      } else {
        _showMaterialNotAvailable(material);
      }
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega a material disponible
  void _navigateToAvailableMaterial(WallMaterial material) {
    try {
      final materialType = _getMaterialType(material.id);
      print('🔧 Estableciendo tipo: "$materialType"'); // Debug

      if (material.id == 'custom') {
        context.pushNamed('custom-brick-config');
        return;
      }

      ref.read(tipoLadrilloProvider.notifier).selectLadrillo(materialType);

      final verificacion = ref.read(tipoLadrilloProvider);
      print('🔍 Verificación: "$verificacion"'); // Debug
      context.pushNamed('ladrillo1');
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Muestra dialog para material no disponible
  void _showMaterialNotAvailable(WallMaterial material) {
    showWallMaterialNotAvailable(
      context,
      materialName: material.name,
      customMessage: _getUnavailableMessage(material),
      onContactSupport: () => _contactSupport(),
    );
  }

  /// Determina si un material está disponible
  bool _isMaterialAvailable(String materialId) {
    const availableIds = ['1', '2', '3', '4', 'custom']; // Panderetas y King Kong
    return availableIds.contains(materialId);
  }

  /// Obtiene el tipo de material para el provider
  String _getMaterialType(String materialId) {
    switch (materialId) {
      case '1':
        return 'Pandereta1';
      case '2':
        return 'Pandereta2';
      case '3':
        return 'Kingkong1';
      case '4':
        return 'Kingkong2';
      case 'custom':
        return 'Custom';
      default:
        return 'Pandereta1';
    }
  }

  /// Obtiene mensaje personalizado para material no disponible
  String _getUnavailableMessage(WallMaterial material) {
    switch (material.id) {
      case '5': // Tabicón
        return 'El cálculo para Tabicón requiere algoritmos especializados que estamos desarrollando.';
      case '6':
      case '7':
      case '8': // Bloquetas
        return 'Los cálculos para Bloquetas necesitan validaciones adicionales de ingeniería.';
      default:
        return 'Este material está en desarrollo y estará disponible próximamente.';
    }
  }

  /// Validaciones de seguridad
  bool _isValidMaterial(WallMaterial? material) {
    return material != null &&
        material.id.isNotEmpty &&
        material.name.isNotEmpty &&
        material.image.isNotEmpty;
  }

  /// Manejo de errores de selección
  void _handleSelectionError(dynamic error, StackTrace stackTrace) {
    _logError('Error en selección de material: $error', stackTrace);
    _showErrorMessage('Error al seleccionar material. Inténtalo de nuevo.');
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
      debugPrint('❌ WallScreen Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      return true;
    }());
  }
}

/// Extensión específica para WallMaterial que proporciona información para la UI
extension WallMaterialUI on WallMaterial {
  /// Determina si el material está disponible
  bool get isAvailable {
    const availableIds = ['1', '2', '3', '4', 'custom'];
    return availableIds.contains(id);
  }

  /// Obtiene el color asociado al material
  Color get primaryColor {
    if (isAvailable) {
      return AppColors.success;
    } else {
      return AppColors.warning;
    }
  }

  /// Obtiene la categoría del material
  WallMaterialCategory get category {
    switch (id) {
      case '1':
      case '2':
        return WallMaterialCategory.pandereta;
      case '3':
      case '4':
        return WallMaterialCategory.kingKong;
      case '5':
        return WallMaterialCategory.tabicon;
      case '6':
      case '7':
      case '8':
        return WallMaterialCategory.bloqueta;
      default:
        return WallMaterialCategory.unknown;
    }
  }

  /// Obtiene el estado de disponibilidad como texto
  String get availabilityStatus {
    return isAvailable ? 'Disponible' : 'Próximamente';
  }

  /// Obtiene información detallada del material
  WallMaterialInfo get detailedInfo {
    return WallMaterialInfo(
      id: id,
      name: name,
      category: category,
      isAvailable: isAvailable,
      primaryColor: primaryColor,
      description: _getDetailedDescription(),
      technicalSpecs: _getTechnicalSpecs(),
    );
  }

  String _getDetailedDescription() {
    switch (category) {
      case WallMaterialCategory.pandereta:
        return 'Ladrillos huecos ideales para muros no portantes y divisiones.';
      case WallMaterialCategory.kingKong:
        return 'Ladrillos resistentes para muros portantes y estructurales.';
      case WallMaterialCategory.tabicon:
        return 'Bloques grandes para construcción rápida y eficiente.';
      case WallMaterialCategory.bloqueta:
        return 'Bloques de concreto para muros de carga y cerramientos.';
      case WallMaterialCategory.unknown:
        return 'Material de construcción especializado.';
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

/// Enum para categorías de materiales de muro
enum WallMaterialCategory {
  pandereta,
  kingKong,
  tabicon,
  bloqueta,
  unknown;

  String get displayName {
    switch (this) {
      case WallMaterialCategory.pandereta:
        return 'Pandereta';
      case WallMaterialCategory.kingKong:
        return 'King Kong';
      case WallMaterialCategory.tabicon:
        return 'Tabicón';
      case WallMaterialCategory.bloqueta:
        return 'Bloqueta';
      case WallMaterialCategory.unknown:
        return 'Desconocido';
    }
  }

  IconData get icon {
    switch (this) {
      case WallMaterialCategory.pandereta:
        return Icons.crop_portrait;
      case WallMaterialCategory.kingKong:
        return Icons.crop_square;
      case WallMaterialCategory.tabicon:
        return Icons.view_module;
      case WallMaterialCategory.bloqueta:
        return Icons.grid_view;
      case WallMaterialCategory.unknown:
        return Icons.help_outline;
    }
  }
}

/// Clase de información detallada del material
class WallMaterialInfo {
  final String id;
  final String name;
  final WallMaterialCategory category;
  final bool isAvailable;
  final Color primaryColor;
  final String description;
  final List<String> technicalSpecs;

  const WallMaterialInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.isAvailable,
    required this.primaryColor,
    required this.description,
    required this.technicalSpecs,
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
    };
  }
}

/// Widget de ejemplo para mostrar información del material seleccionado
class SelectedMaterialInfo extends ConsumerWidget {
  const SelectedMaterialInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMaterial = ref.watch(selectedMaterialProvider);

    if (selectedMaterial == null) {
      return const SizedBox.shrink();
    }

    final info = selectedMaterial.detailedInfo;

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
                  'Material seleccionado: ${info.name}',
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
        ],
      ),
    );
  }
}