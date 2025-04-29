

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/presentation/widgets/bottom_sheet/coating_detail_sheet.dart';

import '../../../config/constants/constants.dart';

class CoatingCard extends StatelessWidget {
  final Coating coating;
  final VoidCallback onTap;

  const CoatingCard({super.key, required this.coating, required this.onTap});

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
                  SvgPicture.asset(coating.image, fit: BoxFit.fill, height: 70, width: 70,),
                  const SizedBox(height: 5,),
                  Text(coating.name,
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
        TextButton(
          onPressed: () {
            _showCoatingDetails(context, coating);
          },
          child: const Text(
            'Ver información',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.blueMetraShop,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.blueMetraShop,
            ),
          ),
        ),
      ],
    );
  }

  void _showCoatingDetails(BuildContext context, Coating coating) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return CoatingDetailSheet(coating: coating, scrollController: scrollController);
        },
      ),
    );
  }
}