import 'package:flutter/material.dart';
import '../../../../../config/theme/theme.dart';
import '../../../../blocs/projects/metrados/combined_results/combined_results_bloc.dart';

/// Modal bottom sheet para seleccionar el formato de compartir
class ShareOptionsModal extends StatelessWidget {
  final Function(ShareFormat) onFormatSelected;

  const ShareOptionsModal({
    super.key,
    required this.onFormatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Compartir Resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOptionTile(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  onFormatSelected(ShareFormat.pdf);
                },
              ),
              _ShareOptionTile(
                icon: Icons.text_fields,
                label: 'Texto',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  onFormatSelected(ShareFormat.text);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Widget individual para cada opción de compartir
class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
