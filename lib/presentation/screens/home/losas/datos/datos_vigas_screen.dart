
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/providers.dart';
import '../../../../widgets/widgets.dart';

class DatosVigasScreen extends ConsumerStatefulWidget {
  const DatosVigasScreen({super.key});

  @override
  ConsumerState<DatosVigasScreen> createState() => _DatosVigasScreenState();
}

class _DatosVigasScreenState extends ConsumerState<DatosVigasScreen> {

  late String losas;

  // GlobalKey
  final GlobalKey<FormState> _formKeyDescriptionViga1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoViga1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoViga1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaViga1 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionViga2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoViga2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoViga2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaViga2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionViga3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoViga3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoViga3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaViga3 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionViga4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoViga4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoViga4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaViga4 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionViga5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoViga5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoViga5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaViga5 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionViga6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoViga6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoViga6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaViga6 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionViga7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoViga7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoViga7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaViga7 = GlobalKey<FormState>();

  //textEditingControllers
  final TextEditingController _descriptionViga1Controller =  TextEditingController();
  final TextEditingController _largoViga1Controller =  TextEditingController();
  final TextEditingController _anchoViga1Controller =  TextEditingController();
  final TextEditingController _alturaViga1Controller =  TextEditingController();

  final TextEditingController _descriptionViga2Controller =  TextEditingController();
  final TextEditingController _largoViga2Controller =  TextEditingController();
  final TextEditingController _anchoViga2Controller =  TextEditingController();
  final TextEditingController _alturaViga2Controller =  TextEditingController();

  final TextEditingController _descriptionViga3Controller =  TextEditingController();
  final TextEditingController _largoViga3Controller =  TextEditingController();
  final TextEditingController _anchoViga3Controller =  TextEditingController();
  final TextEditingController _alturaViga3Controller =  TextEditingController();

  final TextEditingController _descriptionViga4Controller =  TextEditingController();
  final TextEditingController _largoViga4Controller =  TextEditingController();
  final TextEditingController _anchoViga4Controller =  TextEditingController();
  final TextEditingController _alturaViga4Controller =  TextEditingController();

  final TextEditingController _descriptionViga5Controller =  TextEditingController();
  final TextEditingController _largoViga5Controller =  TextEditingController();
  final TextEditingController _anchoViga5Controller =  TextEditingController();
  final TextEditingController _alturaViga5Controller =  TextEditingController();

  final TextEditingController _descriptionViga6Controller =  TextEditingController();
  final TextEditingController _largoViga6Controller =  TextEditingController();
  final TextEditingController _anchoViga6Controller =  TextEditingController();
  final TextEditingController _alturaViga6Controller =  TextEditingController();

  final TextEditingController _descriptionViga7Controller =  TextEditingController();
  final TextEditingController _largoViga7Controller =  TextEditingController();
  final TextEditingController _anchoViga7Controller =  TextEditingController();
  final TextEditingController _alturaViga7Controller =  TextEditingController();

  @override
  Widget build(BuildContext context) {

    ref.watch(losaVigasResultProvider);

    final addViga1 = ref.watch(addViga1Provider);
    final addViga2 = ref.watch(addViga2Provider);
    final addViga3 = ref.watch(addViga3Provider);
    final addViga4 = ref.watch(addViga4Provider);
    final addViga5 = ref.watch(addViga5Provider);
    final addViga6 = ref.watch(addViga6Provider);
    final addViga7 = ref.watch(addViga7Provider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBarWidget(titleAppBar: 'Viga',),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: const Text('Complete los siguientes campos: ',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.all(10),
                        child: const Text("Viga 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
                    ),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyDescriptionViga1, description: 'Descripción' ,controller: _descriptionViga1Controller, hintText: 'ej. Losa de la cocina', isKeyboardText: true,),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyLargoViga1, description: 'Largo' ,controller: _largoViga1Controller, hintText: 'metros',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAnchoViga1, description: 'Ancho' ,controller: _anchoViga1Controller, hintText: 'metros',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAlturaViga1, description: 'Altura' ,controller: _alturaViga1Controller, hintText: 'metros',),),
                    Visibility(
                      visible: addViga1,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(addViga1Provider.notifier).toggleAddViga();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Añadir Viga"),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  )
                              ),                          )
                        ),
                      ),
                    ),
                    CustomAddFourFields(formKey1: _formKeyDescriptionViga2, formKey2: _formKeyLargoViga2, formKey3: _formKeyAnchoViga2, formKey4: _formKeyAlturaViga2, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addViga1, titleMaterial: "Viga 2", firstTextController: _descriptionViga2Controller, secondTextController: _largoViga2Controller, thirdTextController: _anchoViga2Controller, fourthTextController: _alturaViga2Controller, firstHintText: 'ej. viga de la cocina', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addViga2, pressed: () => ref.read(addViga2Provider.notifier).toggleAddViga(), nameAddMaterial: 'Agregar Viga', pressedCancel: () { ref.read(addViga1Provider.notifier).toggleAddViga();},),
                    CustomAddFourFields(formKey1: _formKeyDescriptionViga3, formKey2: _formKeyLargoViga3, formKey3: _formKeyAnchoViga3, formKey4: _formKeyAlturaViga3, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addViga2, titleMaterial: "Viga 3", firstTextController: _descriptionViga3Controller, secondTextController: _largoViga3Controller, thirdTextController: _anchoViga3Controller, fourthTextController: _alturaViga3Controller, firstHintText: 'ej. viga de la cocina', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addViga3, pressed: () => ref.read(addViga3Provider.notifier).toggleAddViga(), nameAddMaterial: 'Agregar Viga', pressedCancel: () { ref.read(addViga2Provider.notifier).toggleAddViga();},),
                    CustomAddFourFields(formKey1: _formKeyDescriptionViga4, formKey2: _formKeyLargoViga4, formKey3: _formKeyAnchoViga4, formKey4: _formKeyAlturaViga4, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addViga3, titleMaterial: "Viga 4", firstTextController: _descriptionViga4Controller, secondTextController: _largoViga4Controller, thirdTextController: _anchoViga4Controller, fourthTextController: _alturaViga4Controller, firstHintText: 'ej. viga de la cocina', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addViga4, pressed: () => ref.read(addViga4Provider.notifier).toggleAddViga(), nameAddMaterial: 'Agregar Viga', pressedCancel: () { ref.read(addViga3Provider.notifier).toggleAddViga();},),
                    CustomAddFourFields(formKey1: _formKeyDescriptionViga5, formKey2: _formKeyLargoViga5, formKey3: _formKeyAnchoViga5, formKey4: _formKeyAlturaViga5, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addViga4, titleMaterial: "Viga 5", firstTextController: _descriptionViga5Controller, secondTextController: _largoViga5Controller, thirdTextController: _anchoViga5Controller, fourthTextController: _alturaViga5Controller, firstHintText: 'ej. viga de la cocina', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addViga5, pressed: () => ref.read(addViga5Provider.notifier).toggleAddViga(), nameAddMaterial: 'Agregar Viga', pressedCancel: () { ref.read(addViga4Provider.notifier).toggleAddViga();},),
                    CustomAddFourFields(formKey1: _formKeyDescriptionViga6, formKey2: _formKeyLargoViga6, formKey3: _formKeyAnchoViga6, formKey4: _formKeyAlturaViga6, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addViga5, titleMaterial: "Viga 6", firstTextController: _descriptionViga6Controller, secondTextController: _largoViga6Controller, thirdTextController: _anchoViga6Controller, fourthTextController: _alturaViga6Controller, firstHintText: 'ej. viga de la cocina', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addViga6, pressed: () => ref.read(addViga6Provider.notifier).toggleAddViga(), nameAddMaterial: 'Agregar Viga', pressedCancel: () { ref.read(addViga5Provider.notifier).toggleAddViga();},),
                    CustomAddFourFields(formKey1: _formKeyDescriptionViga7, formKey2: _formKeyLargoViga7, formKey3: _formKeyAnchoViga7, formKey4: _formKeyAlturaViga7, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addViga6, titleMaterial: "Viga 7", firstTextController: _descriptionViga7Controller, secondTextController: _largoViga7Controller, thirdTextController: _anchoViga7Controller, fourthTextController: _alturaViga7Controller, firstHintText: 'ej. viga de la cocina', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addViga7, pressed: () => ref.read(addViga7Provider.notifier).toggleAddViga(), nameAddMaterial: 'Agregar Viga', pressedCancel: () { ref.read(addViga6Provider.notifier).toggleAddViga();},),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                final FormState formDescription1 = _formKeyDescriptionViga1.currentState!;
                final FormState formLargo1 = _formKeyLargoViga1.currentState!;
                final FormState formAncho1 = _formKeyAnchoViga1.currentState!;
                final FormState formAltura1 = _formKeyAnchoViga1.currentState!;

                var datosViga = ref.read(losaVigasResultProvider.notifier);

                if (formDescription1.validate() && formLargo1.validate() && formAncho1.validate() && formAltura1.validate()) {
                  datosViga.createVigas(_descriptionViga1Controller.text, _largoViga1Controller.text, _anchoViga1Controller.text, _alturaViga1Controller.text);
                  if (addViga1) {
                    context.pushNamed('losas-escaleras');
                  } else {
                    ref.read(losaVigasResultProvider.notifier).clearList();
                    final FormState formDescription2 = _formKeyDescriptionViga2.currentState!;
                    final FormState formLargo2 = _formKeyLargoViga2.currentState!;
                    final FormState formAncho2 = _formKeyAnchoViga2.currentState!;
                    final FormState formAltura2 = _formKeyAnchoViga2.currentState!;

                    if (formDescription2.validate() && formLargo2.validate() && formAncho2.validate() && formAltura2.validate()) {
                      datosViga.createVigas(_descriptionViga1Controller.text, _largoViga1Controller.text, _anchoViga1Controller.text, _alturaViga1Controller.text);
                      datosViga.createVigas(_descriptionViga2Controller.text, _largoViga2Controller.text, _anchoViga2Controller.text, _alturaViga2Controller.text);
                      if (addViga2) {
                        context.pushNamed('losas-escaleras');
                      } else {
                        ref.read(losaVigasResultProvider.notifier).clearList();
                        final FormState formDescription3 = _formKeyDescriptionViga3.currentState!;
                        final FormState formLargo3 = _formKeyLargoViga3.currentState!;
                        final FormState formAncho3 = _formKeyAnchoViga3.currentState!;
                        final FormState formAltura3 = _formKeyAnchoViga3.currentState!;

                        if (formDescription3.validate() && formLargo3.validate() && formAncho3.validate() && formAltura3.validate()) {
                          datosViga.createVigas(_descriptionViga1Controller.text, _largoViga1Controller.text, _anchoViga1Controller.text, _alturaViga1Controller.text);
                          datosViga.createVigas(_descriptionViga2Controller.text, _largoViga2Controller.text, _anchoViga2Controller.text, _alturaViga2Controller.text);
                          datosViga.createVigas(_descriptionViga3Controller.text, _largoViga3Controller.text, _anchoViga3Controller.text, _alturaViga3Controller.text);
                          if (addViga3) {
                            context.pushNamed('losas-escaleras');
                          } else {
                            ref.read(losaVigasResultProvider.notifier).clearList();
                            final FormState formDescription4 = _formKeyDescriptionViga4.currentState!;
                            final FormState formLargo4 = _formKeyLargoViga4.currentState!;
                            final FormState formAncho4 = _formKeyAnchoViga4.currentState!;
                            final FormState formAltura4 = _formKeyAnchoViga4.currentState!;
                            if (formDescription4.validate() && formLargo4.validate() && formAncho4.validate() && formAltura4.validate()) {
                              datosViga.createVigas(_descriptionViga1Controller.text, _largoViga1Controller.text, _anchoViga1Controller.text, _alturaViga1Controller.text);
                              datosViga.createVigas(_descriptionViga2Controller.text, _largoViga2Controller.text, _anchoViga2Controller.text, _alturaViga2Controller.text);
                              datosViga.createVigas(_descriptionViga3Controller.text, _largoViga3Controller.text, _anchoViga3Controller.text, _alturaViga3Controller.text);
                              datosViga.createVigas(_descriptionViga4Controller.text, _largoViga4Controller.text, _anchoViga4Controller.text, _alturaViga4Controller.text);
                              if (addViga4) {
                                context.pushNamed('losas-escaleras');
                              } else {
                                ref.read(losaVigasResultProvider.notifier).clearList();
                                final FormState formDescription5 = _formKeyDescriptionViga5.currentState!;
                                final FormState formLargo5 = _formKeyLargoViga5.currentState!;
                                final FormState formAncho5 = _formKeyAnchoViga5.currentState!;
                                final FormState formAltura5 = _formKeyAnchoViga5.currentState!;
                                if (formDescription5.validate() && formLargo5.validate() && formAncho5.validate() && formAltura5.validate()) {
                                  datosViga.createVigas(_descriptionViga1Controller.text, _largoViga1Controller.text, _anchoViga1Controller.text, _alturaViga1Controller.text);
                                  datosViga.createVigas(_descriptionViga2Controller.text, _largoViga2Controller.text, _anchoViga2Controller.text, _alturaViga2Controller.text);
                                  datosViga.createVigas(_descriptionViga3Controller.text, _largoViga3Controller.text, _anchoViga3Controller.text, _alturaViga3Controller.text);
                                  datosViga.createVigas(_descriptionViga4Controller.text, _largoViga4Controller.text, _anchoViga4Controller.text, _alturaViga4Controller.text);
                                  datosViga.createVigas(_descriptionViga5Controller.text, _largoViga5Controller.text, _anchoViga5Controller.text, _alturaViga5Controller.text);
                                  if (addViga5) {
                                    context.pushNamed('losas-escaleras');
                                  } else {
                                    ref.read(losaVigasResultProvider.notifier).clearList();
                                    final FormState formDescription6 = _formKeyDescriptionViga6.currentState!;
                                    final FormState formLargo6 = _formKeyLargoViga6.currentState!;
                                    final FormState formAncho6 = _formKeyAnchoViga6.currentState!;
                                    final FormState formAltura6 = _formKeyAnchoViga6.currentState!;
                                    if (formDescription6.validate() && formLargo6.validate() && formAncho6.validate() && formAltura6.validate()) {
                                      datosViga.createVigas(_descriptionViga1Controller.text, _largoViga1Controller.text, _anchoViga1Controller.text, _alturaViga1Controller.text);
                                      datosViga.createVigas(_descriptionViga2Controller.text, _largoViga2Controller.text, _anchoViga2Controller.text, _alturaViga2Controller.text);
                                      datosViga.createVigas(_descriptionViga3Controller.text, _largoViga3Controller.text, _anchoViga3Controller.text, _alturaViga3Controller.text);
                                      datosViga.createVigas(_descriptionViga4Controller.text, _largoViga4Controller.text, _anchoViga4Controller.text, _alturaViga4Controller.text);
                                      datosViga.createVigas(_descriptionViga5Controller.text, _largoViga5Controller.text, _anchoViga5Controller.text, _alturaViga5Controller.text);
                                      datosViga.createVigas(_descriptionViga6Controller.text, _largoViga6Controller.text, _anchoViga6Controller.text, _alturaViga6Controller.text);
                                      if (addViga6) {
                                        context.pushNamed('losas-escaleras');
                                      } else {
                                        ref.read(losaVigasResultProvider.notifier).clearList();
                                        final FormState formDescription7 = _formKeyDescriptionViga7.currentState!;
                                        final FormState formLargo7 = _formKeyLargoViga7.currentState!;
                                        final FormState formAncho7 = _formKeyAnchoViga7.currentState!;
                                        final FormState formAltura7 = _formKeyAnchoViga7.currentState!;
                                        if (formDescription7.validate() && formLargo7.validate() && formAncho7.validate() && formAltura7.validate()) {
                                          datosViga.createVigas(_descriptionViga1Controller.text, _largoViga1Controller.text, _anchoViga1Controller.text, _alturaViga1Controller.text);
                                          datosViga.createVigas(_descriptionViga2Controller.text, _largoViga2Controller.text, _anchoViga2Controller.text, _alturaViga2Controller.text);
                                          datosViga.createVigas(_descriptionViga3Controller.text, _largoViga3Controller.text, _anchoViga3Controller.text, _alturaViga3Controller.text);
                                          datosViga.createVigas(_descriptionViga4Controller.text, _largoViga4Controller.text, _anchoViga4Controller.text, _alturaViga4Controller.text);
                                          datosViga.createVigas(_descriptionViga5Controller.text, _largoViga5Controller.text, _anchoViga5Controller.text, _alturaViga5Controller.text);
                                          datosViga.createVigas(_descriptionViga6Controller.text, _largoViga6Controller.text, _anchoViga6Controller.text, _alturaViga6Controller.text);
                                          datosViga.createVigas(_descriptionViga7Controller.text, _largoViga7Controller.text, _anchoViga7Controller.text, _alturaViga7Controller.text);
                                          if (addViga7) {
                                            context.pushNamed('losas-escaleras');
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
                }  else {
                  null;
                }
              },
              color: const Color(0x00ecf0f1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              height: 50,
              minWidth: 200,
              child: const Text("Metrar",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}