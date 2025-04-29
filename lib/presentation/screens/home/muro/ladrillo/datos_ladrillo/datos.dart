import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/widgets/fields/custom_dosage_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_factor_text_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_measure_text_field.dart';

import '../../../../../../config/constants/constants.dart';
import '../../../../../../data/local/shared_preferences_helper.dart';
import '../../../../../../init_dependencies.dart';
import '../../../../../providers/providers.dart';
import '../../../../../widgets/fields/custom_name_text_field.dart';
import '../../../../../widgets/widgets.dart';
import '../tutorial/tutorial_ladrillo_screen.dart';


class DatosLadrilloScreens extends ConsumerStatefulWidget {
  const DatosLadrilloScreens({super.key});
  static const String route = 'detail';

  @override
  ConsumerState<DatosLadrilloScreens> createState() => _DatosLadrilloScreenState();
}

class _DatosLadrilloScreenState extends ConsumerState<DatosLadrilloScreens> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  late final SharedPreferencesHelper sharedPreferencesHelper;

  final TextEditingController factorController = TextEditingController(text: '5');
  final TextEditingController descriptionAreaController = TextEditingController();
  final TextEditingController descriptionMedidasController = TextEditingController();
  final TextEditingController areaTextController = TextEditingController();
  final TextEditingController lengthTextController = TextEditingController();
  final TextEditingController heightTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool showAsentadoError = false;

  late String ladrillo;
  String asentado = "";
  late String factor;
  String proporcionMortero = '';

  String? selectedValueLadrillo;
  String? selectedValueAsentado;
  String? selectedValueMortero;

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
    ref.watch(tipoLadrilloProvider);
    final tipoLadrillo = ref.watch(tipoLadrilloProvider);
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
            validator: _validateStringRequired,
            hintText: '',
          ),
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildTypeSelection(String tipoLadrillo) {
    final List<String> asentadosKingkong = ["soga", "canto", "cabeza"];
    final List<String> asentadosPandereta = ["soga", "canto", "cabeza"];
    return contentChoiceChips(
        'asentado',
        'Tipo de asentado:',
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
                          ? selectedValueLadrillo == typeValue
                          : selectedValueAsentado == typeValue;
                      return ChoiceChip(
                        label: Text(typeValue),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              switch (type) {
                                case 'ladrillo':
                                  selectedValueLadrillo = typeValue;
                                  ladrillo = selectedValueLadrillo!;
                                  selectedValueAsentado = null;
                                  break;
                                case 'asentado':
                                  selectedValueAsentado = typeValue;
                                  asentado = selectedValueAsentado!;
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
                  if (showAsentadoError && type == 'asentado' && selectedValueAsentado == null)
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
    final List<String> asentadosKingkong = ["1 : 3", "1 : 4", "1 : 5", "1 : 6"];
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
                      bool isSelected = selectedValueMortero == typeValue;
                      return ChoiceChip(
                        label: Text(typeValue),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedValueMortero = typeValue;
                              proporcionMortero = selectedValueMortero!;
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
                  if (showAsentadoError && type == 'asentado' && selectedValueMortero == null)
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
                      validator: _validateStringRequired,
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
                            controller: lengthTextController,
                            validator: _validateStringRequired,
                            labelText: 'Largo(metros)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: CustomMeasureTextField(
                            controller: heightTextController,
                            validator: _validateStringRequired,
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
                    validator: _validateStringRequired,
                    labelText: 'Largo(metros)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: CustomMeasureTextField(
                    controller: field['heightMeasure']!,
                    validator: _validateStringRequired,
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

  Widget _buildResultButton(String tipoLadrillo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomElevatedButton(
        label: 'Resultado',
        onPressed: () {
          setState(() {
            showAsentadoError = selectedValueAsentado == null; // Muestra error si `asentado` no está seleccionado
          });

          if (formKey.currentState?.validate() == true && selectedValueAsentado != null) {
            var datosLadrillo = ref.read(ladrilloResultProvider.notifier);

            ladrillo = tipoLadrillo;

            var dosageSelection = proporcionMortero.replaceAll("1 : ", "");

            if (_currentIndex == 0) {
              datosLadrillo.createLadrillo(
                descriptionAreaController.text,
                ladrillo,
                factorController.text,
                dosageSelection,
                asentado,
                area: areaTextController.text,
              );
              for (var field in areaFields) {
                datosLadrillo.createLadrillo(
                  field['description']!.text,
                  ladrillo ?? "Default",
                  factorController.text,
                  dosageSelection,
                  asentado ?? "Soga",
                  area: field['measure']!.text,
                );
              }
            } else {
              datosLadrillo.createLadrillo(
                descriptionMedidasController.text,
                ladrillo,
                factorController.text,
                dosageSelection,
                asentado,
                largo: lengthTextController.text,
                altura: heightTextController.text,
              );
              for (var field in measureFields) {
                datosLadrillo.createLadrillo(
                  field['descriptionMeasure']!.text,
                  ladrillo ?? "Default",
                  factorController.text,
                  dosageSelection,
                  asentado ?? "Soga",
                  largo: field['lengthMeasure']!.text,
                  altura: field['heightMeasure']!.text,
                );
              }
            }
            final ladrillosCreados = ref.read(ladrilloResultProvider);
            print("CREADOS: Número de ladrillos antes de navegar: ${ladrillosCreados.length}");
            print(ref.watch(ladrilloResultProvider));

            context.pushNamed('ladrillo_results');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, completa todos los campos obligatorios')),
            );
          }
          print(proporcionMortero);
        },
      ),
    );
  }
}
