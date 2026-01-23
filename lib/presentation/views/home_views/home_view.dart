import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/assets/app_images.dart';
import 'package:meter_app/presentation/widgets/bottom_sheet/measurements_bottom_sheet.dart';
import 'package:meter_app/presentation/widgets/cards/shortcut_card.dart';
import 'package:meter_app/presentation/widgets/carousels/carousel_cards_articles.dart';

import '../../../config/theme/theme.dart';
import '../../../domain/entities/entities.dart';
import '../../blocs/home/inicio/measurement_bloc.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<Measurement>? _cachedMeasurements;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Inicializar después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _clearAllProviders();

        if (!_isInitialized) {
          _initializeData();
        }
      }
    });
  }

  void _clearAllProviders() {
    try {
      // Limpiar providers de resultados de cálculos
      ref.read(ladrilloResultProvider.notifier).clearList();
      ref.read(falsoPisoResultProvider.notifier).clearList();
      ref.read(contrapisoResultProvider.notifier).clearList();
      ref.read(tarrajeoResultProvider.notifier).clearList();
      ref.read(losaResultProvider.notifier).clearList();
      ref.read(columnaResultProvider.notifier).clearList();
      ref.read(vigaResultProvider.notifier).clearList();

      print('DEBUG: Providers limpiados al navegar al home');
    } catch (e) {
      print('ERROR al limpiar providers: $e');
    }
  }

  void _initializeData() {
    _isInitialized = true;
    final bloc = context.read<MeasurementBloc>();

    // Solo cargar si no hay datos
    if (bloc.state is! MeasurementLoaded) {
      bloc.add(LoadMeasurementItems());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Usa el color primario de tu tema automáticamente
        statusBarColor: AppColors.blueMetraShop,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: BlocConsumer<MeasurementBloc, MeasurementState>(
          listener: (context, state) {
            if (state is MeasurementLoaded) {
              _cachedMeasurements = state.items;
            }
          },
          builder: (context, state) {
            // No usar AnimatedSwitcher aquí para evitar problemas
            if (state is MeasurementLoading && _cachedMeasurements == null) {
              return _buildLoadingState();
            } else if (state is MeasurementError && _cachedMeasurements == null) {
              return _buildErrorState(state.message);
            } else {
              // Usar datos en cache o del estado actual
              final items = state is MeasurementLoaded
                  ? state.items
                  : _cachedMeasurements ?? [];
              return _buildLoadedState(items);
            }
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryMetraShop,
      elevation: 0,
      centerTitle: true,
      title: RichText(
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
      ),
    );
  }

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
              onPressed: () {
                context.read<MeasurementBloc>().add(LoadMeasurementItems());
              },
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

  Widget _buildLoadedState(List<Measurement> items) {
    return RefreshIndicator(
      color: AppColors.blueMetraShop,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            _buildMeasurementsSection(items),
            const SizedBox(height: 28),
            _buildInterestSection(),
            const SizedBox(height: 32),
            _buildKnowledgeSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsSection(List<Measurement> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('¿Qué medición deseas hacer?'),
        const SizedBox(height: 20),
        if (items.isNotEmpty) ...[
          MeasurementSection(items: items.take(3).toList()),
          if (items.length > 3)
            Center(
              child: TextButton(
                onPressed: () => showMeasurementsSheet(context, items),
                child: const Text(
                  'Ver más',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ] else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay mediciones disponibles',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mapa de proveedores'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => FeatureStatusDialog.showTemporarilyDisabled(context),
            //      onTap: () => context.pushNamed('home-to-provider'),
                  child: const ShortcutCard(
                    title: 'Proveedores',
                    imageAssetPath: AppImages.proveedoresHomeCardImg,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Expande tus conocimientos'),
        const SizedBox(height: 20),
        const CarouselCardsArticles(),
      ],
    );
  }

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

  Future<void> _handleRefresh() async {
    context.read<MeasurementBloc>().add(LoadMeasurementItems());
    await Future.delayed(const Duration(milliseconds: 500));
  }
}