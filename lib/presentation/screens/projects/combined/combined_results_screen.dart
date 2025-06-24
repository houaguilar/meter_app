
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/services/shared/UnifiedResultsCombiner.dart';
import '../../../blocs/projects/metrados/combined_results/combined_results_bloc.dart';

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
      title: const Text(
        'Resultados Combinados',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
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
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
          const SizedBox(height: 24),
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<CombinedResultsBloc>().add(RefreshCombinedResultsEvent());
          },
          color: AppColors.secondary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectSummaryCard(state.combinedResult),
                const SizedBox(height: 16),
                _buildMaterialsOverviewCard(state.combinedResult),
                const SizedBox(height: 16),
                _buildMetradosBreakdownCard(state.combinedResult),
                const SizedBox(height: 16),
                _buildStatsCard(state.combinedResult),
                const SizedBox(height: 80), // Espacio para bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectSummaryCard(CombinedCalculationResult result) {
    return _buildModernCard(
      title: 'Resumen del Proyecto',
      icon: Icons.summarize_outlined,
      iconColor: AppColors.secondary,
      child: Column(
        children: [
          _buildSummaryRow('Proyecto', result.projectName),
          const SizedBox(height: 12),
          _buildSummaryRow('Metrados Combinados', '${result.metradoCount}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Área Total', '${result.totalArea.toStringAsFixed(2)} m²'),
          const SizedBox(height: 12),
          _buildSummaryRow('Costo Estimado', 'S/. ${result.totalCost.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Costo por m²', 'S/. ${result.stats.averageCostPerM2.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Fecha de Combinación', _formatDate(result.combinationDate)),
        ],
      ),
    );
  }

  Widget _buildMaterialsOverviewCard(CombinedCalculationResult result) {
    final sortedMaterials = result.sortedMaterials;

    return _buildModernCard(
      title: 'Resumen de Materiales',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.success,
      action: TextButton.icon(
        onPressed: () => _showDetailedMaterialsDialog(result),
        icon: const Icon(Icons.visibility, size: 16),
        label: const Text('Ver Detalle'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de Materiales',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${result.combinedMaterials.length} tipos diferentes',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sortedMaterials.take(5).map((material) =>
              _buildMaterialRow(material, result.metradoSummaries),
          ),
          if (sortedMaterials.length > 5) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showDetailedMaterialsDialog(result),
              child: Text('Ver ${sortedMaterials.length - 5} materiales más'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetradosBreakdownCard(CombinedCalculationResult result) {
    return _buildModernCard(
      title: 'Desglose por Metrado',
      icon: Icons.view_list_outlined,
      iconColor: AppColors.accent,
      child: Column(
        children: result.metradoSummaries.map((summary) =>
            _buildMetradoSummaryRow(summary),
        ).toList(),
      ),
    );
  }

  Widget _buildStatsCard(CombinedCalculationResult result) {
    final stats = result.stats;

    return _buildModernCard(
      title: 'Estadísticas',
      icon: Icons.analytics_outlined,
      iconColor: AppColors.info,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Metrados',
                  '${stats.totalMetrados}',
                  Icons.assessment_outlined,
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Materiales',
                  '${stats.totalMaterials}',
                  Icons.inventory_outlined,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Área Total',
                  '${stats.totalArea.toStringAsFixed(1)} m²',
                  Icons.square_foot_outlined,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Costo Total',
                  'S/. ${stats.totalCost.toStringAsFixed(0)}',
                  Icons.attach_money_outlined,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
                if (action != null) action,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialRow(CombinedMaterial material, List<MetradoSummary> summaries) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMaterialColor(material.name).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getMaterialIcon(material.name),
              color: _getMaterialColor(material.name),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Principal: ${material.topContributor}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${material.totalQuantity.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                material.unit,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetradoSummaryRow(MetradoSummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment_outlined,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.metradoName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.itemCount} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: summary.resultTypes.map((type) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Área: ${summary.area.toStringAsFixed(2)} m²',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Costo: S/. ${summary.cost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
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
                    onPressed: state.isProcessing ? null : () => _generatePdf(),
                    icon: state.isGeneratingPdf
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(state.isGeneratingPdf ? 'Generando...' : 'PDF'),
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
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS DE ACCIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _generatePdf() {
    context.read<CombinedResultsBloc>().add(GenerateCombinedPdfEvent());
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildShareBottomSheet(),
    );
  }

  Widget _buildShareBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Compartir Resultados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige el formato para compartir los resultados combinados',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  context.read<CombinedResultsBloc>().add(
                    ShareCombinedResultsEvent(format: ShareFormat.pdf),
                  );
                },
              ),
              _buildShareOption(
                icon: Icons.table_chart,
                label: 'Excel',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(context);
                  context.read<CombinedResultsBloc>().add(
                    ShareCombinedResultsEvent(format: ShareFormat.excel),
                  );
                },
              ),
              _buildShareOption(
                icon: Icons.text_snippet,
                label: 'Texto',
                color: AppColors.secondary,
                onTap: () {
                  Navigator.pop(context);
                  context.read<CombinedResultsBloc>().add(
                    ShareCombinedResultsEvent(format: ShareFormat.text),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedMaterialsDialog(CombinedCalculationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Detalle de Materiales'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: result.sortedMaterials.length,
            itemBuilder: (context, index) {
              final material = result.sortedMaterials[index];
              return _buildDetailedMaterialItem(material);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMaterialItem(CombinedMaterial material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          _getMaterialIcon(material.name),
          color: _getMaterialColor(material.name),
        ),
        title: Text(
          material.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${material.totalQuantity.toStringAsFixed(2)} ${material.unit}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contribuciones por metrado:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...material.contributions.entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${entry.value.toStringAsFixed(2)} ${material.unit}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' (${material.getContributionPercentage(entry.key).toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.secondary),
            const SizedBox(width: 8),
            const Text('Información'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultados Combinados',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta pantalla muestra la combinación de materiales y costos de múltiples metrados seleccionados.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Características:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildInfoBullet('Suma materiales iguales automáticamente'),
            _buildInfoBullet('Agrega materiales únicos de cada metrado'),
            _buildInfoBullet('Calcula costos totales estimados'),
            _buildInfoBullet('Muestra contribución por metrado'),
            _buildInfoBullet('Genera reportes PDF personalizados'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADOS DE ERROR E INICIAL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'Preparando combinación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES
  // ═══════════════════════════════════════════════════════════════════════════

  Color _getMaterialColor(String materialName) {
    switch (materialName.toLowerCase()) {
      case 'cemento':
        return AppColors.neutral600;
      case 'arena':
        return AppColors.accent;
      case 'agua':
        return AppColors.info;
      case 'ladrillos':
      case 'ladrillo hueco':
      case 'ladrillo sólido':
        return AppColors.error;
      case 'concreto':
        return AppColors.neutral500;
      case 'acero':
        return AppColors.neutral700;
      default:
        return AppColors.secondary;
    }
  }

  IconData _getMaterialIcon(String materialName) {
    switch (materialName.toLowerCase()) {
      case 'cemento':
        return Icons.science_outlined;
      case 'arena':
        return Icons.grain_outlined;
      case 'agua':
        return Icons.water_drop_outlined;
      case 'ladrillos':
      case 'ladrillo hueco':
      case 'ladrillo sólido':
        return Icons.grid_view_rounded;
      case 'concreto':
        return Icons.foundation_outlined;
      case 'acero':
        return Icons.straighten_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SNACKBARS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}