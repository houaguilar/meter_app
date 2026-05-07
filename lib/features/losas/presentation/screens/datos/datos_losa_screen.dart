import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/core/assets/app_icons.dart';
import 'package:meter_app/core/utils/validators.dart';
import 'package:meter_app/features/tutorial/presentation/widgets/tutorial_overlay.dart';

import 'package:meter_app/core/theme/theme.dart';
import 'package:meter_app/core/local/shared_preferences_helper.dart';
import 'package:meter_app/domain/entities/home/losas/tipo_losa.dart';
import 'package:meter_app/features/losas/domain/services/losa_service.dart';
import 'package:meter_app/features/losas/presentation/providers/losa_providers.dart';
import 'package:meter_app/core/widgets/modern_widgets.dart';
import 'package:meter_app/core/widgets/widgets.dart';

/// Pantalla adaptativa de datos para todos los tipos de losas
///
/// Se adapta según el [tipoLosa] recibido:
/// - Viguetas PRE: Muestra bovedillas fijo
/// - Tradicional: Selector de tipo de ladrillo
/// - Maciza: Sin material aligerante, altura desde 15cm
class DatosLosaScreen extends ConsumerStatefulWidget {
  final TipoLosa tipoLosa;

  const DatosLosaScreen({
    required this.tipoLosa,
    super.key,
  });

  static const String route = 'datos-losa';

  @override
  ConsumerState<DatosLosaScreen> createState() => _DatosLosaScreenState();
}

class _DatosLosaScreenState extends ConsumerState<DatosLosaScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, TutorialMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late SharedPreferencesHelper sharedPreferencesHelper;

  int _currentIndex = 0;
  bool _isLoading = false;

  // Controladores de texto
  final TextEditingController _desperdicioMaterialController = TextEditingController(text: '7');
  final TextEditingController _desperdicioConcretoController = TextEditingController(text: '5');
  final TextEditingController _descriptionAreaController = TextEditingController();
  final TextEditingController _descriptionMedidasController = TextEditingController();
  final TextEditingController _areaTextController = TextEditingController();
  final TextEditingController _largoTextController = TextEditingController();
  final TextEditingController _anchoTextController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estados de selección
  String? _selectedAlturaLosa;
  String? _selectedMaterialAligerante;
  String? _selectedResistenciaConcreto;

  // Listas dinámicas
  List<Map<String, TextEditingController>> _areaFields = [];
  List<Map<String, TextEditingController>> _measureFields = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  //  initializeTutorial();
  //  _checkAndShowTutorial();

    // Pre-seleccionar material para viguetas
    if (widget.tipoLosa == TipoLosa.viguetasPrefabricadas) {
      _selectedMaterialAligerante = LosaService.getMaterialFijo(widget.tipoLosa);
    }
  }

  void _checkAndShowTutorial() {
    showModuleTutorial('losa');
  }

  void _showTutorialManually() {
    forceTutorial('losa');
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
    _desperdicioMaterialController.dispose();
    _desperdicioConcretoController.dispose();
    _descriptionAreaController.dispose();
    _descriptionMedidasController.dispose();
    _areaTextController.dispose();
    _largoTextController.dispose();
    _anchoTextController.dispose();
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
      titleAppBar: widget.tipoLosa.displayName,
      isVisibleTutorial: false,
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
            AppColors.blueMetraShop.withValues(alpha: 0.1),
            AppColors.blueMetraShop.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blueMetraShop.withValues(alpha: 0.2),
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
                  color: AppColors.blueMetraShop.withValues(alpha: 0.1),
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
                      widget.tipoLosa.shortName,
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
          _buildAlturaSelection(),

          // CONDITIONAL: Solo para losas aligeradas (no maciza)
          if (widget.tipoLosa.tieneMaterialAligerante) ...[
            const SizedBox(height: 16),
            _buildMaterialAligeranteSection(),
          ],

          const SizedBox(height: 16),
          _buildResistenciaSelection(),
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
              title: 'Factores de Desperdicio',
              subtitle: 'Configura los porcentajes de desperdicio',
              icon: Icons.tune,
            ),
            const SizedBox(height: 16),
            _buildDesperdiciosSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesperdiciosSection() {
    // Losa maciza: Solo desperdicio de concreto
    if (!widget.tipoLosa.tieneMaterialAligerante) {
      return ModernTextField(
        controller: _desperdicioConcretoController,
        label: 'Desperdicio Concreto',
        suffix: '%',
        validator: Validators.percentageField,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: Icons.water_drop,
      );
    }

    // Losas aligeradas: Desperdicio de material + concreto
    return Row(
      children: [
        Expanded(
          child: ModernTextField(
            controller: _desperdicioMaterialController,
            label: 'Desperdicio ${_getMaterialLabel()}',
            suffix: '%',
            validator: Validators.percentageField,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.construction,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ModernTextField(
            controller: _desperdicioConcretoController,
            label: 'Desperdicio Concreto',
            suffix: '%',
            validator: Validators.percentageField,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.water_drop,
          ),
        ),
      ],
    );
  }

  String _getMaterialLabel() {
    switch (widget.tipoLosa) {
      case TipoLosa.viguetasPrefabricadas:
        return 'Bovedillas';
      case TipoLosa.tradicional:
        return 'Ladrillo';
      case TipoLosa.maciza:
        return '';
    }
  }

  Widget _buildAlturaSelection() {
    final alturas = widget.tipoLosa.alturasValidas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Altura de Losa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ModernChoiceChips(
          options: alturas,
          selectedValue: _selectedAlturaLosa,
          onSelected: (value) {
            setState(() {
              _selectedAlturaLosa = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMaterialAligeranteSection() {
    // Viguetas: Material fijo (Bovedillas)
    if (widget.tipoLosa == TipoLosa.viguetasPrefabricadas) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Material Aligerante',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blueMetraShop.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.blueMetraShop.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.blueMetraShop,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Material: Bovedillas (pre-seleccionado)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Tradicional: Selector de tipo de ladrillo
    if (widget.tipoLosa == TipoLosa.tradicional) {
      final tiposLadrillo = LosaService.getTiposLadrilloValidos(widget.tipoLosa) ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Ladrillo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ModernChoiceChips(
            options: tiposLadrillo,
            selectedValue: _selectedMaterialAligerante,
            onSelected: (value) {
              setState(() {
                _selectedMaterialAligerante = value;
              });
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildResistenciaSelection() {
    final resistencias = LosaService.getResistenciasValidas(widget.tipoLosa);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resistencia de Concreto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ModernChoiceChips(
          options: resistencias,
          selectedValue: _selectedResistenciaConcreto,
          onSelected: (value) {
            setState(() {
              _selectedResistenciaConcreto = value;
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
            subtitle: 'Ingresa las medidas de tu losa',
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
                hintText: 'Ej: Losa Dormitorio',
                validator: Validators.requiredField,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: _areaTextController,
                label: 'Área Total',
                suffix: 'm²',
                validator: Validators.positiveNumber,
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
                hintText: 'Ej: Losa Dormitorio',
                validator: Validators.requiredField,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ModernTextField(
                      controller: _largoTextController,
                      label: 'Largo',
                      suffix: 'm',
                      validator: Validators.positiveNumber,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.straighten,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernTextField(
                      controller: _anchoTextController,
                      label: 'Ancho',
                      suffix: 'm',
                      validator: Validators.positiveNumber,
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
          hintText: 'Ej: Losa cocina',
          validator: Validators.requiredField,
          prefixIcon: Icons.description,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: field['measure']!,
          label: 'Área',
          suffix: 'm²',
          validator: Validators.positiveNumber,
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
          hintText: 'Ej: Losa cocina',
          validator: Validators.requiredField,
          prefixIcon: Icons.description,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModernTextField(
                controller: field['largoMeasure']!,
                label: 'Largo',
                suffix: 'm',
                validator: Validators.positiveNumber,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.straighten,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ModernTextField(
                controller: field['anchoMeasure']!,
                label: 'Ancho',
                suffix: 'm',
                validator: Validators.positiveNumber,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ModernActionButtonD(
          onPressed: _isLoading ? null : _processCalculation,
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
        'largoMeasure': TextEditingController(),
        'anchoMeasure': TextEditingController(),
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
      await _createLosaData();

      // Solo navegar si no hubo errores
      await Future.delayed(const Duration(milliseconds: 300));


      if (mounted) {
        context.pushNamed(
          'losas-resultados',
          pathParameters: {'tipo': widget.tipoLosa.routePath},
        );
      }
    } catch (e) {
      _showErrorMessage('Error al procesar los datos: ${e.toString()}');
      // No navegar si hay error
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

    if (_selectedAlturaLosa == null) {
      _showErrorMessage('Selecciona la altura de la losa');
      return false;
    }

    // Validar material aligerante para losas aligeradas
    if (widget.tipoLosa.tieneMaterialAligerante &&
        widget.tipoLosa == TipoLosa.tradicional &&
        _selectedMaterialAligerante == null) {
      _showErrorMessage('Selecciona el tipo de ladrillo');
      return false;
    }

    if (_selectedResistenciaConcreto == null) {
      _showErrorMessage('Selecciona la resistencia del concreto');
      return false;
    }

    return true;
  }

  Future<void> _createLosaData() async {
    final losaResult = ref.read(losaResultProvider.notifier);
    losaResult.clearList();


    if (_currentIndex == 0) {
      // Tab de área

      if (_descriptionAreaController.text.isNotEmpty &&
          _areaTextController.text.isNotEmpty) {

        losaResult.createLosa(
          tipo: widget.tipoLosa,
          description: _descriptionAreaController.text,
          altura: _selectedAlturaLosa!,
          resistenciaConcreto: _selectedResistenciaConcreto!,
          desperdicioConcreto: _desperdicioConcretoController.text,
          materialAligerante: _selectedMaterialAligerante,
          desperdicioMaterialAligerante: widget.tipoLosa.tieneMaterialAligerante
              ? _desperdicioMaterialController.text
              : null,
          area: _areaTextController.text,
        );
      } else {
      }

      for (var field in _areaFields) {
        if (field['description']!.text.isNotEmpty &&
            field['measure']!.text.isNotEmpty) {
          losaResult.createLosa(
            tipo: widget.tipoLosa,
            description: field['description']!.text,
            altura: _selectedAlturaLosa!,
            resistenciaConcreto: _selectedResistenciaConcreto!,
            desperdicioConcreto: _desperdicioConcretoController.text,
            materialAligerante: _selectedMaterialAligerante,
            desperdicioMaterialAligerante: widget.tipoLosa.tieneMaterialAligerante
                ? _desperdicioMaterialController.text
                : null,
            area: field['measure']!.text,
          );
        }
      }
    } else {
      // Tab de medidas
      if (_descriptionMedidasController.text.isNotEmpty &&
          _largoTextController.text.isNotEmpty &&
          _anchoTextController.text.isNotEmpty) {
        losaResult.createLosa(
          tipo: widget.tipoLosa,
          description: _descriptionMedidasController.text,
          altura: _selectedAlturaLosa!,
          resistenciaConcreto: _selectedResistenciaConcreto!,
          desperdicioConcreto: _desperdicioConcretoController.text,
          materialAligerante: _selectedMaterialAligerante,
          desperdicioMaterialAligerante: widget.tipoLosa.tieneMaterialAligerante
              ? _desperdicioMaterialController.text
              : null,
          largo: _largoTextController.text,
          ancho: _anchoTextController.text,
        );
      }

      for (var field in _measureFields) {
        if (field['descriptionMeasure']!.text.isNotEmpty &&
            field['largoMeasure']!.text.isNotEmpty &&
            field['anchoMeasure']!.text.isNotEmpty) {
          losaResult.createLosa(
            tipo: widget.tipoLosa,
            description: field['descriptionMeasure']!.text,
            altura: _selectedAlturaLosa!,
            resistenciaConcreto: _selectedResistenciaConcreto!,
            desperdicioConcreto: _desperdicioConcretoController.text,
            materialAligerante: _selectedMaterialAligerante,
            desperdicioMaterialAligerante: widget.tipoLosa.tieneMaterialAligerante
                ? _desperdicioMaterialController.text
                : null,
            largo: field['largoMeasure']!.text,
            ancho: field['anchoMeasure']!.text,
          );
        }
      }
    }

    // Verificar cuántas losas se crearon
    final losasCreadas = ref.read(losaResultProvider);
    if (losasCreadas.isEmpty) {
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

}
