
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constants/colors.dart';
import '../../../../providers/providers.dart';
import '../../../../widgets/widgets.dart';

class DatosEscalerasScreen extends ConsumerStatefulWidget {
  const DatosEscalerasScreen({super.key});

  @override
  ConsumerState<DatosEscalerasScreen> createState() => _DatosEscalerasScreenState();
}

class _DatosEscalerasScreenState extends ConsumerState<DatosEscalerasScreen> {

  late String losas;

  // GlobalKey
  final GlobalKey<FormState> _formKeyDescriptionMuro1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoMuro1 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoMuro2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoMuro3 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoMuro4 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoMuro5 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoMuro6 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionMuro7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoMuro7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoMuro7 = GlobalKey<FormState>();

  //textEditingControllers
  final TextEditingController _descriptionMuro1Controller =  TextEditingController();
  final TextEditingController _largoMuro1Controller =  TextEditingController();
  final TextEditingController _anchoMuro1Controller =  TextEditingController();

  final TextEditingController _descriptionMuro2Controller =  TextEditingController();
  final TextEditingController _largoMuro2Controller =  TextEditingController();
  final TextEditingController _anchoMuro2Controller =  TextEditingController();

  final TextEditingController _descriptionMuro3Controller =  TextEditingController();
  final TextEditingController _largoMuro3Controller =  TextEditingController();
  final TextEditingController _anchoMuro3Controller =  TextEditingController();

  final TextEditingController _descriptionMuro4Controller =  TextEditingController();
  final TextEditingController _largoMuro4Controller =  TextEditingController();
  final TextEditingController _anchoMuro4Controller =  TextEditingController();

  final TextEditingController _descriptionMuro5Controller =  TextEditingController();
  final TextEditingController _largoMuro5Controller =  TextEditingController();
  final TextEditingController _anchoMuro5Controller =  TextEditingController();

  final TextEditingController _descriptionMuro6Controller =  TextEditingController();
  final TextEditingController _largoMuro6Controller =  TextEditingController();
  final TextEditingController _anchoMuro6Controller =  TextEditingController();

  final TextEditingController _descriptionMuro7Controller =  TextEditingController();
  final TextEditingController _largoMuro7Controller =  TextEditingController();
  final TextEditingController _anchoMuro7Controller =  TextEditingController();

  @override
  Widget build(BuildContext context) {

    final currentFilter = ref.watch(todoCurrentFilterProvider);
    ref.watch(losaEscalerasResultProvider);
    final tipoBloqueta = ref.watch(tipoBloquetaProvider);
    final addMuro1 = ref.watch(addMuroBloqueta1Provider);
    final addMuro2 = ref.watch(addMuroBloqueta2Provider);
    final addMuro3 = ref.watch(addMuroBloqueta3Provider);
    final addMuro4 = ref.watch(addMuroBloqueta4Provider);
    final addMuro5 = ref.watch(addMuroBloqueta5Provider);
    final addMuro6 = ref.watch(addMuroBloqueta6Provider);
    final addMuro7 = ref.watch(addMuroBloqueta7Provider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBarWidget(titleAppBar: 'Losa Aligerada',),
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
                        formKey: _formKeyDescriptionMuro1, description: 'Descripción' ,controller: _descriptionMuro1Controller, hintText: 'ej. Losa de la cocina', isKeyboardText: true,),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyLargoMuro1, description: 'Largo' ,controller: _largoMuro1Controller, hintText: 'metros',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAnchoMuro1, description: 'Ancho' ,controller: _anchoMuro1Controller, hintText: 'metros',),),
                    Visibility(
                      visible: addMuro1,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(addMuroBloqueta1Provider.notifier).toggleAddMuro();
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
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro2, formKey2: _formKeyLargoMuro2, formKey3: _formKeyAnchoMuro2, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addMuro1, titleMaterial: "Muro 2", firstTextController: _descriptionMuro2Controller, secondTextController: _largoMuro2Controller, thirdTextController: _anchoMuro2Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro2, pressed: () => ref.read(addMuroBloqueta2Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addMuroBloqueta1Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro3, formKey2: _formKeyLargoMuro3, formKey3: _formKeyAnchoMuro3, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addMuro2, titleMaterial: "Muro 3", firstTextController: _descriptionMuro3Controller, secondTextController: _largoMuro3Controller, thirdTextController: _anchoMuro3Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro3, pressed: () => ref.read(addMuroBloqueta3Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addMuroBloqueta2Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro4, formKey2: _formKeyLargoMuro4, formKey3: _formKeyAnchoMuro4, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addMuro3, titleMaterial: "Muro 4", firstTextController: _descriptionMuro4Controller, secondTextController: _largoMuro4Controller, thirdTextController: _anchoMuro4Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro4, pressed: () => ref.read(addMuroBloqueta4Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addMuroBloqueta3Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro5, formKey2: _formKeyLargoMuro5, formKey3: _formKeyAnchoMuro5, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addMuro4, titleMaterial: "Muro 5", firstTextController: _descriptionMuro5Controller, secondTextController: _largoMuro5Controller, thirdTextController: _anchoMuro5Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro5, pressed: () => ref.read(addMuroBloqueta5Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addMuroBloqueta4Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro6, formKey2: _formKeyLargoMuro6, formKey3: _formKeyAnchoMuro6, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addMuro5, titleMaterial: "Muro 6", firstTextController: _descriptionMuro6Controller, secondTextController: _largoMuro6Controller, thirdTextController: _anchoMuro6Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro6, pressed: () => ref.read(addMuroBloqueta6Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addMuroBloqueta5Provider.notifier).toggleAddMuro();},),
                    CustomAddThreeFields(formKey1: _formKeyDescriptionMuro7, formKey2: _formKeyLargoMuro7, formKey3: _formKeyAnchoMuro7, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', visibility: addMuro6, titleMaterial: "Muro 7", firstTextController: _descriptionMuro7Controller, secondTextController: _largoMuro7Controller, thirdTextController: _anchoMuro7Controller, firstHintText: 'ej. losa de la cocina', secondHintText: 'metros', thirdHintText: 'metros', buttonVisibility: addMuro7, pressed: () => ref.read(addMuroBloqueta7Provider.notifier).toggleAddMuro(), nameAddMaterial: 'Agregar Losa', pressedCancel: () { ref.read(addMuroBloqueta6Provider.notifier).toggleAddMuro();},),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                /*final FormState formDescription1 = _formKeyDescriptionMuro1.currentState!;
                final FormState formLargo1 = _formKeyLargoMuro1.currentState!;
                final FormState formAltura1 = _formKeyAnchoMuro1.currentState!;

                var datosBloqueta = ref.read(bloquetaResultProvider.notifier);
                losas = tipoBloqueta;

                if (formDescription1.validate() && formLargo1.validate() && formAltura1.validate()) {
                  datosBloqueta.createBloqueta(_descriptionMuro1Controller.text, losas, _largoMuro1Controller.text, _anchoMuro1Controller.text);
                  if (addMuro1) {
                    context.pushNamed('bloqueta_results');
                  } else {
                    ref.read(bloquetaResultProvider.notifier).clearList();
                    final FormState formDescription2 = _formKeyDescriptionMuro2.currentState!;
                    final FormState formLargo2 = _formKeyLargoMuro2.currentState!;
                    final FormState formAltura2 = _formKeyAnchoMuro2.currentState!;

                    if (formDescription2.validate() && formLargo2.validate() && formAltura2.validate()) {
                      datosBloqueta.createBloqueta(_descriptionMuro1Controller.text, losas, _largoMuro1Controller.text, _anchoMuro1Controller.text);
                      datosBloqueta.createBloqueta(_descriptionMuro2Controller.text, losas, _largoMuro2Controller.text, _anchoMuro2Controller.text);
                      if (addMuro2) {
                        context.pushNamed('bloqueta_results');
                      } else {
                        ref.read(bloquetaResultProvider.notifier).clearList();
                        final FormState formDescription3 = _formKeyDescriptionMuro3.currentState!;
                        final FormState formLargo3 = _formKeyLargoMuro3.currentState!;
                        final FormState formAltura3 = _formKeyAnchoMuro3.currentState!;

                        if (formDescription3.validate() && formLargo3.validate() && formAltura3.validate()) {
                          datosBloqueta.createBloqueta(_descriptionMuro1Controller.text, losas, _largoMuro1Controller.text, _anchoMuro1Controller.text);
                          datosBloqueta.createBloqueta(_descriptionMuro2Controller.text, losas, _largoMuro2Controller.text, _anchoMuro2Controller.text);
                          datosBloqueta.createBloqueta(_descriptionMuro3Controller.text, losas, _largoMuro3Controller.text, _anchoMuro3Controller.text);
                          if (addMuro3) {
                            context.pushNamed('bloqueta_results');
                          } else {
                            ref.read(bloquetaResultProvider.notifier).clearList();
                            final FormState formDescription4 = _formKeyDescriptionMuro4.currentState!;
                            final FormState formLargo4 = _formKeyLargoMuro4.currentState!;
                            final FormState formAltura4 = _formKeyAnchoMuro4.currentState!;
                            if (formDescription4.validate() && formLargo4.validate() && formAltura4.validate()) {
                              datosBloqueta.createBloqueta(_descriptionMuro1Controller.text, losas, _largoMuro1Controller.text, _anchoMuro1Controller.text);
                              datosBloqueta.createBloqueta(_descriptionMuro2Controller.text, losas, _largoMuro2Controller.text, _anchoMuro2Controller.text);
                              datosBloqueta.createBloqueta(_descriptionMuro3Controller.text, losas, _largoMuro3Controller.text, _anchoMuro3Controller.text);
                              datosBloqueta.createBloqueta(_descriptionMuro4Controller.text, losas, _largoMuro4Controller.text, _anchoMuro4Controller.text);
                              if (addMuro4) {
                                context.pushNamed('bloqueta_results');
                              } else {
                                ref.read(bloquetaResultProvider.notifier).clearList();
                                final FormState formDescription5 = _formKeyDescriptionMuro5.currentState!;
                                final FormState formLargo5 = _formKeyLargoMuro5.currentState!;
                                final FormState formAltura5 = _formKeyAnchoMuro5.currentState!;
                                if (formDescription5.validate() && formLargo5.validate() && formAltura5.validate()) {
                                  datosBloqueta.createBloqueta(_descriptionMuro1Controller.text, losas, _largoMuro1Controller.text, _anchoMuro1Controller.text);
                                  datosBloqueta.createBloqueta(_descriptionMuro2Controller.text, losas, _largoMuro2Controller.text, _anchoMuro2Controller.text);
                                  datosBloqueta.createBloqueta(_descriptionMuro3Controller.text, losas, _largoMuro3Controller.text, _anchoMuro3Controller.text);
                                  datosBloqueta.createBloqueta(_descriptionMuro4Controller.text, losas, _largoMuro4Controller.text, _anchoMuro4Controller.text);
                                  datosBloqueta.createBloqueta(_descriptionMuro5Controller.text, losas, _largoMuro5Controller.text, _anchoMuro5Controller.text);
                                  if (addMuro5) {
                                    context.pushNamed('bloqueta_results');
                                  } else {
                                    ref.read(bloquetaResultProvider.notifier).clearList();
                                    final FormState formDescription6 = _formKeyDescriptionMuro6.currentState!;
                                    final FormState formLargo6 = _formKeyLargoMuro6.currentState!;
                                    final FormState formAltura6 = _formKeyAnchoMuro6.currentState!;
                                    if (formDescription6.validate() && formLargo6.validate() && formAltura6.validate()) {
                                      datosBloqueta.createBloqueta(_descriptionMuro1Controller.text, losas, _largoMuro1Controller.text, _anchoMuro1Controller.text);
                                      datosBloqueta.createBloqueta(_descriptionMuro2Controller.text, losas, _largoMuro2Controller.text, _anchoMuro2Controller.text);
                                      datosBloqueta.createBloqueta(_descriptionMuro3Controller.text, losas, _largoMuro3Controller.text, _anchoMuro3Controller.text);
                                      datosBloqueta.createBloqueta(_descriptionMuro4Controller.text, losas, _largoMuro4Controller.text, _anchoMuro4Controller.text);
                                      datosBloqueta.createBloqueta(_descriptionMuro5Controller.text, losas, _largoMuro5Controller.text, _anchoMuro5Controller.text);
                                      datosBloqueta.createBloqueta(_descriptionMuro6Controller.text, losas, _largoMuro6Controller.text, _anchoMuro6Controller.text);
                                      if (addMuro6) {
                                        context.pushNamed('bloqueta_results');
                                      } else {
                                        ref.read(bloquetaResultProvider.notifier).clearList();
                                        final FormState formDescription7 = _formKeyDescriptionMuro7.currentState!;
                                        final FormState formLargo7 = _formKeyLargoMuro7.currentState!;
                                        final FormState formAltura7 = _formKeyAnchoMuro7.currentState!;
                                        if (formDescription7.validate() && formLargo7.validate() && formAltura7.validate()) {
                                          datosBloqueta.createBloqueta(_descriptionMuro1Controller.text, losas, _largoMuro1Controller.text, _anchoMuro1Controller.text);
                                          datosBloqueta.createBloqueta(_descriptionMuro2Controller.text, losas, _largoMuro2Controller.text, _anchoMuro2Controller.text);
                                          datosBloqueta.createBloqueta(_descriptionMuro3Controller.text, losas, _largoMuro3Controller.text, _anchoMuro3Controller.text);
                                          datosBloqueta.createBloqueta(_descriptionMuro4Controller.text, losas, _largoMuro4Controller.text, _anchoMuro4Controller.text);
                                          datosBloqueta.createBloqueta(_descriptionMuro5Controller.text, losas, _largoMuro5Controller.text, _anchoMuro5Controller.text);
                                          datosBloqueta.createBloqueta(_descriptionMuro6Controller.text, losas, _largoMuro6Controller.text, _anchoMuro6Controller.text);
                                          datosBloqueta.createBloqueta(_descriptionMuro7Controller.text, losas, _largoMuro7Controller.text, _anchoMuro7Controller.text);
                                          if (addMuro7) {
                                            context.pushNamed('bloqueta_results');
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
                }*/
              },
              color: AppColors.orange,
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