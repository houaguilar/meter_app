import 'package:flutter/material.dart';
import 'package:meter_app/config/constants/colors.dart';

import '../../../config/theme/theme.dart';

class CustomDosageField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String labelText;
  final bool isRequired;

  const CustomDosageField({
    super.key,
    required this.controller,
    required this.validator,
    required this.labelText,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
          decoration: InputDecoration(
            filled: true,
            labelText: labelText,
            floatingLabelStyle: WidgetStateTextStyle.resolveWith( (states) {
              final Color color = states.contains(WidgetState.error)
                  ? Theme.of(context).colorScheme.error
                  : AppColors.primaryMetraShop;
              return TextStyle(color: color, letterSpacing: 1.3);
            }),
            fillColor: AppColors.white, // Fondo blanco
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
              borderSide: BorderSide(
                color: Colors.grey.shade300, // Color del borde
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.borderTextFormFieldColor, // Color al estar enfocado
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red, // Color al haber error
                width: 1,
              ),
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 16, // Tamaño de la fuente del texto
            color: AppColors.primaryMetraShop,
          ),
        ),
        const SizedBox(height: 16), // Espacio inferior
      ],
    );
  }
}
