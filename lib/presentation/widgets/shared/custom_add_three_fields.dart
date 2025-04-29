import 'package:flutter/material.dart';

import '../widgets.dart';


class CustomAddThreeFields extends StatelessWidget {
  const CustomAddThreeFields({
    super.key,
    required this.formKey1,
    required this.formKey2,
    required this.formKey3,
    required this.firstNameTextController,
    required this.secondNameTextController,
    required this.thirdNameTextController,
    required this.visibility,
    required this.titleMaterial,
    required this.firstTextController,
    required this.secondTextController,
    required this.thirdTextController,
    required this.firstHintText,
    required this.secondHintText,
    required this.thirdHintText,
    required this.buttonVisibility,
    required this.pressed,
    required this.nameAddMaterial,
    required this.pressedCancel,
  });

  final GlobalKey<FormState> formKey1;
  final GlobalKey<FormState> formKey2;
  final GlobalKey<FormState> formKey3;
  final String firstNameTextController;
  final String secondNameTextController;
  final String thirdNameTextController;
  final bool visibility;
  final String titleMaterial;
  final TextEditingController firstTextController;
  final TextEditingController secondTextController;
  final TextEditingController thirdTextController;
  final String firstHintText;
  final String secondHintText;
  final String thirdHintText;
  final bool buttonVisibility;
  final VoidCallback pressed;
  final String nameAddMaterial;
  final VoidCallback pressedCancel;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: !visibility,
        child: Column(
          children: [
            const SizedBox(height: 20,),
            const Divider(height: 2,),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: SizedBox()),
                Container(
                    alignment: AlignmentDirectional.center,
                    padding: const EdgeInsets.all(10),
                    child: Text(titleMaterial, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
                ),
                Expanded(child: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                    child: ElevatedButton.icon(
                        onPressed: pressedCancel,
                        icon: const Icon(Icons.cancel_rounded),
                        label: const Text(''),
                      style: ButtonStyle(elevation: WidgetStateProperty.all(0)),
                    ),
                  ),
                )),
              ],
            ),
            SizedBox(
              child: CommonTextFormField(
                formKey: formKey1, description: firstNameTextController, controller: firstTextController, hintText: firstHintText, isKeyboardText: true,),),
            SizedBox(
              child: CommonTextFormField(
                formKey: formKey2, description: secondNameTextController, controller: secondTextController, hintText: secondHintText,),),
            SizedBox(
              child: CommonTextFormField(
                formKey: formKey3, description: thirdNameTextController, controller: thirdTextController, hintText: thirdHintText,),),
            Visibility(
              visible: buttonVisibility,
              child: Column(
                children: [
                  SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: pressed,
                        icon: const Icon(Icons.add),
                        label: Text(nameAddMaterial),
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
