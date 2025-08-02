import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../../widgets/widgets.dart';

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
          _buildConfigRow('Tipo de Elemento', tipoElemento == 'columna' ? 'Columnas' : 'Vigas'),
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
      margin: const EdgeInsets.symmetric(horizontal: 0),
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
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
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
        _buildTableRow(['Cemento', 'bls', cemento.ceil().toString()]),
        _buildTableRow(['Arena gruesa', 'm³', arena.toStringAsFixed(2)]),
        _buildTableRow(['Piedra chancada', 'm³', piedra.toStringAsFixed(2)]),
        _buildTableRow(['Agua', 'm³', agua.toStringAsFixed(2)]),
      ],
    );
  }

  // ✅ NUEVO: Widget con tooltip para unidades
  Widget _buildUnitWithTooltip(String unit) {
    String tooltip = unit == 'm³' ? 'Metros cúbicos (volumen)' :
    unit == 'bls' ? 'Bolsas de cemento' :
    unit == 'kg/cm²' ? 'Kilogramos por centímetro cuadrado (resistencia)' : unit;

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          unit,
          style: const TextStyle(
            fontSize: 16, // ✅ Aumentado
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ✅ MEJORADO: Filas de tabla con tooltips y mayor tamaño de fuente
  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, bool isTotal = false}) {
    return TableRow(
      decoration: isTotal ? BoxDecoration(
        color: AppColors.blueMetraShop.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      children: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String cell = entry.value;

        // ✅ Para la columna de unidades (índice 1), usar tooltips
        Widget cellContent;
        if (index == 1 && !isHeader) {
          cellContent = _buildUnitWithTooltip(cell);
        } else {
          final textStyle = TextStyle(
            fontSize: isHeader ? 14 : 16, // ✅ Aumentado de 12 a 16
            fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? AppColors.textPrimary :
            isTotal ? AppColors.blueMetraShop : AppColors.textSecondary,
          );

          cellContent = Text(
            cell,
            style: textStyle,
            textAlign: index == 0 ? TextAlign.left : TextAlign.center,
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: cellContent,
        );
      }).toList(),
    );
  }

  Widget _buildBottomActionBar(String tipoElemento) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
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
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blueMetraShop,
                      side: const BorderSide(color: AppColors.blueMetraShop),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}