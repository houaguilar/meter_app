
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/providers.dart';
import '../../../widgets/shared/custom_add_three_fields.dart';
import '../../../widgets/widgets.dart';

class DatosLosasMacizasScreen extends ConsumerStatefulWidget {
  const DatosLosasMacizasScreen({super.key});

  @override
  ConsumerState<DatosLosasMacizasScreen> createState() => _DatosLosasMacizasScreenState();
}

class _DatosLosasMacizasScreenState extends ConsumerState<DatosLosasMacizasScreen> {

  late String losas;

  // GlobalKey
  final GlobalKey<FormState> _formKeyDescriptionLosaMaciza1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaMaciza1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaMaciza1 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaMaciza2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaMaciza2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaMaciza2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaMaciza3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaMaciza3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaMaciza3 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaMaciza4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaMaciza4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaMaciza4 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaMaciza5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaMaciza5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaMaciza5 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaMaciza6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaMaciza6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaMaciza6 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaMaciza7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaMaciza7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaMaciza7 = GlobalKey<FormState>();

  //textEditingControllers
  final TextEditingController _descriptionLosaMaciza1Controller =  TextEditingController();
  final TextEditingController _largoLosaMaciza1Controller =  TextEditingController();
  final TextEditingController _anchoLosaMaciza1Controller =  TextEditingController();

  final TextEditingController _descriptionLosaMaciza2Controller =  TextEditingController();
  final TextEditingController _largoLosaMaciza2Controller =  TextEditingController();
  final TextEditingController _anchoLosaMaciza2Controller =  TextEditingController();

  final TextEditingController _descriptionLosaMaciza3Controller =  TextEditingController();
  final TextEditingController _largoLosaMaciza3Controller =  TextEditingController();
  final TextEditingController _anchoLosaMaciza3Controller =  TextEditingController();

  final TextEditingController _descriptionLosaMaciza4Controller =  TextEditingController();
  final TextEditingController _largoLosaMaciza4Controller =  TextEditingController();
  final TextEditingController _anchoLosaMaciza4Controller =  TextEditingController();

  final TextEditingController _descriptionLosaMaciza5Controller =  TextEditingController();
  final TextEditingController _largoLosaMaciza5Controller =  TextEditingController();
  final TextEditingController _anchoLosaMaciza5Controller =  TextEditingController();

  final TextEditingController _descriptionLosaMaciza6Controller =  TextEditingController();
  final TextEditingController _largoLosaMaciza6Controller =  TextEditingController();
  final TextEditingController _anchoLosaMaciza6Controller =  TextEditingController();

  final TextEditingController _descriptionLosaMaciza7Controller =  TextEditingController();
  final TextEditingController _largoLosaMaciza7Controller =  TextEditingController();
  final TextEditingController _anchoLosaMaciza7Controller =  TextEditingController();

  @override
  Widget build(BuildContext context) {

    final currentFilter = ref.watch(todoCurrentFilterProvider);
    ref.watch(losaMacizaResultProvider);

    final addLosaMaciza1 = ref.watch(addLosaMaciza1Provider);
    final addLosaMaciza2 = ref.watch(addLosaMaciza2Provider);
    final addLosaMaciza3 = ref.watch(addLosaMaciza3Provider);
    final addLosaMaciza4 = ref.watch(addLosaMaciza4Provider);
    final addLosaMaciza5 = ref.watch(addLosaMaciza5Provider);
    final addLosaMaciza6 = ref.watch(addLosaMaciza6Provider);
    final addLosaMaciza7 = ref.watch(addLosaMaciza7Provider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const AppBarWidget(titleAppBar: 'Losa Maciza',),
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
                      margin: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Peralte:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                          SegmentedButton(
                            segments: const [
                              ButtonSegment(value: FilterType.all, icon: Text('15')),
                              ButtonSegment(value: FilterType.completed, icon: Text('17')),
                              ButtonSegment(value: FilterType.pending, icon: Text('20')),
                            ],
                            selected: <FilterType>{currentFilter},
                            onSelectionChanged: (value) {
                              ref.read(todoCurrentFilterProvider.notifier).changeCurrentFilter(value.first);
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.all(10),
                        child: const Text("Losa 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
                    ),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyDescriptionLosaMaciza1, description: 'Descripción' ,controller: _descriptionLosaMaciza1Controller, hintText: 'ej. Losa de la cocina', isKeyboardText: true,),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyLargoLosaMaciza1, description: 'Largo' ,controller: _largoLosaMaciza1Controller, hintText: 'metros',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAnchoLosaMaciza1, description: 'Ancho' ,controller: _anchoLosaMaciza1Controller, hintText: 'metros',),),
                    Visibility(
                      visible: addLosaMaciza1,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(addLosaMaciza1Provider.notifier).toggleAddLosaMaciza();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Añadir Losa"),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  )
                              ),                          )
                        ),
                      ),
                    ),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaMaciza2, formKey2: _formKeyLargoLosaMaciza2, formKey3: _formKeyAnchoLosaMaciza2, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaMaciza1, titleMaterial: "Losa 2", firstTextController: _descriptionLosaMaciza2Controller, secondTextController: _largoLosaMaciza2Controller, thirdTextController: _anchoLosaMaciza2Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaMaciza2, pressed: () => ref.read(addLosaMaciza2Provider.notifier).toggleAddLosaMaciza(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaMaciza1Provider.notifier).toggleAddLosaMaciza();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaMaciza3, formKey2: _formKeyLargoLosaMaciza3, formKey3: _formKeyAnchoLosaMaciza3, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaMaciza2, titleMaterial: "Losa 3", firstTextController: _descriptionLosaMaciza3Controller, secondTextController: _largoLosaMaciza3Controller, thirdTextController: _anchoLosaMaciza3Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaMaciza3, pressed: () => ref.read(addLosaMaciza3Provider.notifier).toggleAddLosaMaciza(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaMaciza2Provider.notifier).toggleAddLosaMaciza();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaMaciza4, formKey2: _formKeyLargoLosaMaciza4, formKey3: _formKeyAnchoLosaMaciza4, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaMaciza3, titleMaterial: "Losa 4", firstTextController: _descriptionLosaMaciza4Controller, secondTextController: _largoLosaMaciza4Controller, thirdTextController: _anchoLosaMaciza4Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaMaciza4, pressed: () => ref.read(addLosaMaciza4Provider.notifier).toggleAddLosaMaciza(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaMaciza3Provider.notifier).toggleAddLosaMaciza();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaMaciza5, formKey2: _formKeyLargoLosaMaciza5, formKey3: _formKeyAnchoLosaMaciza5, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaMaciza4, titleMaterial: "Losa 5", firstTextController: _descriptionLosaMaciza5Controller, secondTextController: _largoLosaMaciza5Controller, thirdTextController: _anchoLosaMaciza5Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaMaciza5, pressed: () => ref.read(addLosaMaciza5Provider.notifier).toggleAddLosaMaciza(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaMaciza4Provider.notifier).toggleAddLosaMaciza();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaMaciza6, formKey2: _formKeyLargoLosaMaciza6, formKey3: _formKeyAnchoLosaMaciza6, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaMaciza5, titleMaterial: "Losa 6", firstTextController: _descriptionLosaMaciza6Controller, secondTextController: _largoLosaMaciza6Controller, thirdTextController: _anchoLosaMaciza6Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaMaciza6, pressed: () => ref.read(addLosaMaciza6Provider.notifier).toggleAddLosaMaciza(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaMaciza5Provider.notifier).toggleAddLosaMaciza();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaMaciza7, formKey2: _formKeyLargoLosaMaciza7, formKey3: _formKeyAnchoLosaMaciza7, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaMaciza6, titleMaterial: "Losa 7", firstTextController: _descriptionLosaMaciza7Controller, secondTextController: _largoLosaMaciza7Controller, thirdTextController: _anchoLosaMaciza7Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaMaciza7, pressed: () => ref.read(addLosaMaciza7Provider.notifier).toggleAddLosaMaciza(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaMaciza6Provider.notifier).toggleAddLosaMaciza();},),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                final FormState formDescription1 = _formKeyDescriptionLosaMaciza1.currentState!;
                final FormState formLargo1 = _formKeyLargoLosaMaciza1.currentState!;
                final FormState formAltura1 = _formKeyAnchoLosaMaciza1.currentState!;

                var datosLosaMaciza = ref.read(losaMacizaResultProvider.notifier);

                if (formDescription1.validate() && formLargo1.validate() && formAltura1.validate()) {
                  datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza1Controller.text, _largoLosaMaciza1Controller.text, _anchoLosaMaciza1Controller.text, '17');
                  if (addLosaMaciza1) {
                    context.pushNamed('losas-vigas');
                  } else {
                    ref.read(losaMacizaResultProvider.notifier).clearList();
                    final FormState formDescription2 = _formKeyDescriptionLosaMaciza2.currentState!;
                    final FormState formLargo2 = _formKeyLargoLosaMaciza2.currentState!;
                    final FormState formAltura2 = _formKeyAnchoLosaMaciza2.currentState!;

                    if (formDescription2.validate() && formLargo2.validate() && formAltura2.validate()) {
                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza1Controller.text, _largoLosaMaciza1Controller.text, _anchoLosaMaciza1Controller.text, '17');
                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza2Controller.text, _largoLosaMaciza2Controller.text, _anchoLosaMaciza2Controller.text, '17');
                      if (addLosaMaciza2) {
                        context.pushNamed('losas-vigas');
                      } else {
                        ref.read(losaMacizaResultProvider.notifier).clearList();
                        final FormState formDescription3 = _formKeyDescriptionLosaMaciza3.currentState!;
                        final FormState formLargo3 = _formKeyLargoLosaMaciza3.currentState!;
                        final FormState formAltura3 = _formKeyAnchoLosaMaciza3.currentState!;

                        if (formDescription3.validate() && formLargo3.validate() && formAltura3.validate()) {
                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza1Controller.text, _largoLosaMaciza1Controller.text, _anchoLosaMaciza1Controller.text, '17');
                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza2Controller.text, _largoLosaMaciza2Controller.text, _anchoLosaMaciza2Controller.text, '17');
                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza3Controller.text, _largoLosaMaciza3Controller.text, _anchoLosaMaciza3Controller.text, '17');
                          if (addLosaMaciza3) {
                            context.pushNamed('losas-vigas');
                          } else {
                            ref.read(losaMacizaResultProvider.notifier).clearList();
                            final FormState formDescription4 = _formKeyDescriptionLosaMaciza4.currentState!;
                            final FormState formLargo4 = _formKeyLargoLosaMaciza4.currentState!;
                            final FormState formAltura4 = _formKeyAnchoLosaMaciza4.currentState!;
                            if (formDescription4.validate() && formLargo4.validate() && formAltura4.validate()) {
                              datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza1Controller.text, _largoLosaMaciza1Controller.text, _anchoLosaMaciza1Controller.text, '17');
                              datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza2Controller.text, _largoLosaMaciza2Controller.text, _anchoLosaMaciza2Controller.text, '17');
                              datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza3Controller.text, _largoLosaMaciza3Controller.text, _anchoLosaMaciza3Controller.text, '17');
                              datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza4Controller.text, _largoLosaMaciza4Controller.text, _anchoLosaMaciza4Controller.text, '17');
                              if (addLosaMaciza4) {
                                context.pushNamed('losas-vigas');
                              } else {
                                ref.read(losaMacizaResultProvider.notifier).clearList();
                                final FormState formDescription5 = _formKeyDescriptionLosaMaciza5.currentState!;
                                final FormState formLargo5 = _formKeyLargoLosaMaciza5.currentState!;
                                final FormState formAltura5 = _formKeyAnchoLosaMaciza5.currentState!;
                                if (formDescription5.validate() && formLargo5.validate() && formAltura5.validate()) {
                                  datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza1Controller.text, _largoLosaMaciza1Controller.text, _anchoLosaMaciza1Controller.text, '17');
                                  datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza2Controller.text, _largoLosaMaciza2Controller.text, _anchoLosaMaciza2Controller.text, '17');
                                  datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza3Controller.text, _largoLosaMaciza3Controller.text, _anchoLosaMaciza3Controller.text, '17');
                                  datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza4Controller.text, _largoLosaMaciza4Controller.text, _anchoLosaMaciza4Controller.text, '17');
                                  datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza5Controller.text, _largoLosaMaciza5Controller.text, _anchoLosaMaciza5Controller.text, '17');
                                  if (addLosaMaciza5) {
                                    context.pushNamed('losas-vigas');
                                  } else {
                                    ref.read(losaMacizaResultProvider.notifier).clearList();
                                    final FormState formDescription6 = _formKeyDescriptionLosaMaciza6.currentState!;
                                    final FormState formLargo6 = _formKeyLargoLosaMaciza6.currentState!;
                                    final FormState formAltura6 = _formKeyAnchoLosaMaciza6.currentState!;
                                    if (formDescription6.validate() && formLargo6.validate() && formAltura6.validate()) {
                                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza1Controller.text, _largoLosaMaciza1Controller.text, _anchoLosaMaciza1Controller.text, '17');
                                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza2Controller.text, _largoLosaMaciza2Controller.text, _anchoLosaMaciza2Controller.text, '17');
                                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza3Controller.text, _largoLosaMaciza3Controller.text, _anchoLosaMaciza3Controller.text, '17');
                                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza4Controller.text, _largoLosaMaciza4Controller.text, _anchoLosaMaciza4Controller.text, '17');
                                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza5Controller.text, _largoLosaMaciza5Controller.text, _anchoLosaMaciza5Controller.text, '17');
                                      datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza6Controller.text, _largoLosaMaciza6Controller.text, _anchoLosaMaciza6Controller.text, '17');
                                      if (addLosaMaciza6) {
                                        context.pushNamed('losas-vigas');
                                      } else {
                                        ref.read(losaMacizaResultProvider.notifier).clearList();
                                        final FormState formDescription7 = _formKeyDescriptionLosaMaciza7.currentState!;
                                        final FormState formLargo7 = _formKeyLargoLosaMaciza7.currentState!;
                                        final FormState formAltura7 = _formKeyAnchoLosaMaciza7.currentState!;
                                        if (formDescription7.validate() && formLargo7.validate() && formAltura7.validate()) {
                                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza1Controller.text, _largoLosaMaciza1Controller.text, _anchoLosaMaciza1Controller.text, '17');
                                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza2Controller.text, _largoLosaMaciza2Controller.text, _anchoLosaMaciza2Controller.text, '17');
                                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza3Controller.text, _largoLosaMaciza3Controller.text, _anchoLosaMaciza3Controller.text, '17');
                                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza4Controller.text, _largoLosaMaciza4Controller.text, _anchoLosaMaciza4Controller.text, '17');
                                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza5Controller.text, _largoLosaMaciza5Controller.text, _anchoLosaMaciza5Controller.text, '17');
                                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza6Controller.text, _largoLosaMaciza6Controller.text, _anchoLosaMaciza6Controller.text, '17');
                                          datosLosaMaciza.createLosaMaciza(_descriptionLosaMaciza7Controller.text, _largoLosaMaciza7Controller.text, _anchoLosaMaciza7Controller.text, '17');
                                          if (addLosaMaciza7) {
                                            context.pushNamed('losas-vigas');
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