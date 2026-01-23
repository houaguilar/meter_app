import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/piso/piso.dart';
import 'package:meter_app/config/assets/app_icons.dart';
import '../../../../../blocs/profile/profile_bloc.dart';
import '../../../../../providers/pisos/falso_piso_providers.dart';
import '../../../../../widgets/widgets.dart';

/// Redondea un número hacia arriba con la cantidad de decimales especificada
/// Similar a la función ROUNDUP de Excel
double roundUp(double value, int decimals) {
  final multiplier = pow(10, decimals).toInt();
  return (value * multiplier).ceil() / multiplier;
}

class ResultFalsoPisoScreen extends ConsumerStatefulWidget {
  const ResultFalsoPisoScreen({super.key});

  @override
  ConsumerState<ResultFalsoPisoScreen> createState() => _ResultFalsoPisoScreenState();
}

class _ResultFalsoPisoScreenState extends ConsumerState<ResultFalsoPisoScreen>
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
        ref.read(falsoPisoResultProvider.notifier).clearList();
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
    final falsosPisos = ref.watch(falsoPisoResultProvider);
    final materials = ref.watch(falsoPisoMaterialsProvider);

    if (falsosPisos.isEmpty) {
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
          _buildMetradoDataCard(falsosPisos),
          const SizedBox(height: 20),
          _buildMaterialsCard(materials),
          const SizedBox(height: 20),
          _buildConfigurationCard(falsosPisos),
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
              'No hay datos de falso piso',
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

  Widget _buildMaterialsCard(FalsoPisoMaterials materials) {
    return _buildModernCard(
      title: 'Lista de Materiales',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.success,
      child: Column(
        children: [
          _buildMaterialTable(materials),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(List<Piso> pisos) {
    if (pisos.isEmpty) return const SizedBox.shrink();

    final primerPiso = pisos.first;
    final espesor = double.tryParse(primerPiso.espesor) ?? 5.0;
    final desperdicio = double.tryParse(primerPiso.factorDesperdicio) ?? 5.0;
    final resistencia = primerPiso.resistencia ?? '175 kg/cm²';

    return _buildModernCard(
      title: 'Configuración Aplicada',
      icon: Icons.settings_outlined,
      iconColor: AppColors.warning,
      child: Column(
        children: [
          _buildConfigRow('Espesor', '${espesor.toStringAsFixed(1)} cm'),
          const SizedBox(height: 12),
          _buildConfigRow('Factor de Desperdicio', '${desperdicio.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          _buildConfigRow('Resistencia del Concreto', resistencia),
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
              color: iconColor.withOpacity(0.2),
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
    final areas = ref.watch(areaFalsoPisoProvider);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', 'Área'], isHeader: true),
        ...pisos.asMap().entries.map((entry) {
          final index = entry.key;
          final piso = entry.value;
          final area = index < areas.length ? areas[index] : 0.0;
          return _buildTableRow([
            piso.description,
            'm²',
            area.toStringAsFixed(1),
          ]);
        }).toList(),
        _buildTableRow([
          'Total:',
          'm²',
          ref.watch(falsoPisoMaterialsProvider).areaTotalFormateada,
        ], isTotal: true),
      ],
    );
  }

  Widget _buildMaterialTable(FalsoPisoMaterials materials) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        _buildTableRow(['Cemento', 'bls', materials.cementoBolsas.toString()]),
        _buildTableRow(['Arena gruesa', 'm³', materials.arenaFormateada]),
        _buildTableRow(['Piedra chancada', 'm³', materials.piedraFormateada]),
        _buildTableRow(['Agua', 'm³', materials.aguaFormateada]),
      ],
    );
  }

  // ✅ NUEVO: Widget con tooltip para unidades
  Widget _buildUnitWithTooltip(String unit) {
    String tooltip = unit == 'm²' ? 'Metros cuadrados (área)' :
    unit == 'm³' ? 'Metros cúbicos (volumen)' :
    unit == 'bls' ? 'Bolsas de cemento' : unit;

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
    final falsosPisos = ref.watch(falsoPisoResultProvider);

    if (falsosPisos.isEmpty) {
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
    final falsosPisos = ref.watch(falsoPisoResultProvider);
    if (falsosPisos.isNotEmpty) {
      context.pushNamed('falso-piso-save');
    } else {
      _showErrorSnackBar('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final falsosPisos = ref.watch(falsoPisoResultProvider);
    if (falsosPisos.isNotEmpty) {
      FeatureStatusDialog.showTemporarilyDisabled(context);
   //   context.pushNamed('falso-piso-map-screen');
    } else {
      _showErrorSnackBar('No hay datos de falso piso');
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
      Navigator.of(context).pop();

      context.showCalculationLoader(
        message: 'Generando PDF...',
        description: 'Creando documento con los resultados',
      );

      // Obtener nombre del usuario del ProfileBloc
      final profileState = context.read<ProfileBloc>().state;
      final nombreUsuario = profileState is ProfileLoaded
          ? profileState.userProfile.name
          : null;

      final pdfFile = await PDFFactory.generateFalsoPisoPDF(
        ref,
        nombreUsuario: nombreUsuario,
      );
      final xFile = XFile(pdfFile.path);

      context.hideLoader();

      await Share.shareXFiles(
        [xFile],
        text: 'Resultados del metrado de falso piso - METRASHOP',
      );
    } catch (e) {
      context.hideLoader();
      _showErrorSnackBar('Error al generar PDF: $e');
    }
  }

  Future<void> _shareText() async {
    try {
      Navigator.of(context).pop();
      final materials = ref.watch(falsoPisoMaterialsProvider);
      final falsosPisos = ref.watch(falsoPisoResultProvider);
      final datosMetrado = ref.watch(datosShareFalsoPisoProvider);

      final shareText = _generateShareText(materials, datosMetrado, falsosPisos);

      await Share.share(shareText);
    } catch (e) {
      _showErrorSnackBar('Error al compartir: $e');
    }
  }

  String _generateShareText(FalsoPisoMaterials materials, String datosMetrado, List<Piso> pisos) {
    final configInfo = pisos.isNotEmpty ? _getConfigInfo(pisos) : '';

    return '''RESULTADOS DE FALSO PISO - METRASHOP

DATOS DEL METRADO:
$datosMetrado

LISTA DE MATERIALES:
• Cemento: ${materials.cementoBolsas} bls
• Arena gruesa: ${materials.arenaFormateada} m³
• Piedra chancada: ${materials.piedraFormateada} m³
• Agua: ${materials.aguaFormateada} m³

INFORMACIÓN DEL PROYECTO:
• Área total: ${materials.areaTotalFormateada} m²
• Total de elementos: ${pisos.length}
$configInfo

Generado por METRASHOP - ${DateTime.now().toString().split(' ')[0]}''';
  }

  String _getConfigInfo(List<Piso> pisos) {
    final primer = pisos.first;
    return '''• Resistencia: ${primer.resistencia ?? '175 kg/cm²'}
• Espesor: ${double.tryParse(primer.espesor) ?? 5.0} cm
• Desperdicio: ${double.tryParse(primer.factorDesperdicio) ?? 5.0}%''';
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
}