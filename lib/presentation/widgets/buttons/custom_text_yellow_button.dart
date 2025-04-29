
import 'package:flutter/material.dart';

import '../../styles/button_styles.dart';

class CustomTextYellowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomTextYellowButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: CustomButtonStyles.textYellowStyle,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}