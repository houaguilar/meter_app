import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../config/utils/pdf/pdf_factory.dart';
import '../../../../../providers/home/acero/zapata/steel_footing_providers.dart';

class ResultSteelFootingScreen extends ConsumerStatefulWidget {
  const ResultSteelFootingScreen({super.key});

  @override
  ConsumerState<ResultSteelFootingScreen> createState() => _ResultSteelFootingScreenState();
}

class _ResultSteelFootingScreenState extends ConsumerState<ResultSteelFootingScreen>
    with SingleTickerProviderStateMixin {

  bool _isGeneratingPDF = false; // Flag para prevenir limpieza durante generación de PDF

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
      final footings = ref.read(steelFootingResultProvider);
      final consolidatedResult = ref.read(calculateConsolidatedFootingSteelProvider);

      print('🔍 Estado en ResultSteelFootingScreen:');
      print('- Zapatas: ${footings.length}');
      print('- Resultado consolidado: ${consolidatedResult != null}');

      if (footings.isEmpty || consolidatedResult == null) {
        print('❌ No hay datos válidos, regresando...');
        _showErrorMessage('No hay datos para mostrar. Vuelve a intentar.');
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop && !_isGeneratingPDF) {
          print('🗑️ PopScope activado - Limpiando datos (isGeneratingPDF: $_isGeneratingPDF)');
          ref.read(steelFootingResultProvider.notifier).clearList();
        } else if (didPop && _isGeneratingPDF) {
          print('⚠️ PopScope activado pero NO se limpia porque se está generando PDF');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resultados de Acero en Zapatas'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              children: [
                _buildBody(),
                // Botones de acción en la parte inferior (como ResultLosasScreen)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomActionBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final consolidatedResult = ref.watch(calculateConsolidatedFootingSteelProvider);
    final footings = ref.watch(steelFootingResultProvider);
    final quickStats = ref.watch(quickFootingStatsProvider);

    if (consolidatedResult == null || footings.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 140, // Espacio para los botones inferiores
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con resumen ejecutivo
          _buildExecutiveSummary(quickStats),
          const SizedBox(height: 20),

          // Materiales consolidados
          _buildConsolidatedMaterials(consolidatedResult),
          const SizedBox(height: 20),

          // Detalle por zapata (expandible)
          _buildFootingDetails(consolidatedResult),
          const SizedBox(height: 20),

        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTONES DE ACCIÓN CONSISTENTES CON OTRAS PANTALLAS DE RESULTADOS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomActionBar() {
    final footings = ref.watch(steelFootingResultProvider);

    if (footings.isEmpty) {
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
              // Primera fila: Guardar y Compartir
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
              // Segunda fila: Buscar Proveedores (ancho completo)
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

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCIONES DE LOS BOTONES
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleSaveAction() {
    final footing = ref.watch(steelFootingResultProvider);
    final consolidatedResult = ref.watch(calculateConsolidatedFootingSteelProvider);

    if (footing.isNotEmpty && consolidatedResult != null) {
      // Navegar a pantalla de guardado
      context.pushNamed('save-steel-footing');
    } else {
      _showErrorMessage('No hay datos para guardar');
    }
  }

  void _handleProviderAction() {
    final footings = ref.watch(steelFootingResultProvider);
    final consolidatedResult = ref.watch(calculateConsolidatedFootingSteelProvider);

    if (footings.isNotEmpty && consolidatedResult != null) {
      // Navegar a mapa de proveedores
      context.pushNamed('map-screen-steel-footing');
    } else {
      _showErrorMessage('No hay datos de zapatas de acero');
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
            'Compartir Resultados de Zapatas',
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
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS DE COMPARTIR (ADAPTADOS PARA ZAPATAS)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _sharePDF() async {
    try {
      await _generatePDF();
    } catch (e) {
      _showErrorMessage('Error al generar PDF: $e');
    }
  }

  void _shareText() async {
    try {
      await _shareResults();
    } catch (e) {
      _showErrorMessage('Error al compartir: $e');
    }
  }

  Future<void> _shareResults() async {
    final consolidatedResult = ref.read(calculateConsolidatedFootingSteelProvider);
    if (consolidatedResult == null) return;

    final StringBuffer content = StringBuffer();
    content.writeln('🏗️ RESUMEN DE MATERIALES - ZAPATAS DE ACERO\n');

    content.writeln('📊 RESUMEN GENERAL:');
    content.writeln('• Número de zapatas: ${consolidatedResult.numberOfElements}');
    content.writeln('• Peso total de acero: ${consolidatedResult.totalWeight.toStringAsFixed(2)} kg');
    content.writeln('• Alambre #16: ${consolidatedResult.totalWire.toStringAsFixed(2)} kg');

    content.writeln('\n📋 MATERIALES CONSOLIDADOS:');
    consolidatedResult.consolidatedMaterials.forEach((material, data) {
      content.writeln('• Acero de $material: ${data.quantity.toStringAsFixed(0)} ${data.unit}');
    });

    content.writeln('\n🏗️ DETALLES POR ZAPATA:');
    for (int i = 0; i < consolidatedResult.footingResults.length; i++) {
      final footing = consolidatedResult.footingResults[i];
      content.writeln('\n${i + 1}. ${footing.description}:');
      content.writeln('   • Peso: ${footing.totalWeight.toStringAsFixed(1)} kg');
      content.writeln('   • Alambre: ${footing.wireWeight.toStringAsFixed(1)} kg');

      // Detalles de mallas
      content.writeln('   • Malla inferior:');
      content.writeln('     - Horizontal: ${footing.inferiorMesh.horizontalQuantity} barras x ${footing.inferiorMesh.horizontalLength.toStringAsFixed(1)}m');
      content.writeln('     - Vertical: ${footing.inferiorMesh.verticalQuantity} barras x ${footing.inferiorMesh.verticalLength.toStringAsFixed(1)}m');

      if (footing.superiorMesh != null) {
        content.writeln('   • Malla superior:');
        content.writeln('     - Horizontal: ${footing.superiorMesh!.horizontalQuantity} barras x ${footing.superiorMesh!.horizontalLength.toStringAsFixed(1)}m');
        content.writeln('     - Vertical: ${footing.superiorMesh!.verticalQuantity} barras x ${footing.superiorMesh!.verticalLength.toStringAsFixed(1)}m');
      }
    }

    content.writeln('\n---\nGenerado por MeterApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');

    await Share.share(
      content.toString(),
      subject: 'Resultados de Zapatas de Acero',
    );
  }

  Future<void> _generatePDF() async {
    try {
      // Activar flag para prevenir limpieza de datos
      if (!mounted) return;
      setState(() {
        _isGeneratingPDF = true;
      });

      // Mostrar loader (NO cerramos el bottom sheet)
      if (!mounted) return;

      context.showCalculationLoader(
        message: 'Generando PDF...',
        description: 'Creando documento con los resultados',
      );

      // Generar PDF usando PDFFactory
      final pdfFile = await PDFFactory.generateSteelFootingPDF(ref);

      // Ocultar loader solo si el widget está montado
      if (mounted) {
        context.hideLoader();
      } else {
        return;
      }

      // Compartir PDF (esto cerrará automáticamente el bottom sheet)
      final result = await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Resultados de Zapatas de Acero',
      );

      // Mostrar feedback solo si el widget está montado
      if (mounted && result.status == ShareResultStatus.success) {
        _showSuccessMessage('PDF compartido exitosamente');
      }
    } catch (e) {
      if (mounted) {
        try {
          context.hideLoader();
        } catch (loaderError) {
          // Ignorar error si no se puede ocultar loader
        }
        _showErrorMessage('Error al generar PDF: $e');
      }
    } finally {
      // Desactivar flag después de completar o fallar
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESTO DE MÉTODOS (ADAPTADOS PARA ZAPATAS)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.foundation,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay resultados disponibles',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configura al menos una zapata para ver los resultados',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed('steel-footing'),
            icon: const Icon(Icons.add),
            label: const Text('Configurar Zapatas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummary(dynamic quickStats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.foundation,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen Ejecutivo',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (quickStats != null) ...[
            _buildStatRow('Total de Zapatas', '${quickStats['totalFootings']}'),
            _buildStatRow('Peso Total', '${quickStats['totalWeight']?.toStringAsFixed(1)} kg'),
            _buildStatRow('Alambre #16', '${quickStats['totalWire']?.toStringAsFixed(1)} kg'),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsolidatedMaterials(dynamic consolidatedResult) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Materiales Consolidados',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header de la tabla
          _buildMaterialRow(
            'Material',
            'Cantidad',
            'Unidad',
            isHeader: true,
          ),
          const Divider(color: AppColors.neutral300),

          // Datos de materiales
          ...consolidatedResult.consolidatedMaterials.entries.map((entry) {
            final material = entry.key;
            final data = entry.value;
            final quantity = data.quantity.toStringAsFixed(0);
            final unit = data.unit;

            return _buildMaterialRow('Acero de $material', quantity, unit);
          }),

          // Fila de alambre
          _buildMaterialRow(
            'Alambre #16',
            consolidatedResult.totalWire.toStringAsFixed(1),
            'kg',
            isHighlighted: true,
          ),

          // Fila de peso total
          _buildMaterialRow(
            'Peso total de acero',
            consolidatedResult.totalWeight.toStringAsFixed(1),
            'kg',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(
      String material,
      String quantity,
      String unit, {
        bool isHeader = false,
        bool isHighlighted = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              material,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isHeader ? FontWeight.w600 : null,
                color: isHighlighted ? AppColors.warning : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              quantity,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isHighlighted ? AppColors.warning : AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              unit,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFootingDetails(dynamic result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.view_list,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Detalle por Zapata',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de zapatas
          ...result.footingResults.asMap().entries.map((entry) {
            final index = entry.key;
            final footing = entry.value;
            return _buildFootingCard(footing, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildFootingCard(dynamic footing, int footingNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zapata $footingNumber',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Descripción: ${footing.description}',
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Peso total: ${footing.totalWeight.toStringAsFixed(1)} kg',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Alambre: ${footing.wireWeight.toStringAsFixed(1)} kg',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Detalles de mallas
          _buildMeshDetails('Malla Inferior', footing.inferiorMesh, AppColors.success),

          if (footing.superiorMesh != null) ...[
            const SizedBox(height: 8),
            _buildMeshDetails('Malla Superior', footing.superiorMesh, AppColors.secondary),
          ],
        ],
      ),
    );
  }

  Widget _buildMeshDetails(String title, dynamic mesh, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'H: ${mesh.horizontalQuantity} × ${mesh.horizontalLength.toStringAsFixed(1)}m',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'V: ${mesh.verticalQuantity} × ${mesh.verticalLength.toStringAsFixed(1)}m',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}