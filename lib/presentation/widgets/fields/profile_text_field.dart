
import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final bool obscureText;

  const ProfileTextField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        initialValue: initialValue,
        onChanged: onChanged,
        obscureText: obscureText,
      ),
    );
  }
}
