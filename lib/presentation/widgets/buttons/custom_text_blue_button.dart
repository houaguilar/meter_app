
import 'package:flutter/material.dart';

import '../../styles/button_styles.dart';

class CustomTextBlueButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomTextBlueButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: CustomButtonStyles.textBlueStyle,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}