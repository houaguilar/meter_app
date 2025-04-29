import 'package:flutter/material.dart';
import 'package:meter_app/config/constants/colors.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Dibuja el fondo oscuro
    paint.color = AppColors.white; // Fondo color oscuro
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);

    // Dibuja la primera curva (color azul oscuro)
    final path1 = Path();
    path1.lineTo(0, size.height * 0.75);
    path1.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.77,
      size.width * 0.25,
      size.height * 0.4,
    );
   /* path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.5,
    );*/
    path1.lineTo(size.width * 0.25, 0);
    path1.close();

    paint.color = const Color(0xFF043353); // Color azul oscuro
    canvas.drawPath(path1, paint);

    // Dibuja la segunda curva (color amarillo)
    /*final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.65,
      size.width * 0.5,
      size.height * 0.75,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.85,
      size.width,
      size.height * 0.75,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    paint.color = AppColors.white; // Color amarillo
    canvas.drawPath(path2, paint);*/
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
