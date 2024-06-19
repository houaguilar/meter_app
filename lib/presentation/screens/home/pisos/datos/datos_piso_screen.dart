
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/constants/colors.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/shared/custom_add_four_fields.dart';
import '../../../widgets/widgets.dart';


class DatosPisosScreen extends ConsumerStatefulWidget {
  const DatosPisosScreen({super.key});
  static const String route = 'pisos';

  @override
  ConsumerState<DatosPisosScreen> createState() => _DatosPisosScreenState();
}

class _DatosPisosScreenState extends ConsumerState<DatosPisosScreen> {

  late String piso;

  // GlobalKey
  final GlobalKey<FormState> _formKeyDescriptionPiso1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoPiso1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoPiso1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaPiso1 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionPiso2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoPiso2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoPiso2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaPiso2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionPiso3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoPiso3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoPiso3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaPiso3 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionPiso4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoPiso4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoPiso4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaPiso4 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionPiso5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoPiso5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoPiso5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaPiso5 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionPiso6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoPiso6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoPiso6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaPiso6 = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKeyDescriptionPiso7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLargoPiso7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAnchoPiso7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAlturaPiso7 = GlobalKey<FormState>();

  //textEditingControllers
  final TextEditingController _descriptionPiso1Controller =  TextEditingController();
  final TextEditingController _largoPiso1Controller =  TextEditingController();
  final TextEditingController _anchoPiso1Controller = TextEditingController();
  final TextEditingController _alturaPiso1Controller =  TextEditingController();

  final TextEditingController _descriptionPiso2Controller =  TextEditingController();
  final TextEditingController _largoPiso2Controller =  TextEditingController();
  final TextEditingController _anchoPiso2Controller = TextEditingController();
  final TextEditingController _alturaPiso2Controller =  TextEditingController();

  final TextEditingController _descriptionPiso3Controller =  TextEditingController();
  final TextEditingController _largoPiso3Controller =  TextEditingController();
  final TextEditingController _anchoPiso3Controller = TextEditingController();
  final TextEditingController _alturaPiso3Controller =  TextEditingController();

  final TextEditingController _descriptionPiso4Controller =  TextEditingController();
  final TextEditingController _largoPiso4Controller =  TextEditingController();
  final TextEditingController _anchoPiso4Controller = TextEditingController();
  final TextEditingController _alturaPiso4Controller =  TextEditingController();

  final TextEditingController _descriptionPiso5Controller =  TextEditingController();
  final TextEditingController _largoPiso5Controller =  TextEditingController();
  final TextEditingController _anchoPiso5Controller = TextEditingController();
  final TextEditingController _alturaPiso5Controller =  TextEditingController();

  final TextEditingController _descriptionPiso6Controller =  TextEditingController();
  final TextEditingController _largoPiso6Controller =  TextEditingController();
  final TextEditingController _anchoPiso6Controller = TextEditingController();
  final TextEditingController _alturaPiso6Controller =  TextEditingController();

  final TextEditingController _descriptionPiso7Controller =  TextEditingController();
  final TextEditingController _largoPiso7Controller =  TextEditingController();
  final TextEditingController _anchoPiso7Controller = TextEditingController();
  final TextEditingController _alturaPiso7Controller =  TextEditingController();

  @override
  Widget build(BuildContext context) {

    ref.watch(pisosResultProvider);
    final tipoPiso = ref.watch(tipoPisoProvider);
    final addPiso1 = ref.watch(addPiso1Provider);
    final addPiso2 = ref.watch(addPiso2Provider);
    final addPiso3 = ref.watch(addPiso3Provider);
    final addPiso4 = ref.watch(addPiso4Provider);
    final addPiso5 = ref.watch(addPiso5Provider);
    final addPiso6 = ref.watch(addPiso6Provider);
    final addPiso7 = ref.watch(addPiso7Provider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const AppBarWidget(titleAppBar: 'Datos'),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
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
                        child: const Text("Piso 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
                    ),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyDescriptionPiso1, description: 'Descripción' ,controller: _descriptionPiso1Controller, hintText: 'ej. Muro de la cocina', isKeyboardText: true,),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyLargoPiso1, description: 'Largo' ,controller: _largoPiso1Controller, hintText: 'metros',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAnchoPiso1, description: 'Ancho', controller: _anchoPiso1Controller, hintText: 'ancho',),),
                    SizedBox(
                      child: CommonTextFormField(
                        formKey: _formKeyAlturaPiso1, description: 'Altura' ,controller: _alturaPiso1Controller, hintText: 'metros',),),
                    Visibility(
                      visible: addPiso1,
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.center,
                            child: SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(addPiso1Provider.notifier).toggleAddPiso();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Añadir piso"),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)
                                      )
                                  ),
                                )
                            ),
                          ),
                          const SizedBox(height: 200,)
                        ],
                      ),
                    ),
                    CustomAddFourFields(formKey1: _formKeyDescriptionPiso2, formKey2: _formKeyLargoPiso2, formKey3: _formKeyAnchoPiso2, formKey4: _formKeyAlturaPiso2, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addPiso1, titleMaterial: 'Piso 2', firstTextController: _descriptionPiso2Controller, secondTextController: _largoPiso2Controller, thirdTextController: _anchoPiso2Controller, fourthTextController: _alturaPiso2Controller, firstHintText: 'ej. piso de la cochera', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addPiso2, pressed: () => ref.read(addPiso2Provider.notifier).toggleAddPiso(), nameAddMaterial: 'Agregar Piso', pressedCancel: () { ref.read(addPiso1Provider.notifier).toggleAddPiso(); },),
                    CustomAddFourFields(formKey1: _formKeyDescriptionPiso3, formKey2: _formKeyLargoPiso3, formKey3: _formKeyAnchoPiso3, formKey4: _formKeyAlturaPiso3, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addPiso2, titleMaterial: 'Piso 3', firstTextController: _descriptionPiso3Controller, secondTextController: _largoPiso3Controller, thirdTextController: _anchoPiso3Controller, fourthTextController: _alturaPiso3Controller, firstHintText: 'ej. piso de la cochera', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addPiso3, pressed: () => ref.read(addPiso3Provider.notifier).toggleAddPiso(), nameAddMaterial: 'Agregar Piso', pressedCancel: () { ref.read(addPiso2Provider.notifier).toggleAddPiso(); },),
                    CustomAddFourFields(formKey1: _formKeyDescriptionPiso4, formKey2: _formKeyLargoPiso4, formKey3: _formKeyAnchoPiso4, formKey4: _formKeyAlturaPiso4, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addPiso3, titleMaterial: 'Piso 4', firstTextController: _descriptionPiso4Controller, secondTextController: _largoPiso4Controller, thirdTextController: _anchoPiso4Controller, fourthTextController: _alturaPiso4Controller, firstHintText: 'ej. piso de la cochera', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addPiso4, pressed: () => ref.read(addPiso4Provider.notifier).toggleAddPiso(), nameAddMaterial: 'Agregar Piso', pressedCancel: () { ref.read(addPiso3Provider.notifier).toggleAddPiso(); },),
                    CustomAddFourFields(formKey1: _formKeyDescriptionPiso5, formKey2: _formKeyLargoPiso5, formKey3: _formKeyAnchoPiso5, formKey4: _formKeyAlturaPiso5, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addPiso4, titleMaterial: 'Piso 5', firstTextController: _descriptionPiso5Controller, secondTextController: _largoPiso5Controller, thirdTextController: _anchoPiso5Controller, fourthTextController: _alturaPiso5Controller, firstHintText: 'ej. piso de la cochera', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addPiso5, pressed: () => ref.read(addPiso5Provider.notifier).toggleAddPiso(), nameAddMaterial: 'Agregar Piso', pressedCancel: () { ref.read(addPiso4Provider.notifier).toggleAddPiso(); },),
                    CustomAddFourFields(formKey1: _formKeyDescriptionPiso6, formKey2: _formKeyLargoPiso6, formKey3: _formKeyAnchoPiso6, formKey4: _formKeyAlturaPiso6, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addPiso5, titleMaterial: 'Piso 6', firstTextController: _descriptionPiso6Controller, secondTextController: _largoPiso6Controller, thirdTextController: _anchoPiso6Controller, fourthTextController: _alturaPiso6Controller, firstHintText: 'ej. piso de la cochera', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addPiso6, pressed: () => ref.read(addPiso6Provider.notifier).toggleAddPiso(), nameAddMaterial: 'Agregar Piso', pressedCancel: () { ref.read(addPiso5Provider.notifier).toggleAddPiso(); },),
                    CustomAddFourFields(formKey1: _formKeyDescriptionPiso7, formKey2: _formKeyLargoPiso7, formKey3: _formKeyAnchoPiso7, formKey4: _formKeyAlturaPiso7, firstNameTextController: 'Descripción', secondNameTextController: 'Largo', thirdNameTextController: 'Ancho', fourthNameTextController: 'Altura', visibility: addPiso6, titleMaterial: 'Piso 7', firstTextController: _descriptionPiso7Controller, secondTextController: _largoPiso7Controller, thirdTextController: _anchoPiso7Controller, fourthTextController: _alturaPiso7Controller, firstHintText: 'ej. piso de la cochera', secondHintText: 'metros', thirdHintText: 'metros', fourthHintText: 'metros', buttonVisibility: addPiso7, pressed: () => ref.read(addPiso7Provider.notifier).toggleAddPiso(), nameAddMaterial: 'Agregar Piso', pressedCancel: () { ref.read(addPiso6Provider.notifier).toggleAddPiso(); },),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                final FormState formDescription1 = _formKeyDescriptionPiso1.currentState!;
                final FormState formLargo1 = _formKeyLargoPiso1.currentState!;
                final FormState formAncho1 = _formKeyAnchoPiso1.currentState!;
                final FormState formAltura1 = _formKeyAlturaPiso1.currentState!;

                var datosPiso = ref.read(pisosResultProvider.notifier);
                piso = tipoPiso;

                if (formDescription1.validate() && formLargo1.validate() && formAncho1.validate() && formAltura1.validate()) {
                  datosPiso.createPisos(piso, _descriptionPiso1Controller.text, _largoPiso1Controller.text, _anchoPiso1Controller.text, _alturaPiso1Controller.text);
                  if (addPiso1) {
                    context.pushNamed('pisos_results');
                  } else {
                    ref.read(pisosResultProvider.notifier).clearList();
                    final FormState formDescription2 = _formKeyDescriptionPiso2.currentState!;
                    final FormState formLargo2 = _formKeyLargoPiso2.currentState!;
                    final FormState formAncho2 = _formKeyAnchoPiso2.currentState!;
                    final FormState formAltura2 = _formKeyAlturaPiso2.currentState!;

                    if (formDescription2.validate() && formLargo2.validate() && formAncho2.validate() && formAltura2.validate()) {
                      datosPiso.createPisos(piso, _descriptionPiso1Controller.text, _largoPiso1Controller.text, _anchoPiso1Controller.text, _alturaPiso1Controller.text);
                      datosPiso.createPisos(piso, _descriptionPiso2Controller.text, _largoPiso2Controller.text, _anchoPiso2Controller.text, _alturaPiso2Controller.text);
                      if (addPiso2) {
                        context.pushNamed('pisos_results');
                      } else {
                        ref.read(pisosResultProvider.notifier).clearList();
                        final FormState formDescription3 = _formKeyDescriptionPiso3.currentState!;
                        final FormState formLargo3 = _formKeyLargoPiso3.currentState!;
                        final FormState formAncho3 = _formKeyAnchoPiso3.currentState!;
                        final FormState formAltura3 = _formKeyAlturaPiso3.currentState!;

                        if (formDescription3.validate() && formLargo3.validate() && formAncho3.validate() && formAltura3.validate()) {
                          datosPiso.createPisos(piso, _descriptionPiso1Controller.text, _largoPiso1Controller.text, _anchoPiso1Controller.text, _alturaPiso1Controller.text);
                          datosPiso.createPisos(piso, _descriptionPiso2Controller.text, _largoPiso2Controller.text, _anchoPiso2Controller.text, _alturaPiso2Controller.text);
                          datosPiso.createPisos(piso, _descriptionPiso3Controller.text, _largoPiso3Controller.text, _anchoPiso3Controller.text, _alturaPiso3Controller.text);
                          if (addPiso3) {
                            context.pushNamed('pisos_results');
                          } else {
                            ref.read(pisosResultProvider.notifier).clearList();
                            final FormState formDescription4 = _formKeyDescriptionPiso4.currentState!;
                            final FormState formLargo4 = _formKeyLargoPiso4.currentState!;
                            final FormState formAncho4 = _formKeyAnchoPiso4.currentState!;
                            final FormState formAltura4 = _formKeyAlturaPiso4.currentState!;
                            if (formDescription4.validate() && formLargo4.validate() && formAncho4.validate() && formAltura4.validate()) {
                              datosPiso.createPisos(piso, _descriptionPiso1Controller.text, _largoPiso1Controller.text, _anchoPiso1Controller.text, _alturaPiso1Controller.text);
                              datosPiso.createPisos(piso, _descriptionPiso2Controller.text, _largoPiso2Controller.text, _anchoPiso2Controller.text, _alturaPiso2Controller.text);
                              datosPiso.createPisos(piso, _descriptionPiso3Controller.text, _largoPiso3Controller.text, _anchoPiso3Controller.text, _alturaPiso3Controller.text);
                              datosPiso.createPisos(piso, _descriptionPiso4Controller.text, _largoPiso4Controller.text, _anchoPiso4Controller.text, _alturaPiso4Controller.text);
                              if (addPiso4) {
                                context.pushNamed('pisos_results');
                              } else {
                                ref.read(pisosResultProvider.notifier).clearList();
                                final FormState formDescription5 = _formKeyDescriptionPiso5.currentState!;
                                final FormState formLargo5 = _formKeyLargoPiso5.currentState!;
                                final FormState formAncho5 = _formKeyAnchoPiso5.currentState!;
                                final FormState formAltura5 = _formKeyAlturaPiso5.currentState!;
                                if (formDescription5.validate() && formLargo5.validate() && formAncho5.validate() && formAltura5.validate()) {
                                  datosPiso.createPisos(piso, _descriptionPiso1Controller.text, _largoPiso1Controller.text, _anchoPiso1Controller.text, _alturaPiso1Controller.text);
                                  datosPiso.createPisos(piso, _descriptionPiso2Controller.text, _largoPiso2Controller.text, _anchoPiso2Controller.text, _alturaPiso2Controller.text);
                                  datosPiso.createPisos(piso, _descriptionPiso3Controller.text, _largoPiso3Controller.text, _anchoPiso3Controller.text, _alturaPiso3Controller.text);
                                  datosPiso.createPisos(piso, _descriptionPiso4Controller.text, _largoPiso4Controller.text, _anchoPiso4Controller.text, _alturaPiso4Controller.text);
                                  datosPiso.createPisos(piso, _descriptionPiso5Controller.text, _largoPiso5Controller.text, _anchoPiso5Controller.text, _alturaPiso5Controller.text);
                                  if (addPiso5) {
                                    context.pushNamed('pisos_results');
                                  } else {
                                    ref.read(pisosResultProvider.notifier).clearList();
                                    final FormState formDescription6 = _formKeyDescriptionPiso6.currentState!;
                                    final FormState formLargo6 = _formKeyLargoPiso6.currentState!;
                                    final FormState formAncho6 = _formKeyAnchoPiso6.currentState!;
                                    final FormState formAltura6 = _formKeyAlturaPiso6.currentState!;
                                    if (formDescription6.validate() && formLargo6.validate() && formAncho6.validate() && formAltura6.validate()) {
                                      datosPiso.createPisos(piso, _descriptionPiso1Controller.text, _largoPiso1Controller.text, _anchoPiso1Controller.text, _alturaPiso1Controller.text);
                                      datosPiso.createPisos(piso, _descriptionPiso2Controller.text, _largoPiso2Controller.text, _anchoPiso2Controller.text, _alturaPiso2Controller.text);
                                      datosPiso.createPisos(piso, _descriptionPiso3Controller.text, _largoPiso3Controller.text, _anchoPiso3Controller.text, _alturaPiso3Controller.text);
                                      datosPiso.createPisos(piso, _descriptionPiso4Controller.text, _largoPiso4Controller.text, _anchoPiso4Controller.text, _alturaPiso4Controller.text);
                                      datosPiso.createPisos(piso, _descriptionPiso5Controller.text, _largoPiso5Controller.text, _anchoPiso5Controller.text, _alturaPiso5Controller.text);
                                      datosPiso.createPisos(piso, _descriptionPiso6Controller.text, _largoPiso6Controller.text, _anchoPiso6Controller.text, _alturaPiso6Controller.text);
                                      if (addPiso6) {
                                        context.pushNamed('pisos_results');
                                      } else {
                                        ref.read(pisosResultProvider.notifier).clearList();
                                        final FormState formDescription7 = _formKeyDescriptionPiso7.currentState!;
                                        final FormState formLargo7 = _formKeyLargoPiso7.currentState!;
                                        final FormState formAncho7 = _formKeyAnchoPiso7.currentState!;
                                        final FormState formAltura7 = _formKeyAlturaPiso7.currentState!;
                                        if (formDescription7.validate() && formLargo7.validate() && formAncho7.validate() && formAltura7.validate()) {
                                          datosPiso.createPisos(piso, _descriptionPiso1Controller.text, _largoPiso1Controller.text, _anchoPiso1Controller.text, _alturaPiso1Controller.text);
                                          datosPiso.createPisos(piso, _descriptionPiso2Controller.text, _largoPiso2Controller.text, _anchoPiso2Controller.text, _alturaPiso2Controller.text);
                                          datosPiso.createPisos(piso, _descriptionPiso3Controller.text, _largoPiso3Controller.text, _anchoPiso3Controller.text, _alturaPiso3Controller.text);
                                          datosPiso.createPisos(piso, _descriptionPiso4Controller.text, _largoPiso4Controller.text, _anchoPiso4Controller.text, _alturaPiso4Controller.text);
                                          datosPiso.createPisos(piso, _descriptionPiso5Controller.text, _largoPiso5Controller.text, _anchoPiso5Controller.text, _alturaPiso5Controller.text);
                                          datosPiso.createPisos(piso, _descriptionPiso6Controller.text, _largoPiso6Controller.text, _anchoPiso6Controller.text, _alturaPiso6Controller.text);
                                          datosPiso.createPisos(piso, _descriptionPiso7Controller.text, _largoPiso7Controller.text, _anchoPiso7Controller.text, _alturaPiso7Controller.text);
                                          if (addPiso7) {
                                            context.pushNamed('pisos_results');
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

/*piso = tipoPiso;
var datosPisos = ref.read(pisosResultProvider.notifier);
void createPisoIfNotEmpty(TextEditingController descriptionController, TextEditingController largoController, TextEditingController alturaController, TextEditingController anchoController ) {
  if (descriptionController.text.isNotEmpty && largoController.text.isNotEmpty && alturaController.text.isNotEmpty && anchoController.text.isNotEmpty) {
    datosPisos.createPisos(piso ,descriptionController.text, largoController.text, anchoController.text, alturaController.text);
  }
}
createPisoIfNotEmpty(_descriptionPiso1Controller, _largoPiso1Controller, _alturaPiso1Controller, _anchoPiso1Controller);
createPisoIfNotEmpty(_descriptionPiso2Controller, _largoPiso2Controller, _alturaPiso2Controller, _anchoPiso2Controller);
createPisoIfNotEmpty(_descriptionPiso3Controller, _largoPiso3Controller, _alturaPiso3Controller, _anchoPiso3Controller);
createPisoIfNotEmpty(_descriptionPiso4Controller, _largoPiso4Controller, _alturaPiso4Controller, _anchoPiso4Controller);
createPisoIfNotEmpty(_descriptionPiso5Controller, _largoPiso5Controller, _alturaPiso5Controller, _anchoPiso5Controller);
createPisoIfNotEmpty(_descriptionPiso6Controller, _largoPiso6Controller, _alturaPiso6Controller, _anchoPiso6Controller);
createPisoIfNotEmpty(_descriptionPiso7Controller, _largoPiso7Controller, _alturaPiso7Controller, _anchoPiso7Controller);
context.pushNamed('pisos_results');*/
