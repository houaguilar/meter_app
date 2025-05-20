
import 'package:flutter/material.dart';
import 'package:meter_app/config/constants/colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;

  const SectionTitle({
    Key? key,
    required this.title,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
    this.textColor = AppColors.primaryMetraShop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          width: 40.0,
          height: 3.0,
          decoration: BoxDecoration(
            color: AppColors.blueMetraShop,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}