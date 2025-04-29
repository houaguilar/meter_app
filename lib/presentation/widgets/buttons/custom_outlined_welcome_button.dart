

import 'package:flutter/material.dart';

import '../../styles/button_styles.dart';

class CustomOutlinedWelcomeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomOutlinedWelcomeButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: CustomButtonStyles.outlinedWelcomeStyle,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}