// ============================================================================
// DatosSteelColumnScreen - Basado exactamente en DatosSteelBeamScreen
// con las modificaciones específicas para columnas
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/home/acero/steel_beam_constants.dart';
import 'package:uuid/uuid.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/presentation/screens/home/acero/columna/datos/models/column_form_data.dart';
import 'package:meter_app/presentation/screens/home/acero/widgets/modern_steel_text_form_field.dart';
import 'package:meter_app/presentation/screens/home/acero/viga/datos/models/steel_bar_data.dart';
import 'package:meter_app/presentation/screens/home/acero/viga/datos/models/stirrup_distribution_data.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/acero/columna/steel_column.dart';
import '../../../../../../domain/entities/home/acero/viga/steel_bar.dart';
import '../../../../../../domain/entities/home/acero/viga/stirrup_distribution.dart';
import '../../../../../providers/home/acero/columna/steel_column_providers.dart';
import '../../../../../widgets/modern_widgets.dart';
import '../../../../../widgets/tutorial/tutorial_overlay.dart';
import '../../../../../widgets/widgets.dart';
import '../../widgets/dynamic_steel_bars_widget.dart';
import '../../widgets/dynamic_stirrup_distributions_widget.dart';

class DatosSteelColumnScreen extends ConsumerStatefulWidget {
  const DatosSteelColumnScreen({super.key});
  static const String route = 'steel-column-data';

  @override
  ConsumerState<DatosSteelColumnScreen> createState() => _DatosSteelColumnScreenState();
}

class _DatosSteelColumnScreenState extends ConsumerState<DatosSteelColumnScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, TutorialMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Lista de columnas con sus datos (cambio de _beams a _columns)
  List<ColumnFormData> _columns = [];
  int _currentColumnIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeColumns(); // cambio de _initializeBeams
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _disposeColumnControllers(); // cambio de _disposeBeamControllers
    super.dispose();
  }

  void _showTutorialManually() {
    forceTutorial('losa');
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _initializeColumns() { // cambio de _initializeBeams
    // Inicializar con una columna por defecto
    _columns = [ColumnFormData.initial()];
    _tabController = TabController(
      length: _columns.length,
      vsync: this,
      initialIndex: 0,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentColumnIndex = _tabController.index; // cambio de _currentBeamIndex
      });
    }
  }

  void _disposeColumnControllers() { // cambio de _disposeBeamControllers
    for (final column in _columns) {
      column.dispose();
    }
  }

  void _addNewColumn() { // cambio de _addNewBeam
    setState(() {
      final newColumn = ColumnFormData.initial(index: _columns.length + 1);
      _columns.add(newColumn);

      // Recrear TabController con nueva cantidad
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: _columns.length,
        vsync: this,
        initialIndex: _columns.length - 1,
      );
      _tabController.addListener(_onTabChanged);
      _currentColumnIndex = _columns.length - 1;
    });

    // Animación suave al cambiar a la nueva pestaña
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.animateTo(_columns.length - 1);
    });
  }

  void _removeColumn(int index) { // cambio de _removeBeam
    if (_columns.length <= 1) return; // No permitir eliminar la última columna

    setState(() {
      _columns[index].dispose();
      _columns.removeAt(index);

      // Recrear TabController
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: _columns.length,
        vsync: this,
        initialIndex: index > 0 ? index - 1 : 0,
      );
      _tabController.addListener(_onTabChanged);
      _currentColumnIndex = _tabController.index;
    });
  }

  void _calculateResults() async {
    setState(() => _isLoading = true);

    try {
      // Validar todas las columnas
      for (int i = 0; i < _columns.length; i++) {
        if (!_columns[i].isValid()) {
          setState(() => _isLoading = false);
          _showErrorMessage('Complete todos los datos de la Columna ${i + 1}');
          _tabController.animateTo(i);
          return;
        }
      }

      context.showCalculationLoader();
      await Future.delayed(const Duration(seconds: 1));

      // Limpiar resultados anteriores
      ref.read(steelColumnResultProvider.notifier).clearList();
      ref.read(steelBarsForColumnProvider.notifier).clearAll();
      ref.read(stirrupDistributionsForColumnProvider.notifier).clearAll();

      // Crear todas las columnas
      for (final columnData in _columns) {
        // Crear la columna
        final newColumn = SteelColumn(
          idSteelColumn: const Uuid().v4(),
          description: columnData.descriptionController.text,
          waste: double.parse(columnData.wasteController.text) / 100,
          elements: int.parse(columnData.elementsController.text),
          cover: double.parse(columnData.coverController.text) / 100,
          height: double.parse(columnData.heightController.text),
          length: double.parse(columnData.lengthController.text),
          width: double.parse(columnData.widthController.text),
          hasFooting: columnData.hasFooting,
          footingHeight: columnData.hasFooting
              ? double.parse(columnData.footingHeightController.text)
              : 0.0,
          footingBend: columnData.hasFooting
              ? double.parse(columnData.footingBendController.text)
              : 0.0,
          useSplice: columnData.useSplice,
          stirrupDiameter: columnData.stirrupDiameter,
          stirrupBendLength: double.parse(columnData.stirrupBendLengthController.text),
          restSeparation: double.parse(columnData.restSeparationController.text),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Agregar columna
        ref.read(steelColumnResultProvider.notifier).addColumn(newColumn);

        // Agregar barras de acero para esta columna
        for (final barData in columnData.steelBars) {
          final bar = SteelBar(
            idSteelBar: const Uuid().v4(),
            quantity: barData.quantity,
            diameter: barData.diameter,
          );
          ref.read(steelBarsForColumnProvider.notifier).addBar(newColumn.idSteelColumn, bar);
        }

        // Agregar distribuciones de estribos para esta columna
        for (final distData in columnData.stirrupDistributions) {
          final distribution = StirrupDistribution(
            idStirrupDistribution: const Uuid().v4(),
            quantity: distData.quantity,
            separation: distData.separation,
          );
          ref.read(stirrupDistributionsForColumnProvider.notifier)
              .addDistribution(newColumn.idSteelColumn, distribution);
        }
      }

      if (mounted) {
        context.pushNamed('steel-column-results');
      }
    } catch (e) {
      _showErrorMessage('Error al procesar los datos: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBarWidget(
        titleAppBar: 'Acero en Columnas', // cambio de 'Acero en Vigas'
        isVisibleTutorial: true,
        showTutorial: _showTutorialManually,
      ),
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _calculateResults,
        backgroundColor: _isLoading ? AppColors.textSecondary : AppColors.primary,
        foregroundColor: AppColors.white,
        icon: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white,
          ),
        )
            : const Icon(Icons.calculate),
        label: Text(_isLoading ? 'Calculando...' : 'Calcular'),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTabsSection(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _columns.asMap().entries.map((entry) {
              final index = entry.key;
              final columnData = entry.value;
              return _ColumnFormView(
                columnData: columnData,
                columnIndex: index,
                onDataChanged: () => setState(() {}),
                onRemoveColumn: () => _removeColumn(index),
                canRemove: _columns.length > 1,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabsSection() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Botón agregar columna
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addNewColumn,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar Columna'), // cambio de 'Agregar Viga'
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: _columns.asMap().entries.map((entry) {
              final index = entry.key;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Columna ${index + 1}'), // cambio de 'Viga ${index + 1}'
                    if (_columns.length > 1) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeColumn(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

}

// Widget de formulario individual para cada columna
class _ColumnFormView extends StatefulWidget {
  final ColumnFormData columnData;
  final int columnIndex;
  final VoidCallback onDataChanged;
  final VoidCallback onRemoveColumn;
  final bool canRemove;

  const _ColumnFormView({
    required this.columnData,
    required this.columnIndex,
    required this.onDataChanged,
    required this.onRemoveColumn,
    required this.canRemove,
  });

  @override
  State<_ColumnFormView> createState() => _ColumnFormViewState();
}

class _ColumnFormViewState extends State<_ColumnFormView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header de la columna
            _buildColumnHeader(),
            const SizedBox(height: 20),

            // Datos generales
            _buildGeneralDataSection(),
            const SizedBox(height: 20),

            // CAMBIO: Dimensiones de la Columna (no de la Viga)
            _buildColumnDimensionsSection(),
            const SizedBox(height: 20),

            // CAMBIO: Acero longitudinal sin campo doblez
            _buildLongitudinalSteelSection(),
            const SizedBox(height: 20),

            // Estribos
            _buildStirrupsSection(),
            const SizedBox(height: 100), // Espacio para FAB
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeader() {
    return ModernCard(
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
                  Icons.view_column, // cambio de Icons.view_in_ar
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Columna ${widget.columnIndex + 1}', // cambio de 'Viga'
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Configure los parámetros de esta columna', // cambio de 'viga'
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralDataSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos Generales',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ModernSteelTextFormField(
            controller: widget.columnData.descriptionController,
            label: 'Descripción',
            prefixIcon: Icons.label,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La descripción es requerida';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.wasteController,
                  label: 'Desperdicio (%)',
                  prefixIcon: Icons.warning_amber,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final waste = double.tryParse(value);
                    if (waste == null || waste < 0 || waste > 50) return 'Entre 0 y 50';
                    return null;
                  },
                  onChanged: (value) => widget.onDataChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.elementsController,
                  label: 'Elementos similares',
                  prefixIcon: Icons.copy,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final elements = int.tryParse(value);
                    if (elements == null || elements <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                  onChanged: (value) => widget.onDataChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernSteelTextFormField(
            controller: widget.columnData.coverController,
            label: 'Recubrimiento (cm)',
            prefixIcon: Icons.layers,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              final cover = double.tryParse(value);
              if (cover == null || cover <= 0) return 'Debe ser mayor a 0';
              return null;
            },
            onChanged: (value) => widget.onDataChanged(),
          ),
        ],
      ),
    );
  }

  // CAMBIO PRINCIPAL: Dimensiones de la Columna
  Widget _buildColumnDimensionsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dimensiones de la Columna', // cambio de 'Dimensiones de la Viga'
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.heightController,
                  label: 'Alto (m)',
                  prefixIcon: Icons.height,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final height = double.tryParse(value);
                    if (height == null || height <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.lengthController,
                  label: 'Largo (m)',
                  prefixIcon: Icons.straighten,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final length = double.tryParse(value);
                    if (length == null || length <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.widthController,
                  label: 'Ancho (m)',
                  prefixIcon: Icons.width_normal,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final width = double.tryParse(value);
                    if (width == null || width <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CAMBIO: Sección de zapata en lugar de Apoyo A1 y A2
          _buildFootingSection(),
        ],
      ),
    );
  }

  // NUEVA SECCIÓN: Zapata (reemplaza Apoyo A1 y A2)
  Widget _buildFootingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.columnData.hasFooting
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.columnData.hasFooting
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox para activar zapata
          CheckboxListTile(
            value: widget.columnData.hasFooting,
            onChanged: (value) {
              setState(() {
                widget.columnData.hasFooting = value ?? false;
              });
              widget.onDataChanged();
            },
            title: Text(
              'Incluir Zapata',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.columnData.hasFooting
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            subtitle: Text(
              'Agrega altura y doblez para cimentación',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          // Campos de zapata (solo visibles si está activada)
          if (widget.columnData.hasFooting) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ModernSteelTextFormField(
                    controller: widget.columnData.footingHeightController,
                    label: 'Altura Zapata (m)',
                    prefixIcon: Icons.foundation,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                    ],
                    validator: (value) {
                      if (!widget.columnData.hasFooting) return null;
                      if (value == null || value.isEmpty) return 'Requerido';
                      final height = double.tryParse(value);
                      if (height == null || height <= 0) return 'Debe ser mayor a 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernSteelTextFormField(
                    controller: widget.columnData.footingBendController,
                    label: 'Doblez Zapata (m)',
                    prefixIcon: Icons.turn_right,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                    ],
                    validator: (value) {
                      if (!widget.columnData.hasFooting) return null;
                      if (value == null || value.isEmpty) return 'Requerido';
                      final bend = double.tryParse(value);
                      if (bend == null || bend < 0) return 'Debe ser mayor o igual a 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // CAMBIO: Acero longitudinal sin campo doblez
  Widget _buildLongitudinalSteelSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acero Longitudinal',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // CAMBIO: Solo empalme, SIN doblez
          Container(
            decoration: BoxDecoration(
              color: widget.columnData.useSplice
                  ? AppColors.success.withOpacity(0.05)
                  : AppColors.neutral50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.columnData.useSplice
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.neutral200,
              ),
            ),
            child: CheckboxListTile(
              value: widget.columnData.useSplice,
              onChanged: (value) {
                setState(() {
                  widget.columnData.useSplice = value ?? false;
                });
                widget.onDataChanged();
              },
              title: Text(
                'Usar empalme',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.columnData.useSplice
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
              subtitle: Text(
                'Agrega longitud de empalme según diámetro',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              activeColor: AppColors.success,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 16),

          // Nota sobre diferencias con vigas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Las columnas no requieren doblez de acero longitudinal como las vigas. El doblez solo aplica si hay zapata.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Barras de acero dinámicas
          DynamicSteelBarsWidget(
            steelBars: widget.columnData.steelBars,
            onChanged: widget.onDataChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStirrupsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Estribos',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: widget.columnData.stirrupDiameter,
                    decoration: const InputDecoration(
                      labelText: 'Diámetro del estribo',
                      prefixIcon: Icon(Icons.donut_large),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: SteelBeamConstants.availableDiameters.map((diameter) {
                      return DropdownMenuItem(
                        value: diameter,
                        child: Text(diameter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.columnData.stirrupDiameter = value!;
                      });
                      widget.onDataChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.stirrupBendLengthController,
                  label: 'Doblado (m)',
                  prefixIcon: Icons.turn_right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final bend = double.tryParse(value);
                    if (bend == null || bend < 0) return 'Debe ser mayor o igual a 0';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernSteelTextFormField(
            controller: widget.columnData.restSeparationController,
            label: 'Separación del resto (m)',
            prefixIcon: Icons.space_bar,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              final separation = double.tryParse(value);
              if (separation == null || separation <= 0) return 'Debe ser mayor a 0';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Distribuciones de estribos dinámicas
          DynamicStirrupDistributionsWidget(
            stirrupDistributions: widget.columnData.stirrupDistributions,
            onChanged: widget.onDataChanged,
          ),
        ],
      ),
    );
  }
}
