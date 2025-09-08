// lib/presentation/screens/home/acero/viga/result_steel_beam_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
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
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final consolidatedResult = ref.watch(calculateConsolidatedSteelProvider);
    final beams = ref.watch(steelBeamResultProvider);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Resultados de Acero',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              onPressed: _showShareOptions,
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: consolidatedResult == null
            ? _buildEmptyState()
            : FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildResultsContent(consolidatedResult, beams),
          ),
        ),
        bottomNavigationBar: consolidatedResult != null
            ? _buildBottomActions()
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 80,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay resultados disponibles',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Realiza primero el cálculo de acero',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Volver al formulario'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent(dynamic consolidatedResult, List<dynamic> beams) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(consolidatedResult),
          const SizedBox(height: 24),
          _buildBeamBreakdown(consolidatedResult),
          const SizedBox(height: 24),
          _buildMaterialsTable(consolidatedResult),
          const SizedBox(height: 24),
          _buildTechnicalDetails(beams.first), // Mostrar detalles de la primera viga
          const SizedBox(height: 100), // Espacio para el bottom navigation
        ],
      ),
    );
  }

  Widget _buildSummaryCards(dynamic consolidatedResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildSummaryCard(
              'Vigas Calculadas',
              consolidatedResult.numberOfBeams.toString(),
              Icons.view_column,
              AppColors.primary,
            ),
            _buildSummaryCard(
              'Peso Total',
              '${consolidatedResult.totalWeight.toStringAsFixed(1)} kg',
              Icons.scale,
              AppColors.success,
            ),
            _buildSummaryCard(
              'Alambre #16',
              '${consolidatedResult.totalWire.toStringAsFixed(1)} kg',
              Icons.linear_scale,
              AppColors.warning,
            ),
            _buildSummaryCard(
              'Total Estribos',
              consolidatedResult.totalStirrups.toString(),
              Icons.crop_square,
              AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.white, size: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.trending_up, color: AppColors.white, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeamBreakdown(dynamic consolidatedResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desglose por Viga',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: consolidatedResult.beamResults.map<Widget>((result) {
              return _buildBreakdownItem(
                result.description,
                '${result.totalWeight.toStringAsFixed(2)} kg',
                '${result.totalStirrups} estribos',
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String name, String weight, String stirrups) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              weight,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              stirrups,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTable(dynamic consolidatedResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lista de Materiales',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
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
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Cantidad',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
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
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Materiales de acero
              ...consolidatedResult.consolidatedMaterials.entries.map((entry) {
                return _buildTableRow(
                  'Acero de ${entry.key}',
                  entry.value.quantity.toStringAsFixed(1),
                  entry.value.unit,
                );
              }),
              // Alambre
              _buildTableRow(
                'Alambre #16',
                consolidatedResult.totalWire.toStringAsFixed(1),
                'kg',
              ),
              // Total destacado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'PESO TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        consolidatedResult.totalWeight.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'kg',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(String material, String quantity, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.neutral200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              material,
              style: AppTypography.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              quantity,
              style: AppTypography.bodyMedium,
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

  Widget _buildTechnicalDetails(dynamic beam) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles Técnicos',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: [
              _buildDetailRow('Descripción', beam.description),
              _buildDetailRow('Desperdicio', '${(beam.waste * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('Elementos similares', beam.elements.toString()),
              _buildDetailRow('Recubrimiento', '${(beam.cover * 100).toStringAsFixed(1)} cm'),
              _buildDetailRow('Dimensiones', '${beam.height} × ${beam.length} × ${beam.width} m'),
              _buildDetailRow('Usar empalme', beam.useSplice ? 'Sí' : 'No'),
              _buildDetailRow('Diámetro estribos', beam.stirrupDiameter),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleSaveAction,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleProviderAction,
                icon: const Icon(Icons.location_on),
                label: const Text('Proveedores'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartir Resultados',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  color: AppColors.error,
                  onTap: _sharePDF,
                ),
                _buildShareOption(
                  icon: Icons.text_snippet,
                  label: 'Texto',
                  color: AppColors.primary,
                  onTap: _shareText,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveAction() {
    final consolidatedResult = ref.watch(calculateConsolidatedSteelProvider);
    if (consolidatedResult != null) {
      context.pushNamed('save-steel-beam');
    } else {
      _showErrorMessage('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final consolidatedResult = ref.watch(calculateConsolidatedSteelProvider);
    if (consolidatedResult != null) {
      context.pushNamed('map-screen-steel-beam');
    } else {
      _showErrorMessage('No hay datos de acero');
    }
  }

  Future<void> _sharePDF() async {
    try {
      Navigator.of(context).pop();

      context.showCalculationLoader(
        message: 'Generando PDF...',
        description: 'Creando documento con los resultados',
      );

      // Aquí implementarías la generación del PDF específico para acero
      // Similar a PDFFactory.generateStructuralElementPDF pero para acero
      // final pdfFile = await PDFFactory.generateSteelBeamPDF(ref);

      await Future.delayed(const Duration(seconds: 2)); // Simulación

      context.hideLoader();

      // Simulación de compartir
      final shareText = _generateShareText();
      await Share.share(shareText);

    } catch (e) {
      context.hideLoader();
      _showErrorMessage('Error al generar PDF: $e');
    }
  }

  Future<void> _shareText() async {
    try {
      Navigator.of(context).pop();
      final shareText = _generateShareText();
      await Share.share(shareText);
    } catch (e) {
      _showErrorMessage('Error al compartir: $e');
    }
  }

  String _generateShareText() {
    final consolidatedResult = ref.read(calculateConsolidatedSteelProvider);
    if (consolidatedResult == null) return '';

    final shareData = ref.read(datosShareSteelBeamProvider);
    return '''
📊 RESULTADOS DE ACERO EN VIGAS - METRASHOP

$shareData

💡 Generado con METRASHOP
    ''';
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}