// lib/presentation/screens/projects/result/result_screens_improved.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/error_handler.dart';
import '../../../../domain/services/shared/UnifiedMaterialsCalculator.dart';
import '../../../assets/icons.dart';
import '../../../blocs/projects/metrados/result/result_bloc.dart';
import '../../../widgets/app_bar/app_bar_projects_widget.dart';
import 'services/share_service.dart';

class ResultScreen extends StatefulWidget {
  final String metradoId;

  const ResultScreen({
    super.key,
    required this.metradoId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadResults();
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

  void _loadResults() {
    if (!mounted) return;

    try {
      context.read<ResultBloc>().add(
        LoadResultsEvent(metradoId: widget.metradoId),
      );
    } catch (e) {
      _handleError('Error al cargar resultados: $e');
    }
  }

  void _handleError(String message) {
    if (!mounted) return;

    ErrorHandler.showErrorSnackBar(
      context,
      message,
      onRetry: _loadResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AppBarProjectsWidget(
        titleAppBar: 'Resultados Guardados',
      ),
      body: SafeArea(
        child: BlocConsumer<ResultBloc, ResultState>(
          listener: _handleBlocListener,
          builder: _buildContent,
        ),
      ),
    );
  }

  void _handleBlocListener(BuildContext context, ResultState state) {
    if (state is ResultFailure) {
      _handleError(state.message);
    }
  }

  Widget _buildContent(BuildContext context, ResultState state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getWidgetForState(state),
        ),
      ),
    );
  }

  Widget _getWidgetForState(ResultState state) {
    switch (state.runtimeType) {
      case ResultLoading:
        return _buildLoadingIndicator();

      case ResultSuccess:
        final successState = state as ResultSuccess;
        return _buildSuccessContent(successState.results);

      case ResultFailure:
        final failureState = state as ResultFailure;
        return _buildErrorDisplay(failureState.message);

      default:
        return _buildEmptyState();
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cargando resultados guardados...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar los resultados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadResults,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.archiveProjectIcon,
              width: 64,
              height: 64,
              colorFilter: const ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay resultados disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Este metrado no tiene cálculos guardados todavía.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent(List<dynamic> results) {
    if (results.isEmpty) {
      return _buildEmptyState();
    }

    try {
      final calculationResult = UnifiedMaterialsCalculator.calculateMaterials(results);

      if (calculationResult.hasError) {
        return _buildErrorDisplay(calculationResult.errorMessage!);
      }

      return _buildResultContent(calculationResult);
    } catch (e) {
      return _buildErrorDisplay('Error al procesar resultados: $e');
    }
  }

  Widget _buildResultContent(CalculationResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        right: 24,
        left: 24,
        top: 10,
        bottom: 20,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSuccessIcon(),
          const SizedBox(height: 20),
          _buildResultTypeHeader(result.type),
          const SizedBox(height: 20),
          _buildProjectSummaryCard(result),
          const SizedBox(height: 20),
          _buildMetradoDataCard(result),
          const SizedBox(height: 20),
          _buildMaterialsCard(result),
          if (result.additionalInfo.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildConfigurationCard(result),
          ],
          const SizedBox(height: 120), // Espacio para los botones de abajo
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: SvgPicture.asset(
              AppIcons.checkmarkCircleIcon,
              width: 48,
              height: 48,
              colorFilter: ColorFilter.mode(
                AppColors.success,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultTypeHeader(CalculationType type) {
    final typeColor = _getTypeColor(type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: typeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(type),
            size: 18,
            color: typeColor,
          ),
          const SizedBox(width: 8),
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummaryCard(CalculationResult result) {
    return _buildModernCard(
      title: 'Resumen del Proyecto',
      icon: Icons.summarize_outlined,
      iconColor: AppColors.blueMetraShop,
      child: Column(
        children: [
          _buildSummaryRow('Total ${result.totalUnit}', result.totalValue.toStringAsFixed(2)),
          const SizedBox(height: 12),
          _buildSummaryRow('Total de Elementos', '${result.measurements.length}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tipo de Cálculo', result.type.displayName),
          if (result.additionalInfo.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Configuración',
              '${result.additionalInfo.length} parámetros',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetradoDataCard(CalculationResult result) {
    return _buildModernCard(
      title: 'Datos del Metrado',
      icon: Icons.view_list_outlined,
      iconColor: AppColors.accent,
      child: Column(
        children: [
          _buildDataTable(result),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(CalculationResult result) {
    return _buildModernCard(
      title: 'Lista de Materiales',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.success,
      child: Column(
        children: [
          _buildMaterialTable(result),
          const SizedBox(height: 16),
          _buildMaterialChips(result),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(CalculationResult result) {
    return _buildModernCard(
      title: 'Configuración Aplicada',
      icon: Icons.settings_outlined,
      iconColor: AppColors.warning,
      child: Column(
        children: result.additionalInfo.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildConfigRow(
              _formatInfoKey(entry.key),
              entry.value,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
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
          style: const TextStyle(
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

  Widget _buildConfigRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(CalculationResult result) {
    if (result.measurements.isEmpty) {
      return const Center(
        child: Text('No hay datos de medición disponibles'),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', result.totalUnit], isHeader: true),
        ...result.measurements.map((measurement) {
          return _buildTableRow([
            measurement.description,
            measurement.unit,
            measurement.value.toStringAsFixed(2),
          ]);
        }).toList(),
        _buildTableRow([
          'Total:',
          result.totalUnit,
          result.totalValue.toStringAsFixed(2),
        ], isTotal: true),
      ],
    );
  }

  Widget _buildMaterialTable(CalculationResult result) {
    if (result.materials.isEmpty) {
      return const Center(
        child: Text('No hay materiales disponibles'),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        ...result.materials.map((material) {
          return _buildTableRow([
            material.description,
            material.unit,
            material.quantity,
          ]);
        }).toList(),
      ],
    );
  }

  Widget _buildMaterialChips(CalculationResult result) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: result.materials.map((material) {
        final color = _getMaterialColor(material.description);
        final icon = _getMaterialIcon(material.description);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                '${material.quantity} ${material.unit}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, bool isTotal = false}) {
    final textStyle = TextStyle(
      fontSize: isHeader ? 14 : 12,
      fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? AppColors.textPrimary :
      isTotal ? AppColors.blueMetraShop : AppColors.textSecondary,
    );

    return TableRow(
      decoration: isTotal ? BoxDecoration(
        color: AppColors.blueMetraShop.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      children: cells.map((cell) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          cell,
          style: textStyle,
          textAlign: cells.indexOf(cell) == 0 ? TextAlign.left : TextAlign.center,
        ),
      )).toList(),
    );
  }

  // Helper methods para colores e iconos
  Color _getTypeColor(CalculationType type) {
    switch (type) {
      case CalculationType.ladrillo:
        return Colors.brown;
      case CalculationType.piso:
        return Colors.teal;
      case CalculationType.losaAligerada:
        return Colors.deepPurple;
      case CalculationType.tarrajeo:
        return Colors.amber.shade700;
      case CalculationType.columna:
      case CalculationType.viga:
        return Colors.blue.shade800;
    }
  }

  IconData _getTypeIcon(CalculationType type) {
    switch (type) {
      case CalculationType.ladrillo:
        return Icons.grid_view;
      case CalculationType.piso:
        return Icons.grid_on;
      case CalculationType.losaAligerada:
        return Icons.layers;
      case CalculationType.tarrajeo:
        return Icons.brush;
      case CalculationType.columna:
        return Icons.view_column;
      case CalculationType.viga:
        return Icons.horizontal_rule;
    }
  }

  Color _getMaterialColor(String materialName) {
    final name = materialName.toLowerCase();
    if (name.contains('cemento')) return AppColors.secondary;
    if (name.contains('arena')) return AppColors.warning;
    if (name.contains('agua')) return AppColors.info;
    if (name.contains('piedra')) return AppColors.neutral500;
    if (name.contains('ladrillo')) return AppColors.primary;
    return AppColors.accent;
  }

  IconData _getMaterialIcon(String materialName) {
    final name = materialName.toLowerCase();
    if (name.contains('cemento')) return Icons.inventory;
    if (name.contains('arena')) return Icons.grain;
    if (name.contains('agua')) return Icons.water_drop;
    if (name.contains('piedra')) return Icons.terrain;
    if (name.contains('ladrillo')) return Icons.construction;
    return Icons.category;
  }

  String _formatInfoKey(String key) {
    switch (key) {
      case 'tipoLadrillo':
        return 'Tipo de ladrillo';
      case 'tipoAsentado':
        return 'Tipo de asentado';
      case 'proporcionMortero':
        return 'Proporción mortero';
      case 'desperdicioLadrillo':
        return 'Desperdicio ladrillo';
      case 'desperdicioMortero':
        return 'Desperdicio mortero';
      case 'resistencia':
        return 'Resistencia';
      case 'espesor':
        return 'Espesor';
      case 'altura':
        return 'Altura';
      default:
        return key.replaceAllMapped(
          RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)!.toLowerCase()}',
        ).trim();
    }
  }

  void _handleSaveAction(CalculationResult result) {
    // Como ya está guardado, mostrar mensaje informativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Este metrado ya está guardado en el proyecto'),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showShareOptions(CalculationResult result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildShareBottomSheet(result),
    );
  }

  Widget _buildShareBottomSheet(CalculationResult result) {
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
                  onTap: () => _generateAndSharePDF(result),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildShareOption(
                  icon: Icons.text_fields,
                  label: 'Compartir Texto',
                  color: AppColors.blueMetraShop,
                  onTap: () => _shareText(result),
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
          const SizedBox(height: 8),
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

  Future<void> _generateAndSharePDF(CalculationResult result) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final pdfFile = await _generatePDF(result);
      final xFile = XFile(pdfFile.path);

      // Cerrar el diálogo de carga
      if (mounted) Navigator.of(context).pop();

      await Share.shareXFiles(
        [xFile],
        text: 'Resultados de ${result.type.displayName} - METRASHOP',
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showErrorSnackBar('Error al generar PDF: $e');
    }
  }

  Future<void> _shareText(CalculationResult result) async {
    try {
      final shareText = ShareService.generateShareText(result);
      await Share.share(shareText);
    } catch (e) {
      _showErrorSnackBar('Error al compartir: $e');
    }
  }

  void _navigateToProviders(CalculationResult result) {
    // Navegar según el tipo de resultado
    String routeName = 'map-screen-projects'; // Default

    switch (result.type) {
      case CalculationType.ladrillo:
        routeName = 'map-screen-2';
        break;
      case CalculationType.piso:
        routeName = 'map-screen-pisos';
        break;
      case CalculationType.losaAligerada:
        routeName = 'map-screen-losas';
        break;
      case CalculationType.tarrajeo:
        routeName = 'map-screen-tarrajeo';
        break;
      case CalculationType.columna:
      case CalculationType.viga:
        routeName = 'map-screen-structural';
        break;
    }

    // Por ahora mostrar mensaje hasta que implementes las rutas
    _showErrorSnackBar('Funcionalidad de proveedores próximamente disponible');

    // Cuando tengas las rutas implementadas, descomenta:
    // context.pushNamed(routeName);
  }

  Future<File> _generatePDF(CalculationResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Título
            pw.Text(
              'METRASHOP - ${result.type.displayName.toUpperCase()}',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Información del proyecto
            if (result.additionalInfo.isNotEmpty) ...[
              pw.Text(
                'INFORMACIÓN DEL PROYECTO:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...result.additionalInfo.entries.map((entry) =>
                  pw.Text('• ${_formatInfoKey(entry.key)}: ${entry.value}')
              ),
              pw.SizedBox(height: 20),
            ],

            // Datos del metrado
            pw.Text(
              'DATOS DEL METRADO:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            ...result.measurements.map((measurement) =>
                pw.Text('• ${measurement.description}: ${measurement.value.toStringAsFixed(2)} ${measurement.unit}')
            ),
            pw.Text('Total: ${result.totalValue.toStringAsFixed(2)} ${result.totalUnit}'),
            pw.SizedBox(height: 20),

            // Lista de materiales
            pw.Text(
              'LISTA DE MATERIALES:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            ...result.materials.map((material) =>
                pw.Text('• ${material.description}: ${material.quantity} ${material.unit}')
            ),
            pw.SizedBox(height: 20),

            // Pie de página
            pw.Text(
              'NOTAS:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              '• Cálculos realizados con fórmulas de ingeniería actualizadas',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              '• Los factores de desperdicio están incluidos en las cantidades',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              '• Generado por METRASHOP - ${_getCurrentDate()}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${output.path}/resultados_${result.type.name}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
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
}