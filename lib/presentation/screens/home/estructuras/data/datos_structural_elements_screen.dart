import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/config/assets/app_icons.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../data/local/shared_preferences_helper.dart';
import '../../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../../widgets/modern_widgets.dart';
import '../../../../widgets/tutorial/tutorial_overlay.dart';
import '../../../../widgets/widgets.dart';

class DatosStructuralElementsScreen extends ConsumerStatefulWidget {
  const DatosStructuralElementsScreen({super.key});
  static const String route = 'detail';

  @override
  ConsumerState<DatosStructuralElementsScreen> createState() => _DatosStructuralElementsScreenState();
}

class _DatosStructuralElementsScreenState extends ConsumerState<DatosStructuralElementsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, TutorialMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  bool _isLoading = false;

  // Controladores de texto modernos
  final TextEditingController _factorController = TextEditingController(text: '5');
  final TextEditingController _descriptionAreaController = TextEditingController();
  final TextEditingController _descriptionMedidasController = TextEditingController();
  final TextEditingController _volumenTextController = TextEditingController();
  final TextEditingController _lengthTextController = TextEditingController();
  final TextEditingController _widthTextController = TextEditingController();
  final TextEditingController _heightTextController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estados de selección
  String? _selectedResistencia;

  // Listas dinámicas
  List<Map<String, TextEditingController>> _volumenFields = [];
  List<Map<String, TextEditingController>> _dimensionesFields = [];

  // Tipo de elemento
  String tipoElemento = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    initializeTutorial();
    _checkAndShowTutorial();
    _validateAndSetElementType();
  }

  void _checkAndShowTutorial() {
    // Mostrar tutorial específico para tarrajeo
    showModuleTutorial('structural');
  }

  void _showTutorialManually() {
    forceTutorial('structural');
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

  void _validateAndSetElementType() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tipo = ref.read(tipoStructuralElementProvider);
      print('🔍 Tipo de elemento obtenido en DatosScreen: $tipo');

      if (tipo.isEmpty) {
        print('⚠️ Tipo de elemento vacío, redirigiendo...');
        context.pop();
        return;
      }

      setState(() {
        tipoElemento = tipo;
      });

      print('✅ Tipo de elemento establecido: $tipoElemento');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _factorController.dispose();
    _descriptionAreaController.dispose();
    _descriptionMedidasController.dispose();
    _volumenTextController.dispose();
    _lengthTextController.dispose();
    _widthTextController.dispose();
    _heightTextController.dispose();
    _disposeDynamicFields();
    super.dispose();
  }

  void _disposeDynamicFields() {
    for (var field in _volumenFields) {
      field.values.forEach((controller) => controller.dispose());
    }
    for (var field in _dimensionesFields) {
      field.values.forEach((controller) => controller.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Observar cambios en el provider
    ref.listen(tipoStructuralElementProvider, (previous, next) {
      print('🔄 Cambio detectado en tipoStructuralElementProvider: $previous -> $next');
      if (next.isNotEmpty && next != tipoElemento) {
        setState(() {
          tipoElemento = next;
        });
      }
    });

    // Si no tenemos tipo, mostrar loading
    if (tipoElemento.isEmpty) {
      return Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Cargando...'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String appBarTitle = tipoElemento == 'columna'
        ? 'Datos de Columna'
        : tipoElemento == 'viga'
        ? 'Datos de Viga'
        : tipoElemento == 'sobrecimiento'
        ? 'Datos de Sobrecimiento'
        : tipoElemento == 'cimiento_corrido'
        ? 'Datos de Cimiento Corrido'
        : tipoElemento == 'solado'
        ? 'Datos de Solado'
        : 'Datos de Elemento';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(appBarTitle),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
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
                      'Elemento: ${tipoElemento.capitalize()}',
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
              title: 'Factor de Desperdicio',
              subtitle: 'Configura el porcentaje de desperdicio',
              icon: Icons.tune,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _factorController,
              label: 'Desperdicio',
              suffix: '%',
              validator: _validatePercentage,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.construction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResistenciaSelection() {
    List<String> opcionesResistencia = [];

    switch (tipoElemento) {
      case 'columna':
        opcionesResistencia = ["175 kg/cm²", "210 kg/cm²", "280 kg/cm²"];
        break;
      case 'viga':
        opcionesResistencia = ["175 kg/cm²", "210 kg/cm²", "280 kg/cm²"]; // si quieres que sea lo mismo
        break;
      case 'sobrecimiento':
        opcionesResistencia = ["175 kg/cm²"];
        break;
        case 'cimiento_corrido':
        opcionesResistencia = ["175 kg/cm²"];
        break;
      case 'solado':
        opcionesResistencia = ["175 kg/cm²"];
        break;
      default:
        opcionesResistencia = ["175 kg/cm²", "210 kg/cm²", "280 kg/cm²"];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resistencia del Concreto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ModernChoiceChips(
          options: opcionesResistencia,
          selectedValue: _selectedResistencia,
          onSelected: (value) {
            setState(() {
              _selectedResistencia = value;
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
            subtitle: 'Ingresa las medidas de tu elemento estructural',
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
                      _buildVolumenTab(),
                      _buildDimensionesTab(),
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
            icon: Icon(Icons.view_in_ar),
            text: 'Por Volumen',
          ),
          Tab(
            icon: Icon(Icons.straighten),
            text: 'Por Dimensiones',
          ),
        ],
      ),
    );
  }

  Widget _buildVolumenTab() {
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
                hintText: 'Ej: ${tipoElemento.capitalize()} principal',
                validator: _validateRequired,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: _volumenTextController,
                label: 'Volumen',
                suffix: 'm³',
                validator: _validateNumeric,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.view_in_ar,
              ),
            ],
          ),
          ..._volumenFields.map((field) => _buildDynamicVolumenField(field)),
          const SizedBox(height: 16),
          ModernAddButton(
            onPressed: _addVolumenField,
            label: 'Agregar Nuevo Volumen',
            icon: Icons.add_box,
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionesTab() {
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
                hintText: 'Ej: ${tipoElemento.capitalize()} principal',
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
                      controller: _widthTextController,
                      label: 'Ancho',
                      suffix: 'm',
                      validator: _validateNumeric,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.width_full,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: _heightTextController,
                label: 'Altura',
                suffix: 'm',
                validator: _validateNumeric,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.height,
              ),
            ],
          ),
          ..._dimensionesFields.map((field) => _buildDynamicDimensionesField(field)),
          const SizedBox(height: 16),
          ModernAddButton(
            onPressed: _addDimensionesField,
            label: 'Agregar Nueva Dimensión',
            icon: Icons.add_box,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicVolumenField(Map<String, TextEditingController> field) {
    return ModernMeasurementCard(
      title: 'Volumen Adicional',
      onRemove: () => _removeField(_volumenFields, field),
      children: [
        ModernTextField(
          controller: field['description']!,
          label: 'Descripción',
          hintText: 'Ej: ${tipoElemento.capitalize()} secundario',
          validator: _validateRequired,
          prefixIcon: Icons.description,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: field['volumen']!,
          label: 'Volumen',
          suffix: 'm³',
          validator: _validateNumeric,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icons.view_in_ar,
        ),
      ],
    );
  }

  Widget _buildDynamicDimensionesField(Map<String, TextEditingController> field) {
    return ModernMeasurementCard(
      title: 'Dimensión Adicional',
      onRemove: () => _removeField(_dimensionesFields, field),
      children: [
        ModernTextField(
          controller: field['description']!,
          label: 'Descripción',
          hintText: 'Ej: ${tipoElemento.capitalize()} secundario',
          validator: _validateRequired,
          prefixIcon: Icons.description,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModernTextField(
                controller: field['largo']!,
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
                controller: field['ancho']!,
                label: 'Ancho',
                suffix: 'm',
                validator: _validateNumeric,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.width_full,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: field['altura']!,
          label: 'Altura',
          suffix: 'm',
          validator: _validateNumeric,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icons.height,
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
  void _addVolumenField() {
    setState(() {
      _volumenFields.add({
        'description': TextEditingController(),
        'volumen': TextEditingController(),
      });
    });
  }

  void _addDimensionesField() {
    setState(() {
      _dimensionesFields.add({
        'description': TextEditingController(),
        'largo': TextEditingController(),
        'ancho': TextEditingController(),
        'altura': TextEditingController(),
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
      context.showCalculationLoader(
        message: 'Calculando materiales',
        description: 'Aplicando fórmulas estructurales...',
      );

      // Procesar según el tipo de elemento
      final tipoActual = ref.read(tipoStructuralElementProvider);
      print('🎯 Procesando datos para tipo: $tipoActual');

      if (tipoActual == 'columna') {
        _processColumnaData();
      } else if (tipoActual == 'viga') {
        _processVigaData();
      } else if (tipoActual == 'zapata') {
        _processZapataData();
      } else if (tipoActual == 'sobrecimiento') {
        _processSobrecimientoData();
      } else if (tipoActual == 'cimiento_corrido') {
        _processCimientoCorridoData();
      } else if (tipoActual == 'solado') {
        _processSoladoData();
      } else {
        print('❌ Tipo no reconocido: $tipoActual');
        _showErrorMessage('Error: Tipo de elemento no válido');
        return;
      }

      // Observar cambios en los providers
      ref.watch(vigaResultProvider);
      ref.watch(columnaResultProvider);
      ref.watch(zapataResultProvider);
      ref.watch(sobrecimientoResultProvider);
      ref.watch(cimientoCorridoResultProvider);
      ref.watch(soladoResultProvider);
      context.pushNamed('structural-element-results');

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
        context.hideLoader();
      }
    }
  }

  bool _validateForm() {
    if (_formKey.currentState?.validate() != true) {
      _showErrorMessage('Por favor, completa todos los campos obligatorios');
      return false;
    }

    if (_selectedResistencia == null) {
      _showErrorMessage('Selecciona una resistencia del concreto');
      return false;
    }

    return true;
  }

  void _processColumnaData() {
    var datosColumna = ref.read(columnaResultProvider.notifier);
    datosColumna.clearList();

    try {
      if (_currentIndex == 0) {
        // Tab de volumen
        if (_descriptionAreaController.text.isNotEmpty &&
            _volumenTextController.text.isNotEmpty) {
          datosColumna.createColumna(
            _descriptionAreaController.text,
            _selectedResistencia!,
            _factorController.text,
            volumen: _volumenTextController.text,
          );
        }

        for (var field in _volumenFields) {
          if (field['description']!.text.isNotEmpty &&
              field['volumen']!.text.isNotEmpty) {
            datosColumna.createColumna(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              volumen: field['volumen']!.text,
            );
          }
        }
      } else {
        // Tab de dimensiones
        if (_descriptionMedidasController.text.isNotEmpty &&
            _lengthTextController.text.isNotEmpty &&
            _widthTextController.text.isNotEmpty &&
            _heightTextController.text.isNotEmpty) {
          datosColumna.createColumna(
            _descriptionMedidasController.text,
            _selectedResistencia!,
            _factorController.text,
            largo: _lengthTextController.text,
            ancho: _widthTextController.text,
            altura: _heightTextController.text,
          );
        }

        for (var field in _dimensionesFields) {
          if (field['description']!.text.isNotEmpty &&
              field['largo']!.text.isNotEmpty &&
              field['ancho']!.text.isNotEmpty &&
              field['altura']!.text.isNotEmpty) {
            datosColumna.createColumna(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              largo: field['largo']!.text,
              ancho: field['ancho']!.text,
              altura: field['altura']!.text,
            );
          }
        }
      }

      final columnasCreadas = ref.read(columnaResultProvider);
      print("✅ Columnas creadas: ${columnasCreadas.length}");
    } catch (e) {
      print("❌ Error creando columnas: $e");
      _showErrorMessage('Error al procesar datos de columna: $e');
    }
  }

  void _processVigaData() {
    var datosViga = ref.read(vigaResultProvider.notifier);
    datosViga.clearList();

    try {
      if (_currentIndex == 0) {
        // Tab de volumen
        if (_descriptionAreaController.text.isNotEmpty &&
            _volumenTextController.text.isNotEmpty) {
          datosViga.createViga(
            _descriptionAreaController.text,
            _selectedResistencia!,
            _factorController.text,
            volumen: _volumenTextController.text,
          );
        }

        for (var field in _volumenFields) {
          if (field['description']!.text.isNotEmpty &&
              field['volumen']!.text.isNotEmpty) {
            datosViga.createViga(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              volumen: field['volumen']!.text,
            );
          }
        }
      } else {
        // Tab de dimensiones
        if (_descriptionMedidasController.text.isNotEmpty &&
            _lengthTextController.text.isNotEmpty &&
            _widthTextController.text.isNotEmpty &&
            _heightTextController.text.isNotEmpty) {
          datosViga.createViga(
            _descriptionMedidasController.text,
            _selectedResistencia!,
            _factorController.text,
            largo: _lengthTextController.text,
            ancho: _widthTextController.text,
            altura: _heightTextController.text,
          );
        }

        for (var field in _dimensionesFields) {
          if (field['description']!.text.isNotEmpty &&
              field['largo']!.text.isNotEmpty &&
              field['ancho']!.text.isNotEmpty &&
              field['altura']!.text.isNotEmpty) {
            datosViga.createViga(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              largo: field['largo']!.text,
              ancho: field['ancho']!.text,
              altura: field['altura']!.text,
            );
          }
        }
      }

      final vigasCreadas = ref.read(vigaResultProvider);
      print("✅ Vigas creadas: ${vigasCreadas.length}");
    } catch (e) {
      print("❌ Error creando vigas: $e");
      _showErrorMessage('Error al procesar datos de viga: $e');
    }
  }

  void _processZapataData() {
    var datosZapata = ref.read(zapataResultProvider.notifier);
    datosZapata.clearList();

    try {
      if (_currentIndex == 0) {
        // Tab de volumen
        if (_descriptionAreaController.text.isNotEmpty &&
            _volumenTextController.text.isNotEmpty) {
          datosZapata.createZapata(
            _descriptionAreaController.text,
            _selectedResistencia!,
            _factorController.text,
            volumen: _volumenTextController.text,
          );
        }

        for (var field in _volumenFields) {
          if (field['description']!.text.isNotEmpty &&
              field['volumen']!.text.isNotEmpty) {
            datosZapata.createZapata(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              volumen: field['volumen']!.text,
            );
          }
        }
      } else {
        // Tab de dimensiones
        if (_descriptionMedidasController.text.isNotEmpty &&
            _lengthTextController.text.isNotEmpty &&
            _widthTextController.text.isNotEmpty &&
            _heightTextController.text.isNotEmpty) {
          datosZapata.createZapata(
            _descriptionMedidasController.text,
            _selectedResistencia!,
            _factorController.text,
            largo: _lengthTextController.text,
            ancho: _widthTextController.text,
            altura: _heightTextController.text,
          );
        }

        for (var field in _dimensionesFields) {
          if (field['description']!.text.isNotEmpty &&
              field['largo']!.text.isNotEmpty &&
              field['ancho']!.text.isNotEmpty &&
              field['altura']!.text.isNotEmpty) {
            datosZapata.createZapata(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              largo: field['largo']!.text,
              ancho: field['ancho']!.text,
              altura: field['altura']!.text,
            );
          }
        }
      }

      final zapatasCreadas = ref.read(zapataResultProvider);
      print("✅ Zapatas creadas: ${zapatasCreadas.length}");
    } catch (e) {
      print("❌ Error creando zapatas: $e");
      _showErrorMessage('Error al procesar datos de zapata: $e');
    }
  }

  void _processSobrecimientoData() {
    var datosSobrecimiento = ref.read(sobrecimientoResultProvider.notifier);
    datosSobrecimiento.clearList();

    try {
      if (_currentIndex == 0) {
        // Tab de volumen
        if (_descriptionAreaController.text.isNotEmpty &&
            _volumenTextController.text.isNotEmpty) {
          datosSobrecimiento.createSobrecimiento(
            _descriptionAreaController.text,
            _selectedResistencia!,
            _factorController.text,
            volumen: _volumenTextController.text,
          );
        }

        for (var field in _volumenFields) {
          if (field['description']!.text.isNotEmpty &&
              field['volumen']!.text.isNotEmpty) {
            datosSobrecimiento.createSobrecimiento(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              volumen: field['volumen']!.text,
            );
          }
        }
      } else {
        // Tab de dimensiones
        if (_descriptionMedidasController.text.isNotEmpty &&
            _lengthTextController.text.isNotEmpty &&
            _widthTextController.text.isNotEmpty &&
            _heightTextController.text.isNotEmpty) {
          datosSobrecimiento.createSobrecimiento(
            _descriptionMedidasController.text,
            _selectedResistencia!,
            _factorController.text,
            largo: _lengthTextController.text,
            ancho: _widthTextController.text,
            altura: _heightTextController.text,
          );
        }

        for (var field in _dimensionesFields) {
          if (field['description']!.text.isNotEmpty &&
              field['largo']!.text.isNotEmpty &&
              field['ancho']!.text.isNotEmpty &&
              field['altura']!.text.isNotEmpty) {
            datosSobrecimiento.createSobrecimiento(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              largo: field['largo']!.text,
              ancho: field['ancho']!.text,
              altura: field['altura']!.text,
            );
          }
        }
      }

      final sobrecimientosCreados = ref.read(sobrecimientoResultProvider);
      print("✅ Sobrecimientos creados: ${sobrecimientosCreados.length}");
    } catch (e) {
      print("❌ Error creando sobrecimientos: $e");
      _showErrorMessage('Error al procesar datos de sobrecimiento: $e');
    }
  }

  void _processCimientoCorridoData() {
    var datosCimiento = ref.read(cimientoCorridoResultProvider.notifier);
    datosCimiento.clearList();

    try {
      if (_currentIndex == 0) {
        // Tab de volumen
        if (_descriptionAreaController.text.isNotEmpty &&
            _volumenTextController.text.isNotEmpty) {
          datosCimiento.createCimientoCorrido(
            _descriptionAreaController.text,
            _selectedResistencia!,
            _factorController.text,
            volumen: _volumenTextController.text,
          );
        }

        for (var field in _volumenFields) {
          if (field['description']!.text.isNotEmpty &&
              field['volumen']!.text.isNotEmpty) {
            datosCimiento.createCimientoCorrido(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              volumen: field['volumen']!.text,
            );
          }
        }
      } else {
        // Tab de dimensiones
        if (_descriptionMedidasController.text.isNotEmpty &&
            _lengthTextController.text.isNotEmpty &&
            _widthTextController.text.isNotEmpty &&
            _heightTextController.text.isNotEmpty) {
          datosCimiento.createCimientoCorrido(
            _descriptionMedidasController.text,
            _selectedResistencia!,
            _factorController.text,
            largo: _lengthTextController.text,
            ancho: _widthTextController.text,
            altura: _heightTextController.text,
          );
        }

        for (var field in _dimensionesFields) {
          if (field['description']!.text.isNotEmpty &&
              field['largo']!.text.isNotEmpty &&
              field['ancho']!.text.isNotEmpty &&
              field['altura']!.text.isNotEmpty) {
            datosCimiento.createCimientoCorrido(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              largo: field['largo']!.text,
              ancho: field['ancho']!.text,
              altura: field['altura']!.text,
            );
          }
        }
      }

      final cimientosCreados = ref.read(cimientoCorridoResultProvider);
      print("✅ Cimientos corridos creados: ${cimientosCreados.length}");
    } catch (e) {
      print("❌ Error creando cimientos corridos: $e");
      _showErrorMessage('Error al procesar datos de cimiento corrido: $e');
    }
  }

  void _processSoladoData() {
    var datosSolado = ref.read(soladoResultProvider.notifier);
    datosSolado.clearList();

    try {
      if (_currentIndex == 0) {
        // Tab de área (para solado es más apropiado que volumen)
        if (_descriptionAreaController.text.isNotEmpty &&
            _volumenTextController.text.isNotEmpty) {
          // Para solado, interpretar como área
          datosSolado.createSolado(
            _descriptionAreaController.text,
            _selectedResistencia!,
            _factorController.text,
            area: _volumenTextController.text,
          );
        }

        for (var field in _volumenFields) {
          if (field['description']!.text.isNotEmpty &&
              field['volumen']!.text.isNotEmpty) {
            datosSolado.createSolado(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              area: field['volumen']!.text,
            );
          }
        }
      } else {
        // Tab de dimensiones (largo × ancho para calcular área)
        if (_descriptionMedidasController.text.isNotEmpty &&
            _lengthTextController.text.isNotEmpty &&
            _widthTextController.text.isNotEmpty) {
          datosSolado.createSolado(
            _descriptionMedidasController.text,
            _selectedResistencia!,
            _factorController.text,
            largo: _lengthTextController.text,
            ancho: _widthTextController.text,
          );
        }

        for (var field in _dimensionesFields) {
          if (field['description']!.text.isNotEmpty &&
              field['largo']!.text.isNotEmpty &&
              field['ancho']!.text.isNotEmpty) {
            datosSolado.createSolado(
              field['description']!.text,
              _selectedResistencia!,
              _factorController.text,
              largo: field['largo']!.text,
              ancho: field['ancho']!.text,
            );
          }
        }
      }

      final soladosCreados = ref.read(soladoResultProvider);
      print("✅ Solados creados: ${soladosCreados.length}");
    } catch (e) {
      print("❌ Error creando solados: $e");
      _showErrorMessage('Error al procesar datos de solado: $e');
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

// Extension helper para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}