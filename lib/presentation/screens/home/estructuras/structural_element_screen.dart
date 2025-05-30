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

      // Actualizar selección
      ref.read(selectedStructuralElementProvider.notifier).state = element;

      // Determinar navegación basada en disponibilidad
      if (_isStructuralElementAvailable(element.id)) {
        _navigateToAvailableElement(element);
      } else {
        _showStructuralElementNotAvailable(element);
      }
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega a elemento estructural disponible
  void _navigateToAvailableElement(StructuralElement element) {
    try {
      final elementType = _getStructuralElementType(element.id);
      ref.read(tipoStructuralElementProvider.notifier).selectStructuralElement(elementType);
      context.pushNamed('structural-element-datos');
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Muestra dialog para elemento estructural no disponible
  void _showStructuralElementNotAvailable(StructuralElement element) {
    showStructuralElementNotAvailable(
      context,
      elementName: element.name,
      customMessage: _getUnavailableMessage(element),
      onContactSupport: () => _contactSupport(),
    );
  }

  /// Determina si un elemento estructural está disponible
  bool _isStructuralElementAvailable(String elementId) {
    const availableIds = ['1', '2']; // Columna y Viga disponibles
    return availableIds.contains(elementId);
  }

  /// Obtiene el tipo de elemento estructural para el provider
  String _getStructuralElementType(String elementId) {
    switch (elementId) {
      case '1':
        return 'columna';
      case '2':
        return 'viga';
      default:
        return 'columna';
    }
  }

  /// Obtiene mensaje personalizado para elemento no disponible
  String _getUnavailableMessage(StructuralElement element) {
    switch (element.id) {
      case '3': // Zapata (ejemplo)
        return 'Los cálculos para zapatas requieren análisis geotécnico especializado.';
      case '4': // Cimentación (ejemplo)
        return 'Los cálculos de cimentación necesitan estudios de suelo específicos.';
      default:
        return 'Este elemento estructural está en desarrollo y estará disponible próximamente.';
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

  /// Contactar soporte técnico
  void _contactSupport() {
    // Implementar lógica de contacto
    _showErrorMessage('Funcionalidad de soporte próximamente disponible');
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
      enabled: enabled,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      isAvailable: (item) => _isStructuralElementAvailable(item.id),
      imageType: ImageType.svg,
      primaryColor: AppColors.primary,
    );
  }

  bool _isStructuralElementAvailable(String id) {
    const availableIds = ['1', '2']; // Columna y Viga disponibles
    return availableIds.contains(id);
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

/// Extensión específica para StructuralElement que proporciona información para la UI
extension StructuralElementUI on StructuralElement {
  /// Determina si el elemento estructural está disponible
  bool get isAvailable {
    const availableIds = ['1', '2']; // Columna y Viga
    return availableIds.contains(id);
  }

  /// Obtiene el color asociado al elemento
  Color get primaryColor {
    if (isAvailable) {
      return AppColors.primary;
    } else {
      return AppColors.warning;
    }
  }

  /// Obtiene la categoría del elemento estructural
  StructuralElementCategory get category {
    switch (id) {
      case '1':
        return StructuralElementCategory.columna;
      case '2':
        return StructuralElementCategory.viga;
      case '3':
        return StructuralElementCategory.zapata;
      case '4':
        return StructuralElementCategory.cimentacion;
      default:
        return StructuralElementCategory.unknown;
    }
  }

  /// Obtiene el estado de disponibilidad como texto
  String get availabilityStatus {
    return isAvailable ? 'Disponible' : 'Próximamente';
  }

  /// Obtiene la complejidad de cálculo
  CalculationComplexity get calculationComplexity {
    switch (category) {
      case StructuralElementCategory.columna:
      case StructuralElementCategory.viga:
        return CalculationComplexity.medium;
      case StructuralElementCategory.zapata:
      case StructuralElementCategory.cimentacion:
        return CalculationComplexity.high;
      case StructuralElementCategory.unknown:
        return CalculationComplexity.unknown;
    }
  }

  /// Obtiene información detallada del elemento
  StructuralElementInfo get detailedInfo {
    return StructuralElementInfo(
      id: id,
      name: name,
      category: category,
      isAvailable: isAvailable,
      primaryColor: primaryColor,
      description: _getDetailedDescription(),
      technicalSpecs: _getTechnicalSpecs(),
      complexity: calculationComplexity,
    );
  }

  String _getDetailedDescription() {
    switch (category) {
      case StructuralElementCategory.columna:
        return 'Elementos verticales que transmiten cargas de compresión a la cimentación.';
      case StructuralElementCategory.viga:
        return 'Elementos horizontales que soportan cargas transversales.';
      case StructuralElementCategory.zapata:
        return 'Elementos de cimentación superficial para transmitir cargas al suelo.';
      case StructuralElementCategory.cimentacion:
        return 'Sistema de elementos que transmiten las cargas de la estructura al terreno.';
      case StructuralElementCategory.unknown:
        return 'Elemento estructural especializado.';
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

/// Enum para categorías de elementos estructurales
enum StructuralElementCategory {
  columna,
  viga,
  zapata,
  cimentacion,
  unknown;

  String get displayName {
    switch (this) {
      case StructuralElementCategory.columna:
        return 'Columna';
      case StructuralElementCategory.viga:
        return 'Viga';
      case StructuralElementCategory.zapata:
        return 'Zapata';
      case StructuralElementCategory.cimentacion:
        return 'Cimentación';
      case StructuralElementCategory.unknown:
        return 'Desconocido';
    }
  }

  IconData get icon {
    switch (this) {
      case StructuralElementCategory.columna:
        return Icons.view_column;
      case StructuralElementCategory.viga:
        return Icons.horizontal_rule;
      case StructuralElementCategory.zapata:
        return Icons.foundation;
      case StructuralElementCategory.cimentacion:
        return Icons.account_balance;
      case StructuralElementCategory.unknown:
        return Icons.help_outline;
    }
  }
}

/// Enum para complejidad de cálculo
enum CalculationComplexity {
  low,
  medium,
  high,
  unknown;

  String get displayName {
    switch (this) {
      case CalculationComplexity.low:
        return 'Básico';
      case CalculationComplexity.medium:
        return 'Intermedio';
      case CalculationComplexity.high:
        return 'Avanzado';
      case CalculationComplexity.unknown:
        return 'No definido';
    }
  }

  Color get color {
    switch (this) {
      case CalculationComplexity.low:
        return AppColors.success;
      case CalculationComplexity.medium:
        return AppColors.warning;
      case CalculationComplexity.high:
        return AppColors.error;
      case CalculationComplexity.unknown:
        return AppColors.neutral400;
    }
  }

  IconData get icon {
    switch (this) {
      case CalculationComplexity.low:
        return Icons.star_border;
      case CalculationComplexity.medium:
        return Icons.star_half;
      case CalculationComplexity.high:
        return Icons.star;
      case CalculationComplexity.unknown:
        return Icons.help_outline;
    }
  }
}

/// Clase de información detallada del elemento estructural
class StructuralElementInfo {
  final String id;
  final String name;
  final StructuralElementCategory category;
  final bool isAvailable;
  final Color primaryColor;
  final String description;
  final List<String> technicalSpecs;
  final CalculationComplexity complexity;

  const StructuralElementInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.isAvailable,
    required this.primaryColor,
    required this.description,
    required this.technicalSpecs,
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
      'complexity': complexity.displayName,
    };
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

/// Widget de ejemplo para mostrar información del elemento seleccionado
class SelectedStructuralElementInfo extends ConsumerWidget {
  const SelectedStructuralElementInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedElement = ref.watch(selectedStructuralElementProvider);

    if (selectedElement == null) {
      return const SizedBox.shrink();
    }

    final info = selectedElement.detailedInfo;

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
                  'Elemento seleccionado: ${info.name}',
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
                info.complexity.icon,
                color: info.complexity.color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Complejidad: ${info.complexity.displayName}',
                style: TextStyle(
                  fontSize: 12,
                  color: info.complexity.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}