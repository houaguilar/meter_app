// lib/presentation/screens/home/acero/steel_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/home/acero/steel_element.dart';
import 'package:meter_app/presentation/widgets/shared/responsive_grid_builder.dart';

import '../../../../config/theme/theme.dart';
import '../../../providers/home/acero/steel_element_providers.dart';
import '../../../widgets/cards/generic_item_card.dart';
import '../../../widgets/config/generic_module_config.dart';
import '../../../widgets/widgets.dart';

class SteelMainScreen extends ConsumerStatefulWidget {
  const SteelMainScreen({super.key});

  @override
  ConsumerState<SteelMainScreen> createState() => _SteelMainScreenState();
}

class _SteelMainScreenState extends ConsumerState<SteelMainScreen>
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
    ref.watch(steelElementsProvider);

    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Acero'),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SteelGridBuilder<SteelElement>(
      asyncValue: ref.watch(steelElementsProvider as ProviderListenable<AsyncValue<List<SteelElement>>>),
      itemBuilder: _buildSteelCard,
      onRetry: () => ref.invalidate(steelElementsProvider),
      header: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return ResponsiveHeader(
      title: 'Selecciona el tipo de elemento de acero',
      subtitle: 'Elige el elemento estructural para calcular los materiales de acero necesarios.',
      headerSize: HeaderSize.h2,
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
    );
  }

  Widget _buildSteelCard(SteelElement steel, int index) {
    return SteelCard(
      steel: steel,
      onTap: () => _navigateToSteelElement(context, steel),
      enabled: true,
    );
  }

  void _navigateToSteelElement(BuildContext context, dynamic element) {
    switch (element.id) {
      case '1': // Acero en Viga
        context.pushNamed('steel-beam');
        break;
      case '2': // Acero en Columna
      // Implementar más adelante
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Próximamente: Acero en Columna')),
        );
        break;
      case '3': // Acero en Zapata
      // Implementar más adelante
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Próximamente: Acero en Zapata')),
        );
        break;
    }
  }

}
