// lib/presentation/screens/home/tarrajeo/derrame/result/result_tarrajeo_derrame_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:meter_app/presentation/providers/tarrajeo/tarrajeo_derrame_providers.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../../config/theme/theme.dart';
import '../../../../../assets/icons.dart';
import '../../../../../widgets/widgets.dart';

class ResultTarrajeoDerrameScreen extends ConsumerStatefulWidget {
  const ResultTarrajeoDerrameScreen({super.key});

  @override
  ConsumerState<ResultTarrajeoDerrameScreen> createState() => _ResultTarrajeoDerrameScreenState();
}

class _ResultTarrajeoDerrameScreenState extends ConsumerState<ResultTarrajeoDerrameScreen>
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
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  void _hideLoaderAfterDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.hideLoader();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tarrajeos = ref.watch(tarrajeoDerrameResultProvider);
    final materiales = ref.watch(tarrajeoDerrrameMaterialesProvider);
    final metrados = ref.watch(tarrajeoDerrameMetradosProvider);
    final tipoTarrajeo = ref.watch(tipoTarrajeoDerrrameProvider);

    return Scaffold(
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBarWidget(titleAppBar: 'Resultados Tarrajeo Derrame');
  }

  Widget _buildBody() {
    final materiales = ref.watch(tarrajeoDerrrameMaterialesProvider);
    final tarrajeos = ref.watch(tarrajeoDerrameResultProvider);

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
              'No hay datos de tarrajeo derrame',
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
          scale: value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetradoDataCard() {
    final metrados = ref.watch(tarrajeoDerrameMetradosProvider);
    final totalArea = metrados.fold(0.0, (sum, metrado) => sum + metrado.area);
    final totalVolumen = metrados.fold(0.0, (sum, metrado) => sum + metrado.volumen);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueMetraShop.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.straighten_outlined,
                  color: AppColors.blueMetraShop,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Metrado del Proyecto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueMetraShop,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
            },
            children: [
              _buildTableRow(['Elemento', 'Área', 'Vol.'], isHeader: true),
              ...metrados.map<TableRow>((metrado) => _buildTableRow([
                metrado.descripcion,
                '${metrado.areaFormateada} m²',
                '${metrado.volumenFormateado} m³',
              ])).toList(),
              _buildTableRow([
                'TOTAL',
                '${totalArea.toStringAsFixed(2)} m²',
                '${totalVolumen.toStringAsFixed(4)} m³',
              ], isTotal: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(dynamic materiales) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Materiales Requeridos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.5),
            },
            children: [
              _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
              _buildTableRow(['Cemento', 'bls', materiales.cementoFormateado]),
              _buildTableRow(['Arena fina', 'm³', materiales.arenaFormateada]),
              _buildTableRow(['Agua', 'm³', materiales.aguaFormateada]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard() {
    final tarrajeos = ref.watch(tarrajeoDerrameResultProvider);
    if (tarrajeos.isEmpty) return const SizedBox.shrink();

    final tarrajeo = tarrajeos.first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueMetraShop.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: AppColors.blueMetraShop,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Configuración Técnica',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueMetraShop,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildConfigRow('Tipo de tarrajeo', tarrajeo.tipo),
              _buildConfigRow('Proporción mortero', '1:${tarrajeo.proporcionMortero}'),
              _buildConfigRow('Espesor aplicado', '${tarrajeo.espesor} cm'),
              _buildConfigRow('Factor desperdicio', '${tarrajeo.factorDesperdicio}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard(String tipoTarrajeo, int cantidadElementos) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              AppIcons.archiveProjectIcon,
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                AppColors.surface,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipoTarrajeo.isNotEmpty ? tipoTarrajeo : 'Tarrajeo Derrame',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cantidadElementos elemento${cantidadElementos != 1 ? 's' : ''} calculado${cantidadElementos != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.surface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cálculo completado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
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

  Widget _buildMaterialTable(dynamic materiales) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        _buildTableRow(['Cemento', 'bls', materiales.cementoFormateado]),
        _buildTableRow(['Arena fina', 'm³', materiales.arenaFormateada]),
        _buildTableRow(['Agua', 'm³', materiales.aguaFormateada]),
      ],
    );
  }

  Widget _buildMetradoTable(dynamic metrados) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Elemento', 'Área (m²)', 'Vol. (m³)'], isHeader: true),
        ...metrados.map<TableRow>((metrado) => _buildTableRow([
          metrado.descripcion,
          metrado.areaFormateada,
          metrado.volumenFormateado,
        ])).toList(),
        // Fila de totales
        _buildTableRow([
          'TOTAL',
          '${metrados.fold(0.0, (sum, metrado) => sum + metrado.area).toStringAsFixed(2)}',
          '${metrados.fold(0.0, (sum, metrado) => sum + metrado.volumen).toStringAsFixed(4)}',
        ], isTotal: true),
      ],
    );
  }

  Widget _buildConfigTable(dynamic tarrajeo) {
    return Column(
      children: [
        _buildConfigRow('Tipo de tarrajeo', tarrajeo.tipo),
        _buildConfigRow('Proporción mortero', '1:${tarrajeo.proporcionMortero}'),
        _buildConfigRow('Espesor aplicado', '${tarrajeo.espesor} cm'),
        _buildConfigRow('Factor desperdicio', '${tarrajeo.factorDesperdicio}%'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recomendaciones técnicas:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• El tarrajeo derrame requiere mayor precisión en la aplicación\n'
                    '• Usar mortero más rico (1:4) para mejor acabado\n'
                    '• Aplicar en capas uniformes para evitar irregularidades\n'
                    '• Curar adecuadamente para evitar fisuras',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.blueMetraShop.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
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
  }

  // ✅ Widget con tooltip para unidades (copiado exactamente de tu código)
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ✅ Filas de tabla exactamente como en tu código original
  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, bool isTotal = false}) {
    return TableRow(
      decoration: isHeader ? BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ) : isTotal ? BoxDecoration(
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
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed('map-screen-tarrajeo-derrame'),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Buscar Proveedores'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
    context.pushNamed('save-tarrajeo-derrame');
  }

  void _showShareOptions() async {
    try {
      final materiales = ref.read(tarrajeoDerrrameMaterialesProvider);
      final shareText = '''
🏗️ Resultados - Tarrajeo Derrame

📦 Materiales Requeridos:
• Cemento: ${materiales.cementoFormateado} bolsas
• Arena fina: ${materiales.arenaFormateada} m³
• Agua: ${materiales.aguaFormateada} m³

Calculado con MetraShop 📱
      ''';

      await Share.share(shareText);
    } catch (e) {
      _showErrorMessage('Error al compartir: ${e.toString()}');
    }
  }

  Future<void> _generatePDF() async {
    try {
      context.showCalculationLoader(
        message: 'Generando PDF',
        description: 'Creando documento...',
      );

      // Simular generación de PDF (aquí integrarías con PDFFactory)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        context.hideLoader();
        _showSuccessMessage('PDF generado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        context.hideLoader();
        _showErrorMessage('Error al generar PDF: ${e.toString()}');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}