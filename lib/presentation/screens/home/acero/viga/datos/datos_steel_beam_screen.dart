import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/presentation/screens/home/acero/viga/datos/models/beam_form_data.dart';
import 'package:meter_app/presentation/screens/home/acero/widgets/modern_steel_text_form_field.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/acero/steel_constants.dart';
import '../../../../../../domain/entities/home/acero/viga/steel_beam.dart';
import '../../../../../providers/home/acero/viga/steel_beam_providers.dart';
import '../../../../../widgets/modern_widgets.dart';
import '../../../../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/dynamic_steel_bars_widget.dart';
import '../../widgets/dynamic_stirrup_distributions_widget.dart';

class DatosSteelBeamScreen extends ConsumerStatefulWidget {
  const DatosSteelBeamScreen({super.key});
  static const String route = 'steel-beam-data';

  @override
  ConsumerState<DatosSteelBeamScreen> createState() => _DatosSteelBeamScreenState();
}

class _DatosSteelBeamScreenState extends ConsumerState<DatosSteelBeamScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, TutorialMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Lista de vigas con sus datos
  List<BeamFormData> _beams = [];
  int _currentBeamIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeBeams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _disposeBeamControllers();
    super.dispose();
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

  void _initializeBeams() {
    // Inicializar con una viga por defecto
    _beams = [BeamFormData.initial()];
    _tabController = TabController(
      length: _beams.length,
      vsync: this,
      initialIndex: 0,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentBeamIndex = _tabController.index;
      });
    }
  }

  void _disposeBeamControllers() {
    for (final beam in _beams) {
      beam.dispose();
    }
  }

  void _addNewBeam() {
    setState(() {
      final newBeam = BeamFormData.initial(index: _beams.length + 1);
      _beams.add(newBeam);

      // Recrear TabController con nueva cantidad
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: _beams.length,
        vsync: this,
        initialIndex: _beams.length - 1,
      );
      _tabController.addListener(_onTabChanged);
      _currentBeamIndex = _beams.length - 1;
    });

    // Animación suave al cambiar a la nueva pestaña
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.animateTo(_beams.length - 1);
    });
  }

  void _removeBeam(int index) {
    if (_beams.length <= 1) return; // No permitir eliminar la última viga

    setState(() {
      _beams[index].dispose();
      _beams.removeAt(index);

      // Recrear TabController
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: _beams.length,
        vsync: this,
        initialIndex: index > 0 ? index - 1 : 0,
      );
      _tabController.addListener(_onTabChanged);
      _currentBeamIndex = _tabController.index;
    });
  }

  void _calculateResults() async {
    setState(() => _isLoading = true);

    try {
      // Validar todas las vigas
      for (int i = 0; i < _beams.length; i++) {
        if (!_beams[i].isValid()) {
          setState(() => _isLoading = false);
          _showErrorMessage('Complete todos los datos de la Viga ${i + 1}');
          _tabController.animateTo(i);
          return;
        }
      }

      context.showCalculationLoader();
      await Future.delayed(const Duration(seconds: 1));

      // Limpiar resultados anteriores
      ref.read(steelBeamResultProvider.notifier).clearList();

      // Crear todas las vigas con listas embebidas
      for (final beamData in _beams) {
        // Convertir barras de acero a objetos embebidos
        final steelBarsEmbedded = beamData.steelBars.map((barData) {
          final bar = SteelBeamBarEmbedded();
          bar.idSteelBar = const Uuid().v4();
          bar.quantity = barData.quantity;
          bar.diameter = barData.diameter;
          return bar;
        }).toList();

        // Convertir distribuciones de estribos a objetos embebidos
        final stirrupDistributionsEmbedded = beamData.stirrupDistributions.map((distData) {
          final dist = SteelBeamStirrupDistributionEmbedded();
          dist.idStirrupDistribution = const Uuid().v4();
          dist.quantity = distData.quantity;
          dist.separation = distData.separation;
          return dist;
        }).toList();

        // Crear viga con listas embebidas
        ref.read(steelBeamResultProvider.notifier).createSteelBeam(
          description: beamData.descriptionController.text,
          waste: double.parse(beamData.wasteController.text) / 100,
          elements: int.parse(beamData.elementsController.text),
          cover: double.parse(beamData.coverController.text) / 100,
          height: double.parse(beamData.heightController.text),
          length: double.parse(beamData.lengthController.text),
          width: double.parse(beamData.widthController.text),
          supportA1: double.parse(beamData.supportA1Controller.text),
          supportA2: double.parse(beamData.supportA2Controller.text),
          bendLength: double.parse(beamData.bendLengthController.text),
          useSplice: beamData.useSplice,
          stirrupDiameter: beamData.stirrupDiameter,
          stirrupBendLength: double.parse(beamData.stirrupBendLengthController.text),
          restSeparation: double.parse(beamData.restSeparationController.text),
          steelBars: steelBarsEmbedded,
          stirrupDistributions: stirrupDistributionsEmbedded,
        );
      }

      context.hideLoader();
      setState(() => _isLoading = false);
      context.pushNamed('steel-beam-results');

    } catch (e) {
      context.hideLoader();
      setState(() => _isLoading = false);
      _showErrorMessage('Error en los cálculos: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acero en Vigas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              tabs: _beams.asMap().entries.map((entry) {
                final index = entry.key;
                final beam = entry.value;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        beam.descriptionController.text.isEmpty
                            ? 'Viga ${index + 1}'
                            : beam.descriptionController.text,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_beams.length > 1) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeBeam(index),
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: _beams.asMap().entries.map((entry) {
            final index = entry.key;
            final beam = entry.value;
            return BeamFormWidget(
              key: ValueKey('beam_$index'),
              beamData: beam,
              beamIndex: index,
              onDataChanged: () => setState(() {}),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para agregar viga
          FloatingActionButton(
            onPressed: _addNewBeam,
            backgroundColor: AppColors.secondary,
            heroTag: "add_beam",
            tooltip: 'Agregar Viga',
            child: const Icon(Icons.add, color: AppColors.white),
          ),
          const SizedBox(height: 12),
          // Botón principal de calcular
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
              _isLoading ? 'Calculando...' : 'Calcular ${_beams.length} ${_beams.length == 1 ? 'Viga' : 'Vigas'}',
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para el formulario de cada viga
class BeamFormWidget extends StatefulWidget {
  final BeamFormData beamData;
  final int beamIndex;
  final VoidCallback onDataChanged;

  const BeamFormWidget({
    super.key,
    required this.beamData,
    required this.beamIndex,
    required this.onDataChanged,
  });

  @override
  State<BeamFormWidget> createState() => _BeamFormWidgetState();
}

class _BeamFormWidgetState extends State<BeamFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información de la viga
            _buildBeamHeader(),
            const SizedBox(height: 20),

            // Datos generales
            _buildGeneralDataSection(),
            const SizedBox(height: 20),

            // Dimensiones
            _buildDimensionsSection(),
            const SizedBox(height: 20),

            // Acero longitudinal
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

  Widget _buildBeamHeader() {
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
                  Icons.view_in_ar,
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
                      'Viga ${widget.beamIndex + 1}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Configure los parámetros de esta viga',
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
            controller: widget.beamData.descriptionController,
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
                  controller: widget.beamData.wasteController,
                  label: 'Desperdicio (%)',
                  prefixIcon: Icons.warning_amber,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final waste = double.tryParse(value);
                    if (waste == null || waste < 0 || waste > 50) {
                      return 'Entre 0 y 50%';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.beamData.elementsController,
                  label: 'Elementos similares',
                  prefixIcon: Icons.copy,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final elements = int.tryParse(value);
                    if (elements == null || elements <= 0) {
                      return 'Debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernSteelTextFormField(
            controller: widget.beamData.coverController,
            label: 'Recubrimiento (cm)',
            prefixIcon: Icons.straighten,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dimensiones de la Viga',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.beamData.heightController,
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
                  controller: widget.beamData.lengthController,
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
                  controller: widget.beamData.widthController,
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
          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.beamData.supportA1Controller,
                  label: 'Apoyo A1 (m)',
                  prefixIcon: Icons.support,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final support = double.tryParse(value);
                    if (support == null || support < 0) return 'Debe ser mayor o igual a 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.beamData.supportA2Controller,
                  label: 'Apoyo A2 (m)',
                  prefixIcon: Icons.support,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final support = double.tryParse(value);
                    if (support == null || support < 0) return 'Debe ser mayor o igual a 0';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.beamData.bendLengthController,
                  label: 'Longitud de doblado (m)',
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
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: CheckboxListTile(
                    title: const Text('Usar empalme'),
                    value: widget.beamData.useSplice,
                    onChanged: (value) {
                      setState(() {
                        widget.beamData.useSplice = value ?? false;
                      });
                      widget.onDataChanged();
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barras de acero dinámicas
          DynamicSteelBarsWidget(
            steelBars: widget.beamData.steelBars,
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
                    value: widget.beamData.stirrupDiameter,
                    decoration: const InputDecoration(
                      labelText: 'Diámetro del estribo',
                      prefixIcon: Icon(Icons.donut_large),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: SteelConstants.availableDiameters.map((diameter) {
                      return DropdownMenuItem(
                        value: diameter,
                        child: Text(diameter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.beamData.stirrupDiameter = value!;
                      });
                      widget.onDataChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernSteelTextFormField(
                  controller: widget.beamData.stirrupBendLengthController,
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
            controller: widget.beamData.restSeparationController,
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
            stirrupDistributions: widget.beamData.stirrupDistributions,
            onChanged: widget.onDataChanged,
          ),
        ],
      ),
    );
  }
}