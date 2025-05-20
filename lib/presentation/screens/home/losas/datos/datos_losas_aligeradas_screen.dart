// lib/presentation/screens/home/losas/datos_losas_aligeradas_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/widgets/fields/custom_factor_text_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_measure_text_field.dart';

import '../../../../../config/constants/colors.dart';
import '../../../../../data/local/shared_preferences_helper.dart';

import '../../../../../init_dependencies.dart';
import '../../../../providers/providers.dart';
import '../../../../widgets/fields/custom_name_text_field.dart';
import '../../../../widgets/widgets.dart';
import '../../muro/ladrillo/tutorial/tutorial_ladrillo_screen.dart';

class DatosLosasAligeradasScreen extends ConsumerStatefulWidget {
  const DatosLosasAligeradasScreen({super.key});
  static const String route = 'datos-losas-aligeradas';

  @override
  ConsumerState<DatosLosasAligeradasScreen> createState() => _DatosLosasAligeradasScreenState();
}

class _DatosLosasAligeradasScreenState extends ConsumerState<DatosLosasAligeradasScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  late final SharedPreferencesHelper sharedPreferencesHelper;

  // TextControllers para los campos de entrada
  final TextEditingController desperdicioLadrilloController = TextEditingController(text: '5');
  final TextEditingController desperdicioConcretoController = TextEditingController(text: '5');
  final TextEditingController descriptionAreaController = TextEditingController();
  final TextEditingController descriptionMedidasController = TextEditingController();
  final TextEditingController areaTextController = TextEditingController();
  final TextEditingController largoTextController = TextEditingController();
  final TextEditingController anchoTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // Variables para almacenar las selecciones del usuario
  bool showSelectionError = false;
  String? selectedValueAltura;
  String? selectedValueMaterial;
  String? selectedValueResistencia;

  // Listas de campos dinámicos
  List<Map<String, TextEditingController>> areaFields = [];
  List<Map<String, TextEditingController>> measureFields = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    // Cargamos la configuración de SharedPreferences si es necesario
    sharedPreferencesHelper = serviceLocator<SharedPreferencesHelper>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!sharedPreferencesHelper.isTutorialShown()) {
        showTutorial();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void showTutorial() {
    showDialog(
      context: context,
      builder: (context) => TutorialOverlay(
        onSkip: () {
          sharedPreferencesHelper.setTutorialShown(true);
          context.pop();
        },
      ),
    );
  }

  String? _validateStringRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (double.tryParse(value) == null) {
      return 'Por favor ingresa un número válido';
    }
    if (double.parse(value) < 0) {
      return 'El valor debe ser mayor o igual a 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBarWidget(titleAppBar: 'Losa Aligerada', isVisibleTutorial: true, showTutorial: showTutorial),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                scrollDirection: Axis.vertical,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24, right: 24, left: 24, bottom: 10),
                        child: Column(
                          children: [
                            _buildAlturaSelection(),
                            _buildMaterialSelection(),
                            _buildResistenciaSelection(),
                            _buildProjectFields(),
                          ],
                        ),
                      ),
                      _buildTabs(context),
                    ],
                  ),
                ),
              ),
            ),
            _buildResultButton(),
            const SizedBox(height: 45),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectFields() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const SizedBox(height: 15),
    Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
    children: [
    CustomFactorTextField(
    controller: desperdicioLadrilloController,
    label: 'Desperdicio Ladrillo (%)',
    validator: _validateNumeric,
    hintText: '',
    ),
    CustomFactorTextField(
      // lib/presentation/screens/home/losas/datos_losas_aligeradas_screen.dart (continued)
      controller: desperdicioConcretoController,
      label: 'Desperdicio Concreto (%)',
      validator: _validateNumeric,
      hintText: '',
    ),
    ],
    ),
    ),
          const SizedBox(height: 15),
        ],
    );
  }

  Widget _buildAlturaSelection() {
    final List<String> alturas = ["17 cm", "20 cm", "25 cm"];
    return _buildChoiceChips(
        'altura',
        'Altura de Losa Aligerada:',
        alturas
    );
  }

  Widget _buildMaterialSelection() {
    final List<String> materiales = ["Ladrillo Hueco", "Bovedillas"];
    return _buildChoiceChips(
        'material',
        'Material de Aligerado:',
        materiales
    );
  }

  Widget _buildResistenciaSelection() {
    final List<String> resistencias = ["140 kg/cm²", "175 kg/cm²",  "210 kg/cm²", "245 kg/cm²", "280 kg/cm²"];
    return _buildChoiceChips(
        'resistencia',
        'Resistencia de Concreto:',
        resistencias
    );
  }

  Widget _buildChoiceChips(String type, String description, List<String> items) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryMetraShop),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((value) {
              bool isSelected = false;
              switch (type) {
                case 'altura':
                  isSelected = selectedValueAltura == value;
                  break;
                case 'material':
                  isSelected = selectedValueMaterial == value;
                  break;
                case 'resistencia':
                  isSelected = selectedValueResistencia == value;
                  break;
              }

              return ChoiceChip(
                label: Text(value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      switch (type) {
                        case 'altura':
                          selectedValueAltura = value;
                          break;
                        case 'material':
                          selectedValueMaterial = value;
                          break;
                        case 'resistencia':
                          selectedValueResistencia = value;
                          break;
                      }
                    });
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected ? AppColors.blueMetraShop : AppColors.blueMetraShop.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
                checkmarkColor: isSelected ? AppColors.white : AppColors.blueMetraShop.withOpacity(0.5),
                selectedColor: AppColors.blueMetraShop,
                backgroundColor: isSelected ? AppColors.blueMetraShop : AppColors.white,
                labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.blueMetraShop.withOpacity(0.5)),
              );
            }).toList(),
          ),
          if (showSelectionError && ((type == 'altura' && selectedValueAltura == null) ||
              (type == 'material' && selectedValueMaterial == null) ||
              (type == 'resistencia' && selectedValueResistencia == null)))
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Campo requerido',
                style: TextStyle(color: Colors.red),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Text('Metrado', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryMetraShop),),
        ),
        const SizedBox(height: 10),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryMetraShop,
          unselectedLabelColor: AppColors.primaryMetraShop.withOpacity(0.5),
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          indicatorColor: AppColors.indicatorTabBarColor,
          tabs: const [
            Tab(text: 'Área'),
            Tab(text: 'Medidas'),
          ],
        ),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAreaTab(),
              _buildMeasureTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAreaTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomNameTextField(
                      controller: descriptionAreaController,
                      label: 'Descripción',
                      hintText: 'Ingresa una descripción (Ej. Losa Dormitorio)',
                      validator: _validateStringRequired,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Datos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMetraShop,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomMeasureTextField(
                      controller: areaTextController,
                      validator: _validateStringRequired,
                      labelText: 'Area(m²)',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                ...areaFields.map((field) => _buildDynamicField(
                    field,
                        () => _removeField(areaFields, field)
                )),
                Container(
                  alignment: Alignment.topLeft,
                  child: CustomTextBlueButton(
                    onPressed: () => _addField(areaFields),
                    label:'Agregar nueva medida',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasureTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomNameTextField(
                      controller: descriptionMedidasController,
                      label: 'Descripción',
                      hintText: 'Ingresa una descripción (Ej. Losa Dormitorio)',
                      validator: _validateStringRequired,
                    ),
                    const Text(
                      'Datos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMetraShop,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomMeasureTextField(
                            controller: largoTextController,
                            validator: _validateStringRequired,
                            labelText: 'Largo(metros)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomMeasureTextField(
                            controller: anchoTextController,
                            validator: _validateStringRequired,
                            labelText: 'Ancho(metros)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                ...measureFields.map((field) => _buildDynamicMeasureField(
                    field,
                        () => _removeField(measureFields, field)
                )),
                Container(
                  alignment: Alignment.centerLeft,
                  child: CustomTextBlueButton(
                    onPressed: () => _addMeasureField(measureFields),
                    label:'Agregar nueva medida',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicField(Map<String, TextEditingController> field, VoidCallback onRemove) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomNameTextField(
              controller: field['description']!,
              label: 'Descripción adicional',
              validator: _validateStringRequired,
              hintText: 'Ingresa una descripción (Ej. Losa ...)',
              onPressed: onRemove,
              icon: Icons.close,
              color: AppColors.errorGeneralColor,
              isVisible: true,
            ),
            const Text(
              'Datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMetraShop,
              ),
            ),
            const SizedBox(height: 8),
            CustomMeasureTextField(
              controller: field['measure']!,
              validator: _validateStringRequired,
              labelText: 'Area(m²)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicMeasureField(Map<String, TextEditingController> field, VoidCallback onRemove) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomNameTextField(
              controller: field['descriptionMeasure']!,
              label: 'Descripción adicional',
              validator: _validateStringRequired,
              hintText: 'Ingresa una descripción (Ej. Losa ...)',
              onPressed: onRemove,
              icon: Icons.close,
              color: AppColors.errorGeneralColor,
              isVisible: true,
            ),
            const SizedBox(height: 10),
            const Text(
              'Datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMetraShop,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomMeasureTextField(
                    controller: field['largoMeasure']!,
                    validator: _validateStringRequired,
                    labelText: 'Largo(metros)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomMeasureTextField(
                    controller: field['anchoMeasure']!,
                    validator: _validateStringRequired,
                    labelText: 'Ancho(metros)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addField(List<Map<String, TextEditingController>> fields) {
    setState(() {
      fields.add({
        'description': TextEditingController(),
        'measure': TextEditingController(),
      });
    });
  }

  void _addMeasureField(List<Map<String, TextEditingController>> fields) {
    setState(() {
      fields.add({
        'descriptionMeasure': TextEditingController(),
        'largoMeasure': TextEditingController(),
        'anchoMeasure': TextEditingController(),
      });
    });
  }

  void _removeField(List<Map<String, TextEditingController>> fields, Map<String, TextEditingController> field) {
    setState(() {
      fields.remove(field);
    });
  }

  Widget _buildResultButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomElevatedButton(
        label: 'Resultado',
        onPressed: () {
          setState(() {
            showSelectionError = selectedValueAltura == null ||
                selectedValueMaterial == null ||
                selectedValueResistencia == null;
          });

          if (formKey.currentState?.validate() == true &&
              selectedValueAltura != null &&
              selectedValueMaterial != null &&
              selectedValueResistencia != null) {

            final losaAligeradaResult = ref.read(losaAligeradaResultProvider.notifier);

            if (_currentIndex == 0) {
              // Pestaña de Área
              losaAligeradaResult.createLosaAligerada(
                descriptionAreaController.text,
                selectedValueAltura!,
                selectedValueMaterial!,
                selectedValueResistencia!,
                desperdicioLadrilloController.text,
                desperdicioConcretoController.text,
                area: areaTextController.text,
              );

              // Agregar campos adicionales
              for (var field in areaFields) {
                losaAligeradaResult.createLosaAligerada(
                  field['description']!.text,
                  selectedValueAltura!,
                  selectedValueMaterial!,
                  selectedValueResistencia!,
                  desperdicioLadrilloController.text,
                  desperdicioConcretoController.text,
                  area: field['measure']!.text,
                );
              }
            } else {
              // Pestaña de Medidas
              losaAligeradaResult.createLosaAligerada(
                descriptionMedidasController.text,
                selectedValueAltura!,
                selectedValueMaterial!,
                selectedValueResistencia!,
                desperdicioLadrilloController.text,
                desperdicioConcretoController.text,
                largo: largoTextController.text,
                ancho: anchoTextController.text,
              );

              // Agregar campos adicionales
              for (var field in measureFields) {
                losaAligeradaResult.createLosaAligerada(
                  field['descriptionMeasure']!.text,
                  selectedValueAltura!,
                  selectedValueMaterial!,
                  selectedValueResistencia!,
                  desperdicioLadrilloController.text,
                  desperdicioConcretoController.text,
                  largo: field['largoMeasure']!.text,
                  ancho: field['anchoMeasure']!.text,
                );
              }
            }
            final pisosCreados = ref.read(losaAligeradaResultProvider);
            print("CREADOS: Número de losas antes de navegar: ${pisosCreados.length}");
            print(ref.watch(losaAligeradaResultProvider));
            // Navegar a la pantalla de resultados
            context.pushNamed('losas-aligeradas-results');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, completa todos los campos obligatorios')),
            );
          }
        },
      ),
    );
  }
}