import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/home/losas/losas.dart';
import '../../../../providers/providers.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultLosasScreen extends ConsumerStatefulWidget {
  const ResultLosasScreen({super.key});

  @override
  ConsumerState<ResultLosasScreen> createState() => _ResultLosasScreenState();
}

class _ResultLosasScreenState extends ConsumerState<ResultLosasScreen>
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
        ref.read(losaAligeradaResultProvider.notifier).clearList();
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
    return AppBarWidget(titleAppBar: 'Resultados Losa Aligerada');
  }

  Widget _buildBody() {
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);

    if (losasAligeradas.isEmpty) {
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
          _buildMetradoDataCard(losasAligeradas),
          const SizedBox(height: 20),
          _buildMaterialsCard(),
          const SizedBox(height: 20),
          _buildConfigurationCard(losasAligeradas),
          const SizedBox(height: 120), // Espacio para los botones de abajo
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
              'No hay datos de losas aligeradas',
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

  Widget _buildMetradoDataCard(List<LosaAligerada> losasAligeradas) {
    return _buildModernCard(
      title: 'Datos del Metrado',
      icon: Icons.view_list_outlined,
      iconColor: AppColors.accent,
      child: Column(
        children: [
          _buildDataTable(losasAligeradas),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard() {
    final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider);
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider);
    final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider);

    return _buildModernCard(
      title: 'Lista de Materiales',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.success,
      child: Column(
        children: [
          _buildMaterialTable(cantidadCemento, cantidadArena, cantidadPiedra, cantidadAgua),
 //         const SizedBox(height: 16),
 //         _buildMaterialChips(cantidadCemento, cantidadArena, cantidadPiedra, cantidadAgua),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(List<LosaAligerada> losasAligeradas) {
    if (losasAligeradas.isEmpty) return const SizedBox.shrink();

    final primeraLosa = losasAligeradas.first;
    final desperdicioLadrillo = double.tryParse(primeraLosa.desperdicioLadrillo) ?? 5.0;
    final desperdicioConcreto = double.tryParse(primeraLosa.desperdicioConcreto) ?? 5.0;

    return _buildModernCard(
      title: 'Configuración Aplicada',
      icon: Icons.settings_outlined,
      iconColor: AppColors.warning,
      child: Column(
        children: [
          _buildConfigRow('Altura de Losa', primeraLosa.altura),
          const SizedBox(height: 12),
          _buildConfigRow('Material Aligerado', primeraLosa.materialAligerado),
          const SizedBox(height: 12),
          _buildConfigRow('Resistencia Concreto', primeraLosa.resistenciaConcreto),
          const SizedBox(height: 12),
          _buildConfigRow('Desperdicio Ladrillo', '${desperdicioLadrillo.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          _buildConfigRow('Desperdicio Concreto', '${desperdicioConcreto.toStringAsFixed(1)}%'),
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

  Widget _buildDataTable(List<LosaAligerada> losasAligeradas) {
    final areaTotal = _calcularAreaTotal(losasAligeradas);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', 'Área'], isHeader: true),
        ...losasAligeradas.map((losa) {
          final area = _calcularAreaLosa(losa);
          return _buildTableRow([
            losa.description,
            'm²',
            area.toStringAsFixed(2),
          ]);
        }).toList(),
        _buildTableRow([
          'Total:',
          'm²',
          areaTotal.toStringAsFixed(2),
        ], isTotal: true),
      ],
    );
  }

  Widget _buildMaterialTable(double cemento, double arena, double piedra, double agua) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        _buildTableRow(['Cemento', 'Bls', cemento.ceil().toString()]),
        _buildTableRow(['Arena gruesa', 'm³', arena.toStringAsFixed(2)]),
        _buildTableRow(['Piedra chancada', 'm³', piedra.toStringAsFixed(2)]),
        _buildTableRow(['Agua', 'm³', agua.toStringAsFixed(2)]),
      ],
    );
  }

  Widget _buildMaterialChips(double cemento, double arena, double piedra, double agua) {
    final materialsList = [
      {'icon': Icons.inventory, 'label': 'Cemento', 'value': '${cemento.ceil()} bls', 'color': AppColors.secondary},
      {'icon': Icons.grain, 'label': 'Arena', 'value': '${arena.toStringAsFixed(2)} m³', 'color': AppColors.warning},
      {'icon': Icons.landscape, 'label': 'Piedra', 'value': '${piedra.toStringAsFixed(2)} m³', 'color': AppColors.primary},
      {'icon': Icons.water_drop, 'label': 'Agua', 'value': '${agua.toStringAsFixed(2)} m³', 'color': AppColors.info},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: materialsList.map((material) {
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
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);

    if (losasAligeradas.isEmpty) {
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
  double _calcularAreaTotal(List<LosaAligerada> losasAligeradas) {
    double total = 0.0;
    for (var losa in losasAligeradas) {
      total += _calcularAreaLosa(losa);
    }
    return total;
  }

  double _calcularAreaLosa(LosaAligerada losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(losa.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }

  String _getMaterialAligerado(List<LosaAligerada> losasAligeradas) {
    return losasAligeradas.isNotEmpty ? losasAligeradas.first.materialAligerado : 'N/A';
  }

  void _handleSaveAction() {
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);
    if (losasAligeradas.isNotEmpty) {
      context.pushNamed('save-losas');
    } else {
      _showErrorSnackBar('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);
    if (losasAligeradas.isNotEmpty) {
      context.pushNamed('map-screen-losas');
    } else {
      _showErrorSnackBar('No hay datos de losas');
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

      final pdfFile = await PDFFactory.generateLosaAligeradaPDF(ref);
      final xFile = XFile(pdfFile.path);

      context.hideLoader();

      await Share.shareXFiles(
        [xFile],
        text: 'Resultados del metrado de losas aligeradas - METRASHOP',
      );
    } catch (e) {
      context.hideLoader();
      _showErrorSnackBar('Error al generar PDF: $e');
    }
  }

  Future<void> _shareText() async {
    try {
      Navigator.of(context).pop();
      final shareText = _generateShareText();
      await Share.share(shareText);
    } catch (e) {
      _showErrorSnackBar('Error al compartir: $e');
    }
  }

  String _generateShareText() {
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);
    final datosLosa = ref.watch(datosShareLosaAligeradaProvider);
    final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider);
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider);
    final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider);

    final buffer = StringBuffer();

    // Encabezado
    buffer.writeln('METRASHOP - LOSAS ALIGERADAS');
    buffer.writeln('=' * 50);
    buffer.writeln();

    // Información del proyecto
    if (losasAligeradas.isNotEmpty) {
      final primeraLosa = losasAligeradas.first;
      buffer.writeln('INFORMACIÓN DEL PROYECTO:');
      buffer.writeln('• Altura de losa: ${primeraLosa.altura}');
      buffer.writeln('• Material aligerado: ${primeraLosa.materialAligerado}');
      buffer.writeln('• Resistencia concreto: ${primeraLosa.resistenciaConcreto}');
      buffer.writeln('• Total de losas: ${losasAligeradas.length}');
      buffer.writeln();
    }

    // Datos del metrado
    buffer.writeln('DATOS DEL METRADO:');
    buffer.writeln(datosLosa);
    buffer.writeln();

    // Lista de materiales
    buffer.writeln('LISTA DE MATERIALES:');
    buffer.writeln('• Cemento: ${cantidadCemento.ceil()} bls');
    buffer.writeln('• Arena gruesa: ${cantidadArena.toStringAsFixed(2)} m³');
    buffer.writeln('• Piedra chancada: ${cantidadPiedra.toStringAsFixed(2)} m³');
    buffer.writeln('• Agua: ${cantidadAgua.toStringAsFixed(2)} m³');
    buffer.writeln();

    // Pie de página
    buffer.writeln('Calculado con METRASHOP');
    buffer.writeln('"CALCULA Y COMPRA SIN PARAR DE CONSTRUIR"');
    buffer.writeln('Fecha: ${_getCurrentDate()}');

    return buffer.toString();
  }

  Future<File> _generatePDF() async {
    final pdf = pw.Document();
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);
    final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider);
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider);
    final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider);
    final volumenConcreto = ref.watch(volumenConcretoLosaAligeradaProvider);

    if (losasAligeradas.isEmpty) {
      throw Exception('No hay datos de losas para generar PDF');
    }

    final primeraLosa = losasAligeradas.first;

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Título
            pw.Text(
              'RESULTADOS DE LOSAS ALIGERADAS',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Información del proyecto
            pw.Text(
              'INFORMACIÓN DEL PROYECTO:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Altura de losa: ${primeraLosa.altura}'),
            pw.Text('• Material aligerado: ${primeraLosa.materialAligerado}'),
            pw.Text('• Resistencia concreto: ${primeraLosa.resistenciaConcreto}'),
            pw.Text('• Área total: ${_calcularAreaTotal(losasAligeradas).toStringAsFixed(2)} m²'),
            pw.Text('• Total de losas: ${losasAligeradas.length}'),
            pw.Text('• Volumen total concreto: ${volumenConcreto.toStringAsFixed(2)} m³'),
            pw.SizedBox(height: 20),

            // Materiales calculados
            pw.Text(
              'MATERIALES CALCULADOS:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Cemento: ${cantidadCemento.ceil()} bolsas'),
            pw.Text('• Arena gruesa: ${cantidadArena.toStringAsFixed(2)} m³'),
            pw.Text('• Piedra chancada: ${cantidadPiedra.toStringAsFixed(2)} m³'),
            pw.Text('• Agua: ${cantidadAgua.toStringAsFixed(2)} m³'),
            pw.SizedBox(height: 20),

            // Configuración aplicada
            pw.Text(
              'CONFIGURACIÓN APLICADA:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Desperdicio de ladrillo: ${double.tryParse(primeraLosa.desperdicioLadrillo) ?? 5.0}%'),
            pw.Text('• Desperdicio de concreto: ${double.tryParse(primeraLosa.desperdicioConcreto) ?? 5.0}%'),
            pw.SizedBox(height: 20),

            // Detalle de losas
            pw.Text(
              'DETALLE DE LOSAS:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...losasAligeradas.map((losa) => pw.Text(
              '• ${losa.description}: ${_calcularAreaLosa(losa).toStringAsFixed(2)} m²',
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
            pw.Text('• El volumen de concreto se calcula según el tipo de material aligerado',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Factores de desperdicio aplicados de forma independiente',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Generado por METRASHOP - ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/resultados_losas_aligeradas_${DateTime.now().millisecondsSinceEpoch}.pdf');
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