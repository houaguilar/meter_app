
import 'package:flutter/material.dart';

import '../../styles/button_styles.dart';

class CustomIconOutlinedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomIconOutlinedButton({super.key, 
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: CustomButtonStyles.outlinedIconStyle,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.blue),
      label: Text(label),
    );
  }
}