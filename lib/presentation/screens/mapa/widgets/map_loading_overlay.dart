// lib/presentation/screens/mapa/widgets/map_loading_overlay.dart
import 'package:flutter/material.dart';
import '../../../../config/theme/theme.dart';

class MapLoadingOverlay extends StatelessWidget {
  const MapLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando mapa...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
