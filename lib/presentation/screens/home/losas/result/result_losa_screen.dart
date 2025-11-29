import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/utils/pdf/pdf_factory.dart';
import 'package:meter_app/config/assets/app_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/home/losas/losa.dart';
import '../../../../../domain/services/losas/losa_service.dart';
import '../../../../providers/providers.dart';
import '../../../../widgets/widgets.dart';

class ResultLosaScreen extends ConsumerStatefulWidget {
  const ResultLosaScreen({super.key});

  @override
  ConsumerState<ResultLosaScreen> createState() => _ResultLosaScreenState();
}

class _ResultLosaScreenState extends ConsumerState<ResultLosaScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 ResultLosaScreen - initState()');

    // Verificar el estado del provider al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final losas = ref.read(losaResultProvider);
      debugPrint('🎬 Provider al inicializar: ${losas.length} losas');
      if (losas.isNotEmpty) {
        debugPrint('🎬 Primera losa: ${losas.first.description}');
      } else {
        debugPrint('⚠️ Provider está vacío en initState!');
      }
    });

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
        ref.read(losaResultProvider.notifier).clearList();
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
    return AppBarWidget(titleAppBar: 'Resultados Losa');
  }

  Widget _buildBody() {
    final losas = ref.watch(losaResultProvider);

    debugPrint('📺 ResultLosaScreen - _buildBody()');
    debugPrint('📺 Losas en el provider: ${losas.length}');
    if (losas.isNotEmpty) {
      debugPrint('📺 Primera losa: ${losas.first.description}');
    }

    if (losas.isEmpty) {
      debugPrint('⚠️ Losas está vacío, mostrando empty state');
      return _buildEmptyState();
    }

    debugPrint('✅ Mostrando resultados de ${losas.length} losas');
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
          _buildMetradoDataCard(losas),
          const SizedBox(height: 20),
          _buildMaterialsConcretoCard(),
          const SizedBox(height: 20),
          _buildMaterialesAligerantesCard(),
          const SizedBox(height: 20),
          _buildConfigurationCard(losas),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 80,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos de losas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Regresa y agrega información de losas',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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

  Widget _buildMetradoDataCard(List<Losa> losas) {
    return _buildModernCard(
      title: 'Datos del Metrado',
      icon: Icons.view_list_outlined,
      iconColor: AppColors.accent,
      child: Column(
        children: [
          _buildDataTable(losas),
        ],
      ),
    );
  }

  Widget _buildMaterialsConcretoCard() {
    final cantidadCemento = ref.watch(cantidadCementoLosaProvider);
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaProvider);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaProvider);
    final cantidadAgua = ref.watch(cantidadAguaLosaProvider);
    final cantidadAditivo = ref.watch(cantidadAditivoPlastificanteLosaProvider);

    return _buildModernCard(
      title: 'Materiales de Concreto',
      icon: Icons.water_drop_outlined,
      iconColor: AppColors.blueMetraShop,
      child: Column(
        children: [
          _buildMaterialConcretoTable(
            cantidadCemento,
            cantidadArena,
            cantidadPiedra,
            cantidadAditivo,
            cantidadAgua,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialesAligerantesCard() {
    final materialesAligerantes = ref.watch(materialesAligerantesProvider);

    // Si no hay materiales aligerantes, no mostrar card
    if (materialesAligerantes.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildModernCard(
      title: 'Materiales Aligerantes',
      icon: Icons.grid_view_outlined,
      iconColor: AppColors.warning,
      child: Column(
        children: [
          _buildMaterialAligeranteTable(materialesAligerantes),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(List<Losa> losas) {
    if (losas.isEmpty) return const SizedBox.shrink();

    final primeraLosa = losas.first;
    final desperdicioConcreto = double.tryParse(primeraLosa.desperdicioConcreto) ?? 5.0;
    final desperdicioMaterial = primeraLosa.desperdicioMaterialAligerante != null
        ? double.tryParse(primeraLosa.desperdicioMaterialAligerante!) ?? 7.0
        : null;

    return _buildModernCard(
      title: 'Configuración Aplicada',
      icon: Icons.settings_outlined,
      iconColor: AppColors.secondary,
      child: Column(
        children: [
          _buildConfigRow('Tipo de Losa', primeraLosa.tipoLosa.displayName),
          const SizedBox(height: 12),
          _buildConfigRow('Altura', primeraLosa.altura),
          const SizedBox(height: 12),
          if (primeraLosa.materialAligerante != null) ...[
            _buildConfigRow('Material Aligerante', primeraLosa.materialAligerante!),
            const SizedBox(height: 12),
          ],
          _buildConfigRow('Resistencia Concreto', primeraLosa.resistenciaConcreto),
          const SizedBox(height: 12),
          _buildConfigRow('Desperdicio Concreto', '${desperdicioConcreto.toStringAsFixed(1)}%'),
          if (desperdicioMaterial != null) ...[
            const SizedBox(height: 12),
            _buildConfigRow('Desperdicio Material', '${desperdicioMaterial.toStringAsFixed(1)}%'),
          ],
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
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(List<Losa> losas) {
    final areaTotal = _calcularAreaTotal(losas);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Descripción', 'Und.', 'Área'], isHeader: true),
        ...losas.map((losa) {
          final area = _calcularAreaLosa(losa);
          return _buildTableRow([
            losa.description,
            'm²',
            area.toStringAsFixed(1),
          ]);
        }).toList(),
        _buildTableRow([
          'Total:',
          'm²',
          areaTotal.toStringAsFixed(1),
        ], isTotal: true),
      ],
    );
  }

  Widget _buildMaterialConcretoTable(
    double cemento,
    double arena,
    double piedra,
    double aditivo,
    double agua,
  ) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        _buildTableRow(['Cemento', 'bls', cemento.ceil().toString()]),
        _buildTableRow(['Arena gruesa', 'm³', arena.toStringAsFixed(1)]),
        _buildTableRow(['Piedra chancada', 'm³', piedra.toStringAsFixed(1)]),
        _buildTableRow(['Aditivo plastificante', 'L', aditivo.toStringAsFixed(1)]),
        _buildTableRow(['Agua', 'm³', agua.toStringAsFixed(1)]),
      ],
    );
  }

  Widget _buildMaterialAligeranteTable(Map<String, double> materiales) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(['Material', 'Und.', 'Cantidad'], isHeader: true),
        ...materiales.entries.map((entry) {
          return _buildTableRow([
            entry.key, // Descripción (ej: "Bovedillas", "Ladrillo hueco 30×30×15 cm")
            'und',
            entry.value.ceil().toString(),
          ]);
        }).toList(),
      ],
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, bool isTotal = false}) {
    return TableRow(
      decoration: isTotal ? BoxDecoration(
        color: AppColors.blueMetraShop.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      children: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String cell = entry.value;

        final textStyle = TextStyle(
          fontSize: isHeader ? 14 : 16,
          fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppColors.textPrimary :
          isTotal ? AppColors.blueMetraShop : AppColors.textSecondary,
        );

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: textStyle,
            textAlign: index == 0 ? TextAlign.left : TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomActionBar() {
    final losas = ref.watch(losaResultProvider);

    if (losas.isEmpty) {
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

  // Métodos auxiliares
  double _calcularAreaTotal(List<Losa> losas) {
    double total = 0.0;
    for (var losa in losas) {
      total += _calcularAreaLosa(losa);
    }
    return total;
  }

  double _calcularAreaLosa(Losa losa) {
    final service = LosaService(losa.tipoLosa);
    return service.calcularArea(losa);
  }

  void _handleSaveAction() {
    final losas = ref.watch(losaResultProvider);
    if (losas.isNotEmpty) {
      final tipo = losas.first.tipoLosa.routePath;
      context.pushNamed(
        'save-losas',
        pathParameters: {'tipo': tipo},
      );
    } else {
      _showErrorSnackBar('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final losas = ref.watch(losaResultProvider);
    if (losas.isNotEmpty) {
      final tipo = losas.first.tipoLosa.routePath;
      context.pushNamed(
        'map-screen-losas',
        pathParameters: {'tipo': tipo},
      );
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

      // Generar PDF usando PDFFactory
      final pdfFile = await PDFFactory.generateLosaAligeradaPDF(ref);

      // Ocultar loader
      context.hideLoader();

      // Compartir PDF
      final result = await Share.shareXFiles([XFile(pdfFile.path)]);

      if (result.status == ShareResultStatus.success) {
        _showSuccessSnackBar('PDF compartido exitosamente');
      }
    } catch (e) {
      context.hideLoader();
      _showErrorSnackBar('Error al generar PDF: $e');
    } finally {
      context.hideLoader();
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
    final losas = ref.watch(losaResultProvider);
    final datosLosa = ref.watch(datosShareLosaProvider);
    final cantidadCemento = ref.watch(cantidadCementoLosaProvider);
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaProvider);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaProvider);
    final cantidadAditivo = ref.watch(cantidadAditivoPlastificanteLosaProvider);
    final cantidadAgua = ref.watch(cantidadAguaLosaProvider);
    final materialesAligerantes = ref.watch(materialesAligerantesProvider);

    final buffer = StringBuffer();

    // Encabezado
    buffer.writeln('METRASHOP - LOSAS');
    buffer.writeln('=' * 50);
    buffer.writeln();

    // Información del proyecto
    if (losas.isNotEmpty) {
      final primeraLosa = losas.first;
      buffer.writeln('INFORMACIÓN DEL PROYECTO:');
      buffer.writeln('• Tipo: ${primeraLosa.tipoLosa.displayName}');
      buffer.writeln('• Altura de losa: ${primeraLosa.altura}');
      if (primeraLosa.materialAligerante != null) {
        buffer.writeln('• Material aligerante: ${primeraLosa.materialAligerante}');
      }
      buffer.writeln('• Resistencia concreto: ${primeraLosa.resistenciaConcreto}');
      buffer.writeln('• Total de losas: ${losas.length}');
      buffer.writeln();
    }

    // Datos del metrado
    buffer.writeln('DATOS DEL METRADO:');
    buffer.writeln(datosLosa);
    buffer.writeln();

    // Materiales de concreto
    buffer.writeln('MATERIALES DE CONCRETO:');
    buffer.writeln('• Cemento: ${cantidadCemento.ceil()} bls');
    buffer.writeln('• Arena gruesa: ${cantidadArena.toStringAsFixed(2)} m³');
    buffer.writeln('• Piedra chancada: ${cantidadPiedra.toStringAsFixed(2)} m³');
    buffer.writeln('• Aditivo plastificante: ${cantidadAditivo.toStringAsFixed(2)} L');
    buffer.writeln('• Agua: ${cantidadAgua.toStringAsFixed(2)} m³');
    buffer.writeln();

    // Materiales aligerantes
    if (materialesAligerantes.isNotEmpty) {
      buffer.writeln('MATERIALES ALIGERANTES:');
      materialesAligerantes.forEach((descripcion, cantidad) {
        buffer.writeln('• $descripcion: ${cantidad.ceil()} und');
      });
      buffer.writeln();
    }

    // Pie de página
    buffer.writeln('Calculado con METRASHOP');
    buffer.writeln('"CALCULA Y COMPRA SIN PARAR DE CONSTRUIR"');
    buffer.writeln('Fecha: ${_getCurrentDate()}');

    return buffer.toString();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
