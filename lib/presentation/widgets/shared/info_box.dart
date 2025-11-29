import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/config/assets/app_icons.dart';

import '../../../config/theme/theme.dart';

class InfoBox extends StatelessWidget {
  final String message;

  const InfoBox({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.backgroundInfoColor,

        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(AppIcons.infoIcon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: AppColors.textInfoColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
