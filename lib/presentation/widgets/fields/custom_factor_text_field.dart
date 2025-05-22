import 'package:flutter/material.dart';

import '../../../config/theme/theme.dart';

class CustomFactorTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final String hintText;
  final bool isRequired;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isVisible;

  const CustomFactorTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.hintText,
    this.isRequired = true,
    this.onPressed,
    this.icon,
    this.color,
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMetraShop,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 50,
            child: TextFormField(
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                filled: true,
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
                hintText: hintText,
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
          ),
          const SizedBox(height: 16), // Espacio inferior
        ],
      ),
    );
  }
}
