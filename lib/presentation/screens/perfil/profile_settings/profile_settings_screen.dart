
import 'package:flutter/material.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_image_tab.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_information_tab.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_settings_tab.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryMetraShop,
          iconTheme: const IconThemeData(color: AppColors.white),
          title: const Text('Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Datos'),
              Tab(text: 'Imagen',),
              Tab(text: 'Contraseña'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProfileInformationTab(),
            ProfileImageTab(),
            ProfileSettingsTab(),
          ],
        ),
      ),
    );
  }
}
