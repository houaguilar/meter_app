// lib/presentation/screens/home/estructuras/structural_element_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/estructuras/structural_element.dart';
import '../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../widgets/cards/generic_item_card.dart';
import '../../../widgets/config/generic_module_config.dart';
import '../../../widgets/dialogs/unified_feature_disabled_dialog.dart';
import '../../../widgets/shared/responsive_grid_builder.dart';
import '../../../widgets/widgets.dart';

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
      ref.read(tipoStructuralElementProvider.notifier).state = '';
      ref.read(columnaResultProvider.notifier).clearList();
      ref.read(vigaResultProvider.notifier).clearList();
      print('🧹 Estado inicial limpiado');
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
      print('🔍 Elemento seleccionado: ${element.name} (ID: ${element.id})');

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
      print('🏗️ Tipo de elemento a establecer: $elementType');

      // FIX: Establecer el tipo de elemento usando StateProvider
      ref.read(tipoStructuralElementProvider.notifier).state = elementType;

      // Verificar que se estableció correctamente
      final tipoEstablecido = ref.read(tipoStructuralElementProvider);
      print('✅ Tipo establecido en provider: $tipoEstablecido');

      // Esperar un frame para asegurar que el estado se propagó
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tipoFinal = ref.read(tipoStructuralElementProvider);
        print('🔍 Tipo final antes de navegar: $tipoFinal');

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
        print('🏛️ Seleccionando COLUMNA para ID: $elementId');
        return 'columna';
      case '2':
        print('🌉 Seleccionando VIGA para ID: $elementId');
        return 'viga';
      case '3':
        print('🌉 Seleccionando ZAPATA para ID: $elementId');
        return 'zapata';
      case '4':
        print('🌉 Seleccionando CIMIENTO CORRIDO para ID: $elementId');
        return 'cimiento_corrido';
      case '5':
        print('🧱 Seleccionando SOBRECIMIENTO para ID: $elementId');
        return 'sobrecimiento';
      case '6':
        print('🧱 Seleccionando SOLADO para ID: $elementId');
        return 'solado';
      default:
        print('❓ ID no reconocido: $elementId, usando columna por defecto');
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
      debugPrint('❌ StructuralElementScreen Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      return true;
    }());
  }
}

/// Factory method para StructuralElementCard usando GenericItemCard
class StructuralElementCard extends StatelessWidget {
  final StructuralElement structuralElement;
  final VoidCallback onTap;
  final bool enabled;

  const StructuralElementCard({
    super.key,
    required this.structuralElement,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemCard<StructuralElement>(
      item: structuralElement,
      onTap: onTap,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      imageType: ImageType.svg,
      primaryColor: AppColors.primary,
    );
  }
}

/// GridBuilder específico para elementos estructurales
class StructuralElementGridBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Widget Function(T element, int index) itemBuilder;
  final VoidCallback? onRetry;
  final Widget? header;

  const StructuralElementGridBuilder({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    this.onRetry,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridBuilder<T>(
      asyncValue: asyncValue,
      itemBuilder: itemBuilder,
      moduleConfig: GenericModuleConfig.structuralModuleConfig,
      loadingText: 'Cargando elementos estructurales...',
      emptyText: 'No hay elementos estructurales disponibles',
      errorText: 'Error al cargar elementos estructurales',
      onRetry: onRetry,
      header: header,
    );
  }
}

/// Factory method para mostrar elementos estructurales no disponibles
void showStructuralElementNotAvailable(
    BuildContext context, {
      required String elementName,
      String? customMessage,
      VoidCallback? onContactSupport,
    }) {
  context.showFeatureDisabledDialog(
    title: '$elementName no disponible',
    message: customMessage ??
        'Este elemento estructural está en desarrollo y estará disponible próximamente.',
    featureType: FeatureType.structural,
    onContactSupport: onContactSupport,
  );
}

/// Widget de debug para mostrar información del elemento seleccionado
class SelectedStructuralElementInfo extends ConsumerWidget {
  const SelectedStructuralElementInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedElement = ref.watch(selectedStructuralElementProvider);
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

    // Debug widget para mostrar el estado actual
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
          Text(
            'DEBUG INFO:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text('Elemento seleccionado: ${selectedElement?.name ?? 'Ninguno'}'),
          Text('ID del elemento: ${selectedElement?.id ?? 'N/A'}'),
          Text('Tipo en provider: $tipoElemento'),
          const SizedBox(height: 8),
          if (selectedElement != null)
            ElevatedButton(
              onPressed: () {
                print('🔍 Estado actual del provider:');
                print('- Elemento: ${selectedElement.name}');
                print('- ID: ${selectedElement.id}');
                print('- Tipo en provider: $tipoElemento');
              },
              child: const Text('Debug Print'),
            ),
        ],
      ),
    );
  }
}