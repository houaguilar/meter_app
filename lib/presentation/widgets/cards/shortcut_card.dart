import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/theme.dart';

class ShortcutCard extends StatelessWidget {
  final String title;
  final String imageAssetPath;

  const ShortcutCard({
    super.key,
    required this.title,
    required this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SvgPicture.asset(
              imageAssetPath,
              fit: BoxFit.contain,
              height: 100,
              width: 100,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.yellowMetraShop,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)
                )
            ),
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMetraShop,
                  backgroundColor: AppColors.yellowMetraShop
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
