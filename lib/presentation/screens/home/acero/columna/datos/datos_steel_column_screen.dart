import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/presentation/screens/home/acero/columna/datos/models/column_form_data.dart';
import 'package:meter_app/presentation/screens/home/acero/widgets/modern_steel_text_form_field.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/acero/columna/steel_column.dart';
import '../../../../../../domain/entities/home/acero/steel_constants.dart';
import 'package:meter_app/config/assets/app_icons.dart';
import '../../../../../providers/home/acero/columna/steel_column_providers.dart';
import '../../../../../widgets/dialogs/confirm_dialog.dart';
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
    _initializeColumns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _disposeColumnControllers();
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

      // Crear todas las columnas con listas embebidas
      for (final columnData in _columns) {
        // Convertir barras de acero a objetos embebidos
        final steelBarsEmbedded = columnData.steelBars.map((barData) {
          final bar = SteelBarEmbedded();
          bar.idSteelBar = const Uuid().v4();
          bar.quantity = barData.quantity;
          bar.diameter = barData.diameter;
          return bar;
        }).toList();

        // Convertir distribuciones de estribos a objetos embebidos
        final stirrupDistributionsEmbedded = columnData.stirrupDistributions.map((distData) {
          final dist = StirrupDistributionEmbedded();
          dist.idStirrupDistribution = const Uuid().v4();
          dist.quantity = distData.quantity;
          dist.separation = distData.separation;
          return dist;
        }).toList();

        // Crear la columna con listas embebidas
        final newColumn = SteelColumn(
          idSteelColumn: const Uuid().v4(),
          description: columnData.descriptionController.text,
          waste: double.parse(columnData.wasteController.text) / 100,
          elements: int.parse(columnData.elementsController.text),
          cover: double.parse(columnData.coverController.text),
          stirrupCover: double.parse(columnData.stirrupCoverController.text),
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
          steelBars: steelBarsEmbedded,
          stirrupDistributions: stirrupDistributionsEmbedded,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Agregar columna al provider
        ref.read(steelColumnResultProvider.notifier).addColumn(newColumn);
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
      appBar: AppBar(
        title: const Text('Acero en Columnas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              ConfirmDialog.show(
                  context: context,
                  title: '¿Seguro que deseas salir?',
                  content: 'Si sales del resumen se perderá todo el progreso.',
                  confirmText: 'Salir',
                  cancelText: 'Cancelar',
                  onConfirm: () {context.goNamed('home');},
                  onCancel: () {context.pop();},
                  isVisible: true);
            },
            child: SvgPicture.asset(AppIcons.closeDialogIcon, width: 32, height: 32,),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              tabs: _columns.asMap().entries.map((entry) {
                final index = entry.key;
                final column = entry.value;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        column.descriptionController.text.isEmpty
                            ? 'Columna ${index + 1}'
                            : column.descriptionController.text,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_columns.length > 1) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeColumn(index),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.7),
              isScrollable: true,
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: FadeTransition(
          opacity: _fadeAnimation,
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
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FAB 1: Botón redondo pequeño para agregar columna
          FloatingActionButton(
            onPressed: _addNewColumn,
            backgroundColor: AppColors.secondary,
            heroTag: "add_column",
            tooltip: 'Agregar Columna',
            child: const Icon(Icons.add, color: AppColors.white),
          ),
          const SizedBox(height: 12),
          // FAB 2: Botón extended principal para calcular
          FloatingActionButton.extended(
            onPressed: _isLoading ? null : _calculateResults,
            backgroundColor: AppColors.primary,
            heroTag: "calculate",
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.calculate, color: AppColors.white),
            label: Text(
              _isLoading
                  ? 'Calculando...'
                  : 'Calcular ${_columns.length} ${_columns.length == 1 ? 'Columna' : 'Columnas'}',
              style: const TextStyle(color: AppColors.white),
            ),
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
            const SizedBox(height: 5),

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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.coverController,
                  label: 'Recub. columna (cm)',
                  prefixIcon: Icons.layers,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.columnData.stirrupCoverController,
                  label: 'Recub. estribos (cm)',
                  prefixIcon: Icons.build_circle,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final stirrupCover = double.tryParse(value);
                    if (stirrupCover == null || stirrupCover <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                  onChanged: (value) => widget.onDataChanged(),
                ),
              ),
            ],
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    items: SteelConstants.availableDiametersSturrips.map((diameter) {
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
