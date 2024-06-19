import 'package:flutter/material.dart';

class OptionsDialog extends StatelessWidget {
  final List<DialogOption> options;

  const OptionsDialog({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return Column(
            children: [
              _buildDialogOption(
                context,
                icon: option.icon,
                text: option.text,
                onTap: option.onTap,
              ),
              if (option != options.last) const Divider(height: 1, color: Colors.grey),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDialogOption(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogOption {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  DialogOption({required this.icon, required this.text, required this.onTap});
}
