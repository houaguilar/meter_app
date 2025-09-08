// lib/presentation/screens/home/acero/viga/datos_steel_beam_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/acero/steel_constants.dart';
import '../../../../../providers/home/acero/viga/steel_beam_providers.dart';
import '../../../../../widgets/modern_widgets.dart';
import '../../../../../widgets/tutorial/tutorial_overlay.dart';
import '../../../../../widgets/widgets.dart';

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

  int _currentIndex = 0;
  bool _isLoading = false;

  // Controladores de texto para datos generales
  final TextEditingController _descriptionController = TextEditingController(text: 'VIGA 1');
  final TextEditingController _wasteController = TextEditingController(text: '7');
  final TextEditingController _elementsController = TextEditingController(text: '10');
  final TextEditingController _coverController = TextEditingController(text: '4');

  // Controladores para dimensiones
  final TextEditingController _heightController = TextEditingController(text: '3.5');
  final TextEditingController _lengthController = TextEditingController(text: '0.6');
  final TextEditingController _widthController = TextEditingController(text: '0.4');
  final TextEditingController _supportA1Controller = TextEditingController(text: '0.4');
  final TextEditingController _supportA2Controller = TextEditingController(text: '0.4');

  // Controladores para acero longitudinal
  final TextEditingController _bendLengthController = TextEditingController(text: '0.4');
  bool _useSplice = true;

  // Controladores para estribos
  String _stirrupDiameter = '6mm';
  final TextEditingController _stirrupBendController = TextEditingController(text: '8');
  final TextEditingController _restSeparationController = TextEditingController(text: '20');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Listas dinámicas para barras de acero y distribuciones
  List<SteelBarData> _steelBars = [
    SteelBarData(quantity: 6, diameter: '3/4"'),
    SteelBarData(quantity: 2, diameter: '1/2"'),
  ];

  List<StirrupDistributionData> _stirrupDistributions = [
    StirrupDistributionData(quantity: 1, separation: 5),
    StirrupDistributionData(quantity: 6, separation: 10),
    StirrupDistributionData(quantity: 4, separation: 15),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _initializeAnimations();
    initializeTutorial();
    _checkAndShowTutorial();
  }

  void _checkAndShowTutorial() {
    // Mostrar tutorial específico para tarrajeo
    showModuleTutorial('structural');
  }

  void _showTutorialManually() {
    forceTutorial('structural');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _descriptionController.dispose();
    _wasteController.dispose();
    _elementsController.dispose();
    _coverController.dispose();
    _heightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _supportA1Controller.dispose();
    _supportA2Controller.dispose();
    _bendLengthController.dispose();
    _stirrupBendController.dispose();
    _restSeparationController.dispose();
  }

  void _initializeTabController() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
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
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar('Datos'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralDataTab(),
                  _buildDimensionsTab(),
                  _buildLongitudinalSteelTab(),
                  _buildStirrupsTab(),
                ],
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBarWidget(
      titleAppBar: title,
      isVisibleTutorial: true,
      showTutorial: _showTutorialManually,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.neutral600,
        labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.labelMedium,
        tabs: const [
          Tab(text: 'General'),
          Tab(text: 'Dimensiones'),
          Tab(text: 'Acero Long.'),
          Tab(text: 'Estribos'),
        ],
      ),
    );
  }

  Widget _buildGeneralDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información General'),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _descriptionController,
              label: 'Descripción del Elemento',
              hintText: 'Ej: VIGA 1, VIGA PRINCIPAL',
              prefixIcon: Icons.description,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ModernTextField(
                    controller: _wasteController,
                    label: 'Desperdicio (%)',
                    hintText: '7',
                    prefixIcon: Icons.warning_amber,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final waste = double.tryParse(value ?? '');
                      if (waste == null || waste < 0 || waste > 100) {
                        return 'Valor entre 0 y 100';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ModernTextField(
                    controller: _elementsController,
                    label: 'Elementos Similares',
                    hintText: '10',
                    prefixIcon: Icons.copy,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final elements = int.tryParse(value ?? '');
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
            ModernTextField(
              controller: _coverController,
              label: 'Recubrimiento (cm)',
              hintText: '4',
              prefixIcon: Icons.layers,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final cover = double.tryParse(value ?? '');
                if (cover == null || cover < 0) {
                  return 'Debe ser mayor o igual a 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Dimensiones de la Viga'),
          const SizedBox(height: 16),
          ModernTextField(
            controller: _heightController,
            label: 'Alto (m)',
            hintText: '3.5',
            prefixIcon: Icons.height,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final height = double.tryParse(value ?? '');
              if (height == null || height <= 0) {
                return 'Debe ser mayor a 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernTextField(
                  controller: _lengthController,
                  label: 'Largo (m)',
                  hintText: '0.6',
                  prefixIcon: Icons.straighten,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final length = double.tryParse(value ?? '');
                    if (length == null || length <= 0) {
                      return 'Debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernTextField(
                  controller: _widthController,
                  label: 'Ancho (m)',
                  hintText: '0.4',
                  prefixIcon: Icons.width_normal,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),

                  validator: (value) {
                    final width = double.tryParse(value ?? '');
                    if (width == null || width <= 0) {
                      return 'Debe ser mayor a 0';
                    }
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
                child: ModernTextField(
                  controller: _supportA1Controller,
                  label: 'Apoyo A1 (m)',
                  hintText: '0.4',
                  prefixIcon: Icons.support,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final support = double.tryParse(value ?? '');
                    if (support == null || support < 0) {
                      return 'Debe ser mayor o igual a 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernTextField(
                  controller: _supportA2Controller,
                  label: 'Apoyo A2 (m)',
                  hintText: '0.4',
                  prefixIcon: Icons.support,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final support = double.tryParse(value ?? '');
                    if (support == null || support < 0) {
                      return 'Debe ser mayor o igual a 0';
                    }
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

  Widget _buildLongitudinalSteelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Acero Longitudinal'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernTextField(
                  controller: _bendLengthController,
                  label: 'Doblez (m)',
                  hintText: '0.4',
                  prefixIcon: Icons.turn_right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final bend = double.tryParse(value ?? '');
                    if (bend == null || bend < 0) {
                      return 'Debe ser mayor o igual a 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCheckboxTile('Usar Empalme', _useSplice, (value) {
                  setState(() {
                    _useSplice = value ?? false;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDynamicSteelBarsSection(),
        ],
      ),
    );
  }

  Widget _buildStirrupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Estribos'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Diámetro',
                  _stirrupDiameter,
                  SteelConstants.availableDiameters,
                      (value) {
                    setState(() {
                      _stirrupDiameter = value ?? '6mm';
                    });
                  },
                  Icons.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernTextField(
                  controller: _stirrupBendController,
                  label: 'Doblez (cm)',
                  hintText: '8',
                  prefixIcon: Icons.turn_right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final bend = double.tryParse(value ?? '');
                    if (bend == null || bend < 0) {
                      return 'Debe ser mayor o igual a 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernTextField(
            controller: _restSeparationController,
            label: 'Resto @ (cm)',
            hintText: '20',
            prefixIcon: Icons.space_bar,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final separation = double.tryParse(value ?? '');
              if (separation == null || separation <= 0) {
                return 'Debe ser mayor a 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildDynamicStirrupDistributionsSection(),
        ],
      ),
    );
  }

  Widget _buildDynamicSteelBarsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Barras de Acero',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._steelBars.asMap().entries.map((entry) {
            final index = entry.key;
            final bar = entry.value;
            return _buildSteelBarRow(bar, index);
          }),
          const SizedBox(height: 16),
          _buildAddButton(
            'Añadir Barra de Acero',
            Icons.add,
            _addSteelBar,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicStirrupDistributionsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Estribos',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._stirrupDistributions.asMap().entries.map((entry) {
            final index = entry.key;
            final distribution = entry.value;
            return _buildStirrupDistributionRow(distribution, index);
          }),
          const SizedBox(height: 16),
          _buildAddButton(
            'Añadir Distribución',
            Icons.add,
            _addStirrupDistribution,
          ),
        ],
      ),
    );
  }

  Widget _buildSteelBarRow(SteelBarData bar, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: bar.quantity.toString(),
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  _steelBars[index] = bar.copyWith(quantity: int.tryParse(value) ?? 1);
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: bar.diameter,
              decoration: const InputDecoration(
                labelText: 'Diámetro',
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
                  _steelBars[index] = bar.copyWith(diameter: value ?? '1/2"');
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _steelBars.length > 1 ? () => _removeSteelBar(index) : null,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildStirrupDistributionRow(StirrupDistributionData distribution, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: distribution.quantity.toString(),
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  _stirrupDistributions[index] = distribution.copyWith(quantity: int.tryParse(value) ?? 1);
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: distribution.separation.toString(),
              decoration: const InputDecoration(
                labelText: 'Separación (cm)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                setState(() {
                  _stirrupDistributions[index] = distribution.copyWith(separation: double.tryParse(value) ?? 10);
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _stirrupDistributions.length > 1 ? () => _removeStirrupDistribution(index) : null,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: AppTypography.bodyMedium,
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      String value,
      List<String> items,
      ValueChanged<String?> onChanged,
      IconData prefixIcon,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: AppColors.primary),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAddButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodyLarge.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleCalculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calculate),
                SizedBox(width: 8),
                Text(
                  'CALCULAR ACERO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares
  void _addSteelBar() {
    setState(() {
      _steelBars.add(SteelBarData(quantity: 1, diameter: '1/2"'));
    });
  }

  void _removeSteelBar(int index) {
    setState(() {
      _steelBars.removeAt(index);
    });
  }

  void _addStirrupDistribution() {
    setState(() {
      _stirrupDistributions.add(StirrupDistributionData(quantity: 1, separation: 10));
    });
  }

  void _removeStirrupDistribution(int index) {
    setState(() {
      _stirrupDistributions.removeAt(index);
    });
  }

// Reemplaza el método _handleCalculate en datos_steel_beam_screen.dart

  Future<void> _handleCalculate() async {
    // Validar formulario
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_steelBars.isEmpty) {
      _showErrorMessage('Debe agregar al menos una barra de acero longitudinal');
      return;
    }

    if (_stirrupDistributions.isEmpty) {
      _showErrorMessage('Debe agregar al menos una distribución de estribos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      context.showCalculationLoader(
        message: 'Calculando acero...',
        description: 'Procesando datos de la viga',
      );

      // Limpiar datos anteriores
      ref.read(steelBeamResultProvider.notifier).clearList();

      // Crear viga de acero
      ref.read(steelBeamResultProvider.notifier).createSteelBeam(
        description: _descriptionController.text.trim(),
        waste: (double.tryParse(_wasteController.text) ?? 7) / 100,
        elements: int.tryParse(_elementsController.text) ?? 10,
        cover: (double.tryParse(_coverController.text) ?? 4) / 100,
        height: double.tryParse(_heightController.text) ?? 3.5,
        length: double.tryParse(_lengthController.text) ?? 0.6,
        width: double.tryParse(_widthController.text) ?? 0.4,
        supportA1: double.tryParse(_supportA1Controller.text) ?? 0.4,
        supportA2: double.tryParse(_supportA2Controller.text) ?? 0.4,
        bendLength: double.tryParse(_bendLengthController.text) ?? 0.4,
        useSplice: _useSplice,
        stirrupDiameter: _stirrupDiameter,
        stirrupBendLength: (double.tryParse(_stirrupBendController.text) ?? 8) / 100,
        restSeparation: (double.tryParse(_restSeparationController.text) ?? 20) / 100,
      );

      // Esperar un frame para que se actualice el provider
      await Future.delayed(const Duration(milliseconds: 100));

      // Obtener la viga creada
      final beams = ref.read(steelBeamResultProvider);
      print('📊 Vigas después de crear: ${beams.length}');

      if (beams.isNotEmpty) {
        final beamId = beams.last.idSteelBeam;
        print('🔑 ID de viga creada: $beamId');

        // Agregar barras de acero
        for (final bar in _steelBars) {
          ref.read(steelBarsForBeamProvider.notifier).addSteelBar(
            beamId,
            bar.quantity,
            bar.diameter,
          );
          print('➕ Barra agregada: ${bar.quantity} x ${bar.diameter}');
        }

        // Agregar distribuciones de estribos
        for (final distribution in _stirrupDistributions) {
          ref.read(stirrupDistributionsForBeamProvider.notifier).addDistribution(
            beamId,
            distribution.quantity,
            distribution.separation / 100, // convertir cm a metros
          );
          print('➕ Distribución agregada: ${distribution.quantity} @ ${distribution.separation}cm');
        }

        // Verificar que los datos se guardaron correctamente
        final steelBarsMap = ref.read(steelBarsForBeamProvider);
        final stirrupDistributionsMap = ref.read(stirrupDistributionsForBeamProvider);

        print('🔍 Barras guardadas para $beamId: ${steelBarsMap[beamId]?.length ?? 0}');
        print('🔍 Distribuciones guardadas para $beamId: ${stirrupDistributionsMap[beamId]?.length ?? 0}');
      }

      await Future.delayed(const Duration(seconds: 1));

      context.hideLoader();

      // Verificar resultado consolidado antes de navegar
      final consolidatedResult = ref.read(calculateConsolidatedSteelProvider);
      print('📋 Resultado consolidado: ${consolidatedResult != null}');

      if (consolidatedResult != null) {
        print('✅ Navegando a resultados...');
        context.pushNamed('steel-beam-results');
      } else {
        print('❌ No se pudo calcular el resultado');
        _showErrorMessage('Error al calcular los resultados. Verifique los datos ingresados.');
      }

    } catch (e, stackTrace) {
      print('❌ Error en cálculo: $e');
      print('Stack trace: $stackTrace');
      context.hideLoader();
      _showErrorMessage('Error en el cálculo: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _hasUnsavedChanges() {
    // Verificar si hay cambios en los formularios
    return _descriptionController.text.trim() != 'VIGA 1' ||
        _wasteController.text != '7' ||
        _elementsController.text != '10' ||
        _steelBars.length > 2 ||
        _stirrupDistributions.length > 3;
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text('¿Estás seguro de que quieres salir? Se perderán los datos ingresados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
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

// Clases auxiliares para manejar datos dinámicos
class SteelBarData {
  final int quantity;
  final String diameter;

  const SteelBarData({
    required this.quantity,
    required this.diameter,
  });

  SteelBarData copyWith({
    int? quantity,
    String? diameter,
  }) {
    return SteelBarData(
      quantity: quantity ?? this.quantity,
      diameter: diameter ?? this.diameter,
    );
  }
}

class StirrupDistributionData {
  final int quantity;
  final double separation; // en cm

  const StirrupDistributionData({
    required this.quantity,
    required this.separation,
  });

  StirrupDistributionData copyWith({
    int? quantity,
    double? separation,
  }) {
    return StirrupDistributionData(
      quantity: quantity ?? this.quantity,
      separation: separation ?? this.separation,
    );
  }
}