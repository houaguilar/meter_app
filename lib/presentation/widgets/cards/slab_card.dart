
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/presentation/widgets/bottom_sheet/slab_detail_sheet.dart';

import '../../../config/theme/theme.dart';
import '../../../domain/entities/home/losas/slab.dart';

class SlabCard extends StatelessWidget {
  final Slab slab;
  final VoidCallback onTap;

  const SlabCard({super.key, required this.slab, required this.onTap});

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
                  SvgPicture.asset(slab.image, fit: BoxFit.fill, height: 70, width: 70,),
                  const SizedBox(height: 5,),
                  Text(slab.name,
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

  void _showSlabDetails(BuildContext context, Slab slab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return SlabDetailSheet(slab: slab, scrollController: scrollController);
        },
      ),
    );
  }
}