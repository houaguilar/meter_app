

import 'package:flutter/material.dart';

class SuccessDialog {
  static Future<void> show({
    required BuildContext context,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Éxito', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(content, style: const TextStyle(fontSize: 16)),
          actions: <Widget>[
            TextButton(
              onPressed: onConfirm,
              child: Text(confirmText, style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
