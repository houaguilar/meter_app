
import 'package:flutter/material.dart';

import '../../../config/constants/colors.dart';
import '../../painters/wave_painter.dart';

class WaveHeader extends StatelessWidget {
  final double height;
  final Color color;

  const WaveHeader({
    Key? key,
    required this.height,
    this.color = AppColors.primaryMetraShop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
      ),
      child: CustomPaint(
        painter: WavePainter(),
        size: Size(double.infinity, height),
      ),
    );
  }
}
