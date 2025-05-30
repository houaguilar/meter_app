import 'package:flutter/material.dart';

import '../../config/theme/theme.dart';

class WavePainters extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blueMetraShop.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Primera onda
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.5,
        size.width * 0.5,
        size.height * 0.6
    );
    path.quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.7,
        size.width,
        size.height * 0.6
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Segunda onda (más pequeña)
    final path2 = Path();
    paint.color = AppColors.blueMetraShop.withOpacity(0.2);

    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.65,
        size.width * 0.4,
        size.height * 0.8
    );
    path2.quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.95,
        size.width,
        size.height * 0.8
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}