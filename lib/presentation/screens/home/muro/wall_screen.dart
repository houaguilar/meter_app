// lib/presentation/screens/home/muro/wall_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/widgets/cards/wall_material_card_improved.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/home/muro/wall_material.dart';
import '../../../providers/home/muro/wall_material_providers_improved.dart';
import '../../../providers/providers.dart';
import '../../../widgets/dialogs/feature_disabled_dialog.dart';
import '../../../widgets/widgets.dart';

class WallScreen extends ConsumerStatefulWidget {
  const WallScreen({super.key});

  static const String routeName = 'muro';

  @override
  ConsumerState<WallScreen> createState() => _MuroScreenState();
}

class _MuroScreenState extends ConsumerState<WallScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  /// Mantiene el estado activo para optimizar rendimiento
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Estados para manejo de errores y loading
  bool _hasError = false;
  String? _errorMessage;

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
      duration: const Duration(milliseconds: 600),
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
      appBar: AppBarWidget(titleAppBar: 'Tipos de Muro'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final materialsAsync = ref.watch(wallMaterialsProvider);

    return materialsAsync.when(
      data: (materials) => _buildMaterialContent(materials),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildMaterialContent(List<WallMaterial> materials) {
    if (materials.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildMaterialGrid(materials),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona el tipo de material',
            style: _getHeaderTextStyle(),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige el material que utilizarás para tu proyecto',
            style: _getSubtitleTextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialGrid(List<WallMaterial> materials) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);
    final padding = _getResponsivePadding();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: _getChildAspectRatio(screenWidth),
          crossAxisSpacing: _getGridSpacing(screenWidth),
          mainAxisSpacing: _getGridSpacing(screenWidth),
        ),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return _buildAnimatedMaterialCard(material, index);
        },
      ),
    );
  }

  Widget _buildAnimatedMaterialCard(WallMaterial material, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(
            opacity: value,
            child: WallMaterialCardImproved(
              material: material,
              onTap: () => _handleMaterialSelection(material),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando materiales...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(_getResponsivePadding()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar materiales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ha ocurrido un problema. Inténtalo de nuevo.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(wallMaterialsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(_getResponsivePadding()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay materiales disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los materiales aparecerán aquí cuando estén disponibles.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Maneja la selección de materiales con validación de disponibilidad
  void _handleMaterialSelection(WallMaterial material) {
    try {
      // Validar entrada
      if (!_isValidMaterial(material)) {
        _showErrorMessage('Material no válido');
        return;
      }

      // Limpiar selecciones previas
      ref.read(selectedMaterialProvider.notifier).state = material;

      switch (material.id) {
        case '1': // Pandereta 1
          _navigateToLadrillo('Pandereta1');
          break;
        case '2': // Pandereta 2
          _navigateToLadrillo('Pandereta2');
          break;
        case '3': // King Kong 18H
          _navigateToLadrillo('Kingkong1');
          break;
        case '4': // King Kong 30%
          _navigateToLadrillo('Kingkong2');
          break;
        case '5': // Tabicón - No disponible
          _showFeatureDisabledDialog('Tabicón');
          break;
        case '6': // Bloque P14 - No disponible
        case '7': // Bloque P10 - No disponible
        case '8': // Bloque P7 - No disponible
          _showFeatureDisabledDialog('Bloquetas');
          break;
        default:
          _showErrorMessage('Material no reconocido');
          _logError('Material ID no reconocido: ${material.id}');
      }
    } catch (e, stackTrace) {
      _handleSelectionError(e, stackTrace);
    }
  }

  /// Navega a la pantalla de datos de ladrillo
  void _navigateToLadrillo(String tipoLadrillo) {
    try {
      ref.read(tipoLadrilloProvider.notifier).selectLadrillo(tipoLadrillo);
      context.pushNamed('ladrillo1');
    } catch (e, stackTrace) {
      _handleNavigationError(e, stackTrace);
    }
  }

  /// Muestra dialog para funciones no disponibles
  void _showFeatureDisabledDialog(String materialType) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FeatureDisabledDialog(
        title: '$materialType no disponible',
        message: 'Esta funcionalidad está en desarrollo y estará disponible próximamente.',
        materialType: materialType,
      ),
    );
  }

  /// Validaciones de seguridad
  bool _isValidMaterial(WallMaterial? material) {
    return material != null &&
        material.id.isNotEmpty &&
        material.name.isNotEmpty;
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
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Sistema de logging para debugging
  void _logError(String message, [StackTrace? stackTrace]) {
    // Solo en modo debug
    assert(() {
      debugPrint('❌ MuroScreen Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      return true;
    }());
  }

  // Métodos para responsive design
  double _getResponsivePadding() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1200) return 24.0;
    return 32.0;
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;  // Móviles
    if (screenWidth < 840) return 3;  // Móviles grandes
    if (screenWidth < 1200) return 4; // Tablets
    return 5; // Desktop
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) return 0.8;  // Móviles - más cuadradas
    return 0.7; // Otros dispositivos
  }

  double _getGridSpacing(double screenWidth) {
    if (screenWidth < 600) return 12.0;
    if (screenWidth < 1200) return 16.0;
    return 20.0;
  }

  TextStyle _getHeaderTextStyle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 18.0 : 20.0;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: AppColors.textPrimary,
    );
  }

  TextStyle _getSubtitleTextStyle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14.0 : 16.0;

    return TextStyle(
      fontSize: fontSize,
      color: AppColors.textSecondary,
    );
  }
}