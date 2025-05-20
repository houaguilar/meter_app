// lib/presentation/widgets/cards/structural_element_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/constants/constants.dart';
import '../../../domain/entities/home/estructuras/structural_element.dart';
import '../bottom_sheet/structural_element_detail_sheet.dart';

class StructuralElementCard extends StatelessWidget {
  final StructuralElement element;
  final VoidCallback onTap;

  const StructuralElementCard({super.key, required this.element, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  SvgPicture.asset(element.image, fit: BoxFit.fill, height: 70, width: 70,),
                  const SizedBox(height: 5,),
                  Text(element.name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMetraShop
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showElementDetails(BuildContext context, StructuralElement element) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return StructuralElementDetailSheet(element: element, scrollController: scrollController);
        },
      ),
    );
  }
}