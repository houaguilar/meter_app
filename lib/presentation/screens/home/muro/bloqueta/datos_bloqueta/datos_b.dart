import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/widgets/fields/custom_factor_text_field.dart';
import 'package:meter_app/presentation/widgets/fields/custom_measure_text_field.dart';

import '../../../../../../config/constants/constants.dart';
import '../../../../../../data/local/shared_preferences_helper.dart';
import '../../../../../../init_dependencies.dart';
import '../../../../../providers/providers.dart';
import '../../../../../widgets/fields/custom_name_text_field.dart';
import '../../../../../widgets/widgets.dart';
import '../../ladrillo/tutorial/tutorial_ladrillo_screen.dart';


class DatosBloquetaScreens extends ConsumerStatefulWidget {
  const DatosBloquetaScreens({super.key});
  static const String route = 'detail';

  @override
  ConsumerState<DatosBloquetaScreens> createState() => _DatosBloquetaScreenState();
}

class _DatosBloquetaScreenState extends ConsumerState<DatosBloquetaScreens> with TickerProviderStateMixin {
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

  final formKey = GlobalKey<FormState>();

  late String bloqueta;
  late String factor;

  String? selectedValueAsentado;
  String? selectedValueBloqueta;

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
    ref.watch(tipoBloquetaProvider);
    final tipoBloqueta = ref.watch(tipoBloquetaProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBarWidget(titleAppBar: 'Medición',),
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
            _buildResultButton(tipoBloqueta),
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
        CustomFactorTextField(
          controller: factorController,
          label: '(%) Desperdicio',
          validator: _validateProjectName,
          hintText: '',
        ),
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
  Widget _buildResultButton(String tipoBloqueta) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomElevatedButton(
        label: 'Resultado',
        onPressed: () {
          var datosBloqueta = ref.read(bloquetaResultProvider.notifier);

          bloqueta = tipoBloqueta;

          if (_currentIndex == 0) {
            datosBloqueta.createBloqueta(
              descriptionAreaController.text,
              bloqueta,
              factorController.text,
              area: areaTextController.text,
            );
            for (var field in areaFields) {
              datosBloqueta.createBloqueta(
                field['description']!.text,
                bloqueta ?? "Default",
                factorController.text,
                area: field['measure']!.text,
              );
            }
          } else {
            datosBloqueta.createBloqueta(
              descriptionMedidasController.text,
              bloqueta,
              factorController.text,
              largo: lengthTextController.text,
              altura: heightTextController.text,
            );
            for (var field in measureFields) {
              datosBloqueta.createBloqueta(
                field['descriptionMeasure']!.text,
                bloqueta ?? "Default",
                factorController.text,
                largo: field['lengthMeasure']!.text,
                altura: field['heightMeasure']!.text,
              );
            }
          }
          print('datosLadrillo:');
          print(datosBloqueta);
          print(ref.watch(bloquetaResultProvider));
          // Navegamos a la siguiente pantalla de resultados, donde se mostrarán los datos
          context.pushNamed('bloqueta_results');
        },
      ),
    );
  }
}
