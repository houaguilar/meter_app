import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/features/tarrajeo/presentation/providers/tarrajeo_derrame_providers.dart';

import 'package:meter_app/core/theme/theme.dart';
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/features/tarrajeo/presentation/providers/coating_providers.dart';
import 'package:meter_app/features/tarrajeo/presentation/providers/tarrajeo_providers.dart';
import 'package:meter_app/core/widgets/cards/generic_item_card.dart';
import 'package:meter_app/core/widgets/core/generic_module_config.dart';
import 'package:meter_app/core/widgets/dialogs/unified_feature_disabled_dialog.dart';
import 'package:meter_app/core/widgets/shared/responsive_grid_builder.dart';
import 'package:meter_app/core/widgets/widgets.dart';

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
      ref.read(selectedCoatingProvider.notifier).select(coating);

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
          case '2': // derrame
        ref.read(tipoTarrajeoDerrrameProvider.notifier).selectTarrajeoDerrrame(coatingType);
        context.pushNamed('tarrajeo-derrame');
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
    const availableIds = ['1', '2', '3', '4', '5', '6']; // Tarrajeo normal y Yeso
    return availableIds.contains(coatingId);
  }

  /// Obtiene el tipo de revestimiento para el provider
  String _getCoatingType(String coatingId) {
    switch (coatingId) {
      case '1':
        return 'Tarrajeo Normal';
      case '2':
        return 'Tarrajeo Derrame';
      case '3':
        return 'Tarrajeo Cielorraso';
      case '4':
        return 'Solaqueo';
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
      if (stackTrace != null) {
      }
      return true;
    }());
  }
}
