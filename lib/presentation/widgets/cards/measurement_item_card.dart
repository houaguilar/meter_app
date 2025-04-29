import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/presentation/assets/icons.dart';

class MeasurementItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final VoidCallback onTap;

  const MeasurementItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 4, bottom: 4),
      child: Card(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: SizedBox(
              height: 60,
              width: 40,
              child: SvgPicture.asset(imageAsset),
            ),
            title: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14
                )
            ),
            subtitle: Text(description, style: const TextStyle(fontSize: 10),),
            trailing: SvgPicture.asset(AppIcons.chevronCircleRightIcon),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
