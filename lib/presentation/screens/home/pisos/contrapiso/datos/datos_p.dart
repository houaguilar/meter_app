import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/providers/pisos/pisos_providers.dart';
import 'package:meter_app/presentation/widgets/fields/custom_factor_text_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_measure_text_field.dart';

import '../../../../../../../data/local/shared_preferences_helper.dart';
import '../../../../../../../init_dependencies.dart';
import '../../../../../../config/theme/theme.dart';
import '../../../../../widgets/fields/custom_name_text_field.dart';
import '../../../../../widgets/widgets.dart';
import '../../../muro/ladrillo/tutorial/tutorial_ladrillo_screen.dart';

class DatosPisosScreens extends ConsumerStatefulWidget {
  const DatosPisosScreens({super.key});
  static const String route = 'contrapiso-detail';

  @override
  ConsumerState<DatosPisosScreens> createState() => _DatosPisosScreenState();
}

class _DatosPisosScreenState extends ConsumerState<DatosPisosScreens> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  late final SharedPreferencesHelper sharedPreferencesHelper;

  // TextControllers para campos base
  final TextEditingController factorController = TextEditingController(text: '5');
  final TextEditingController descriptionAreaController = TextEditingController();
  final TextEditingController descriptionMedidasController = TextEditingController();
  final TextEditingController areaTextController = TextEditingController();
  final TextEditingController lengthTextController = TextEditingController();
  final TextEditingController heightTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool showEspesorError = false;
  bool showProporcionError = false;

  String espesor = "";
  String proporcionMortero = '';

  String? selectedValueEspesor;
  String? selectedValueProporcion;

  // Listas para campos dinámicos
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
    factorController.dispose();
    descriptionAreaController.dispose();
    descriptionMedidasController.dispose();
    areaTextController.dispose();
    lengthTextController.dispose();
    heightTextController.dispose();

    // Dispose dynamic controllers
    for (var field in areaFields) {
      field.values.forEach((controller) => controller.dispose());
    }
    for (var field in measureFields) {
      field.values.forEach((controller) => controller.dispose());
    }

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

  String? _validateProjectName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBarWidget(titleAppBar: 'Contrapiso - Medición'),
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
                            _buildEspesorSelection(),
                            _buildProporcionSelection(),
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: CustomFactorTextField(
            controller: factorController,
            label: 'Desperdicio (%)',
            validator: _validateProjectName,
            hintText: 'Ej: 5',
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildEspesorSelection() {
    // Espesores típicos para contrapiso (4-7 cm)
    const List<String> espesores = ["4 cm", "5 cm", "6 cm", "7 cm"];

    return _contentChoiceChips(
        'espesor',
        'Espesor del Contrapiso:',
        espesores
    );
  }

  Widget _buildProporcionSelection() {
    // Proporciones de mortero más comunes para contrapiso
    const List<String> proporciones = ["1 : 3", "1 : 4", "1 : 5", "1 : 6"];
    return _contentChoiceChips(
        'proporcion',
        'Proporción Mortero (Cemento:Arena):',
        proporciones
    );
  }

  Widget _contentChoiceChips(String type, String description, List<String> typeList) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                description,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primaryMetraShop
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Wrap(
                  runAlignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: typeList.map((typeValue) {
                    bool isSelected = false;

                    switch(type) {
                      case 'espesor':
                        isSelected = selectedValueEspesor == typeValue;
                        break;
                      case 'proporcion':
                        isSelected = selectedValueProporcion == typeValue;
                        break;
                    }

                    return ChoiceChip(
                      label: Text(typeValue),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            switch (type) {
                              case 'espesor':
                                selectedValueEspesor = typeValue;
                                espesor = selectedValueEspesor!;
                                break;
                              case 'proporcion':
                                selectedValueProporcion = typeValue;
                                proporcionMortero = selectedValueProporcion!;
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
                if ((type == 'espesor' && showEspesorError && selectedValueEspesor == null) ||
                    (type == 'proporcion' && showProporcionError && selectedValueProporcion == null))
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Campo requerido',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Metrado',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.primaryMetraShop
            ),
          ),
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomNameTextField(
                      controller: descriptionAreaController,
                      label: 'Descripción',
                      hintText: 'Ingresa una descripción (Ej. Sala)',
                      validator: _validateProjectName,
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
                      validator: _validateProjectName,
                      labelText: 'Área (m²)',
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
                      hintText: 'Ingresa una descripción (Ej. Sala)',
                      validator: _validateProjectName,
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
                            controller: lengthTextController,
                            validator: _validateProjectName,
                            labelText: 'Largo (metros)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomMeasureTextField(
                            controller: heightTextController,
                            validator: _validateProjectName,
                            labelText: 'Ancho (metros)',
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
              validator: _validateProjectName,
              hintText: 'Ingresa una descripción (Ej. Cocina)',
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
              validator: _validateProjectName,
              labelText: 'Área (m²)',
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
              validator: _validateProjectName,
              hintText: 'Ingresa una descripción (Ej. Cocina)',
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
                    controller: field['lengthMeasure']!,
                    validator: _validateProjectName,
                    labelText: 'Largo (metros)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomMeasureTextField(
                    controller: field['heightMeasure']!,
                    validator: _validateProjectName,
                    labelText: 'Ancho (metros)',
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
        'lengthMeasure': TextEditingController(),
        'heightMeasure': TextEditingController(),
      });
    });
  }

  void _removeField(List<Map<String, TextEditingController>> fields, Map<String, TextEditingController> field) {
    setState(() {
      // Dispose controllers before removing
      field.values.forEach((controller) => controller.dispose());
      fields.remove(field);
    });
  }

  Widget _buildResultButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomElevatedButton(
        label: 'Calcular Contrapiso',
        onPressed: () {
          // Validar selecciones
          setState(() {
            showEspesorError = selectedValueEspesor == null;
            showProporcionError = selectedValueProporcion == null;
          });

          // Verificar todos los campos requeridos
          bool camposValidos = formKey.currentState?.validate() == true &&
              selectedValueEspesor != null &&
              selectedValueProporcion != null;

          if (camposValidos) {
            var datosPiso = ref.read(pisosResultProvider.notifier);

            // Limpiar lista anterior
            datosPiso.clearList();

            var espesorValor = espesor.replaceAll(" cm", "");
            var proporcionValor = proporcionMortero.replaceAll("1 : ", "");

            if (_currentIndex == 0) {
              // Tab de área
              datosPiso.createPisos(
                'contrapiso', // Tipo fijo
                descriptionAreaController.text,
                factorController.text,
                espesorValor,
                proporcionMortero: proporcionValor,
                area: areaTextController.text,
              );

              for (var field in areaFields) {
                datosPiso.createPisos(
                  'contrapiso',
                  field['description']!.text,
                  factorController.text,
                  espesorValor,
                  proporcionMortero: proporcionValor,
                  area: field['measure']!.text,
                );
              }
            } else {
              // Tab de medidas
              datosPiso.createPisos(
                'contrapiso',
                descriptionMedidasController.text,
                factorController.text,
                espesorValor,
                proporcionMortero: proporcionValor,
                largo: lengthTextController.text,
                ancho: heightTextController.text,
              );

              for (var field in measureFields) {
                datosPiso.createPisos(
                  'contrapiso',
                  field['descriptionMeasure']!.text,
                  factorController.text,
                  espesorValor,
                  proporcionMortero: proporcionValor,
                  largo: field['lengthMeasure']!.text,
                  ancho: field['heightMeasure']!.text,
                );
              }
            }

            final pisosCreados = ref.read(pisosResultProvider);
            print("CREADOS: Número de contrapisos: ${pisosCreados.length}");
            print(ref.watch(pisosResultProvider));

            // Navegar a resultados
            context.pushNamed('contrapiso-result');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, completa todos los campos obligatorios'),
                backgroundColor: AppColors.errorGeneralColor,
              ),
            );
          }
        },
      ),
    );
  }
}