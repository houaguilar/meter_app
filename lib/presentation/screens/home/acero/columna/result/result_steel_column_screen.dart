import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../providers/home/acero/columna/steel_column_providers.dart';

class ResultSteelColumnScreen extends ConsumerStatefulWidget { // cambio de ResultSteelBeamScreen
  const ResultSteelColumnScreen({super.key});

  @override
  ConsumerState<ResultSteelColumnScreen> createState() => _ResultSteelColumnScreenState(); // cambio de nombre
}

class _ResultSteelColumnScreenState extends ConsumerState<ResultSteelColumnScreen> // cambio de nombre
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
      final columns = ref.read(steelColumnResultProvider); // cambio de steelBeamResultProvider
      final consolidatedResult = ref.read(calculateConsolidatedColumnSteelProvider); // cambio de provider

      print('🔍 Estado en ResultSteelColumnScreen:'); // cambio de texto
      print('- Columnas: ${columns.length}'); // cambio de Vigas a Columnas
      print('- Resultado consolidado: ${consolidatedResult != null}');

      if (columns.isEmpty || consolidatedResult == null) { // cambio de beams a columns
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
        title: const Text('Resultados de Acero en Columnas'), // cambio de título
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
          child: Stack(
            children: [
              _buildBody(),
              // Botones de acción en la parte inferior (como ResultLosasScreen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final consolidatedResult = ref.watch(calculateConsolidatedColumnSteelProvider); // cambio de provider
    final columns = ref.watch(steelColumnResultProvider); // cambio de steelBeamResultProvider
    final quickStats = ref.watch(quickStatsColumnProvider); // cambio de provider

    if (consolidatedResult == null || columns.isEmpty) { // cambio de beams a columns
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 140, // Espacio para los botones inferiores
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con resumen ejecutivo
          _buildExecutiveSummary(quickStats),
          const SizedBox(height: 20),

          // Materiales consolidados
          _buildConsolidatedMaterials(consolidatedResult),
          const SizedBox(height: 20),

          // Detalle por columna (cambio de viga a columna)
          _buildColumnDetails(consolidatedResult), // cambio de _buildBeamDetails
          const SizedBox(height: 20),

          // Gráfico de distribución (opcional)
          _buildDistributionChart(consolidatedResult),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTONES DE ACCIÓN CONSISTENTES CON OTRAS PANTALLAS DE RESULTADOS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomActionBar() {
    final columns = ref.watch(steelColumnResultProvider); // cambio de steelBeamResultProvider

    if (columns.isEmpty) { // cambio de beams a columns
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primera fila: Guardar y Compartir
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleSaveAction(),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showShareOptions(),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir'),
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
                ],
              ),
              const SizedBox(height: 12),
              // Segunda fila: Buscar Proveedores (ancho completo)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleProviderAction(),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Buscar Proveedores'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueMetraShop,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCIONES DE LOS BOTONES
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleSaveAction() {
    final columns = ref.watch(steelColumnResultProvider); // cambio de steelBeamResultProvider
    final consolidatedResult = ref.watch(calculateConsolidatedColumnSteelProvider); // cambio de provider

    if (columns.isNotEmpty && consolidatedResult != null) { // cambio de beams a columns
      // Navegar a pantalla de guardado
      context.pushNamed('save-steel-column'); // cambio de ruta
    } else {
      _showErrorMessage('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final columns = ref.watch(steelColumnResultProvider); // cambio de steelBeamResultProvider
    final consolidatedResult = ref.watch(calculateConsolidatedColumnSteelProvider); // cambio de provider

    if (columns.isNotEmpty && consolidatedResult != null) { // cambio de beams a columns
      // Navegar a mapa de proveedores
      context.pushNamed('map-screen-steel-column'); // cambio de ruta
    } else {
      _showErrorMessage('No hay datos de columnas de acero'); // cambio de texto
    }
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
            'Elige el formato para compartir tus resultados',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildShareOption(
                  icon: Icons.picture_as_pdf,
                  label: 'Compartir PDF',
                  color: Colors.red,
                  onTap: () => _sharePDF(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildShareOption(
                  icon: Icons.text_fields,
                  label: 'Compartir Texto',
                  color: AppColors.blueMetraShop,
                  onTap: () => _shareText(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.neutral400),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS DE COMPARTIR (ADAPTADOS PARA COLUMNAS)
  // ═══════════════════════════════════════════════════════════════════════════

  void _sharePDF() async {
    try {
      _generatePDF();
    } catch (e) {
      _showErrorMessage('Error al generar PDF: $e');
    }
  }

  void _shareText() async {
    try {
      await _shareResults();
    } catch (e) {
      _showErrorMessage('Error al compartir: $e');
    }
  }

  Future<void> _shareResults() async {
    final consolidatedResult = ref.read(calculateConsolidatedColumnSteelProvider); // cambio de provider
    if (consolidatedResult == null) return;

    final StringBuffer content = StringBuffer();
    content.writeln('📊 RESUMEN DE MATERIALES - COLUMNAS DE ACERO\n'); // cambio de VIGAS a COLUMNAS

    content.writeln('📋 MATERIALES CONSOLIDADOS:');
    consolidatedResult.consolidatedMaterials.forEach((material, data) {
      content.writeln('• $material: ${data.quantity.toStringAsFixed(0)} ${data.unit}');
    });

    content.writeln('\n🏗️ DETALLES POR COLUMNA:'); // cambio de VIGA a COLUMNA
    for (int i = 0; i < consolidatedResult.columnResults.length; i++) { // cambio de beamResults a columnResults
      final column = consolidatedResult.columnResults[i]; // cambio de beam a column
      content.writeln('Columna ${i + 1}: ${column.description}'); // cambio de Viga a Columna
      content.writeln('  • Peso total: ${column.totalWeight.toStringAsFixed(2)} kg');
      // Agregar info específica de columna
      if (column.hasFooting) {
        content.writeln('  • Con zapata: Sí');
      }
    }

    await Share.share(
      content.toString(),
      subject: 'Resultados de Columnas de Acero', // cambio de Vigas a Columnas
    );
  }

  void _generatePDF() {
    // Implementar generación de PDF similar a otras pantallas
    _showErrorMessage('Funcionalidad de PDF en desarrollo');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESTO DE MÉTODOS (ADAPTADOS PARA COLUMNAS)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_column, // cambio de Icons.construction
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
            'Configura al menos una columna para ver los resultados', // cambio de viga a columna
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed('steel-column'), // cambio de ruta
            icon: const Icon(Icons.add),
            label: const Text('Configurar Columnas'), // cambio de texto
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummary(dynamic quickStats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen Ejecutivo',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (quickStats != null) ...[
            _buildStatRow('Total de Columnas', '${quickStats['totalColumns']}'), // cambio de Vigas a Columnas
            _buildStatRow('Peso Total de Acero', '${quickStats['totalWeight']?.toStringAsFixed(2)} kg'), // cambio de estadística
            _buildStatRow('Alambre #16', '${quickStats['totalWire']?.toStringAsFixed(2)} kg'), // cambio de estadística
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsolidatedMaterials(dynamic consolidatedResult) {
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
                  Icons.inventory_2_outlined,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Materiales Consolidados',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header de la tabla
          _buildMaterialRow(
            'Material',
            'Cantidad',
            'Unidad',
            isHeader: true,
          ),
          const Divider(color: AppColors.neutral300),

          // Datos de materiales
          ...consolidatedResult.consolidatedMaterials.entries.map((entry) {
            final material = entry.key;
            final data = entry.value;
            final quantity = data.quantity.toStringAsFixed(0);
            final unit = data.unit;

            return _buildMaterialRow(material, quantity, unit);
          }),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(
      String material,
      String quantity,
      String unit, {
        bool isHeader = false,
        bool isHighlighted = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              material,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isHeader ? FontWeight.w600 : null,
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

  // CAMBIO PRINCIPAL: buildColumnDetails en lugar de buildBeamDetails
  Widget _buildColumnDetails(dynamic result) {
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
                  Icons.view_column, // cambio de Icons.view_list
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Detalle por Columna', // cambio de Viga a Columna
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de columnas (cambio de vigas)
          ...result.columnResults.asMap().entries.map((entry) { // cambio de beamResults a columnResults
            final index = entry.key;
            final column = entry.value; // cambio de beam a column
            return _buildColumnCard(column, index + 1); // cambio de _buildBeamCard
          }),
        ],
      ),
    );
  }

  // CAMBIO PRINCIPAL: buildColumnCard en lugar de buildBeamCard
  Widget _buildColumnCard(dynamic column, int columnNumber) { // cambio de beam a column y beamNumber a columnNumber
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
          Text(
            'Columna $columnNumber', // cambio de Viga a Columna
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'ID: ${column.columnId}', // cambio de beamId a columnId
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Descripción: ${column.description}',
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Peso total: ${column.totalWeight.toStringAsFixed(2)} kg',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          // CAMBIO: Agregar info específica de columna (zapata)
          if (column.hasFooting) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Con zapata: Sí',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDistributionChart(dynamic result) {
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
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_outline,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Distribución de Materiales',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            child: const Center(
              child: Text(
                'Gráfico en desarrollo',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}