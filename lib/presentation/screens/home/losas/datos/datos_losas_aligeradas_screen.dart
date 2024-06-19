
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/providers.dart';
import '../../../widgets/shared/custom_add_three_fields.dart';
import '../../../widgets/widgets.dart';

class DatosLosasAligeradasScreen extends ConsumerStatefulWidget {
  const DatosLosasAligeradasScreen({super.key});

  @override
  ConsumerState<DatosLosasAligeradasScreen> createState() => _DatosLosasAligeradasScreenState();
}

class _DatosLosasAligeradasScreenState extends ConsumerState<DatosLosasAligeradasScreen> {

  late String losas;

  // GlobalKey
  final GlobalKey<FormState> _formKeyDescriptionLosaAligerada1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaAligerada1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaAligerada1 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaAligerada2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaAligerada2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaAligerada2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaAligerada3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaAligerada3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaAligerada3 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaAligerada4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaAligerada4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaAligerada4 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaAligerada5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaAligerada5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaAligerada5 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaAligerada6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaAligerada6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaAligerada6 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionLosaAligerada7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoLosaAligerada7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoLosaAligerada7 = GlobalKey<FormState>();

  //textEditingControllers
  final TextEditingController _descriptionLosaAligerada1Controller =  TextEditingController();
  final TextEditingController _largoLosaAligerada1Controller =  TextEditingController();
  final TextEditingController _anchoLosaAligerada1Controller =  TextEditingController();

  final TextEditingController _descriptionLosaAligerada2Controller =  TextEditingController();
  final TextEditingController _largoLosaAligerada2Controller =  TextEditingController();
  final TextEditingController _anchoLosaAligerada2Controller =  TextEditingController();

  final TextEditingController _descriptionLosaAligerada3Controller =  TextEditingController();
  final TextEditingController _largoLosaAligerada3Controller =  TextEditingController();
  final TextEditingController _anchoLosaAligerada3Controller =  TextEditingController();

  final TextEditingController _descriptionLosaAligerada4Controller =  TextEditingController();
  final TextEditingController _largoLosaAligerada4Controller =  TextEditingController();
  final TextEditingController _anchoLosaAligerada4Controller =  TextEditingController();

  final TextEditingController _descriptionLosaAligerada5Controller =  TextEditingController();
  final TextEditingController _largoLosaAligerada5Controller =  TextEditingController();
  final TextEditingController _anchoLosaAligerada5Controller =  TextEditingController();

  final TextEditingController _descriptionLosaAligerada6Controller =  TextEditingController();
  final TextEditingController _largoLosaAligerada6Controller =  TextEditingController();
  final TextEditingController _anchoLosaAligerada6Controller =  TextEditingController();

  final TextEditingController _descriptionLosaAligerada7Controller =  TextEditingController();
  final TextEditingController _largoLosaAligerada7Controller =  TextEditingController();
  final TextEditingController _anchoLosaAligerada7Controller =  TextEditingController();

  @override
  Widget build(BuildContext context) {

    final currentFilter = ref.watch(todoCurrentFilterProvider);
    ref.watch(losaAigeradaResultProvider);
    final addLosaAligerada1 = ref.watch(addLosaAligerada1Provider);
    final addLosaAligerada2 = ref.watch(addLosaAligerada2Provider);
    final addLosaAligerada3 = ref.watch(addLosaAligerada3Provider);
    final addLosaAligerada4 = ref.watch(addLosaAligerada4Provider);
    final addLosaAligerada5 = ref.watch(addLosaAligerada5Provider);
    final addLosaAligerada6 = ref.watch(addLosaAligerada6Provider);
    final addLosaAligerada7 = ref.watch(addLosaAligerada7Provider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const AppBarWidget(titleAppBar: 'Losa Aligerada',),
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
                                ButtonSegment(value: FilterType.all, icon: Text('17')),
                                ButtonSegment(value: FilterType.completed, icon: Text('20')),
                                ButtonSegment(value: FilterType.pending, icon: Text('25')),
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
                        formKey: _formKeyDescriptionLosaAligerada1, description: 'Descripción' ,controller: _descriptionLosaAligerada1Controller, hintText: 'ej. Paño 1', isKeyboardText: true,),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyLargoLosaAligerada1, description: 'Largo' ,controller: _largoLosaAligerada1Controller, hintText: 'metros',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAnchoLosaAligerada1, description: 'Ancho' ,controller: _anchoLosaAligerada1Controller, hintText: 'metros',),),
                    Visibility(
                      visible: addLosaAligerada1,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(addLosaAligerada1Provider.notifier).toggleAddLosaAligerada();
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
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaAligerada2, formKey2: _formKeyLargoLosaAligerada2, formKey3: _formKeyAnchoLosaAligerada2, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaAligerada1, titleMaterial: 'Losa 2', firstTextController: _descriptionLosaAligerada2Controller, secondTextController: _largoLosaAligerada2Controller, thirdTextController: _anchoLosaAligerada2Controller, firstHintText: 'ej. Paño 2', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaAligerada2, pressed: () => ref.read(addLosaAligerada2Provider.notifier).toggleAddLosaAligerada(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaAligerada1Provider.notifier).toggleAddLosaAligerada();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaAligerada3, formKey2: _formKeyLargoLosaAligerada3, formKey3: _formKeyAnchoLosaAligerada3, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaAligerada2, titleMaterial: 'Losa 3', firstTextController: _descriptionLosaAligerada3Controller, secondTextController: _largoLosaAligerada3Controller, thirdTextController: _anchoLosaAligerada3Controller, firstHintText: 'ej. Paño 3', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaAligerada3, pressed: () => ref.read(addLosaAligerada3Provider.notifier).toggleAddLosaAligerada(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaAligerada2Provider.notifier).toggleAddLosaAligerada();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaAligerada4, formKey2: _formKeyLargoLosaAligerada4, formKey3: _formKeyAnchoLosaAligerada4, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaAligerada3, titleMaterial: 'Losa 4', firstTextController: _descriptionLosaAligerada4Controller, secondTextController: _largoLosaAligerada4Controller, thirdTextController: _anchoLosaAligerada4Controller, firstHintText: 'ej. Paño 4', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaAligerada4, pressed: () => ref.read(addLosaAligerada4Provider.notifier).toggleAddLosaAligerada(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaAligerada3Provider.notifier).toggleAddLosaAligerada();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaAligerada5, formKey2: _formKeyLargoLosaAligerada5, formKey3: _formKeyAnchoLosaAligerada5, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaAligerada4, titleMaterial: 'Losa 5', firstTextController: _descriptionLosaAligerada5Controller, secondTextController: _largoLosaAligerada5Controller, thirdTextController: _anchoLosaAligerada5Controller, firstHintText: 'ej. Paño 5', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaAligerada5, pressed: () => ref.read(addLosaAligerada5Provider.notifier).toggleAddLosaAligerada(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaAligerada4Provider.notifier).toggleAddLosaAligerada();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaAligerada6, formKey2: _formKeyLargoLosaAligerada6, formKey3: _formKeyAnchoLosaAligerada6, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaAligerada5, titleMaterial: 'Losa 6', firstTextController: _descriptionLosaAligerada6Controller, secondTextController: _largoLosaAligerada6Controller, thirdTextController: _anchoLosaAligerada6Controller, firstHintText: 'ej. Paño 6', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaAligerada6, pressed: () => ref.read(addLosaAligerada6Provider.notifier).toggleAddLosaAligerada(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaAligerada5Provider.notifier).toggleAddLosaAligerada();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionLosaAligerada7, formKey2: _formKeyLargoLosaAligerada7, formKey3: _formKeyAnchoLosaAligerada7, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addLosaAligerada6, titleMaterial: 'Losa 7', firstTextController: _descriptionLosaAligerada7Controller, secondTextController: _largoLosaAligerada7Controller, thirdTextController: _anchoLosaAligerada7Controller, firstHintText: 'ej. Paño 7', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addLosaAligerada7, pressed: () => ref.read(addLosaAligerada7Provider.notifier).toggleAddLosaAligerada(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addLosaAligerada6Provider.notifier).toggleAddLosaAligerada();},),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                final FormState formDescription1 = _formKeyDescriptionLosaAligerada1.currentState!;
                final FormState formLargo1 = _formKeyLargoLosaAligerada1.currentState!;
                final FormState formAncho1 = _formKeyAnchoLosaAligerada1.currentState!;

                var datosLosaAligerada = ref.read(losaAigeradaResultProvider.notifier);

                if (formDescription1.validate() && formLargo1.validate() && formAncho1.validate()) {
                  datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada1Controller.text, _largoLosaAligerada1Controller.text, _anchoLosaAligerada1Controller.text, '17');
                  if (addLosaAligerada1) {
                    context.pushNamed('losas-macizas');
                  } else {
                    ref.read(losaAigeradaResultProvider.notifier).clearList();
                    final FormState formDescription2 = _formKeyDescriptionLosaAligerada2.currentState!;
                    final FormState formLargo2 = _formKeyLargoLosaAligerada2.currentState!;
                    final FormState formAncho2 = _formKeyAnchoLosaAligerada2.currentState!;

                    if (formDescription2.validate() && formLargo2.validate() && formAncho2.validate()) {
                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada1Controller.text, _largoLosaAligerada1Controller.text, _anchoLosaAligerada1Controller.text, '17');
                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada2Controller.text, _largoLosaAligerada2Controller.text, _anchoLosaAligerada2Controller.text, '17');
                      if (addLosaAligerada2) {
                        context.pushNamed('losas-macizas');
                      } else {
                        ref.read(losaAigeradaResultProvider.notifier).clearList();
                        final FormState formDescription3 = _formKeyDescriptionLosaAligerada3.currentState!;
                        final FormState formLargo3 = _formKeyLargoLosaAligerada3.currentState!;
                        final FormState formAncho3 = _formKeyAnchoLosaAligerada3.currentState!;

                        if (formDescription3.validate() && formLargo3.validate() && formAncho3.validate()) {
                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada1Controller.text, _largoLosaAligerada1Controller.text, _anchoLosaAligerada1Controller.text, '17');
                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada2Controller.text, _largoLosaAligerada2Controller.text, _anchoLosaAligerada2Controller.text, '17');
                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada3Controller.text, _largoLosaAligerada3Controller.text, _anchoLosaAligerada3Controller.text, '17');
                          if (addLosaAligerada3) {
                            context.pushNamed('losas-macizas');
                          } else {
                            ref.read(losaAigeradaResultProvider.notifier).clearList();
                            final FormState formDescription4 = _formKeyDescriptionLosaAligerada4.currentState!;
                            final FormState formLargo4 = _formKeyLargoLosaAligerada4.currentState!;
                            final FormState formAncho4 = _formKeyAnchoLosaAligerada4.currentState!;
                            if (formDescription4.validate() && formLargo4.validate() && formAncho4.validate()) {
                              datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada1Controller.text, _largoLosaAligerada1Controller.text, _anchoLosaAligerada1Controller.text, '17');
                              datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada2Controller.text, _largoLosaAligerada2Controller.text, _anchoLosaAligerada2Controller.text, '17');
                              datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada3Controller.text, _largoLosaAligerada3Controller.text, _anchoLosaAligerada3Controller.text, '17');
                              datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada4Controller.text, _largoLosaAligerada4Controller.text, _anchoLosaAligerada4Controller.text, '17');
                              if (addLosaAligerada4) {
                                context.pushNamed('losas-macizas');
                              } else {
                                ref.read(losaAigeradaResultProvider.notifier).clearList();
                                final FormState formDescription5 = _formKeyDescriptionLosaAligerada5.currentState!;
                                final FormState formLargo5 = _formKeyLargoLosaAligerada5.currentState!;
                                final FormState formAncho5 = _formKeyAnchoLosaAligerada5.currentState!;
                                if (formDescription5.validate() && formLargo5.validate() && formAncho5.validate()) {
                                  datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada1Controller.text, _largoLosaAligerada1Controller.text, _anchoLosaAligerada1Controller.text, '17');
                                  datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada2Controller.text, _largoLosaAligerada2Controller.text, _anchoLosaAligerada2Controller.text, '17');
                                  datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada3Controller.text, _largoLosaAligerada3Controller.text, _anchoLosaAligerada3Controller.text, '17');
                                  datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada4Controller.text, _largoLosaAligerada4Controller.text, _anchoLosaAligerada4Controller.text, '17');
                                  datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada5Controller.text, _largoLosaAligerada5Controller.text, _anchoLosaAligerada5Controller.text, '17');
                                  if (addLosaAligerada5) {
                                    context.pushNamed('losas-macizas');
                                  } else {
                                    ref.read(losaAigeradaResultProvider.notifier).clearList();
                                    final FormState formDescription6 = _formKeyDescriptionLosaAligerada6.currentState!;
                                    final FormState formLargo6 = _formKeyLargoLosaAligerada6.currentState!;
                                    final FormState formAncho6 = _formKeyAnchoLosaAligerada6.currentState!;
                                    if (formDescription6.validate() && formLargo6.validate() && formAncho6.validate()) {
                                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada1Controller.text, _largoLosaAligerada1Controller.text, _anchoLosaAligerada1Controller.text, '17');
                                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada2Controller.text, _largoLosaAligerada2Controller.text, _anchoLosaAligerada2Controller.text, '17');
                                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada3Controller.text, _largoLosaAligerada3Controller.text, _anchoLosaAligerada3Controller.text, '17');
                                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada4Controller.text, _largoLosaAligerada4Controller.text, _anchoLosaAligerada4Controller.text, '17');
                                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada5Controller.text, _largoLosaAligerada5Controller.text, _anchoLosaAligerada5Controller.text, '17');
                                      datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada6Controller.text, _largoLosaAligerada6Controller.text, _anchoLosaAligerada6Controller.text, '17');
                                      if (addLosaAligerada6) {
                                        context.pushNamed('losas-macizas');
                                      } else {
                                        ref.read(losaAigeradaResultProvider.notifier).clearList();
                                        final FormState formDescription7 = _formKeyDescriptionLosaAligerada7.currentState!;
                                        final FormState formLargo7 = _formKeyLargoLosaAligerada7.currentState!;
                                        final FormState formAncho7 = _formKeyAnchoLosaAligerada7.currentState!;
                                        if (formDescription7.validate() && formLargo7.validate() && formAncho7.validate()) {
                                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada1Controller.text, _largoLosaAligerada1Controller.text, _anchoLosaAligerada1Controller.text, '17');
                                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada2Controller.text, _largoLosaAligerada2Controller.text, _anchoLosaAligerada2Controller.text, '17');
                                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada3Controller.text, _largoLosaAligerada3Controller.text, _anchoLosaAligerada3Controller.text, '17');
                                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada4Controller.text, _largoLosaAligerada4Controller.text, _anchoLosaAligerada4Controller.text, '17');
                                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada5Controller.text, _largoLosaAligerada5Controller.text, _anchoLosaAligerada5Controller.text, '17');
                                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada6Controller.text, _largoLosaAligerada6Controller.text, _anchoLosaAligerada6Controller.text, '17');
                                          datosLosaAligerada.createLosaAligerada(_descriptionLosaAligerada7Controller.text, _largoLosaAligerada7Controller.text, _anchoLosaAligerada7Controller.text, '17');
                                          if (addLosaAligerada7) {
                                            context.pushNamed('losas-macizas');
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