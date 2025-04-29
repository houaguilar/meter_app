
import 'package:flutter/material.dart';

import '../../styles/button_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomElevatedButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: CustomButtonStyles.elevatedStyle,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}