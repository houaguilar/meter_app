

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_app/config/constants/constants.dart';


const seedColor = Color.fromARGB(255, 7, 80, 59);
const niceColor = Color(0xFF3498db);

class AppTheme {

  AppTheme();


  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryMetraShop,

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.primaryMetraShop,
    ),

    fontFamily: 'assets/fonts/Poppins',
    textTheme: GoogleFonts.poppinsTextTheme()
  );

}