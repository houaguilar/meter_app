import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:meter_app/core/theme/theme.dart';
import 'package:meter_app/domain/entities/home/losas/slab.dart';
import 'package:meter_app/domain/entities/home/losas/tipo_losa.dart';
import 'package:meter_app/features/losas/presentation/providers/slab_providers.dart';
import 'package:meter_app/core/widgets/cards/generic_item_card.dart';
import 'package:meter_app/core/widgets/core/generic_module_config.dart';
import 'package:meter_app/core/widgets/dialogs/unified_feature_disabled_dialog.dart';
import 'package:meter_app/core/widgets/shared/responsive_grid_builder.dart';
import 'package:meter_app/core/widgets/widgets.dart';

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
      ref.read(selectedSlabProvider.notifier).select(slab);

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
      TipoLosa? tipoLosa;

      switch (slab.id) {
        case '1': // Losa aligerada con viguetas prefabricadas
          tipoLosa = TipoLosa.viguetasPrefabricadas;
          break;
        case '2': // Losa aligerada tradicional
          tipoLosa = TipoLosa.tradicional;
          break;
        case '3': // Losa maciza
          tipoLosa = TipoLosa.maciza;
          break;
        default:
          _showErrorMessage('Tipo de losa no reconocido');
          _logError('Losa ID no reconocida: ${slab.id}');
          return;
      }

      // Navegar usando la ruta dinámica
      context.push('/home/losas/datos/${tipoLosa.routePath}');
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
    // Todas las losas están ahora disponibles con la nueva arquitectura
    const availableIds = ['1', '2', '3'];
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
      if (stackTrace != null) {
      }
      return true;
    }());
  }
}
