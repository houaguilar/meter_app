import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:meter_app/core/theme/theme.dart';
import 'package:meter_app/domain/entities/home/piso/floor.dart';
import 'package:meter_app/features/pisos/presentation/providers/floor_providers.dart';
import 'package:meter_app/features/pisos/presentation/providers/pisos_providers.dart';
import 'package:meter_app/core/widgets/cards/generic_item_card.dart';
import 'package:meter_app/core/widgets/core/generic_module_config.dart';
import 'package:meter_app/core/widgets/dialogs/unified_feature_disabled_dialog.dart';
import 'package:meter_app/core/widgets/shared/responsive_grid_builder.dart';
import 'package:meter_app/core/widgets/widgets.dart';

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
      ref.read(selectedFloorProvider.notifier).select(floor);

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
      if (stackTrace != null) {
      }
      return true;
    }());
  }
}
