// lib/presentation/screens/home/estructuras/structural_element_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:meter_app/core/theme/theme.dart';
import 'package:meter_app/domain/entities/home/estructuras/structural_element.dart';
import 'package:meter_app/features/estructuras/presentation/providers/structural_element_providers.dart';
import 'package:meter_app/core/widgets/dialogs/unified_feature_disabled_dialog.dart';
import 'package:meter_app/core/widgets/widgets.dart';
import 'package:meter_app/features/estructuras/presentation/widgets/structural_element_widgets.dart';

import '../../../../core/widgets/core/generic_module_config.dart';
import '../../../../core/widgets/shared/responsive_grid_builder.dart';

class StructuralElementScreen extends ConsumerStatefulWidget {
  const StructuralElementScreen({super.key});

  static const String routeName = 'structural-elements';

  @override
  ConsumerState<StructuralElementScreen> createState() => _StructuralElementScreenState();
}

class _StructuralElementScreenState extends ConsumerState<StructuralElementScreen>
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

    // FIX: Limpiar estado al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tipoStructuralElementProvider.notifier).update('');
      ref.read(columnaResultProvider.notifier).clearList();
      ref.read(vigaResultProvider.notifier).clearList();
    });
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
      appBar: AppBarWidget(titleAppBar: 'Elementos Estructurales'),
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
    return StructuralElementGridBuilder<StructuralElement>(
      asyncValue: AsyncValue.data(ref.watch(structuralElementsProvider)),
      itemBuilder: _buildStructuralElementCard,
      onRetry: () => ref.invalidate(structuralElementsProvider),
      header: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return ResponsiveHeader(
      title: 'Tipo de elemento estructural',
      subtitle: 'Selecciona el elemento estructural para tu proyecto',
      headerSize: HeaderSize.h2,
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
    );
  }

  Widget _buildStructuralElementCard(StructuralElement element, int index) {
    return StructuralElementCard(
      structuralElement: element,
      onTap: () => _handleStructuralElementSelection(element),
      enabled: true,
    );
  }

  /// Maneja la selección de elementos estructurales con validación y navegación
  void _handleStructuralElementSelection(StructuralElement element) {
    try {
      // Validar elemento
      if (!_isValidStructuralElement(element)) {
        _showErrorMessage('Elemento estructural no válido');
        return;
      }

      // Debug: imprimir información del elemento seleccionado

      // Actualizar selección
      ref.read(selectedStructuralElementProvider.notifier).selectElement(element);

      // Determinar navegación basada en disponibilidad
      if (_isStructuralElementAvailable(element.id)) {
        _navigateToAvailableElement(element);
      }
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega a elemento estructural disponible
  void _navigateToAvailableElement(StructuralElement element) {
    try {
      final elementType = _getStructuralElementType(element.id);

      // Debug: imprimir el tipo de elemento que se va a establecer

      // FIX: Establecer el tipo de elemento usando NotifierProvider
      ref.read(tipoStructuralElementProvider.notifier).update(elementType);

      // Verificar que se estableció correctamente
      final tipoEstablecido = ref.read(tipoStructuralElementProvider);

      // Esperar un frame para asegurar que el estado se propagó
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tipoFinal = ref.read(tipoStructuralElementProvider);

        // Navegar a la pantalla de datos
        context.pushNamed('structural-element-datos');
      });
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Determina si un elemento estructural está disponible
  bool _isStructuralElementAvailable(String elementId) {
    const availableIds = ['1', '2','3', '4', '5', '6']; // Columna y Viga disponibles
    return availableIds.contains(elementId);
  }

  /// Obtiene el tipo de elemento estructural para el provider
  String _getStructuralElementType(String elementId) {
    switch (elementId) {
      case '1':
        return 'columna';
      case '2':
        return 'viga';
      case '3':
        return 'zapata';
      case '4':
        return 'cimiento_corrido';
      case '5':
        return 'sobrecimiento';
      case '6':
        return 'solado';
      default:
        return 'columna';
    }
  }

  /// Validaciones de seguridad
  bool _isValidStructuralElement(StructuralElement? element) {
    return element != null &&
        element.id.isNotEmpty &&
        element.name.isNotEmpty &&
        element.image.isNotEmpty;
  }

  /// Manejo de errores de selección
  void _handleSelectionError(dynamic error, StackTrace stackTrace) {
    _logError('Error en selección de elemento estructural: $error', stackTrace);
    _showErrorMessage('Error al seleccionar elemento. Inténtalo de nuevo.');
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
      if (stackTrace != null) {
      }
      return true;
    }());
  }
}

