import 'package:flutter/material.dart';


class CommonTextFormField extends StatelessWidget {
  const CommonTextFormField({super.key, 
    required this.formKey,
    required this.description,
    required this.controller,
    required this.hintText,
    this.isKeyboardText,
  });
  final GlobalKey<FormState> formKey;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final bool? isKeyboardText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: TextFormField(
                  scrollPadding: const EdgeInsets.only(bottom: 300),
                  controller: controller,
                  onChanged: (value) {
                    value = controller.text;
                  },
                  keyboardType: isKeyboardText == true ? TextInputType.text : TextInputType.number ,
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    floatingLabelStyle: const TextStyle(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                      ),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                      ),
                    ),
                    hintText: hintText,
                    hintStyle: const TextStyle(fontSize: 12),
                    hintTextDirection: TextDirection.ltr,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (value.contains('@')) {
                      return 'Please don\'t use the @ char.';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}