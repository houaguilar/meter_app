
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/domain/entities/home/piso/floor.dart';
import 'package:meter_app/presentation/widgets/bottom_sheet/floor_detail_sheet.dart';

import '../../../config/constants/constants.dart';

class FloorCard extends StatelessWidget {
  final Floor floor;
  final VoidCallback onTap;

  const FloorCard({super.key, required this.floor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  SvgPicture.asset(floor.image, fit: BoxFit.fill, height: 70, width: 70,),
                  const SizedBox(height: 5,),
                  Text(floor.name,
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

  void _showCoatingDetails(BuildContext context, Floor floor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return FloorDetailSheet(floor: floor, scrollController: scrollController);
        },
      ),
    );
  }
}