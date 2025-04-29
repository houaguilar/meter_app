import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/providers/tarrajeo/tarrajeo_providers.dart';
import 'package:meter_app/presentation/widgets/fields/custom_dosage_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_factor_text_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_measure_text_field.dart';

import '../../../../../../config/constants/constants.dart';
import '../../../../../../data/local/shared_preferences_helper.dart';
import '../../../../../../init_dependencies.dart';
import '../../../../widgets/fields/custom_name_text_field.dart';
import '../../../../widgets/widgets.dart';
import '../../muro/ladrillo/tutorial/tutorial_ladrillo_screen.dart';


class DatosTarrajeoScreen extends ConsumerStatefulWidget {
  const DatosTarrajeoScreen({super.key});
  static const String route = 'detail';

  @override
  ConsumerState<DatosTarrajeoScreen> createState() => _DatosTarrajeoScreenState();
}

class _DatosTarrajeoScreenState extends ConsumerState<DatosTarrajeoScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  late final SharedPreferencesHelper sharedPreferencesHelper;

  // TextControllers y formKey para campos base de proyecto
  final TextEditingController factorController = TextEditingController();
  final TextEditingController descriptionAreaController = TextEditingController();
  final TextEditingController descriptionMedidasController = TextEditingController();
  final TextEditingController areaTextController = TextEditingController();
  final TextEditingController lengthTextController = TextEditingController();
  final TextEditingController heightTextController = TextEditingController();
  final TextEditingController cementoProporcionController = TextEditingController();
  final TextEditingController arenaProporcionController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool showAsentadoError = false;

  late String ladrillo;
  String espesor = "";
  late String factor;
  String dosage = '';

  String? selectedValueTarrajeo;
  String? selectedValueEspesor;
  String? selectedValueDosage;

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
    //   _tabController.dispose();
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
    ref.watch(tipoTarrajeoProvider);
    final tipoLadrillo = ref.watch(tipoTarrajeoProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBarWidget(titleAppBar: 'Medición', isVisibleTutorial: true, showTutorial: showTutorial,),
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
                            _buildTypeSelection(tipoLadrillo),
                            _buildProjectFields(),
                            _buildTypeDosageSelection(tipoLadrillo),
                          ],
                        ),
                      ),
                      _buildTabs(context),
                    ],
                  ),
                ),
              ),
            ),
            _buildResultButton(tipoLadrillo),
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
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
        SizedBox(height: 15,),

        /*     CustomNameTextField(
          controller: projectNameController,
          label: 'Nombre del proyecto',
          hintText: 'Ingresa un nombre (Ej. Cocina)',
          validator: _validateProjectName,
          isVisible: true,
          onPressed: () {showTutorial();},
          icon: Icons.help_rounded,
          color: AppColors.blueMetraShop,
        ),
        CustomNameTextField(
          controller: descriptionController,
          label: 'Descripción',
          hintText: 'Ingresa una descripción (Ej. Muro 1)',
          validator: _validateProjectName,
        ),*/
      ],
    );
  }

  Widget _buildTypeSelection(String tipoLadrillo) {
    final List<String> asentadosKingkong = ["1 cm", "1.5 cm", "2 cm"];
    final List<String> asentadosPandereta = ["1 cm", "1.5 cm", "2 cm"];
    return contentChoiceChips(
        'asentado',
        'Tipo de asentado',
        tipoLadrillo == 'Kingkong' ? asentadosKingkong : asentadosPandereta
    );
  }

  Widget contentChoiceChips(String type, String description, List<String> typeList) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    runAlignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: typeList.map((typeValue) {
                      bool isSelected = type == 'ladrillo'
                          ? selectedValueTarrajeo == typeValue
                          : selectedValueEspesor == typeValue;
                      return ChoiceChip(
                        label: Text(typeValue),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              switch (type) {
                                case 'ladrillo':
                                  selectedValueTarrajeo = typeValue;
                                  ladrillo = selectedValueTarrajeo!;
                                  selectedValueEspesor = null; // Reinicia el asentado
                                  break;
                                case 'asentado':
                                  selectedValueEspesor = typeValue;
                                  espesor = selectedValueEspesor!;
                                  break;
                              }
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // Define el radio de borde
                          side: BorderSide(
                            color: isSelected ? AppColors.blueMetraShop : AppColors.blueMetraShop.withOpacity(0.5), // Color del borde
                            width: 1.0, // Grosor del borde
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
                  if (type == 'asentado' && selectedValueEspesor == null)
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

  Widget _buildTypeDosageSelection(String tipoLadrillo) {
    final List<String> asentadosKingkong = ["1 : 4", "1 : 5"];
    return contentDosageChoiceChips(
        'asentado',
        'Dosificación:',
        asentadosKingkong
    );
  }

  Widget contentDosageChoiceChips(String type, String description, List<String> typeList) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    runAlignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: typeList.map((typeValue) {
                      bool isSelected = selectedValueDosage == typeValue;
                      return ChoiceChip(
                        label: Text(typeValue),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedValueDosage = typeValue;
                              dosage = selectedValueDosage!;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // Define el radio de borde
                          side: BorderSide(
                            color: isSelected ? AppColors.blueMetraShop : AppColors.blueMetraShop.withOpacity(0.5), // Color del borde
                            width: 1.0, // Grosor del borde
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
                  if (showAsentadoError && type == 'asentado' && selectedValueDosage == null)
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
          height: 600, // Puedes ajustar esta altura según sea necesario
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
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomNameTextField(
                      controller: descriptionAreaController,
                      label: 'Descripción',
                      hintText: 'Ingresa una descripción (Ej. Muro 1)',
                      validator: _validateProjectName,
                    ),
                    const SizedBox(height: 8,),
                    const Text(
                      'Datos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMetraShop, // Ajustar según el diseño
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
                      hintText: 'Ingresa una descripción (Ej. Muro 1)',
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
                            labelText: 'Altura(metros)',
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

  // Este método construye el campo dinámico con un botón de eliminar
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
              hintText: 'Ingresa una descripción (Ej. Muro ...)',
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

  // Similar para las medidas
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
              hintText: 'Ingresa una descripción (Ej. Muro ...)',
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
                    labelText: 'Altura(metros)',
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
      fields.remove(field);
    });
  }

  // Función para procesar el resultado y almacenar datos en LadrilloResultProvider
  Widget _buildResultButton(String tipoLadrillo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomElevatedButton(
        label: 'Resultado',
        onPressed: () {
          setState(() {
            showAsentadoError = selectedValueEspesor == null; // Muestra error si `asentado` no está seleccionado
          });

          if (formKey.currentState?.validate() == true && selectedValueEspesor != null) {
            var datosTarrajeo = ref.read(tarrajeoResultProvider.notifier);
            var espesorValor = espesor.replaceAll(" cm", "");

            ladrillo = tipoLadrillo;
            var dosageSelection = dosage.replaceAll("1 : ", "");

            if (_currentIndex == 0) {
              datosTarrajeo.createTarrajeo(
                ladrillo,
                descriptionAreaController.text,
                factorController.text,
                dosageSelection,
                dosageSelection,
                espesorValor,
                area: areaTextController.text,
              );
              for (var field in areaFields) {
                datosTarrajeo.createTarrajeo(
                  ladrillo ?? "Default",
                  field['description']!.text,
                  factorController.text,
                  dosageSelection,
                  dosageSelection,
                  espesorValor,
                  area: field['measure']!.text,
                );
              }
            } else {
              datosTarrajeo.createTarrajeo(
                ladrillo,
                descriptionMedidasController.text,
                factorController.text,
                dosageSelection,
                dosageSelection,
                espesorValor,
                longitud: lengthTextController.text,
                ancho: heightTextController.text,
              );
              for (var field in measureFields) {
                datosTarrajeo.createTarrajeo(
                  ladrillo ?? "Default",
                  field['descriptionMeasure']!.text,
                  factorController.text,
                  dosageSelection,
                  dosageSelection,
                  espesorValor,
                  longitud: field['lengthMeasure']!.text,
                  ancho: field['heightMeasure']!.text,
                );
              }
            }
            print('datosLadrillo:');
            print(datosTarrajeo);
            print(ref.watch(tarrajeoResultProvider));

            // Navegamos a la siguiente pantalla de resultados, donde se mostrarán los datos
            context.pushNamed('tarrajeo_results');
          }
        },
      ),
    );
  }
}
