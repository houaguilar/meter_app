// lib/presentation/screens/home/acero/viga/result/result_steel_beam_screen.dart - VERSIÓN MEJORADA
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/acero/steel_constants.dart';
import '../../../../../assets/icons.dart';
import '../../../../../providers/home/acero/viga/steel_beam_providers.dart';

class ResultSteelBeamScreen extends ConsumerStatefulWidget {
  const ResultSteelBeamScreen({super.key});

  @override
  ConsumerState<ResultSteelBeamScreen> createState() => _ResultSteelBeamScreenState();
}

class _ResultSteelBeamScreenState extends ConsumerState<ResultSteelBeamScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _hideLoaderAfterDelay();
    _validateDataOnInit();
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

  void _hideLoaderAfterDelay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.hideLoader();
        }
      });
    });
  }

  void _validateDataOnInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final beams = ref.read(steelBeamResultProvider);
      final consolidatedResult = ref.read(calculateConsolidatedSteelProvider);

      print('🔍 Estado en ResultSteelBeamScreen:');
      print('- Vigas: ${beams.length}');
      print('- Resultado consolidado: ${consolidatedResult != null}');

      if (beams.isEmpty || consolidatedResult == null) {
        print('❌ No hay datos válidos, regresando...');
        _showErrorMessage('No hay datos para mostrar. Vuelve a intentar.');
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de Acero'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: _shareResults,
            icon: const Icon(Icons.share),
            tooltip: 'Compartir resultados',
          ),
          IconButton(
            onPressed: _generatePDF,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generar PDF',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('steel-beam'),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'Calcular Más Vigas',
          style: TextStyle(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final consolidatedResult = ref.watch(calculateConsolidatedSteelProvider);
    final beams = ref.watch(steelBeamResultProvider);
    final quickStats = ref.watch(quickStatsProvider);

    if (consolidatedResult == null || beams.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con resumen ejecutivo
          _buildExecutiveSummary(quickStats),
          const SizedBox(height: 20),

          // Materiales consolidados
          _buildConsolidatedMaterials(consolidatedResult),
          const SizedBox(height: 20),

          // Detalle por viga (expandible)
          _buildBeamDetails(consolidatedResult),
          const SizedBox(height: 20),

          // Gráfico de distribución (opcional)
          _buildDistributionChart(consolidatedResult),
          const SizedBox(height: 100), // Espacio para FAB
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay resultados disponibles',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configura al menos una viga para ver los resultados',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed('steel-beam-data'),
            icon: const Icon(Icons.add),
            label: const Text('Configurar Vigas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummary(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.summarize,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen Ejecutivo',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stats['totalBeams']} ${stats['totalBeams'] == 1 ? 'viga calculada' : 'vigas calculadas'}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Métricas principales
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Peso Total',
                  '${(stats['totalWeight'] as double).toStringAsFixed(2)} kg',
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Alambre #16',
                  '${(stats['totalWire'] as double).toStringAsFixed(2)} kg',
                  Icons.cable,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Estribos',
                  '${stats['totalStirrups']}',
                  Icons.donut_large,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Elementos',
                  '${stats['totalBeams']} vigas',
                  Icons.view_in_ar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsolidatedMaterials(ConsolidatedSteelResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lista de Materiales Consolidada',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Materiales totales para todas las vigas',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabla de materiales
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Material',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Cantidad',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Unidad',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filas de materiales
                ...result.consolidatedMaterials.entries.map((entry) {
                  return _buildMaterialRow(
                    'Acero de ${entry.key}',
                    entry.value.quantity.toStringAsFixed(0),
                    entry.value.unit,
                  );
                }),

                // Alambre
                _buildMaterialRow(
                  'Alambre #16',
                  result.totalWire.toStringAsFixed(2),
                  'kg',
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(String material, String quantity, String unit, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.warning.withOpacity(0.1) : null,
        border: const Border(
          bottom: BorderSide(color: AppColors.neutral200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              material,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isHighlighted ? FontWeight.w600 : null,
                color: isHighlighted ? AppColors.warning : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              quantity,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isHighlighted ? AppColors.warning : AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              unit,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeamDetails(ConsolidatedSteelResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.view_list,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Detalle por Viga',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de vigas
          ...result.beamResults.asMap().entries.map((entry) {
            final index = entry.key;
            final beam = entry.value;
            return _buildBeamDetailCard(beam, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildBeamDetailCard(SteelCalculationResult beam, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beam.description,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${beam.totalWeight.toStringAsFixed(2)} kg • ${beam.totalStirrups} estribos',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Materiales de esta viga
          Row(
            children: [
              ...beam.materials.entries.take(3).map((entry) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.neutral300),
                    ),
                    child: Column(
                      children: [
                        Text(
                          entry.key,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${entry.value.quantity.toStringAsFixed(0)}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (beam.materials.length > 3)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${beam.materials.length - 3}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(ConsolidatedSteelResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Distribución de Acero por Diámetro',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico simple de barras horizontales
          ...result.consolidatedMaterials.entries.map((entry) {
            final maxQuantity = result.consolidatedMaterials.values
                .map((v) => v.quantity)
                .reduce((a, b) => a > b ? a : b);
            final percentage = (entry.value.quantity / maxQuantity);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Acero ${entry.key}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${entry.value.quantity.toStringAsFixed(0)} ${entry.value.unit}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: percentage,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getColorForDiameter(entry.key),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getColorForDiameter(String diameter) {
    // Asignar colores diferentes según el diámetro
    switch (diameter) {
      case '6mm':
      case '1/4"':
        return AppColors.info;
      case '8mm':
      case '3/8"':
        return AppColors.warning;
      case '12mm':
      case '1/2"':
        return AppColors.primary;
      case '5/8"':
        return AppColors.secondary;
      case '3/4"':
        return AppColors.success;
      case '1"':
        return AppColors.error;
      default:
        return AppColors.neutral400;
    }
  }

  void _shareResults() {
    final summaryText = ref.read(consolidatedSummaryProvider);
    Share.share(
      summaryText,
      subject: 'Resultados de Cálculo de Acero en Vigas',
    );
  }

  void _generatePDF() {
    // TODO: Implementar generación de PDF
    _showSuccessMessage('Función de PDF en desarrollo');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}