import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/muro/wall_material.dart';
import '../../../../domain/entities/home/muro/tipo_ladrillo.dart';
import '../../../providers/home/muro/custom_brick_providers.dart';
import '../../../providers/home/muro/wall_material_providers_improved.dart';
import '../../../providers/home/muro/custom_brick_isar_providers.dart';
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
      appBar: AppBarWidget(titleAppBar: 'Materiales de Muro'),
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
    // CAMBIO: Usar el provider que combina ladrillos guardados con predefinidos
    final materialsAsync = ref.watch(wallMaterialsWithCustomProvider);

    return WallMaterialGridBuilder<WallMaterial>(
      asyncValue: materialsAsync,
      onRetry: () {
        ref.invalidate(wallMaterialsWithCustomProvider);
      },
      itemBuilder: (material, index) {
        // Si es un custom brick guardado, agregar botón de eliminar
        if (material.id.startsWith('saved_')) {
          return _buildCustomBrickCard(material);
        }
        // Para otros materiales, usar la tarjeta normal
        return WallMaterialCard(
          wallMaterial: material,
          onTap: () => _handleMaterialSelection(material),
        );
      },
      header: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blueMetraShop.withOpacity(0.2),
                      AppColors.blueMetraShop.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.construction,
                  color: AppColors.blueMetraShop,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Materiales de Muro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecciona el tipo de ladrillo para tu proyecto',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contador de ladrillos personalizados
          Consumer(
            builder: (context, ref, child) {
              final customBricksAsync = ref.watch(customBricksProvider);

              return customBricksAsync.when(
                data: (customBricks) {
                  if (customBricks.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${customBricks.length} ladrillo${customBricks.length != 1 ? 's' : ''} personalizado${customBricks.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
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

      // Navegar según el tipo de material
      _navigateToMaterial(material);
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega según el tipo de material
  void _navigateToMaterial(WallMaterial material) {
    try {
      // NUEVO: Verificar si es un ladrillo personalizado guardado
      if (material.id.startsWith('saved_')) {
        // Para ladrillos guardados, usar las dimensiones directamente
        ref.read(customBrickDimensionsProvider.notifier).updateDimensions(
          length: material.lengthBrick,
          width: material.widthBrick,
          height: material.heightBrick,
          name: material.name.replaceFirst('⭐ ', ''), // Quitar la estrella
        );

        // Establecer tipo Custom y continuar flujo
        ref.read(tipoLadrilloNotifierProvider.notifier).selectLadrillo('Custom');
        context.pushNamed('ladrillo1');
        return;
      }

      // Para el ladrillo personalizable (crear nuevo)
      if (material.id == 'custom') {
        // Resetear dimensiones a valores default antes de entrar
        ref.read(customBrickDimensionsProvider.notifier).clearDimensions();
        context.pushNamed('custom-brick-config');
        return;
      }

      // Para ladrillos predefinidos (lógica existente)
      final materialType = _getMaterialType(material.id);
      print('🔧 Estableciendo tipo: "$materialType"');

      ref.read(tipoLadrilloNotifierProvider.notifier).selectLadrillo(materialType);

      final verificacion = ref.read(tipoLadrilloNotifierProvider);
      print('🔍 Verificación: "$verificacion"');
      context.pushNamed('ladrillo1');

    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Obtiene el tipo de material para el provider usando ENUM
  String _getMaterialType(String materialId) {
    final tipo = TipoLadrillo.fromRepositoryId(materialId);
    return tipo?.providerKey ?? TipoLadrillo.pandereta1.providerKey;
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

  /// Widget para custom bricks guardados con botón de eliminar
  Widget _buildCustomBrickCard(WallMaterial material) {
    return Stack(
      children: [
        WallMaterialCard(
          wallMaterial: material,
          onTap: () => _handleMaterialSelection(material),
        ),
        // Botón de eliminar en la esquina superior derecha
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleDeleteCustomBrick(material),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Maneja la eliminación de un custom brick
  void _handleDeleteCustomBrick(WallMaterial material) {
    // Extraer el customId del material ID (formato: 'saved_{customId}')
    final customId = material.id.replaceFirst('saved_', '');
    final brickName = material.name.replaceFirst('⭐ ', '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Eliminar Ladrillo',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que quieres eliminar "$brickName"?',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.neutral300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.blueMetraShop,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Esto no afectará resultados ya guardados',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _confirmDeleteCustomBrick(customId, brickName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text(
                'Eliminar',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Confirma y ejecuta la eliminación
  Future<void> _confirmDeleteCustomBrick(String customId, String brickName) async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Eliminando "$brickName"...'),
              ],
            ),
            backgroundColor: AppColors.blueMetraShop,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Ejecutar eliminación
      await ref.read(customBrickSaveStateProvider.notifier).deleteCustomBrick(customId);

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Ladrillo "$brickName" eliminado'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                Expanded(
                  child: Text('Error al eliminar: $e'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}