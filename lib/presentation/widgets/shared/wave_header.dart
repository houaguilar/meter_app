
import 'package:flutter/material.dart';

import '../../painters/wave_painter.dart';

class WaveHeader extends StatelessWidget {
  final double height;

  const WaveHeader({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: WavePainter(),
      ),
    );
  }
}
