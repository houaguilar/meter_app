
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../config/constants/constants.dart';
import '../../../../../providers/providers.dart';
import '../../../../widgets/shared/custom_add_three_fields.dart';
import '../../../../widgets/widgets.dart';

class DatosLadrilloScreen extends ConsumerStatefulWidget {
  const DatosLadrilloScreen({super.key});
  static const String route = 'detail';

  @override
  ConsumerState<DatosLadrilloScreen> createState() => _DatosLadrilloScreenState();
}

class _DatosLadrilloScreenState extends ConsumerState<DatosLadrilloScreen> {

  List<String> ladrillos = ["Kingkong", "Pandereta"];
  List<String> asentadosKingkong = ["soga","cabeza","canto"];
  List<String> asentadosPandereta = ["soga","canto"];

  final formKey = GlobalKey<FormState>();

  late String description;
  late String ladrillo;
  String asentado = "";

  String? selectedValueLadrillo;
  String? selectedValueAsentado;

  // GlobalKey
  final GlobalKey<FormState> _formKeyDescriptionMuro1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaMuro1 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaMuro2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaMuro3 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaMuro4 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaMuro5 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaMuro6 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaMuro7 = GlobalKey<FormState>();

  //textEditingControllers
  final TextEditingController _descriptionMuro1Controller =  TextEditingController();
  final TextEditingController _largoMuro1Controller =  TextEditingController();
  final TextEditingController _alturaMuro1Controller =  TextEditingController();

  final TextEditingController _descriptionMuro2Controller =  TextEditingController();
  final TextEditingController _largoMuro2Controller =  TextEditingController();
  final TextEditingController _alturaMuro2Controller =  TextEditingController();

  final TextEditingController _descriptionMuro3Controller =  TextEditingController();
  final TextEditingController _largoMuro3Controller =  TextEditingController();
  final TextEditingController _alturaMuro3Controller =  TextEditingController();

  final TextEditingController _descriptionMuro4Controller =  TextEditingController();
  final TextEditingController _largoMuro4Controller =  TextEditingController();
  final TextEditingController _alturaMuro4Controller =  TextEditingController();

  final TextEditingController _descriptionMuro5Controller =  TextEditingController();
  final TextEditingController _largoMuro5Controller =  TextEditingController();
  final TextEditingController _alturaMuro5Controller =  TextEditingController();

  final TextEditingController _descriptionMuro6Controller =  TextEditingController();
  final TextEditingController _largoMuro6Controller =  TextEditingController();
  final TextEditingController _alturaMuro6Controller =  TextEditingController();

  final TextEditingController _descriptionMuro7Controller =  TextEditingController();
  final TextEditingController _largoMuro7Controller =  TextEditingController();
  final TextEditingController _alturaMuro7Controller =  TextEditingController();

  @override
  Widget build(BuildContext context) {

    ref.watch(ladrilloResultProvider);
    final tipoLadrillo = ref.watch(tipoLadrilloProvider);
    final addMuro1 = ref.watch(addMuroLadrillo1Provider);
    final addMuro2 = ref.watch(addMuroLadrillo2Provider);
    final addMuro3 = ref.watch(addMuroLadrillo3Provider);
    final addMuro4 = ref.watch(addMuroLadrillo4Provider);
    final addMuro5 = ref.watch(addMuroLadrillo5Provider);
    final addMuro6 = ref.watch(addMuroLadrillo6Provider);
    final addMuro7 = ref.watch(addMuroLadrillo7Provider);

    return Scaffold(
      appBar: const AppBarWidget(titleAppBar: 'Datos',),
     // resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40,),
                    SizedBox(
                      child: Container(
                        padding: const EdgeInsets.only(right: 15, left: 15, bottom: 10),
                        child: const Text('Complete los siguientes campos: ',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Container(
                          child: contentDropdownButton('asentado', 'Tipo de asentado', tipoLadrillo == 'Kingkong' ? asentadosKingkong : asentadosPandereta)
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.all(10),
                        child: const Text("Muro 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
                    ),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyDescriptionMuro1, description: 'Descripción' ,controller: _descriptionMuro1Controller, hintText: 'ej. Muro de la cocina', isKeyboardText: true,),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyLargoMuro1, description: 'Largo' ,controller: _largoMuro1Controller, hintText: 'metros',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAlturaMuro1, description: 'Altura' ,controller: _alturaMuro1Controller, hintText: 'metros',),),
                    Visibility(
                      visible: addMuro1,
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.center,
                            child: SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(addMuroLadrillo1Provider.notifier).toggleAddMuro();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Añadir muro"),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)
                                      )
                                  ),
                                )
                            ),
                          ),
                          const SizedBox(height: 150,)
                        ],
                      ),
                    ),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro2, formKey2: _formKeyLargoMuro2, formKey3: _formKeyAlturaMuro2, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Altura', visibility: addMuro1, titleMaterial: 'Muro 2', firstTextController: _descriptionMuro2Controller, secondTextController: _largoMuro2Controller, thirdTextController: _alturaMuro2Controller, firstHintText: 'ej. Muro de cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro2, pressed: () => ref.read(addMuroLadrillo2Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Muro', pressedCancel: () { ref.read(addMuroLadrillo1Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro3, formKey2: _formKeyLargoMuro3, formKey3: _formKeyAlturaMuro3, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Altura', visibility: addMuro2, titleMaterial: 'Muro 3', firstTextController: _descriptionMuro3Controller, secondTextController: _largoMuro3Controller, thirdTextController: _alturaMuro3Controller, firstHintText: 'ej. Muro de cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro3, pressed: () => ref.read(addMuroLadrillo3Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Muro', pressedCancel: () { ref.read(addMuroLadrillo2Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro4, formKey2: _formKeyLargoMuro4, formKey3: _formKeyAlturaMuro4, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Altura', visibility: addMuro3, titleMaterial: 'Muro 4', firstTextController: _descriptionMuro4Controller, secondTextController: _largoMuro4Controller, thirdTextController: _alturaMuro4Controller, firstHintText: 'ej. Muro de cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro4, pressed: () => ref.read(addMuroLadrillo4Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Muro', pressedCancel: () { ref.read(addMuroLadrillo3Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro5, formKey2: _formKeyLargoMuro5, formKey3: _formKeyAlturaMuro5, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Altura', visibility: addMuro4, titleMaterial: 'Muro 5', firstTextController: _descriptionMuro5Controller, secondTextController: _largoMuro5Controller, thirdTextController: _alturaMuro5Controller, firstHintText: 'ej. Muro de cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro5, pressed: () => ref.read(addMuroLadrillo5Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Muro', pressedCancel: () { ref.read(addMuroLadrillo4Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro6, formKey2: _formKeyLargoMuro6, formKey3: _formKeyAlturaMuro6, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Altura', visibility: addMuro5, titleMaterial: 'Muro 6', firstTextController: _descriptionMuro6Controller, secondTextController: _largoMuro6Controller, thirdTextController: _alturaMuro6Controller, firstHintText: 'ej. Muro de cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro6, pressed: () => ref.read(addMuroLadrillo6Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Muro', pressedCancel: () { ref.read(addMuroLadrillo5Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro7, formKey2: _formKeyLargoMuro7, formKey3: _formKeyAlturaMuro7, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Altura', visibility: addMuro6, titleMaterial: 'Muro 7', firstTextController: _descriptionMuro7Controller, secondTextController: _largoMuro7Controller, thirdTextController: _alturaMuro7Controller, firstHintText: 'ej. Muro de cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro7, pressed: () => ref.read(addMuroLadrillo7Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Muro', pressedCancel: () { ref.read(addMuroLadrillo6Provider.notifier).toggleAddMuro();},),
                    const SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                final FormState formDescription1 = _formKeyDescriptionMuro1.currentState!;
                final FormState formLargo1 = _formKeyLargoMuro1.currentState!;
                final FormState formAltura1 = _formKeyAlturaMuro1.currentState!;
                final FormState formButton = formKey.currentState!;

                var datosLadrillo = ref.read(ladrilloResultProvider.notifier);
                ladrillo = tipoLadrillo;

                if (formButton.validate()) {
                  if (formDescription1.validate() && formLargo1.validate() &&
                      formAltura1.validate()) {
                    datosLadrillo.createLadrillo(
                        _descriptionMuro1Controller.text, ladrillo, asentado,
                        _largoMuro1Controller.text,
                        _alturaMuro1Controller.text);
                    if (addMuro1) {
                      context.pushNamed('ladrillo_results');
                    } else {
                      ref.read(ladrilloResultProvider.notifier).clearList();
                      final FormState formDescription2 = _formKeyDescriptionMuro2
                          .currentState!;
                      final FormState formLargo2 = _formKeyLargoMuro2
                          .currentState!;
                      final FormState formAltura2 = _formKeyAlturaMuro2
                          .currentState!;

                      if (formDescription2.validate() &&
                          formLargo2.validate() && formAltura2.validate()) {
                        datosLadrillo.createLadrillo(
                            _descriptionMuro1Controller.text, ladrillo,
                            asentado, _largoMuro1Controller.text,
                            _alturaMuro1Controller.text);
                        datosLadrillo.createLadrillo(
                            _descriptionMuro2Controller.text, ladrillo,
                            asentado, _largoMuro2Controller.text,
                            _alturaMuro2Controller.text);
                        if (addMuro2) {
                          context.pushNamed('ladrillo_results');
                        } else {
                          ref.read(ladrilloResultProvider.notifier).clearList();
                          final FormState formDescription3 = _formKeyDescriptionMuro3
                              .currentState!;
                          final FormState formLargo3 = _formKeyLargoMuro3
                              .currentState!;
                          final FormState formAltura3 = _formKeyAlturaMuro3
                              .currentState!;

                          if (formDescription3.validate() &&
                              formLargo3.validate() && formAltura3.validate()) {
                            datosLadrillo.createLadrillo(
                                _descriptionMuro1Controller.text, ladrillo,
                                asentado, _largoMuro1Controller.text,
                                _alturaMuro1Controller.text);
                            datosLadrillo.createLadrillo(
                                _descriptionMuro2Controller.text, ladrillo,
                                asentado, _largoMuro2Controller.text,
                                _alturaMuro2Controller.text);
                            datosLadrillo.createLadrillo(
                                _descriptionMuro3Controller.text, ladrillo,
                                asentado, _largoMuro3Controller.text,
                                _alturaMuro3Controller.text);
                            if (addMuro3) {
                              context.pushNamed('ladrillo_results');
                            } else {
                              ref.read(ladrilloResultProvider.notifier)
                                  .clearList();
                              final FormState formDescription4 = _formKeyDescriptionMuro4
                                  .currentState!;
                              final FormState formLargo4 = _formKeyLargoMuro4
                                  .currentState!;
                              final FormState formAltura4 = _formKeyAlturaMuro4
                                  .currentState!;
                              if (formDescription4.validate() &&
                                  formLargo4.validate() &&
                                  formAltura4.validate()) {
                                datosLadrillo.createLadrillo(
                                    _descriptionMuro1Controller.text, ladrillo,
                                    asentado, _largoMuro1Controller.text,
                                    _alturaMuro1Controller.text);
                                datosLadrillo.createLadrillo(
                                    _descriptionMuro2Controller.text, ladrillo,
                                    asentado, _largoMuro2Controller.text,
                                    _alturaMuro2Controller.text);
                                datosLadrillo.createLadrillo(
                                    _descriptionMuro3Controller.text, ladrillo,
                                    asentado, _largoMuro3Controller.text,
                                    _alturaMuro3Controller.text);
                                datosLadrillo.createLadrillo(
                                    _descriptionMuro4Controller.text, ladrillo,
                                    asentado, _largoMuro4Controller.text,
                                    _alturaMuro4Controller.text);
                                if (addMuro4) {
                                  context.pushNamed('ladrillo_results');
                                } else {
                                  ref.read(ladrilloResultProvider.notifier)
                                      .clearList();
                                  final FormState formDescription5 = _formKeyDescriptionMuro5
                                      .currentState!;
                                  final FormState formLargo5 = _formKeyLargoMuro5
                                      .currentState!;
                                  final FormState formAltura5 = _formKeyAlturaMuro5
                                      .currentState!;
                                  if (formDescription5.validate() &&
                                      formLargo5.validate() &&
                                      formAltura5.validate()) {
                                    datosLadrillo.createLadrillo(
                                        _descriptionMuro1Controller.text,
                                        ladrillo, asentado,
                                        _largoMuro1Controller.text,
                                        _alturaMuro1Controller.text);
                                    datosLadrillo.createLadrillo(
                                        _descriptionMuro2Controller.text,
                                        ladrillo, asentado,
                                        _largoMuro2Controller.text,
                                        _alturaMuro2Controller.text);
                                    datosLadrillo.createLadrillo(
                                        _descriptionMuro3Controller.text,
                                        ladrillo, asentado,
                                        _largoMuro3Controller.text,
                                        _alturaMuro3Controller.text);
                                    datosLadrillo.createLadrillo(
                                        _descriptionMuro4Controller.text,
                                        ladrillo, asentado,
                                        _largoMuro4Controller.text,
                                        _alturaMuro4Controller.text);
                                    datosLadrillo.createLadrillo(
                                        _descriptionMuro5Controller.text,
                                        ladrillo, asentado,
                                        _largoMuro5Controller.text,
                                        _alturaMuro5Controller.text);
                                    if (addMuro5) {
                                      context.pushNamed('ladrillo_results');
                                    } else {
                                      ref.read(ladrilloResultProvider.notifier)
                                          .clearList();
                                      final FormState formDescription6 = _formKeyDescriptionMuro6
                                          .currentState!;
                                      final FormState formLargo6 = _formKeyLargoMuro6
                                          .currentState!;
                                      final FormState formAltura6 = _formKeyAlturaMuro6
                                          .currentState!;
                                      if (formDescription6.validate() &&
                                          formLargo6.validate() &&
                                          formAltura6.validate()) {
                                        datosLadrillo.createLadrillo(
                                            _descriptionMuro1Controller.text,
                                            ladrillo, asentado,
                                            _largoMuro1Controller.text,
                                            _alturaMuro1Controller.text);
                                        datosLadrillo.createLadrillo(
                                            _descriptionMuro2Controller.text,
                                            ladrillo, asentado,
                                            _largoMuro2Controller.text,
                                            _alturaMuro2Controller.text);
                                        datosLadrillo.createLadrillo(
                                            _descriptionMuro3Controller.text,
                                            ladrillo, asentado,
                                            _largoMuro3Controller.text,
                                            _alturaMuro3Controller.text);
                                        datosLadrillo.createLadrillo(
                                            _descriptionMuro4Controller.text,
                                            ladrillo, asentado,
                                            _largoMuro4Controller.text,
                                            _alturaMuro4Controller.text);
                                        datosLadrillo.createLadrillo(
                                            _descriptionMuro5Controller.text,
                                            ladrillo, asentado,
                                            _largoMuro5Controller.text,
                                            _alturaMuro5Controller.text);
                                        datosLadrillo.createLadrillo(
                                            _descriptionMuro6Controller.text,
                                            ladrillo, asentado,
                                            _largoMuro6Controller.text,
                                            _alturaMuro6Controller.text);
                                        if (addMuro6) {
                                          context.pushNamed('ladrillo_results');
                                        } else {
                                          ref.read(
                                              ladrilloResultProvider.notifier)
                                              .clearList();
                                          final FormState formDescription7 = _formKeyDescriptionMuro7
                                              .currentState!;
                                          final FormState formLargo7 = _formKeyLargoMuro7
                                              .currentState!;
                                          final FormState formAltura7 = _formKeyAlturaMuro7
                                              .currentState!;
                                          if (formDescription7.validate() &&
                                              formLargo7.validate() &&
                                              formAltura7.validate()) {
                                            datosLadrillo.createLadrillo(
                                                _descriptionMuro1Controller
                                                    .text, ladrillo, asentado,
                                                _largoMuro1Controller.text,
                                                _alturaMuro1Controller.text);
                                            datosLadrillo.createLadrillo(
                                                _descriptionMuro2Controller
                                                    .text, ladrillo, asentado,
                                                _largoMuro2Controller.text,
                                                _alturaMuro2Controller.text);
                                            datosLadrillo.createLadrillo(
                                                _descriptionMuro3Controller
                                                    .text, ladrillo, asentado,
                                                _largoMuro3Controller.text,
                                                _alturaMuro3Controller.text);
                                            datosLadrillo.createLadrillo(
                                                _descriptionMuro4Controller
                                                    .text, ladrillo, asentado,
                                                _largoMuro4Controller.text,
                                                _alturaMuro4Controller.text);
                                            datosLadrillo.createLadrillo(
                                                _descriptionMuro5Controller
                                                    .text, ladrillo, asentado,
                                                _largoMuro5Controller.text,
                                                _alturaMuro5Controller.text);
                                            datosLadrillo.createLadrillo(
                                                _descriptionMuro6Controller
                                                    .text, ladrillo, asentado,
                                                _largoMuro6Controller.text,
                                                _alturaMuro6Controller.text);
                                            datosLadrillo.createLadrillo(
                                                _descriptionMuro7Controller
                                                    .text, ladrillo, asentado,
                                                _largoMuro7Controller.text,
                                                _alturaMuro7Controller.text);
                                            if (addMuro7) {
                                              context.pushNamed(
                                                  'ladrillo_results');
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  } else {
                    null;
                  }
                } else {
                  null;
                }
                /*var datosLadrillo = ref.read(ladrilloResultProvider.notifier);
                ladrillo = tipoLadrillo;
                void createLadrilloIfNotEmpty(TextEditingController descriptionController, TextEditingController largoController, TextEditingController alturaController) {
                  if (descriptionController.text.isNotEmpty && largoController.text.isNotEmpty && alturaController.text.isNotEmpty) {
                    datosLadrillo.createLadrillo(descriptionController.text, ladrillo, asentado, largoController.text, alturaController.text);
                  }
                }
                createLadrilloIfNotEmpty(_descriptionMuro1Controller, _largoMuro1Controller, _alturaMuro1Controller);
                createLadrilloIfNotEmpty(_descriptionMuro2Controller, _largoMuro2Controller, _alturaMuro2Controller);
                createLadrilloIfNotEmpty(_descriptionMuro3Controller, _largoMuro3Controller, _alturaMuro3Controller);
                createLadrilloIfNotEmpty(_descriptionMuro4Controller, _largoMuro4Controller, _alturaMuro4Controller);
                createLadrilloIfNotEmpty(_descriptionMuro5Controller, _largoMuro5Controller, _alturaMuro5Controller);
                createLadrilloIfNotEmpty(_descriptionMuro6Controller, _largoMuro6Controller, _alturaMuro6Controller);
                createLadrilloIfNotEmpty(_descriptionMuro7Controller, _largoMuro7Controller, _alturaMuro7Controller);
                context.pushNamed('ladrillo_results');*/
              },
              color: AppColors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              height: 50,
              minWidth: 200,
              child: const Text("Metrar",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  )
              ),
            ),
            const SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }

  Widget contentDropdownButton(String type, String description, List<String> typeList) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(description),
                const SizedBox(width: 50,),
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6)
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: DropdownButtonFormField(
                        value: type == 'ladrillo' ? selectedValueLadrillo : selectedValueAsentado,
                        items: typeList.map((e) => DropdownMenuItem(value: e,child: Text(e.toString()),)).toList(),
                        onChanged: (value) {
                          setState(() {
                            switch (type) {
                              case 'ladrillo':
                                selectedValueLadrillo = value;
                                ladrillo = selectedValueLadrillo!;
                                selectedValueAsentado = null;
                                break;
                              case 'asentado':
                                selectedValueAsentado = value;
                                asentado = selectedValueAsentado!;
                                break;
                            }
                          });
                        },
                        validator: (value) => value == null ? 'campo requerido' : null,
                        hint: const Text("Selecionar"),
                   //   underline: const SizedBox(),
                        isExpanded: true,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}