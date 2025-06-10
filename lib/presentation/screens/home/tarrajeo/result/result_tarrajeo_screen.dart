import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:meter_app/presentation/providers/tarrajeo/tarrajeo_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../assets/icons.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultTarrajeoScreen extends ConsumerStatefulWidget {
  const ResultTarrajeoScreen({super.key});

  @override
  ConsumerState<ResultTarrajeoScreen> createState() => _ResultTarrajeoScreenState();
}

class _ResultTarrajeoScreenState extends ConsumerState<ResultTarrajeoScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _hideLoaderAfterDelay();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(tarrajeoResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBarWidget(titleAppBar: 'Resultados');
  }

  Widget _buildBody() {
    final tarrajeos = ref.watch(tarrajeoResultProvider);
    final materiales = ref.watch(tarrajeoMaterialesProvider);
    final hayDatos = ref.watch(hayDatosValidosProvider);

    if (tarrajeos.isEmpty || !hayDatos) {
      return _buildEmptyState();
    }

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
          _buildProjectSummaryCard(materiales),
          const SizedBox(height: 20),
          _buildMetradoDataCard(),
          const SizedBox(height: 20),
          _buildMaterialsCard(materiales),
          const SizedBox(height: 20),
          _buildConfigurationCard(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay datos de tarrajeo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Regresa y completa los datos para ver los resultados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Regresar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueMetraShop,
                foregroundColor: Colors.white,
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

  Widget _buildProjectSummaryCard(TarrajeoMateriales materiales) {
    final estadisticas = ref.watch(estadisticasTarrajeoProvider);
    final tarrajeos = ref.watch(tarrajeoResultProvider);

    return _buildModernCard(
      title: 'Resumen del Proyecto',
      icon: Icons.summarize_outlined,
      iconColor: AppColors.blueMetraShop,
      child: Column(
        children: [
          _buildSummaryRow('Área Total', '${estadisticas['area_total'].toStringAsFixed(2)} m²'),
          const SizedBox(height: 12),
          _buildSummaryRow('Total de Tarrajeos', '${tarrajeos.length}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Espesor Promedio', '${estadisticas['espesor_promedio'].toStringAsFixed(1)} cm'),
          const SizedBox(height: 12),
          _buildSummaryRow('Proporción Mortero', '1:${estadisticas['proporcion_mas_usada']}'),
        ],
      ),
    );
  }

  Widget _buildMetradoDataCard() {
    return _buildModernCard(
      title: 'Datos del Metrado',
      icon: Icons.view_list_outlined,
      iconColor: AppColors.accent,
      child: Column(
        children: [
          const _TarrajeoMetradoTable(),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(TarrajeoMateriales materiales) {
    return _buildModernCard(
      title: 'Lista de Materiales',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.success,
      child: Column(
        children: [
          _buildMaterialTable(materiales),
          const SizedBox(height: 16),
          _buildMaterialChips(materiales),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard() {
    final tarrajeos = ref.watch(tarrajeoResultProvider);
    final estadisticas = ref.watch(estadisticasTarrajeoProvider);

    if (tarrajeos.isEmpty) return const SizedBox.shrink();

    final primerTarrajeo = tarrajeos.first;
    final desperdicioTarrajeo = double.tryParse(primerTarrajeo.factorDesperdicio) ?? 5.0;

    return _buildModernCard(
      title: 'Configuración Aplicada',
      icon: Icons.settings_outlined,
      iconColor: AppColors.warning,
      child: Column(
        children: [
          _buildConfigRow('Desperdicio de Mortero', '${desperdicioTarrajeo.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          _buildConfigRow('Proporción Mortero', '1:${estadisticas['proporcion_mas_usada']}'),
          const SizedBox(height: 12),
          _buildConfigRow('Volumen Total', '${estadisticas['volumen_total'].toStringAsFixed(3)} m³'),
        ],
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
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

  Widget _buildMaterialTable(TarrajeoMateriales materiales) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        _buildTableRow(['Cemento', 'Bls', materiales.cementoFormateado]),
        _buildTableRow(['Arena fina', 'm³', materiales.arenaFormateada]),
        _buildTableRow(['Agua', 'm³', materiales.aguaFormateada]),
      ],
    );
  }

  Widget _buildMaterialChips(TarrajeoMateriales materiales) {
    final materials_list = [
      {'icon': Icons.inventory, 'label': 'Cemento', 'value': '${materiales.cementoFormateado} bls', 'color': AppColors.secondary},
      {'icon': Icons.grain, 'label': 'Arena fina', 'value': '${materiales.arenaFormateada} m³', 'color': AppColors.warning},
      {'icon': Icons.water_drop, 'label': 'Agua', 'value': '${materiales.aguaFormateada} m³', 'color': AppColors.info},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: materials_list.map((material) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (material['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (material['color'] as Color).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                material['icon'] as IconData,
                size: 16,
                color: material['color'] as Color,
              ),
              const SizedBox(width: 6),
              Text(
                material['value'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: material['color'] as Color,
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

  Widget _buildBottomActionBar() {
    final hayDatos = ref.watch(hayDatosValidosProvider);

    if (!hayDatos) {
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

  void _handleSaveAction() {
    final hayDatos = ref.watch(hayDatosValidosProvider);
    if (hayDatos) {
      context.pushNamed('save-tarrajeo');
    } else {
      _showErrorSnackBar('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final hayDatos = ref.watch(hayDatosValidosProvider);
    if (hayDatos) {
      context.pushNamed('map-screen-tarrajeo');
    } else {
      _showErrorSnackBar('No hay datos de tarrajeo');
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

  Future<void> _sharePDF() async {
    try {
      Navigator.of(context).pop();

      context.showCalculationLoader(
        message: 'Generando PDF...',
        description: 'Creando documento con los resultados',
      );

      final pdfFile = await PDFFactory.generateTarrajeoPDF(ref);
      final xFile = XFile(pdfFile.path);

      context.hideLoader();

      await Share.shareXFiles(
        [xFile],
        text: 'Resultados del metrado de tarrajeo - METRASHOP',
      );
    } catch (e) {
      context.hideLoader();
      _showErrorSnackBar('Error al generar PDF: $e');
    }
  }

  Future<void> _shareText() async {
    try {
      Navigator.of(context).pop();
      final resumen = ref.read(resumenCompletoProvider);
      await Share.share(resumen);
    } catch (e) {
      _showErrorSnackBar('Error al compartir: $e');
    }
  }

  Future<File> _generatePDF() async {
    final pdf = pw.Document();
    final materiales = ref.read(tarrajeoMaterialesProvider);
    final estadisticas = ref.read(estadisticasTarrajeoProvider);
    final metrados = ref.read(tarrajeoMetradosProvider);
    final tarrajeos = ref.read(tarrajeoResultProvider);

    if (metrados.isEmpty || tarrajeos.isEmpty) {
      throw Exception('No hay datos de tarrajeo para generar PDF');
    }

    final primerTarrajeo = tarrajeos.first;

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'RESULTADOS DE TARRAJEO',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Información del proyecto
            pw.Text(
              'INFORMACIÓN DEL PROYECTO:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Tipo: ${primerTarrajeo.tipo}'),
            pw.Text('• Proporción Mortero: 1:${estadisticas['proporcion_mas_usada']}'),
            pw.Text('• Área total: ${estadisticas['area_total'].toStringAsFixed(2)} m²'),
            pw.Text('• Total de tarrajeos: ${tarrajeos.length}'),
            pw.Text('• Espesor promedio: ${estadisticas['espesor_promedio'].toStringAsFixed(1)} cm'),
            pw.SizedBox(height: 20),

            // Materiales calculados
            pw.Text(
              'MATERIALES CALCULADOS:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Cemento: ${materiales.cementoFormateado} bolsas'),
            pw.Text('• Arena fina: ${materiales.arenaFormateada} m³'),
            pw.Text('• Agua: ${materiales.aguaFormateada} m³'),
            pw.SizedBox(height: 20),

            // Configuración aplicada
            pw.Text(
              'CONFIGURACIÓN APLICADA:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Desperdicio de Mortero: ${double.tryParse(primerTarrajeo.factorDesperdicio) ?? 5.0}%'),
            pw.Text('• Volumen total de mortero: ${materiales.volumenFormateado} m³'),
            pw.SizedBox(height: 20),

            // Detalle de tarrajeos
            pw.Text(
              'DETALLE DE TARRAJEOS:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...metrados.map((metrado) => pw.Text(
              '• ${metrado.descripcion}: ${metrado.volumenFormateado} m³',
              style: pw.TextStyle(fontSize: 12),
            )),
            pw.SizedBox(height: 20),

            // Información técnica
            pw.Text(
              'INFORMACIÓN TÉCNICA:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text('• Cálculos basados en fórmulas de ingeniería actualizadas',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Factores de desperdicio aplicados según especificaciones técnicas',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Volúmenes calculados considerando espesor y área de aplicación',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Generado por METRASHOP - ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/resultados_tarrajeo_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
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

/// Widget para mostrar la tabla de metrados
class _TarrajeoMetradoTable extends ConsumerWidget {
  const _TarrajeoMetradoTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrados = ref.watch(tarrajeoMetradosProvider);

    if (metrados.isEmpty) {
      return const Text(
        'No hay datos de metrado disponibles',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      );
    }

    double volumenTotal = metrados.fold(0.0, (sum, m) => sum + m.volumen);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', 'Volumen'], isHeader: true),
        ...metrados.map((metrado) => _buildTableRow([
          metrado.descripcion,
          'm³',
          metrado.volumenFormateado,
        ])).toList(),
        _buildTableRow([
          'Total:',
          'm³',
          volumenTotal.toStringAsFixed(3),
        ], isTotal: true),
      ],
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
}