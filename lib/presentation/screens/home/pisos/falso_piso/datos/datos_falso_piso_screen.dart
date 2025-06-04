import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/widgets/fields/custom_factor_text_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_measure_text_field.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../data/local/shared_preferences_helper.dart';
import '../../../../../../init_dependencies.dart';
import '../../../../../providers/pisos/falso_piso_providers.dart';
import '../../../../../widgets/fields/custom_name_text_field.dart';
import '../../../../../widgets/widgets.dart';
import '../../../muro/ladrillo/tutorial/tutorial_ladrillo_screen.dart';


class DatosFalsoPisoScreen extends ConsumerStatefulWidget {
  const DatosFalsoPisoScreen({super.key});
  static const String route = 'datos-falso-piso';

  @override
  ConsumerState<DatosFalsoPisoScreen> createState() => _DatosFalsoPisoScreenState();
}

class _DatosFalsoPisoScreenState extends ConsumerState<DatosFalsoPisoScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  late final SharedPreferencesHelper sharedPreferencesHelper;

  // TextControllers y formKey para campos base de proyecto
  final TextEditingController factorController = TextEditingController(text: '5');
  final TextEditingController descriptionAreaController = TextEditingController();
  final TextEditingController descriptionMedidasController = TextEditingController();
  final TextEditingController areaTextController = TextEditingController();
  final TextEditingController lengthTextController = TextEditingController();
  final TextEditingController heightTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool showEspesorError = false;
  bool showResistenciaError = false;

  String espesor = "";
  String resistencia = '';

  String? selectedValueEspesor;
  String? selectedValueResistencia;

  // Usamos listas de mapas para manejar dinámicamente los campos adicionales
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
    // Liberar controladores dinámicos
    for (var field in areaFields) {
      field['description']?.dispose();
      field['measure']?.dispose();
    }
    for (var field in measureFields) {
      field['descriptionMeasure']?.dispose();
      field['lengthMeasure']?.dispose();
      field['heightMeasure']?.dispose();
    }
    // Liberar controladores principales
    factorController.dispose();
    descriptionAreaController.dispose();
    descriptionMedidasController.dispose();
    areaTextController.dispose();
    lengthTextController.dispose();
    heightTextController.dispose();
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
      appBar: AppBarWidget(titleAppBar: 'Falso Piso',),
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
                            _buildProjectFields(),
                            _buildResistenciaSelection(),
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

  // Métodos auxiliares para construir la UI
  Widget _buildProjectFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15,),
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
            hintText: '',
          ),
        ),
        const SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildEspesorSelection() {
    final List<String> espesoresFalsoPiso = ["8 cm", "9 cm", "10 cm", "11 cm", "12 cm"];

    return contentChoiceChips(
        'espesor',
        'Espesor:',
        espesoresFalsoPiso
    );
  }

  Widget _buildResistenciaSelection() {
    final List<String> resistencias = ["140 kg/cm²", "175 kg/cm²", "210 kg/cm²"];
    return contentChoiceChips(
        'resistencia',
        'Resistencia:',
        resistencias
    );
  }

  Widget contentChoiceChips(String type, String description, List<String> typeList) {
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
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryMetraShop),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
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
                        case 'resistencia':
                          isSelected = selectedValueResistencia == typeValue;
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
                                case 'resistencia':
                                  selectedValueResistencia = typeValue;
                                  resistencia = selectedValueResistencia!;
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
                      (type == 'resistencia' && showResistenciaError && selectedValueResistencia == null))
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Campo requerido',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                ],
              ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Text('Metrado', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryMetraShop),),
        ),
        const SizedBox(height: 10,),
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
            const SizedBox(height: 12,),
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
                      hintText: 'Ingresa una descripción (Ej. Falso piso sala)',
                      validator: _validateProjectName,
                    ),
                    const SizedBox(height: 8,),
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
            const SizedBox(height: 12,),
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
                      hintText: 'Ingresa una descripción (Ej. Falso piso sala)',
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
                            labelText: 'Largo(metros)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: CustomMeasureTextField(
                            controller: heightTextController,
                            validator: _validateProjectName,
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
              validator: _validateProjectName,
              hintText: 'Ingresa una descripción (Ej. Falso piso ...)',
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
              validator: _validateProjectName,
              hintText: 'Ingresa una descripción (Ej. Falso piso ...)',
              onPressed: onRemove,
              icon: Icons.close,
              color: AppColors.errorGeneralColor,
              isVisible: true,
            ),
            const SizedBox(height: 10,),
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
                    labelText: 'Largo(metros)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: CustomMeasureTextField(
                    controller: field['heightMeasure']!,
                    validator: _validateProjectName,
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
        'lengthMeasure': TextEditingController(),
        'heightMeasure': TextEditingController(),
      });
    });
  }

  void _removeField(List<Map<String, TextEditingController>> fields, Map<String, TextEditingController> field) {
    setState(() {
      // Liberar memoria de los controladores antes de eliminar
      field['description']?.dispose();
      field['measure']?.dispose();
      field['descriptionMeasure']?.dispose();
      field['lengthMeasure']?.dispose();
      field['heightMeasure']?.dispose();

      fields.remove(field);
    });
  }

  Widget _buildResultButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomElevatedButton(
        label: 'Resultado',
        onPressed: () {
          // Validar selecciones
          setState(() {
            showEspesorError = selectedValueEspesor == null;
            showResistenciaError = selectedValueResistencia == null;
          });

          // Verificar todos los campos requeridos
          bool camposValidos = formKey.currentState?.validate() == true &&
              selectedValueEspesor != null &&
              selectedValueResistencia != null;

          if (camposValidos) {
            var datosFalsoPiso = ref.read(falsoPisoResultProvider.notifier);
            var espesorValor = espesor.replaceAll(" cm", "");

            if (_currentIndex == 0) {
              // Tab de Área
              datosFalsoPiso.createFalsoPiso(
                descriptionAreaController.text,
                factorController.text,
                espesorValor,
                resistencia: resistencia,
                area: areaTextController.text,
              );

              // Agregar campos dinámicos de área
              for (var field in areaFields) {
                datosFalsoPiso.createFalsoPiso(
                  field['description']!.text,
                  factorController.text,
                  espesorValor,
                  resistencia: resistencia,
                  area: field['measure']!.text,
                );
              }
            } else {
              // Tab de Medidas
              datosFalsoPiso.createFalsoPiso(
                descriptionMedidasController.text,
                factorController.text,
                espesorValor,
                resistencia: resistencia,
                largo: lengthTextController.text,
                ancho: heightTextController.text,
              );

              // Agregar campos dinámicos de medidas
              for (var field in measureFields) {
                datosFalsoPiso.createFalsoPiso(
                  field['descriptionMeasure']!.text,
                  factorController.text,
                  espesorValor,
                  resistencia: resistencia,
                  largo: field['lengthMeasure']!.text,
                  ancho: field['heightMeasure']!.text,
                );
              }
            }

            final falsosPisosCreados = ref.read(falsoPisoResultProvider);
            print("CREADOS: Número de falsos pisos antes de navegar: ${falsosPisosCreados.length}");
            print("Datos: ${ref.watch(falsoPisoResultProvider)}");

            // Navegar a resultados
            context.pushNamed('falso-pisos-results');
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