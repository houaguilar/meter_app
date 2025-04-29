import 'package:flutter/material.dart';

import '../widgets.dart';


class CustomAddFloor extends StatelessWidget {
  const CustomAddFloor({
    super.key,
    required this.formKey1,
    required this.formKey2,
    required this.formKey3,
    required this.formKey4,
    required this.visibility,
    required this.piso,
    required this.descriptionController,
    required this.largoController,
    required this.anchoController,
    required this.alturaController,
    required this.buttonVisibility,
    required this.pressed,
  });

  final GlobalKey<FormState> formKey1;
  final GlobalKey<FormState> formKey2;
  final GlobalKey<FormState> formKey3;
  final GlobalKey<FormState> formKey4;
  final bool visibility;
  final String piso;
  final TextEditingController descriptionController;
  final TextEditingController largoController;
  final TextEditingController anchoController;
  final TextEditingController alturaController;
  final bool buttonVisibility;
  final VoidCallback pressed;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: !visibility,
        child: Column(
          children: [
            const SizedBox(height: 20,),
            const Divider(height: 2,),
            const SizedBox(height: 10,),
            Container(
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.all(10),
                child: Text(piso, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
            ),
            SizedBox(
              child: CommonTextFormField(
                formKey: formKey1, description: 'Descripción' ,controller: descriptionController, hintText: 'ej. Muro de la cocina', isKeyboardText: true,),),
            SizedBox(
              child: CommonTextFormField(
                formKey: formKey2, description: 'Largo' ,controller: largoController, hintText: 'metros',),),
            SizedBox(
              child: CommonTextFormField(
                formKey: formKey3, description: 'Ancho' ,controller: anchoController, hintText: 'metros',),),
            SizedBox(
              child: CommonTextFormField(
                formKey: formKey4, description: 'Altura' ,controller: alturaController, hintText: 'metros',),),
            Visibility(
              visible: buttonVisibility,
              child: Column(
                children: [
                  SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: pressed,
                        icon: const Icon(Icons.add),
                        label: const Text("Añadir piso"),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            )
                        ),
                      )
                  ),
                  const SizedBox(height: 200,)
                ],
              ),
            ),
            const SizedBox(height: 30,)
          ],
        )
    );
  }
}
