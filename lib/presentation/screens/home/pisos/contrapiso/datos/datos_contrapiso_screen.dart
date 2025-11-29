import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/assets/app_icons.dart';
import 'package:meter_app/presentation/providers/pisos/contrapiso_providers.dart';

import '../../../../../../../config/theme/theme.dart';
import '../../../../../../../data/local/shared_preferences_helper.dart';
import '../../../../../widgets/modern_widgets.dart';
import '../../../../../widgets/tutorial/tutorial_overlay.dart';
import '../../../../../widgets/widgets.dart';

class DatosContrapisoScreen extends ConsumerStatefulWidget {
  const DatosContrapisoScreen({super.key});
  static const String route = 'contrapiso-detail';

  @override
  ConsumerState<DatosContrapisoScreen> createState() => _DatosContrapisoScreenState();
}

class _DatosContrapisoScreenState extends ConsumerState<DatosContrapisoScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, TutorialMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late SharedPreferencesHelper sharedPreferencesHelper;

  int _currentIndex = 0;
  bool _isLoading = false;

  // Controladores de texto mejorados
  final TextEditingController _factorController = TextEditingController(text: '5');
  final TextEditingController _descriptionAreaController = TextEditingController();
  final TextEditingController _descriptionMedidasController = TextEditingController();
  final TextEditingController _areaTextController = TextEditingController();
  final TextEditingController _lengthTextController = TextEditingController();
  final TextEditingController _heightTextController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estados de selección
  String? _selectedEspesor;
  String? _selectedProporcion;

  // Listas dinámicas
  List<Map<String, TextEditingController>> _areaFields = [];
  List<Map<String, TextEditingController>> _measureFields = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    initializeTutorial();
    _checkAndShowTutorial();
  }

  void _checkAndShowTutorial() {
    // Mostrar tutorial específico para tarrajeo
    showModuleTutorial('piso');
  }

  void _showTutorialManually() {
    forceTutorial('piso');
  }

  void _initializeControllers() {
    _tabController = TabController(length: 2, vsync: this);
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
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _factorController.dispose();
    _descriptionAreaController.dispose();
    _descriptionMedidasController.dispose();
    _areaTextController.dispose();
    _lengthTextController.dispose();
    _heightTextController.dispose();
    _disposeDynamicFields();
    super.dispose();
  }

  void _disposeDynamicFields() {
    for (var field in _areaFields) {
      field.values.forEach((controller) => controller.dispose());
    }
    for (var field in _measureFields) {
      field.values.forEach((controller) => controller.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBarWidget(
      titleAppBar: 'Cálculo de Contrapiso',
      isVisibleTutorial: true,
      showTutorial: _showTutorialManually,
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    _buildConfigurationSection(),
                    _buildTabSection(),
                  ],
                ),
              ),
            ),
          ),
          _buildActionSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueMetraShop.withOpacity(0.1),
            AppColors.blueMetraShop.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blueMetraShop.withOpacity(0.2),
          width: 1,
        ),
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
                child: SvgPicture.asset(
                  AppIcons.archiveProjectIcon,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.blueMetraShop,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración del Proyecto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tipo: Contrapiso',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEspesorSelection(),
          const SizedBox(height: 16),
          _buildProporcionSelection(),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModernSectionHeader(
              title: 'Factor de Desperdicio',
              subtitle: 'Configura el porcentaje de desperdicio del mortero',
              icon: Icons.tune,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _factorController,
              label: 'Desperdicio Mortero',
              suffix: '%',
              validator: _validatePercentage,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEspesorSelection() {
    const List<String> espesores = ["4 cm", "5 cm", "6 cm", "7 cm"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Espesor del Contrapiso',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ModernChoiceChips(
          options: espesores,
          selectedValue: _selectedEspesor,
          onSelected: (value) {
            setState(() {
              _selectedEspesor = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProporcionSelection() {
    const List<String> proporciones = ["1 : 4", "1 : 5"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proporción del Mortero',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ModernChoiceChips(
          options: proporciones,
          selectedValue: _selectedProporcion,
          onSelected: (value) {
            setState(() {
              _selectedProporcion = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModernSectionHeader(
            title: 'Datos del Metrado',
            subtitle: 'Ingresa las medidas de tu contrapiso',
            icon: Icons.straighten,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildTabBar(),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAreaTab(),
                      _buildMeasureTab(),
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

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.blueMetraShop,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppColors.blueMetraShop,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.crop_square),
            text: 'Por Área',
          ),
          Tab(
            icon: Icon(Icons.straighten),
            text: 'Por Medidas',
          ),
        ],
      ),
    );
  }

  Widget _buildAreaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ModernMeasurementCard(
            title: 'Medida Principal',
            children: [
              ModernTextField(
                controller: _descriptionAreaController,
                label: 'Descripción',
                hintText: 'Ej: Contrapiso sala',
                validator: _validateRequired,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: _areaTextController,
                label: 'Área Total',
                suffix: 'm²',
                validator: _validateNumeric,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.crop_square,
              ),
            ],
          ),
          ..._areaFields.map((field) => _buildDynamicAreaField(field)),
          const SizedBox(height: 16),
          ModernAddButton(
            onPressed: _addAreaField,
            label: 'Agregar Nueva Área',
            icon: Icons.add_box,
          ),
        ],
      ),
    );
  }

  Widget _buildMeasureTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ModernMeasurementCard(
            title: 'Medida Principal',
            children: [
              ModernTextField(
                controller: _descriptionMedidasController,
                label: 'Descripción',
                hintText: 'Ej: Contrapiso sala',
                validator: _validateRequired,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ModernTextField(
                      controller: _lengthTextController,
                      label: 'Largo',
                      suffix: 'm',
                      validator: _validateNumeric,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.straighten,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernTextField(
                      controller: _heightTextController,
                      label: 'Ancho',
                      suffix: 'm',
                      validator: _validateNumeric,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.height,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ..._measureFields.map((field) => _buildDynamicMeasureField(field)),
          const SizedBox(height: 16),
          ModernAddButton(
            onPressed: _addMeasureField,
            label: 'Agregar Nueva Medida',
            icon: Icons.add_box,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicAreaField(Map<String, TextEditingController> field) {
    return ModernMeasurementCard(
      title: 'Área Adicional',
      onRemove: () => _removeField(_areaFields, field),
      children: [
        ModernTextField(
          controller: field['description']!,
          label: 'Descripción',
          hintText: 'Ej: Contrapiso cocina',
          validator: _validateRequired,
          prefixIcon: Icons.description,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: field['measure']!,
          label: 'Área',
          suffix: 'm²',
          validator: _validateNumeric,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icons.crop_square,
        ),
      ],
    );
  }

  Widget _buildDynamicMeasureField(Map<String, TextEditingController> field) {
    return ModernMeasurementCard(
      title: 'Medida Adicional',
      onRemove: () => _removeField(_measureFields, field),
      children: [
        ModernTextField(
          controller: field['descriptionMeasure']!,
          label: 'Descripción',
          hintText: 'Ej: Contrapiso cocina',
          validator: _validateRequired,
          prefixIcon: Icons.description,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModernTextField(
                controller: field['lengthMeasure']!,
                label: 'Largo',
                suffix: 'm',
                validator: _validateNumeric,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.straighten,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ModernTextField(
                controller: field['heightMeasure']!,
                label: 'Ancho',
                suffix: 'm',
                validator: _validateNumeric,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.height,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ModernActionButtonD(
          onPressed: _isLoading ? null : () => _processCalculation(),
          isLoading: _isLoading,
          label: 'Calcular Materiales',
          icon: Icons.calculate,
        ),
      ),
    );
  }

  // Métodos auxiliares
  void _addAreaField() {
    setState(() {
      _areaFields.add({
        'description': TextEditingController(),
        'measure': TextEditingController(),
      });
    });
  }

  void _addMeasureField() {
    setState(() {
      _measureFields.add({
        'descriptionMeasure': TextEditingController(),
        'lengthMeasure': TextEditingController(),
        'heightMeasure': TextEditingController(),
      });
    });
  }

  void _removeField(List<Map<String, TextEditingController>> fields,
      Map<String, TextEditingController> field) {
    setState(() {
      field.values.forEach((controller) => controller.dispose());
      fields.remove(field);
    });
  }

  Future<void> _processCalculation() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _createPisoData();
      print(ref.watch(contrapisoResultProvider));
      ref.watch(contrapisoResultProvider);
      context.pushNamed('contrapiso-result');

      context.showCalculationLoader(
        message: 'Calculando materiales',
        description: 'Aplicando fórmulas actualizadas...',
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        context.hideLoader();
      }
    } catch (e) {
      _showErrorMessage('Error al procesar los datos: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_formKey.currentState?.validate() != true) {
      _showErrorMessage('Por favor, completa todos los campos obligatorios');
      return false;
    }

    if (_selectedEspesor == null) {
      _showErrorMessage('Selecciona un espesor');
      return false;
    }

    if (_selectedProporcion == null) {
      _showErrorMessage('Selecciona una proporción de mortero');
      return false;
    }

    return true;
  }

  Future<void> _createPisoData() async {
    final datosPiso = ref.read(contrapisoResultProvider.notifier);
    datosPiso.clearList();

    final espesorValor = _selectedEspesor!.replaceAll(" cm", "");
    final proporcionValor = _selectedProporcion!.replaceAll("1 : ", "");

    if (_currentIndex == 0) {
      // Tab de área
      if (_descriptionAreaController.text.isNotEmpty &&
          _areaTextController.text.isNotEmpty) {
        datosPiso.createContrapiso(
          _descriptionAreaController.text,
          _factorController.text,
          espesorValor,
          proporcionMortero: proporcionValor,
          area: _areaTextController.text,
        );
      }

      for (var field in _areaFields) {
        if (field['description']!.text.isNotEmpty &&
            field['measure']!.text.isNotEmpty) {
          datosPiso.createContrapiso(
            field['description']!.text,
            _factorController.text,
            espesorValor,
            proporcionMortero: proporcionValor,
            area: field['measure']!.text,
          );
        }
      }
    } else {
      // Tab de medidas
      if (_descriptionMedidasController.text.isNotEmpty &&
          _lengthTextController.text.isNotEmpty &&
          _heightTextController.text.isNotEmpty) {
        datosPiso.createContrapiso(
          _descriptionMedidasController.text,
          _factorController.text,
          espesorValor,
          proporcionMortero: proporcionValor,
          largo: _lengthTextController.text,
          ancho: _heightTextController.text,
        );
      }

      for (var field in _measureFields) {
        if (field['descriptionMeasure']!.text.isNotEmpty &&
            field['lengthMeasure']!.text.isNotEmpty &&
            field['heightMeasure']!.text.isNotEmpty) {
          datosPiso.createContrapiso(
            field['descriptionMeasure']!.text,
            _factorController.text,
            espesorValor,
            proporcionMortero: proporcionValor,
            largo: field['lengthMeasure']!.text,
            ancho: field['heightMeasure']!.text,
          );
        }
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
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

  // Validadores
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _validateNumeric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number <= 0) {
      return 'El valor debe ser mayor a 0';
    }

    return null;
  }

  String? _validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number < 0 || number > 100) {
      return 'Debe estar entre 0% y 100%';
    }

    return null;
  }
}