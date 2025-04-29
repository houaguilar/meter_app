
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/domain/entities/home/piso/floor.dart';

import '../../../config/constants/constants.dart';

class FloorDetailSheet extends StatelessWidget {
  final Floor floor;
  final ScrollController scrollController;

  const FloorDetailSheet({super.key, required this.floor, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller:  scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SvgPicture.asset(floor.image, height: 150),
            const SizedBox(height: 16),
            Text(floor.name,
              style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryMetraShop,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Text(floor.details),
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