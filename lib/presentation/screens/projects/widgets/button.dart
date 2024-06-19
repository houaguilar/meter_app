import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final Function onPressed;

  const ButtonWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50.0),
        FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => onPressed(),
          icon: const Icon(Icons.save_alt_rounded),
          label: const Text("Guardar"),
        ),
      ],
    );
  }
}