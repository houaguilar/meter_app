
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/domain/entities/home/losas/slab.dart';

import '../../../config/constants/constants.dart';

class SlabDetailSheet extends StatelessWidget {
  final Slab slab;
  final ScrollController scrollController;

  const SlabDetailSheet({super.key, required this.slab, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller:  scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SvgPicture.asset(slab.image, height: 150),
            const SizedBox(height: 16),
            Text(slab.name,
              style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryMetraShop,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Text(slab.details),
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