import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:meter_app/presentation/providers/tarrajeo/tarrajeo_providers.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import 'package:meter_app/config/assets/app_icons.dart';
import '../../../../blocs/profile/profile_bloc.dart';
import '../../../../widgets/widgets.dart';

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
    return AppBarWidget(titleAppBar: 'Resultados Tarrajeo');
  }

  Widget _buildBody() {
    final materiales = ref.watch(tarrajeoMaterialesProvider);
    final tarrajeos = ref.watch(tarrajeoResultProvider);

    if (tarrajeos.isEmpty) {
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
          _buildConfigRow('Factor de Desperdicio', '${desperdicioTarrajeo.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          _buildConfigRow('Espesor Promedio', '${estadisticas['espesor_promedio'].toStringAsFixed(1)} cm'),
          const SizedBox(height: 12),
          _buildConfigRow('Proporción Mortero', '1:${estadisticas['proporcion_mas_usada']}'),
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

  // ✅ MEJORADO: Fila de resumen con mayor tamaño de fuente
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
            fontSize: 16, // ✅ Aumentado de 14 a 16
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
        _buildTableRow(['Cemento', 'bls', materiales.cementoFormateado.toString()]),
        _buildTableRow(['Arena fina', 'm³', materiales.arenaFormateada]),
        _buildTableRow(['Agua', 'm³', materiales.aguaFormateada]),
      ],
    );
  }

  // ✅ NUEVO: Widget con tooltip para unidades
  Widget _buildUnitWithTooltip(String unit) {
    String tooltip = unit == 'm²' ? 'Metros cuadrados (área)' :
    unit == 'm³' ? 'Metros cúbicos (volumen)' :
    unit == 'bls' ? 'Bolsas de cemento' :
    unit == 'kg' ? 'Kilogramos de peso' : unit;

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

  Widget _buildBottomActionBar() {
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
                      onPressed: () => _saveResults(),
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
                  onPressed: () => _searchProviders(),
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

  void _saveResults() {
    final tarrajeos = ref.watch(tarrajeoResultProvider);
    if (tarrajeos.isNotEmpty) {
      context.pushNamed('save-tarrajeo');
    } else {
      _showErrorSnackBar('No hay datos para guardar');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _searchProviders() {
    FeatureStatusDialog.showTemporarilyDisabled(context);
    //  context.pushNamed('map-screen-tarrajeo');
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

  Future<void> _sharePDF() async {
    try {
      Navigator.pop(context);
      context.showCalculationLoader(
        message: 'Generando PDF...',
        description: 'Creando documento con los resultados',
      );

      // Obtener nombre del usuario del ProfileBloc
      final profileState = context.read<ProfileBloc>().state;
      final nombreUsuario = profileState is ProfileLoaded
          ? profileState.userProfile.name
          : null;

      final pdfFile = await PDFFactory.generateTarrajeoPDF(
        ref,
        nombreUsuario: nombreUsuario,
      );
      final result = await Share.shareXFiles([XFile(pdfFile.path)]);

      if (result.status == ShareResultStatus.success) {
        _showSuccessMessage('PDF compartido exitosamente');
      }
    } catch (e) {
      _showErrorMessage('Error al generar PDF: $e');
    } finally {
      context.hideLoader();
    }
  }

  Future<void> _shareText() async {
    try {
      Navigator.pop(context);
      final resumen = ref.read(resumenCompletoProvider);
      await Share.share(resumen, subject: 'Resultados de Tarrajeo');
    } catch (e) {
      _showErrorMessage('Error al compartir texto: $e');
    }
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
}

// Widget para mostrar la tabla de metrados con mejoras
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

    double areaTotal = metrados.fold(0.0, (sum, m) => sum + m.area);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', 'Área'], isHeader: true),
        ...metrados.map((metrado) => _buildTableRow([
          metrado.descripcion,
          'm²',
          metrado.areaFormateada,
        ])).toList(),
        _buildTableRow([
          'Total:',
          'm²',
          areaTotal.toStringAsFixed(1),
        ], isTotal: true),
      ],
    );
  }

  // ✅ NUEVO: Widget con tooltip para unidades
  Widget _buildUnitWithTooltip(String unit) {
    String tooltip = unit == 'm²' ? 'Metros cuadrados (área)' :
    unit == 'm³' ? 'Metros cúbicos (volumen)' :
    unit == 'bls' ? 'Bolsas de cemento' :
    unit == 'kg' ? 'Kilogramos de peso' : unit;

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
}