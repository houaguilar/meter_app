
import 'package:flutter/material.dart';

import 'package:meter_app/presentation/styles/button_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // ← Debe tener el ? para ser nullable

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: CustomButtonStyles.elevatedStyle,
      onPressed: onPressed, // Puede ser null
      child: Text(label),
    );
  }
}