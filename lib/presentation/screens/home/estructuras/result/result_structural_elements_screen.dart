// lib/presentation/screens/home/estructuras/result/result_structural_elements_screen.dart
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
import '../../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultStructuralElementsScreen extends ConsumerStatefulWidget {
  const ResultStructuralElementsScreen({super.key});

  @override
  ConsumerState<ResultStructuralElementsScreen> createState() => _ResultStructuralElementsScreenState();
}

class _ResultStructuralElementsScreenState extends ConsumerState<ResultStructuralElementsScreen>
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
      final tipoElemento = ref.read(tipoStructuralElementProvider);
      final columnas = ref.read(columnaResultProvider);
      final vigas = ref.read(vigaResultProvider);

      print('🔍 Estado en ResultScreen:');
      print('- Tipo: $tipoElemento');
      print('- Columnas: ${columnas.length}');
      print('- Vigas: ${vigas.length}');

      if (tipoElemento.isEmpty ||
          (tipoElemento == 'columna' && columnas.isEmpty) ||
          (tipoElemento == 'viga' && vigas.isEmpty)) {
        print('❌ No hay datos válidos, regresando...');
        _showErrorMessage('No hay datos para mostrar. Vuelve a intentar.');
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

    return WillPopScope(
      onWillPop: () async {
        _clearDataOnExit();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(tipoElemento),
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(tipoElemento),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBarWidget(titleAppBar: 'Resultados');
  }

  Widget _buildBody(String tipoElemento) {
    if (tipoElemento.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
          _buildMetradoDataCard(tipoElemento),
          const SizedBox(height: 20),
          _buildMaterialsCard(tipoElemento),
          const SizedBox(height: 20),
          _buildConfigurationCard(tipoElemento),
          const SizedBox(height: 120),
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

  Widget _buildMetradoDataCard(String tipoElemento) {
    return _buildModernCard(
      title: 'Datos del Metrado',
      icon: Icons.view_list_outlined,
      iconColor: AppColors.accent,
      child: Column(
        children: [
          _buildDataTable(tipoElemento),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(String tipoElemento) {
    return _buildModernCard(
      title: 'Lista de Materiales',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.success,
      child: Column(
        children: [
          _buildMaterialTable(tipoElemento),
 //         const SizedBox(height: 16),
   //       _buildMaterialChips(tipoElemento),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(String tipoElemento) {
    final factorDesperdicio = _getFactorDesperdicio(tipoElemento);
    final resistencia = _getResistencia(tipoElemento);

    return _buildModernCard(
      title: 'Configuración Aplicada',
      icon: Icons.settings_outlined,
      iconColor: AppColors.warning,
      child: Column(
        children: [
          _buildConfigRow('Factor de Desperdicio', '${factorDesperdicio.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          _buildConfigRow('Resistencia del Concreto', resistencia),
          const SizedBox(height: 12),
          _buildConfigRow('Tipo de Elemento', tipoElemento.capitalize()),
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

  Widget _buildDataTable(String tipoElemento) {
    final elements = _getElements(tipoElemento);
    final volumenes = _getVolumenes(tipoElemento);
    final totalVolumen = _getTotalVolumen(tipoElemento);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', 'Volumen'], isHeader: true),
        ...List.generate(elements.length, (index) {
          return _buildTableRow([
            elements[index].description ?? 'Sin descripción',
            'm³',
            volumenes[index].toStringAsFixed(2),
          ]);
        }),
        _buildTableRow([
          'Total:',
          'm³',
          totalVolumen.toStringAsFixed(2),
        ], isTotal: true),
      ],
    );
  }

  Widget _buildMaterialTable(String tipoElemento) {
    final cemento = _getCemento(tipoElemento);
    final arena = _getArena(tipoElemento);
    final piedra = _getPiedra(tipoElemento);
    final agua = _getAgua(tipoElemento);

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
        _buildTableRow(['Piedra para concreto', 'm³', piedra.toStringAsFixed(2)]),
        _buildTableRow(['Agua', 'm³', agua.toStringAsFixed(2)]),
      ],
    );
  }

  Widget _buildMaterialChips(String tipoElemento) {
    final cemento = _getCemento(tipoElemento);
    final arena = _getArena(tipoElemento);
    final piedra = _getPiedra(tipoElemento);
    final agua = _getAgua(tipoElemento);

    final materials = [
      {'icon': Icons.inventory, 'label': 'Cemento', 'value': '${cemento.ceil()} bls', 'color': AppColors.primary},
      {'icon': Icons.grain, 'label': 'Arena', 'value': '${arena.toStringAsFixed(2)} m³', 'color': AppColors.secondary},
      {'icon': Icons.texture, 'label': 'Piedra', 'value': '${piedra.toStringAsFixed(2)} m³', 'color': AppColors.warning},
      {'icon': Icons.water_drop, 'label': 'Agua', 'value': '${agua.toStringAsFixed(2)} m³', 'color': AppColors.info},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: materials.map((material) {
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

  Widget _buildBottomActionBar(String tipoElemento) {
    if (tipoElemento.isEmpty) {
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

  // Métodos auxiliares para obtener datos
  List<dynamic> _getElements(String tipoElemento) {
    if (tipoElemento == 'columna') {
      return ref.watch(columnaResultProvider);
    } else if (tipoElemento == 'viga') {
      return ref.watch(vigaResultProvider);
    }
    return [];
  }

  List<double> _getVolumenes(String tipoElemento) {
    if (tipoElemento == 'columna') {
      return ref.watch(volumenColumnaProvider);
    } else if (tipoElemento == 'viga') {
      return ref.watch(volumenVigaProvider);
    }
    return [];
  }

  double _getTotalVolumen(String tipoElemento) {
    final volumenes = _getVolumenes(tipoElemento);
    return volumenes.fold(0.0, (sum, volumen) => sum + volumen);
  }

  int _getTotalElementos(String tipoElemento) {
    return _getElements(tipoElemento).length;
  }

  String _getResistencia(String tipoElemento) {
    final elements = _getElements(tipoElemento);
    if (elements.isNotEmpty) {
      return elements.first.resistencia ?? 'N/A';
    }
    return 'N/A';
  }

  double _getFactorDesperdicio(String tipoElemento) {
    final elements = _getElements(tipoElemento);
    if (elements.isNotEmpty) {
      return double.tryParse(elements.first.factorDesperdicio ?? '5') ?? 5.0;
    }
    return 5.0;
  }

  double _getCemento(String tipoElemento) {
    if (tipoElemento == 'columna') {
      return ref.watch(cantidadCementoColumnaProvider);
    } else if (tipoElemento == 'viga') {
      return ref.watch(cantidadCementoVigaProvider);
    }
    return 0.0;
  }

  double _getArena(String tipoElemento) {
    if (tipoElemento == 'columna') {
      return ref.watch(cantidadArenaColumnaProvider);
    } else if (tipoElemento == 'viga') {
      return ref.watch(cantidadArenaVigaProvider);
    }
    return 0.0;
  }

  double _getPiedra(String tipoElemento) {
    if (tipoElemento == 'columna') {
      return ref.watch(cantidadPiedraColumnaProvider);
    } else if (tipoElemento == 'viga') {
      return ref.watch(cantidadPiedraVigaProvider);
    }
    return 0.0;
  }

  double _getAgua(String tipoElemento) {
    if (tipoElemento == 'columna') {
      return ref.watch(cantidadAguaColumnaProvider);
    } else if (tipoElemento == 'viga') {
      return ref.watch(cantidadAguaVigaProvider);
    }
    return 0.0;
  }

  // Métodos de acción
  void _handleSaveAction() {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);
    if (tipoElemento.isNotEmpty) {
      context.pushNamed('save-structural-element');
    } else {
      _showErrorMessage('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);
    if (tipoElemento.isNotEmpty) {
      context.pushNamed('map-screen-structural');
    } else {
      _showErrorMessage('No hay datos de elementos estructurales');
    }
  }

  Future<void> _sharePDF() async {
    try {
      Navigator.of(context).pop();

      context.showCalculationLoader(
        message: 'Generando PDF...',
        description: 'Creando documento con los resultados',
      );

      final pdfFile = await PDFFactory.generateStructuralElementPDF(ref);

      final xFile = XFile(pdfFile.path);

      context.hideLoader();

      await Share.shareXFiles(
        [xFile],
        text: 'Resultados del metrado de elementos estructurales - METRASHOP',
      );
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
    final tipoElemento = ref.watch(tipoStructuralElementProvider);
    final elements = _getElements(tipoElemento);
    final volumenes = _getVolumenes(tipoElemento);

    String datosMetrado = 'DATOS METRADO\n';
    for (int i = 0; i < elements.length && i < volumenes.length; i++) {
      datosMetrado += '* ${elements[i].description}: ${volumenes[i].toStringAsFixed(2)} m³\n';
    }

    final cemento = _getCemento(tipoElemento);
    final arena = _getArena(tipoElemento);
    final piedra = _getPiedra(tipoElemento);
    final agua = _getAgua(tipoElemento);

    return '''$datosMetrado
-------------
LISTA DE MATERIALES
*Cemento: ${cemento.ceil()} bls
*Arena gruesa: ${arena.toStringAsFixed(2)} m³
*Piedra para concreto: ${piedra.toStringAsFixed(2)} m³
*Agua: ${agua.toStringAsFixed(2)} m³

*Factor de Desperdicio: ${_getFactorDesperdicio(tipoElemento).toStringAsFixed(1)}%
*Resistencia: ${_getResistencia(tipoElemento)}''';
  }

  Future<File> _generatePDF() async {
    final pdf = pw.Document();
    final tipoElemento = ref.watch(tipoStructuralElementProvider);
    final elements = _getElements(tipoElemento);
    final volumenes = _getVolumenes(tipoElemento);

    if (elements.isEmpty) {
      throw Exception('No hay datos de elementos estructurales para generar PDF');
    }

    final primerElemento = elements.first;
    final cemento = _getCemento(tipoElemento);
    final arena = _getArena(tipoElemento);
    final piedra = _getPiedra(tipoElemento);
    final agua = _getAgua(tipoElemento);
    final totalVolumen = _getTotalVolumen(tipoElemento);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Título
            pw.Text(
              'RESULTADOS DE ${tipoElemento.toUpperCase()}S',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Información del proyecto
            pw.Text(
              'INFORMACIÓN DEL PROYECTO:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Tipo de Elemento: ${tipoElemento.capitalize()}'),
            pw.Text('• Resistencia del Concreto: ${primerElemento.resistencia}'),
            pw.Text('• Volumen total: ${totalVolumen.toStringAsFixed(2)} m³'),
            pw.Text('• Total de ${tipoElemento}s: ${elements.length}'),
            pw.SizedBox(height: 20),

            // Materiales calculados
            pw.Text(
              'MATERIALES CALCULADOS:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Cemento: ${cemento.ceil()} bolsas'),
            pw.Text('• Arena gruesa: ${arena.toStringAsFixed(2)} m³'),
            pw.Text('• Piedra para concreto: ${piedra.toStringAsFixed(2)} m³'),
            pw.Text('• Agua: ${agua.toStringAsFixed(2)} m³'),
            pw.SizedBox(height: 20),

            // Configuración aplicada
            pw.Text(
              'CONFIGURACIÓN APLICADA:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Factor de Desperdicio: ${_getFactorDesperdicio(tipoElemento).toStringAsFixed(1)}%'),
            pw.Text('• Resistencia del Concreto: ${_getResistencia(tipoElemento)}'),
            pw.SizedBox(height: 20),

            // Detalle de elementos
            pw.Text(
              'DETALLE DE ${tipoElemento.toUpperCase()}S:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...List.generate(elements.length, (index) => pw.Text(
              '• ${elements[index].description}: ${volumenes[index].toStringAsFixed(2)} m³',
              style: pw.TextStyle(fontSize: 12),
            )),
            pw.SizedBox(height: 20),

            // Información técnica
            pw.Text(
              'INFORMACIÓN TÉCNICA:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text('• Cálculos basados en dosificaciones de concreto según resistencia',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Factores de desperdicio aplicados independientemente',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Volúmenes calculados en metros cúbicos (m³)',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Generado por METRASHOP - ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/resultados_${tipoElemento}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  void _clearDataOnExit() {
    final tipoElemento = ref.read(tipoStructuralElementProvider);
    if (tipoElemento == 'columna') {
      ref.read(columnaResultProvider.notifier).clearList();
    } else if (tipoElemento == 'viga') {
      ref.read(vigaResultProvider.notifier).clearList();
    }
    print('🧹 Datos limpiados al salir');
  }

  void _showErrorMessage(String message) {
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

// Extension helper para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}