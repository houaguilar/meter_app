// lib/presentation/widgets/bottom_sheet/structural_element_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/constants/constants.dart';
import '../../../domain/entities/home/estructuras/structural_element.dart';

class StructuralElementDetailSheet extends StatelessWidget {
  final StructuralElement element;
  final ScrollController scrollController;

  const StructuralElementDetailSheet({super.key, required this.element, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SvgPicture.asset(element.image, height: 150),
            const SizedBox(height: 16),
            Text(element.name,
              style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryMetraShop,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Text(element.details),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Acción para ver proveedores
              },
              child: const Text('Ver proveedores'),
            ),
          ],
        ),
      ),
    );
  }
}