
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';

import '../../../config/theme/theme.dart';

class CoatingDetailSheet extends StatelessWidget {
  final Coating coating;
  final ScrollController scrollController;

  const CoatingDetailSheet({super.key, required this.coating, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller:  scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SvgPicture.asset(coating.image, height: 150),
            const SizedBox(height: 16),
            Text(coating.name,
              style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryMetraShop,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Text(coating.details),
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