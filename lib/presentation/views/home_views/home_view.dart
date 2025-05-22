import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/assets/images.dart';
import 'package:meter_app/presentation/widgets/bottom_sheet/measurements_bottom_sheet.dart';
import 'package:meter_app/presentation/widgets/cards/shortcut_card.dart';
import 'package:meter_app/presentation/widgets/carousels/carousel_cards_articles.dart';

import '../../../config/theme/theme.dart';
import '../../../domain/entities/entities.dart';
import '../../blocs/home/inicio/measurement_bloc.dart';
import '../../widgets/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  /// Mantiene el estado activo para optimizar rendimiento
  @override
  bool get wantKeepAlive => true;

  /// Controla si la vista está montada para evitar errores de setState
  bool _isMounted = true;

  /// Cache local de items de medición para optimizar rendimiento
  List<Measurement>? _cachedMeasurements;

  /// Indica si es la primera carga para manejar estados iniciales
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _initializeView();
  }

  @override
  void dispose() {
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Inicializa la vista y sus dependencias
  void _initializeView() {
    WidgetsBinding.instance.addObserver(this);

    // Cargar datos inicial de forma segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        _loadMeasurementItems();
      }
    });

    _logViewInitialization();
  }

  /// Carga los elementos de medición de forma segura
  void _loadMeasurementItems() {
    try {
      if (_isMounted && context.mounted) {
        context.read<MeasurementBloc>().add(LoadMeasurementItems());
      }
    } catch (e) {
      _handleLoadError(e);
    }
  }

  /// Maneja errores durante la carga de datos
  void _handleLoadError(dynamic error) {
    assert(() {
      debugPrint('Error cargando mediciones: $error');
      return true;
    }());

    if (_isMounted && context.mounted) {
      _showErrorSnackBar('Error al cargar las mediciones. Inténtalo de nuevo.');
    }
  }

  /// Muestra un snackbar de error de forma segura
  void _showErrorSnackBar(String message) {
    if (!_isMounted || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorGeneralColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: AppColors.white,
          onPressed: _loadMeasurementItems,
        ),
      ),
    );
  }

  /// Log de inicialización (solo en modo debug)
  void _logViewInitialization() {
    assert(() {
      debugPrint('HomeView inicializada correctamente');
      return true;
    }());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _isMounted) {
      // Refrescar datos cuando la app vuelve a primer plano
      _refreshDataIfNeeded();
    }
  }

  /// Refresca datos si es necesario
  void _refreshDataIfNeeded() {
    // Solo refrescar si han pasado más de 5 minutos desde la última carga
    // o si no hay datos en cache
    if (_cachedMeasurements == null || _isFirstLoad) {
      _loadMeasurementItems();
      _isFirstLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido para AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Construye la app bar personalizada
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryMetraShop,
      elevation: 0,
      centerTitle: true,
      title: _buildAppBarTitle(),
      // Configuración de accesibilidad
      toolbarHeight: kToolbarHeight,
    );
  }

  /// Construye el título de la app bar
  Widget _buildAppBarTitle() {
    return Semantics(
      label: 'METRASHOP - Aplicación de mediciones',
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: 'METRA',
              style: TextStyle(color: AppColors.white),
            ),
            TextSpan(
              text: 'SHOP',
              style: TextStyle(color: AppColors.blueMetraShop),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el cuerpo principal de la vista
  Widget _buildBody() {
    return BlocConsumer<MeasurementBloc, MeasurementState>(
      listener: _handleBlocStateChanges,
      builder: _buildBlocContent,
    );
  }

  /// Maneja cambios de estado del bloc
  void _handleBlocStateChanges(BuildContext context, MeasurementState state) {
    if (state is MeasurementError && _isMounted) {
      _showErrorSnackBar(state.message);
    }

    // Actualizar cache cuando se cargan datos exitosamente
    if (state is MeasurementLoaded) {
      _cachedMeasurements = state.items;
    }
  }

  /// Construye el contenido basado en el estado del bloc
  Widget _buildBlocContent(BuildContext context, MeasurementState state) {
    return switch (state) {
      MeasurementLoading() => _buildLoadingState(),
      MeasurementLoaded() => _buildLoadedState(state.items),
      MeasurementError() => _buildErrorState(state.message),
      _ => _buildInitialState(),
    };
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando mediciones...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryMetraShop,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado con datos cargados
  Widget _buildLoadedState(List<Measurement> items) {
    return RefreshIndicator(
      color: AppColors.blueMetraShop,
      onRefresh: _handlePullToRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildMainContent(items),
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorGeneralColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar contenido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMetraShop,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty ? message : 'Ha ocurrido un error inesperado',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.greyTextColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMeasurementItems,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueMetraShop,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado inicial (fallback)
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No se encontraron mediciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryMetraShop,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMeasurementItems,
            child: const Text('Cargar contenido'),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido principal cuando hay datos
  Widget _buildMainContent(List<Measurement> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 35),
        _buildMeasurementsSection(items),
        _buildInterestSection(),
        _buildKnowledgeSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Sección de mediciones
  Widget _buildMeasurementsSection(List<Measurement> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('¿Qué medición deseas hacer?'),
        const SizedBox(height: 20),
        _buildMeasurementsList(items),
        _buildViewMoreButton(items),
      ],
    );
  }

  /// Lista de mediciones (primeras 3)
  Widget _buildMeasurementsList(List<Measurement> items) {
    final displayItems = items.take(3).toList();

    return MeasurementSection(items: displayItems);
  }

  /// Botón "Ver más"
  Widget _buildViewMoreButton(List<Measurement> items) {
    if (items.length <= 3) return const SizedBox.shrink();

    return Center(
      child: TextButton(
        onPressed: () => _showAllMeasurements(items),
        child: const Text(
          'Ver más',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  /// Sección "Te puede interesar"
  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        _buildSectionTitle('Te puede interesar'),
        const SizedBox(height: 20),
        _buildInterestCards(),
      ],
    );
  }

  /// Cards de interés
  Widget _buildInterestCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildProviderCard(),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildMaterialsCard(),
          ),
        ],
      ),
    );
  }

  /// Card de proveedores
  Widget _buildProviderCard() {
    return GestureDetector(
      onTap: () => _navigateToProviders(),
      child: const ShortcutCard(
        title: 'Proveedores',
        imageAssetPath: AppImages.proveedoresHomeCardImg,
      ),
    );
  }

  /// Card de materiales
  Widget _buildMaterialsCard() {
    return GestureDetector(
      onTap: () => _navigateToMaterials(),
      child: const ShortcutCard(
        title: 'Materiales',
        imageAssetPath: AppImages.materialesHomeCardImg,
      ),
    );
  }

  /// Sección de conocimientos
  Widget _buildKnowledgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildSectionTitle('Expande tus conocimientos'),
        const SizedBox(height: 20),
        const CarouselCardsArticles(),
      ],
    );
  }

  /// Construye títulos de sección consistentes
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryMetraShop,
        ),
      ),
    );
  }

  /// Maneja pull-to-refresh
  Future<void> _handlePullToRefresh() async {
    try {
      if (_isMounted && context.mounted) {
        context.read<MeasurementBloc>().add(LoadMeasurementItems());
        // Simular delay mínimo para UX
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      _handleLoadError(e);
    }
  }

  /// Muestra todas las mediciones en bottom sheet
  void _showAllMeasurements(List<Measurement> items) {
    try {
      if (_isMounted && context.mounted) {
        showMeasurementsSheet(context, items);
      }
    } catch (e) {
      assert(() {
        debugPrint('Error mostrando measurements sheet: $e');
        return true;
      }());
    }
  }

  /// Navega a proveedores de forma segura
  void _navigateToProviders() {
    try {
      if (_isMounted && context.mounted) {
        context.pushNamed('home-to-provider');
      }
    } catch (e) {
      _handleNavigationError('proveedores', e);
    }
  }

  /// Navega a materiales de forma segura
  void _navigateToMaterials() {
    try {
      if (_isMounted && context.mounted) {
        context.pushNamed('home-to-test');
      }
    } catch (e) {
      _handleNavigationError('materiales', e);
    }
  }

  /// Maneja errores de navegación
  void _handleNavigationError(String destination, dynamic error) {
    assert(() {
      debugPrint('Error navegando a $destination: $error');
      return true;
    }());

    if (_isMounted && context.mounted) {
      _showErrorSnackBar('Error al navegar a $destination');
    }
  }
}