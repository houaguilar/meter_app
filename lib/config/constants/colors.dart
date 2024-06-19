import 'dart:math';

import 'package:flutter/material.dart';

const Color kYellowLight = Color(0xFFFFF7EC);
const Color kYellow = Color(0xFFFAF0DA);
const Color kYellowDark = Color(0xFFEBBB7F);

const Color kRedLight = Color(0xFFFCF0F0);
const Color kRed = Color(0xFFFBE4E6);
const Color kRedDark = Color(0xFFF08A8E);

const Color kBlueLight = Color(0xFFEDF4FE);
const Color kBlue = Color(0xFFE1EDFC);
const Color kBlueDark = Color(0xFFC0D3F8);

const Color kGreenLight = Color(0xFFE4F6E6);
const Color kGreen = Color(0xFFD7ECD9);
const Color kGreenDark = Color(0xFFB5EAD7);

List<Color> colorList = [
  kYellowLight,
  kYellow,
  kYellowDark,
  kRedLight,
  kRed,
  kRedDark,
  kBlueLight,
  kBlue,
  kRedDark,
  kGreenLight,
  kGreen,
  kGreenDark,
];

Color getRandomColor() {
  Random random = Random();
  return colorList[random.nextInt(colorList.length)];
}

class AppColors {
  static const Color teal = Color(0xFF317088);
  static const Color orange = Color(0xFFF2A65A);
  static const Color silver = Color(0xFFC4CACE);
}