
import 'package:flutter/material.dart';

import '../../styles/button_styles.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomOutlinedButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: CustomButtonStyles.outlinedStyle,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}