
import 'package:flutter/material.dart';

import '../../config/constants/constants.dart';

class CustomButtonStyles {
  static final ButtonStyle elevatedStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.white,
    backgroundColor: AppColors.blueMetraShop,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
  );

  static final ButtonStyle elevatedIconStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.white,
    backgroundColor: AppColors.blueMetraShop,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  );

  static final ButtonStyle outlinedWelcomeStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.blueMetraShop,
    backgroundColor: AppColors.white,
    side: const BorderSide(color: AppColors.blueMetraShop),
    minimumSize: const Size(244, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
  );

  static final ButtonStyle outlinedCardStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.blueMetraShop,
    backgroundColor: AppColors.white,
    side: const BorderSide(color: AppColors.blueMetraShop),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  );

  static final ButtonStyle outlinedStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.blueMetraShop,
    side: const BorderSide(color: AppColors.blueMetraShop),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  );

  static final ButtonStyle outlinedIconStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.blueMetraShop,
    side: const BorderSide(color: AppColors.blueMetraShop),
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  );

  static final ButtonStyle textYellowStyle = TextButton.styleFrom(
    foregroundColor: AppColors.yellowMetraShop,
    minimumSize: const Size(double.infinity, 20),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
  );

  static final ButtonStyle textBlueStyle = TextButton.styleFrom(
    foregroundColor: AppColors.blueMetraShop,
    minimumSize: const Size(double.infinity, 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
  );

  static final ButtonStyle filledStyle = FilledButton.styleFrom(
    foregroundColor: AppColors.blueMetraShop,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  );
}