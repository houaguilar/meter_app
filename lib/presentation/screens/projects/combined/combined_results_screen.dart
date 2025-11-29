
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/services/shared/UnifiedResultsCombiner.dart';
import '../../../blocs/profile/profile_bloc.dart';
import '../../../blocs/projects/metrados/combined_results/combined_results_bloc.dart';
import 'widgets/material_card.dart';
import 'widgets/material_detail_dialog.dart';
import 'widgets/material_helpers.dart';
import 'widgets/share_options_modal.dart';
import 'widgets/stats_header.dart';

class CombinedResultsScreen extends StatefulWidget {
  final int projectId;
  final List<int> selectedMetradoIds;
  final String projectName;

  const CombinedResultsScreen({
    super.key,
    required this.projectId,
    required this.selectedMetradoIds,
    required this.projectName,
  });

  @override
  State<CombinedResultsScreen> createState() => _CombinedResultsScreenState();
}

class _CombinedResultsScreenState extends State<CombinedResultsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCombinedResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  void _loadCombinedResults() {
    context.read<CombinedResultsBloc>().add(
      LoadCombinedResultsEvent(
        projectId: widget.projectId,
        selectedMetradoIds: widget.selectedMetradoIds,
        projectName: widget.projectName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultados Unificados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${widget.selectedMetradoIds.length} metrados combinados',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
        tooltip: 'Volver',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<CombinedResultsBloc>().add(RefreshCombinedResultsEvent());
          },
          tooltip: 'Actualizar',
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showInfoDialog,
          tooltip: 'Información',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocConsumer<CombinedResultsBloc, CombinedResultsState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        if (state is CombinedResultsLoading) {
          return _buildLoadingState();
        } else if (state is CombinedResultsSuccess) {
          return _buildSuccessState(state);
        } else if (state is CombinedResultsError) {
          return _buildErrorState(state.message);
        }

        return _buildInitialState();
      },
    );
  }

  void _handleStateChanges(BuildContext context, CombinedResultsState state) {
    if (state is CombinedResultsSuccess) {
      if (state.message != null) {
        _showSuccessSnackBar(state.message!);
      }
      if (state.error != null) {
        _showErrorSnackBar(state.error!);
      }
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Combinando resultados...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Procesando ${widget.selectedMetradoIds.length} metrados',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(CombinedResultsSuccess state) {
    final result = state.combinedResult;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            // Header con estadísticas generales
            SliverToBoxAdapter(
              child: StatsHeader(result: result),
            ),

            // Título de materiales unificados
            SliverToBoxAdapter(
              child: _buildMaterialsHeader(result),
            ),

            // Lista de materiales combinados/sumados
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final material = result.sortedMaterials[index];
                  return MaterialCard(
                    material: material,
                    index: index,
                    onTap: () => _showMaterialDetailDialog(material),
                  );
                },
                childCount: result.sortedMaterials.length,
              ),
            ),

            // Espaciado para bottom navigation
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsHeader(CombinedCalculationResult result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: AppColors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Materiales Combinados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${result.combinedMaterials.length} tipos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Error al combinar resultados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadCombinedResults,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.merge_type,
            size: 64,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'Preparando combinación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Iniciando proceso de unificación...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return BlocBuilder<CombinedResultsBloc, CombinedResultsState>(
      builder: (context, state) {
        if (state is! CombinedResultsSuccess) {
          return const SizedBox.shrink(); // Retorna widget vacío en lugar de null
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isProcessing ? null : () => _showShareOptions(),
                  icon: state.isSharing
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.share_outlined),
                  label: Text(state.isSharing ? 'Compartiendo...' : 'Compartir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.isProcessing ? null : () => _showDetailedMaterialsDialog(state.combinedResult),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver Detalle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIÁLOGOS Y MODALES
  // ═══════════════════════════════════════════════════════════════════════════

  void _showMaterialDetailDialog(CombinedMaterial material) {
    showDialog(
      context: context,
      builder: (context) => MaterialDetailDialog(material: material),
    );
  }

  void _showShareOptions() {
    // Obtener nombre del usuario del ProfileBloc
    final profileState = context.read<ProfileBloc>().state;
    final nombreUsuario = profileState is ProfileLoaded
        ? profileState.userProfile.name
        : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ShareOptionsModal(
        onFormatSelected: (format) {
          context.read<CombinedResultsBloc>().add(
            ShareCombinedResultsEvent(
              format: format,
              nombreUsuario: nombreUsuario,
            ),
          );
        },
      ),
    );
  }

  void _showDetailedMaterialsDialog(CombinedCalculationResult result) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Resumen Detallado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: result.sortedMaterials.length,
                  itemBuilder: (context, index) {
                    final material = result.sortedMaterials[index];
                    return ListTile(
                      leading: Icon(
                        MaterialHelpers.getMaterialIcon(material.name),
                        color: MaterialHelpers.getMaterialColor(material.name),
                      ),
                      title: Text(material.name),
                      subtitle: Text('${material.contributions.length} metrado(s)'),
                      trailing: Text(
                        material.formattedQuantity,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Unificación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta pantalla muestra la unión de resultados de múltiples metrados seleccionados.',
            ),
            const SizedBox(height: 8),
            const Text('Características:'),
            const SizedBox(height: 4),
            const Text('• Materiales repetidos se SUMAN'),
            const Text('• Materiales únicos se muestran individuales'),
            const Text('• Se preserva el origen de cada material'),
            const Text('• Cálculos sin precios'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para SnackBars
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}