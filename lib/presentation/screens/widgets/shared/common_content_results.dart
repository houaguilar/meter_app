import 'package:flutter/material.dart';

class CommonContentResults extends StatelessWidget {
  const CommonContentResults({
    super.key,
    required this.descripcion,
    required this.unidad,
    required this.cantidad,
    required this.sizeText,
    required this.weightText,
  });

  final String descripcion;
  final String unidad;
  final String cantidad;
  final double sizeText;
  final FontWeight weightText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 115,
            child: Text(descripcion,
              style: TextStyle(fontSize: sizeText, fontWeight: weightText),
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(unidad,
              style: TextStyle(fontSize: sizeText, fontWeight: weightText),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(cantidad,
              style: TextStyle(fontSize: sizeText, fontWeight: weightText),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}