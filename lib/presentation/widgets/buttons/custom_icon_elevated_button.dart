
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/presentation/styles/button_styles.dart';

class CustomIconElevatedButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onPressed;

  const CustomIconElevatedButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: CustomButtonStyles.elevatedIconStyle,
      onPressed: onPressed,
      icon: SvgPicture.asset(icon),
      iconAlignment: IconAlignment.end,
      label: Text(label),
    );
  }


}