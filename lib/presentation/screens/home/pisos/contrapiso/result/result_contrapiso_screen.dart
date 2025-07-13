import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:meter_app/presentation/providers/pisos/contrapiso_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/entities.dart';
import '../../../../../assets/icons.dart';
import '../../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultContrapisoScreen extends ConsumerStatefulWidget {
  const ResultContrapisoScreen({super.key});

  @override
  ConsumerState<ResultContrapisoScreen> createState() => _ResultContrapisoScreenState();
}

class _ResultContrapisoScreenState extends ConsumerState<ResultContrapisoScreen>
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
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        context.hideLoader();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pisos = ref.watch(contrapisoResultProvider);
    final materials = ref.watch(contrapisoMaterialsProvider);  // ✅ Cambio: usar materials

    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Resultados'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: pisos.isEmpty
              ? _buildEmptyState()
              : _buildResultsContent(pisos, materials),  // ✅ Pasar materials
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),  // ✅ Mantener tus botones originales
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.infoIcon,
            width: 120,
            height: 120,
            colorFilter: ColorFilter.mode(
              AppColors.neutral400,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega datos de contrapiso para ver los resultados',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent(List<Piso> pisos, ContrapisoMaterials materials) {  // ✅ Cambio de tipo
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildSuccessIcon(),
            const SizedBox(height: 24),
            _buildProjectSummaryCard(materials, pisos),  // ✅ Pasar materials
            const SizedBox(height: 16),
            _buildMetradoDataCard(pisos),
            const SizedBox(height: 16),
            _buildMaterialsCard(materials),  // ✅ Pasar materials
            const SizedBox(height: 16),
            _buildConfigurationCard(pisos),
            const SizedBox(height: 100), // Espacio para el bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
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
    );
  }

  Widget _buildProjectSummaryCard(ContrapisoMaterials materials, List<Piso> pisos) {  // ✅ Cambio de tipo
    return _buildModernCard(
      title: 'Resumen del Proyecto',
      icon: Icons.summarize_outlined,
      iconColor: AppColors.blueMetraShop,
      child: Column(
        children: [
          _buildSummaryRow('Área Total', '${materials.areaTotalFormateada} m²'),  // ✅ Cambio: Volumen → Área
          const SizedBox(height: 12),
          _buildSummaryRow('Total de Contrapisos', '${pisos.length}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tipo', 'Contrapiso'),
          const SizedBox(height: 12),
          _buildSummaryRow('Proporción Mortero', _getProporcionMortero(pisos)),
        ],
      ),
    );
  }

  Widget _buildMetradoDataCard(List<Piso> pisos) {
    return _buildModernCard(
      title: 'Datos del Metrado',
      icon: Icons.view_list_outlined,
      iconColor: AppColors.accent,
      child: Column(
        children: [
          _buildDataTable(pisos),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(ContrapisoMaterials materials) {  // ✅ Cambio de tipo
    return _buildModernCard(
      title: 'Lista de Materiales',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.success,
      child: Column(
        children: [
          _buildMaterialTable(materials),
          const SizedBox(height: 16),
          _buildMaterialChips(materials),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(List<Piso> pisos) {
    if (pisos.isEmpty) return const SizedBox.shrink();

    final primerPiso = pisos.first;
    final desperdicio = double.tryParse(primerPiso.factorDesperdicio) ?? 5.0;
    final espesor = double.tryParse(primerPiso.espesor) ?? 5.0;

    return _buildModernCard(
      title: 'Configuración Aplicada',
      icon: Icons.settings_outlined,
      iconColor: AppColors.warning,
      child: Column(
        children: [
          _buildConfigRow('Desperdicio de Mortero', '${desperdicio.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          _buildConfigRow('Espesor promedio', '${espesor.toStringAsFixed(1)} cm'),
          const SizedBox(height: 12),
          _buildConfigRow('Proporción Mortero', '1:${primerPiso.proporcionMortero ?? "5"}'),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withOpacity(0.3),
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

  Widget _buildDataTable(List<Piso> pisos) {
    final areas = ref.watch(areaContrapisoProvider);  // ✅ Cambio: usar provider de áreas

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', 'Área'], isHeader: true),  // ✅ Cambio: Volumen → Área
        ...pisos.asMap().entries.map((entry) {
          final index = entry.key;
          final piso = entry.value;
          final area = index < areas.length ? areas[index] : 0.0;  // ✅ Cambio: usar área
          return _buildTableRow([
            piso.description,
            'm²',  // ✅ Cambio: m³ → m²
            area.toStringAsFixed(2),
          ]);
        }).toList(),
        _buildTableRow([
          'Total:',
          'm²',  // ✅ Cambio: m³ → m²
          ref.watch(contrapisoMaterialsProvider).areaTotalFormateada,  // ✅ Cambio
        ], isTotal: true),
      ],
    );
  }

  Widget _buildMaterialTable(ContrapisoMaterials materials) {  // ✅ Cambio de tipo
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        _buildTableRow(['Cemento', 'Bls', materials.cementoBolsas.toString()]),  // ✅ Método formateado
        _buildTableRow(['Arena gruesa', 'm³', materials.arenaFormateada]),  // ✅ Método formateado
        _buildTableRow(['Agua', 'm³', materials.aguaFormateada]),  // ✅ Método formateado
      ],
    );
  }

  Widget _buildMaterialChips(ContrapisoMaterials materials) {  // ✅ Cambio de tipo
    final materials_list = [
      {'icon': Icons.inventory, 'label': 'Cemento', 'value': '${materials.cementoBolsas} bls', 'color': AppColors.primary},
      {'icon': Icons.grain, 'label': 'Arena', 'value': '${materials.arenaFormateada} m³', 'color': AppColors.warning},
      {'icon': Icons.water_drop, 'label': 'Agua', 'value': '${materials.aguaFormateada} m³', 'color': AppColors.info},
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

  // ✅ TUS BOTONES ORIGINALES MANTENIDOS EXACTAMENTE IGUAL
  Widget _buildBottomActionBar() {
    final pisos = ref.watch(contrapisoResultProvider);

    if (pisos.isEmpty) {
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
              // Botones de acción principales en fila
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
              // Botón principal de proveedores
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

  // Métodos auxiliares
  String _getProporcionMortero(List<Piso> pisos) {
    return pisos.isNotEmpty ? '1:${pisos.first.proporcionMortero ?? "5"}' : 'N/A';
  }

  // ✅ Método para calcular área (reemplaza _calcularVolumenPiso)
  double _calcularAreaPiso(Piso piso) {
    if (piso.area != null && piso.area!.isNotEmpty) {
      return double.tryParse(piso.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }

  void _handleSaveAction() {
    final pisos = ref.watch(contrapisoResultProvider);
    if (pisos.isNotEmpty) {
      context.pushNamed('contrapiso-save');
    } else {
      _showErrorSnackBar('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final pisos = ref.watch(contrapisoResultProvider);
    if (pisos.isNotEmpty) {
      context.pushNamed('contrapiso-map-screen');
    } else {
      _showErrorSnackBar('No hay datos de contrapiso');
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
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildShareOption(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  color: AppColors.error,
                  onTap: _sharePDF,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildShareOption(
                  icon: Icons.text_snippet,
                  label: 'Texto',
                  color: AppColors.info,
                  onTap: _shareText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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

      final pdfFile = await PDFFactory.generateContrapisoPDF(ref);
      final xFile = XFile(pdfFile.path);

      context.hideLoader();

      await Share.shareXFiles(
        [xFile],
        text: 'Resultados del metrado de contrapiso - METRASHOP',
      );
    } catch (e) {
      context.hideLoader();
      _showErrorSnackBar('Error al generar PDF: $e');
    }
  }

  Future<void> _shareText() async {
    try {
      Navigator.of(context).pop();
      final pisos = ref.watch(contrapisoResultProvider);
      final materials = ref.watch(contrapisoMaterialsProvider);  // ✅ Cambio aquí
      final datosMetrado = ref.watch(datosShareContrapisoProvider);

      final shareText = _buildShareText(materials, datosMetrado, pisos);

      await Share.share(shareText);
    } catch (e) {
      _showErrorSnackBar('Error al compartir: $e');
    }
  }

  String _buildShareText(ContrapisoMaterials materials, String datosMetrado, List<Piso> pisos) {  // ✅ Cambio de tipo
    final primerPiso = pisos.isNotEmpty ? pisos.first : null;
    final proporcion = primerPiso?.proporcionMortero ?? '5';
    final desperdicio = primerPiso != null ? double.tryParse(primerPiso.factorDesperdicio) ?? 5.0 : 5.0;

    return '''RESULTADOS DE CONTRAPISO - METRASHOP

DATOS DEL METRADO:
$datosMetrado

LISTA DE MATERIALES:
• Cemento: ${materials.cementoBolsas} bls
• Arena gruesa: ${materials.arenaFormateada} m³
• Agua: ${materials.aguaFormateada} m³

INFORMACIÓN DEL PROYECTO:
• Tipo: Contrapiso
• Proporción Mortero: 1:$proporcion
• Área total: ${materials.areaTotalFormateada} m²
• Factor de desperdicio: ${desperdicio.toStringAsFixed(1)}%
• Total de secciones: ${pisos.length}

Generado por METRASHOP - ${DateTime.now().toString().split(' ')[0]}''';
  }

  Future<File> _generatePDF() async {
    final pdf = pw.Document();
    final pisos = ref.watch(contrapisoResultProvider);
    final materials = ref.watch(contrapisoMaterialsProvider);  // ✅ Cambio aquí

    if (pisos.isEmpty) {
      throw Exception('No hay datos de contrapiso para generar PDF');
    }

    final primerPiso = pisos.first;

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Título
            pw.Text(
              'RESULTADOS DE CONTRAPISO',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Información del proyecto
            pw.Text(
              'INFORMACIÓN DEL PROYECTO:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Tipo: Contrapiso'),
            pw.Text('• Proporción Mortero: 1:${primerPiso.proporcionMortero ?? "5"}'),
            pw.Text('• Área total: ${materials.areaTotalFormateada} m²'),  // ✅ Cambio: Volumen → Área
            pw.Text('• Total de secciones: ${pisos.length}'),
            pw.SizedBox(height: 20),

            // Materiales calculados
            pw.Text(
              'MATERIALES CALCULADOS:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Cemento: ${materials.cementoBolsas} bolsas'),
            pw.Text('• Arena gruesa: ${materials.arenaFormateada} m³'),
            pw.Text('• Agua: ${materials.aguaFormateada} m³'),
            pw.SizedBox(height: 20),

            // Configuración aplicada
            pw.Text(
              'CONFIGURACIÓN APLICADA:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Desperdicio de Mortero: ${double.tryParse(primerPiso.factorDesperdicio) ?? 5.0}%'),
            pw.Text('• Espesor promedio: ${double.tryParse(primerPiso.espesor) ?? 5.0} cm'),
            pw.SizedBox(height: 20),

            // Detalle de áreas - ✅ CAMBIADO DE "DETALLE DE SECCIONES"
            pw.Text(
              'DETALLE DE ÁREAS:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...pisos.map((piso) {
              final area = _calcularAreaPiso(piso);  // ✅ Cambio: usar método de área
              return pw.Text(
                '• ${piso.description}: ${area.toStringAsFixed(2)} m²',  // ✅ Cambio: m³ → m²
                style: pw.TextStyle(fontSize: 12),
              );
            }),
            pw.SizedBox(height: 20),

            // Información técnica
            pw.Text(
              'INFORMACIÓN TÉCNICA:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text('• Cálculos basados en factores técnicos del Excel líneas 15-164',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Factores de materiales según proporción de mortero aplicados',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Factor de desperdicio aplicado de forma independiente',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Generado por METRASHOP - ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/resultados_contrapiso_${DateTime.now().millisecondsSinceEpoch}.pdf');
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