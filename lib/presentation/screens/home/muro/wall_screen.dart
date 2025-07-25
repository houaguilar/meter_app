// lib/presentation/screens/home/muro/wall_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/muro/wall_material.dart';
import '../../../providers/home/muro/wall_material_providers_improved.dart';
import '../../../providers/providers.dart';
import '../../../widgets/cards/generic_item_card.dart';
import '../../../widgets/config/generic_module_config.dart';
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
      // REMOVIDO: enabled parameter que dependía de available logic
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

      // Navegar directamente (REMOVIDO: check de disponibilidad)
      _navigateToMaterial(material);
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega según el tipo de material
  void _navigateToMaterial(WallMaterial material) {
    try {
      final materialType = _getMaterialType(material.id);
      print('🔧 Estableciendo tipo: "$materialType"');

      if (material.id == 'custom') {
        context.pushNamed('custom-brick-config');
        return;
      }

      ref.read(tipoLadrilloProvider.notifier).selectLadrillo(materialType);

      final verificacion = ref.read(tipoLadrilloProvider);
      print('🔍 Verificación: "$verificacion"');
      context.pushNamed('ladrillo1');
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
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

// REMOVIDO: Extension WallMaterialUI con lógica de available
// REMOVIDO: Toda lógica relacionada con disponibilidad