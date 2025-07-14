import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cross_file/cross_file.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/error_handler.dart';
import '../../../../domain/services/shared/UnifiedMaterialsCalculator.dart';
import '../../../assets/icons.dart';
import '../../../blocs/projects/metrados/result/result_bloc.dart';
import '../../../widgets/app_bar/app_bar_projects_widget.dart';

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
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
          SizedBox(height: 16),
          Text(
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
            const Icon(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No hay resultados disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Realiza un cálculo para ver los resultados aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(List<dynamic> results) {
    if (results.isEmpty) {
      return _buildEmptyState();
    }

    try {
      // Usar la calculadora unificada actualizada para procesar los resultados
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
        bottom: 120, // Espacio para los botones flotantes
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSuccessIcon(),
          const SizedBox(height: 20),
          _buildResultTypeHeader(result.type),
          const SizedBox(height: 20),
          // ❌ ELIMINADO: _buildProjectSummaryCard(result),
          _buildMetradoDataCard(result),
          const SizedBox(height: 20),
          _buildMaterialsCard(result),
          if (result.additionalInfo.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildConfigurationCard(result),
          ],
          const SizedBox(height: 32),
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
              colorFilter: const ColorFilter.mode(
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
            size: 20,
            color: typeColor,
          ),
          const SizedBox(width: 12),
          Text(
            _getTypeDisplayName(type),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
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
      title: 'Configuración',
      icon: Icons.settings_outlined,
      iconColor: AppColors.blueMetraShop,
      child: Column(
        children: result.additionalInfo.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatConfigKey(entry.key),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blueMetraShop.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueMetraShop,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataTable(CalculationResult result) {
    if (result.measurements.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay mediciones disponibles',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
      },
      children: [
        _buildTableHeader(['Descripción', 'Medida', 'Und.']),
        ...result.measurements.map((measurement) {
          return _buildTableRow([
            measurement.description,
            measurement.value.toStringAsFixed(2),
            measurement.unit,
          ]);
        }),
        // Fila de total
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            border: const Border(
              top: BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                result.totalValue.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                result.totalUnit,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
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
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        _buildTableHeader(['Material', 'Und.', 'Cantidad']),
        ...result.materials.map((material) {
          return _buildTableRow([
            material.description,
            material.unit,
            material.quantity,
          ]);
        }),
      ],
    );
  }

  Widget _buildMaterialChips(CalculationResult result) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: result.materials.map((material) {
        return Chip(
          label: Text(
            '${material.description}: ${material.quantity} ${material.unit}',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.success.withOpacity(0.1),
          side: const BorderSide(color: AppColors.success),
        );
      }).toList(),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
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

  TableRow _buildTableHeader(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            cell,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            cell,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton.extended(
          onPressed: _shareResults,
          backgroundColor: AppColors.blueMetraShop,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.share),
          label: const Text('Compartir'),
          heroTag: 'share',
        ),
        FloatingActionButton.extended(
          onPressed: _generatePDF,
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('PDF'),
          heroTag: 'pdf',
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES
  // ═══════════════════════════════════════════════════════════════════════════

  Color _getTypeColor(CalculationType type) {
    switch (type) {
      case CalculationType.ladrillo:
        return AppColors.error;
      case CalculationType.piso:
        return AppColors.blueMetraShop;
      case CalculationType.losaAligerada:
        return AppColors.success;
      case CalculationType.tarrajeo:
        return AppColors.accent;
      case CalculationType.columna:
        return Colors.orange;
      case CalculationType.viga:
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(CalculationType type) {
    switch (type) {
      case CalculationType.ladrillo:
        return Icons.view_module_outlined;
      case CalculationType.piso:
        return Icons.layers_outlined;
      case CalculationType.losaAligerada:
        return Icons.foundation_outlined;
      case CalculationType.tarrajeo:
        return Icons.format_paint_outlined;
      case CalculationType.columna:
        return Icons.view_column_outlined;
      case CalculationType.viga:
        return Icons.horizontal_rule_outlined;
      default:
        return Icons.calculate_outlined;
    }
  }

  String _getTypeDisplayName(CalculationType type) {
    switch (type) {
      case CalculationType.ladrillo:
        return 'Muro de Ladrillos';
      case CalculationType.piso:
        return 'Piso';
      case CalculationType.losaAligerada:
        return 'Losa Aligerada';
      case CalculationType.tarrajeo:
        return 'Tarrajeo';
      case CalculationType.columna:
        return 'Columna';
      case CalculationType.viga:
        return 'Viga';
      default:
        return 'Cálculo';
    }
  }

  String _formatConfigKey(String key) {
    switch (key) {
      case 'tipoAsentado':
        return 'Tipo de Asentado';
      case 'proporcionMortero':
        return 'Proporción Mortero';
      case 'desperdicioLadrillo':
        return 'Desperdicio Ladrillo';
      case 'desperdicioMortero':
        return 'Desperdicio Mortero';
      case 'tipoPiso':
        return 'Tipo de Piso';
      case 'resistencia':
        return 'Resistencia';
      case 'espesor':
        return 'Espesor';
      case 'desperdicio':
        return 'Desperdicio';
      case 'altura':
        return 'Altura';
      case 'materialAligerado':
        return 'Material Aligerado';
      case 'resistenciaConcreto':
        return 'Resistencia Concreto';
      case 'desperdicioConcreto':
        return 'Desperdicio Concreto';
      case 'tipo':
        return 'Tipo';
      default:
        return key;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCIONES DE COMPARTIR Y PDF
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _shareResults() async {
    try {
      final state = context.read<ResultBloc>().state;
      if (state is! ResultSuccess) return;

      final result = UnifiedMaterialsCalculator.calculateMaterials(state.results);
      if (result.hasError) return;

      final shareText = _generateShareText(result);
      await Share.share(shareText, subject: 'Resultados de MetraShop');
    } catch (e) {
      _handleError('Error al compartir: $e');
    }
  }

  Future<void> _generatePDF() async {
    try {
      final state = context.read<ResultBloc>().state;
      if (state is! ResultSuccess) return;

      final result = UnifiedMaterialsCalculator.calculateMaterials(state.results);
      if (result.hasError) return;

      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final pdf = await _createPDF(result);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/resultados_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        Navigator.of(context).pop(); // Cerrar indicador de carga
        await Share.shareXFiles([XFile(file.path)], text: 'Resultados de MetraShop');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar indicador de carga
      }
      _handleError('Error al generar PDF: $e');
    }
  }

  String _generateShareText(CalculationResult result) {
    final buffer = StringBuffer();
    buffer.writeln('📋 RESULTADOS DE METRASHOP');
    buffer.writeln('');
    buffer.writeln('🏗️ TIPO: ${_getTypeDisplayName(result.type)}');
    buffer.writeln('📐 TOTAL: ${result.totalValue.toStringAsFixed(2)} ${result.totalUnit}');
    buffer.writeln('');
    buffer.writeln('📊 MATERIALES NECESARIOS:');

    for (final material in result.materials) {
      buffer.writeln('• ${material.description}: ${material.quantity} ${material.unit}');
    }

    if (result.additionalInfo.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('⚙️ CONFIGURACIÓN:');
      for (final entry in result.additionalInfo.entries) {
        buffer.writeln('• ${_formatConfigKey(entry.key)}: ${entry.value}');
      }
    }

    buffer.writeln('');
    buffer.writeln('📱 Generado con MetraShop');
    return buffer.toString();
  }

  Future<pw.Document> _createPDF(CalculationResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Resultados de MetraShop',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Tipo: ${_getTypeDisplayName(result.type)}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Total: ${result.totalValue.toStringAsFixed(2)} ${result.totalUnit}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Materiales:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Material', 'Cantidad', 'Unidad'],
                data: result.materials.map((material) => [
                  material.description,
                  material.quantity,
                  material.unit,
                ]).toList(),
              ),
              if (result.additionalInfo.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Configuración:',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                ...result.additionalInfo.entries.map((entry) => pw.Text(
                  '• ${_formatConfigKey(entry.key)}: ${entry.value}',
                )),
              ],
              pw.Spacer(),
              pw.Text(
                'Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}