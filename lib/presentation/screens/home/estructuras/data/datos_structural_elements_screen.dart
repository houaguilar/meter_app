import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/widgets/fields/custom_factor_text_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_measure_text_field.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../data/local/shared_preferences_helper.dart';
import '../../../../../init_dependencies.dart';
import '../../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../../providers/home/estructuras/structural_providers.dart';
import '../../../../widgets/fields/custom_name_text_field.dart';
import '../../../../widgets/widgets.dart';
import '../../muro/ladrillo/tutorial/tutorial_ladrillo_screen.dart';

class DatosStructuralElementsScreen extends ConsumerStatefulWidget {
  const DatosStructuralElementsScreen({super.key});
  static const String route = 'detail';

  @override
  ConsumerState<DatosStructuralElementsScreen> createState() => _DatosStructuralElementsScreenState();
}

class _DatosStructuralElementsScreenState extends ConsumerState<DatosStructuralElementsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  late final SharedPreferencesHelper sharedPreferencesHelper;

  // TextControllers y formKey para campos base de proyecto
  final TextEditingController factorController = TextEditingController(text: '5');
  final TextEditingController descriptionAreaController = TextEditingController();
  final TextEditingController descriptionMedidasController = TextEditingController();
  final TextEditingController volumenTextController = TextEditingController();
  final TextEditingController lengthTextController = TextEditingController();
  final TextEditingController widthTextController = TextEditingController();
  final TextEditingController heightTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool showResistenciaError = false;

  String tipoElemento = '';
  String resistencia = '';
  late String factor;

  String? selectedValueResistencia;

  // Usamos listas de mapas para manejar dinámicamente los campos adicionales
  List<Map<String, TextEditingController>> volumenFields = [];
  List<Map<String, TextEditingController>> dimensionesFields = [];

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
    tipoElemento = ref.watch(tipoStructuralElementProvider);
    String appBarTitle = tipoElemento == 'columna' ? 'Columna' : 'Viga';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBarWidget(titleAppBar: appBarTitle, isVisibleTutorial: true, showTutorial: showTutorial),
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
                            _buildResistenciaSelection(),
                            _buildFactorDesperdicio(),
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

  Widget _buildFactorDesperdicio() {
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
            validator: _validateStringRequired,
            hintText: '',
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildResistenciaSelection() {
    final List<String> opcionesResistencia = ["175 kg/cm²", "210 kg/cm²", "245 kg/cm²", "280 kg/cm²"];
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
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Resistencia del concreto:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryMetraShop),
              ),
            ),
            const SizedBox(height: 10),
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
                    children: opcionesResistencia.map((opcion) {
                      bool isSelected = selectedValueResistencia == opcion;
                      return ChoiceChip(
                        label: Text(opcion),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedValueResistencia = opcion;
                              resistencia = selectedValueResistencia!;
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
                  if (showResistenciaError && selectedValueResistencia == null)
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Metrado', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryMetraShop)),
        ),
        const SizedBox(height: 10),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryMetraShop,
          unselectedLabelColor: AppColors.primaryMetraShop.withOpacity(0.5),
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          indicatorColor: AppColors.indicatorTabBarColor,
          tabs: const [
            Tab(text: 'Volumen'),
            Tab(text: 'Dimensiones'),
          ],
        ),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildVolumenTab(),
              _buildDimensionesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVolumenTab() {
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomNameTextField(
                      controller: descriptionAreaController,
                      label: 'Descripción',
                      hintText: 'Ingresa una descripción (Ej. Columna 1)',
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
                      controller: volumenTextController,
                      validator: _validateStringRequired,
                      labelText: 'Volumen (m³)',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                ...volumenFields.map((field) => _buildDynamicVolumenField(
                    field,
                        () => _removeField(volumenFields, field)
                )),
                Container(
                  alignment: Alignment.topLeft,
                  child: CustomTextBlueButton(
                    onPressed: () => _addVolumenField(volumenFields),
                    label: 'Agregar nuevo elemento',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionesTab() {
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
                      hintText: 'Ingresa una descripción (Ej. Columna 1)',
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
                            labelText: 'Largo (m)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomMeasureTextField(
                            controller: widthTextController,
                            validator: _validateStringRequired,
                            labelText: 'Ancho (m)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    CustomMeasureTextField(
                      controller: heightTextController,
                      validator: _validateStringRequired,
                      labelText: 'Altura (m)',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                ...dimensionesFields.map((field) => _buildDynamicDimensionesField(
                    field,
                        () => _removeField(dimensionesFields, field)
                )),
                Container(
                  alignment: Alignment.centerLeft,
                  child: CustomTextBlueButton(
                    onPressed: () => _addDimensionesField(dimensionesFields),
                    label: 'Agregar nuevo elemento',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicVolumenField(Map<String, TextEditingController> field, VoidCallback onRemove) {
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
              hintText: 'Ingresa una descripción (Ej. Columna ...)',
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
              controller: field['volumen']!,
              validator: _validateStringRequired,
              labelText: 'Volumen (m³)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicDimensionesField(Map<String, TextEditingController> field, VoidCallback onRemove) {
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
              hintText: 'Ingresa una descripción (Ej. Columna ...)',
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
                    controller: field['largo']!,
                    validator: _validateStringRequired,
                    labelText: 'Largo (m)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomMeasureTextField(
                    controller: field['ancho']!,
                    validator: _validateStringRequired,
                    labelText: 'Ancho (m)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            CustomMeasureTextField(
              controller: field['altura']!,
              validator: _validateStringRequired,
              labelText: 'Altura (m)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  void _addVolumenField(List<Map<String, TextEditingController>> fields) {
    setState(() {
      fields.add({
        'description': TextEditingController(),
        'volumen': TextEditingController(),
      });
    });
  }

  void _addDimensionesField(List<Map<String, TextEditingController>> fields) {
    setState(() {
      fields.add({
        'description': TextEditingController(),
        'largo': TextEditingController(),
        'ancho': TextEditingController(),
        'altura': TextEditingController(),
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
            showResistenciaError = selectedValueResistencia == null; // Muestra error si resistencia no está seleccionada
          });

          if (formKey.currentState?.validate() == true && selectedValueResistencia != null) {
            if (tipoElemento == 'columna') {
              var datosColumna = ref.read(columnaResultProvider.notifier);

              if (_currentIndex == 0) {
                datosColumna.createColumna(
                  descriptionAreaController.text,
                  resistencia,
                  factorController.text,
                  volumen: volumenTextController.text,
                );

                for (var field in volumenFields) {
                  datosColumna.createColumna(
                    field['description']!.text,
                    resistencia,
                    factorController.text,
                    volumen: field['volumen']!.text,
                  );
                }
              } else {
                datosColumna.createColumna(
                  descriptionMedidasController.text,
                  resistencia,
                  factorController.text,
                  largo: lengthTextController.text,
                  ancho: widthTextController.text,
                  altura: heightTextController.text,
                );

                for (var field in dimensionesFields) {
                  datosColumna.createColumna(
                    field['description']!.text,
                    resistencia,
                    factorController.text,
                    largo: field['largo']!.text,
                    ancho: field['ancho']!.text,
                    altura: field['altura']!.text,
                  );
                }
              }
              final pisosCreados = ref.read(columnaResultProvider);
              print("CREADOS: Número de columna antes de navegar: ${pisosCreados.length}");
              print('Columnas creadas:');
              print(ref.watch(columnaResultProvider));
            } else {
              var datosViga = ref.read(vigaResultProvider.notifier);

              if (_currentIndex == 0) {
                datosViga.createViga(
                  descriptionAreaController.text,
                  resistencia,
                  factorController.text,
                  volumen: volumenTextController.text,
                );

                for (var field in volumenFields) {
                  datosViga.createViga(
                    field['description']!.text,
                    resistencia,
                    factorController.text,
                    volumen: field['volumen']!.text,
                  );
                }
              } else {
                datosViga.createViga(
                  descriptionMedidasController.text,
                  resistencia,
                  factorController.text,
                  largo: lengthTextController.text,
                  ancho: widthTextController.text,
                  altura: heightTextController.text,
                );

                for (var field in dimensionesFields) {
                  datosViga.createViga(
                    field['description']!.text,
                    resistencia,
                    factorController.text,
                    largo: field['largo']!.text,
                    ancho: field['ancho']!.text,
                    altura: field['altura']!.text,
                  );
                }
              }
              final pisosCreados = ref.read(vigaResultProvider);
              print("CREADOS: Número de vigas antes de navegar: ${pisosCreados.length}");
              print('Vigas creadas:');
              print(ref.watch(vigaResultProvider));
            }
            final pisosCreados = ref.read(structuralElementsProvider);
            print("CREADOS: Número de estructuralElements antes de navegar: ${pisosCreados.length}");
            print(ref.watch(structuralElementsProvider));
            // Navegar a la pantalla de resultados
            context.pushNamed('structural-element-results');
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