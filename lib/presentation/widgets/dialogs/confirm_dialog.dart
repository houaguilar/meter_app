

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/config/constants/constants.dart';

import '../../assets/icons.dart';

class ConfirmDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String? content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    required bool isVisible,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Column(
            children: [
              SvgPicture.asset(
                AppIcons.yellowWarningTriangleIcon,
                width: 45,
                height: 45,
              ),
              const SizedBox(height: 10),
              Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16
                  )
              ),
            ],
          ),
          content: Visibility(
            visible: isVisible,
            child: Text(
              content ?? '',
              style: const TextStyle(
                  fontSize: 14
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.blueMetraShop,
                    minimumSize: const Size(125, 45),
                    side: const BorderSide(color: AppColors.blueMetraShop),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800
                    ),
                  ),
                  onPressed: onCancel,
                  child: Text(cancelText),

                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.blueMetraShop,
                    minimumSize: const Size(125, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800
                    ),
                  ),
                  onPressed: onConfirm,
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
