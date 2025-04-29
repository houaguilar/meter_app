
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_app/presentation/assets/images.dart';

import '../../../config/constants/constants.dart';

class CarouselCards extends StatelessWidget {
  final Function(int) onPageChanged;

  const CarouselCards({super.key, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView(
        onPageChanged: onPageChanged,
        children: [
          _buildCard(
            context,
            title: 'Mediciones',
            description: 'Mide tu espacio y calcula la \ncantidad de material que necesitas.',
            imagePath: AppImages.muroImg,
          ),
          _buildCard(
            context,
            title: 'Materiales',
            description: 'Encuentra los materiales y proveedores que te hacen falta.',
            imagePath: AppImages.materialImg,
          ),
          _buildCard(
            context,
            title: 'Aprendizaje',
            description: 'Tu mejora profesional es \nimportante, sigue aprendiendo.',
            imagePath: AppImages.aprendizajeImg,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24),
      child: Card(
        elevation: 2,
        color: AppColors.cardWelcomeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListTile(
            leading: SvgPicture.asset(imagePath),
            title: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                title,
                style: GoogleFonts.poppins(textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
                )
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                description,
                style: GoogleFonts.poppins(textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 9
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
