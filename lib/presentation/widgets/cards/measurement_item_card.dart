import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/config/assets/app_icons.dart';

import '../../../config/theme/theme.dart';

class MeasurementItemCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  const MeasurementItemCard({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 3,
        shadowColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.white,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Imagen con fondo mejorado
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white,
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(0),
                    child: _buildImage(imageAsset),
                  ),
                  const SizedBox(width: 16),
                  // Contenido expandido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Icono de navegación mejorado
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.blueMetraShop.withOpacity(0.12),
                          AppColors.blueMetraShop.withOpacity(0.18),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      AppIcons.chevronCircleRightIcon,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    // Auto-detectar si es SVG o PNG
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
      );
    }
  }
}