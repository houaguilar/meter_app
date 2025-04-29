

import 'package:flutter/material.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';

class WallMaterialDetailSheet extends StatelessWidget {
  final WallMaterial material;
  final ScrollController scrollController;

  const WallMaterialDetailSheet({super.key, required this.material, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(material.image, height: 150),
            const SizedBox(height: 16),
            Text(material.name,
                style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.primaryMetraShop,
                    fontWeight: FontWeight.bold
                ),
            ),
            const SizedBox(height: 16),
            Text(material.details),
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
