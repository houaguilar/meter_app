import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_image_tab.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_information_tab.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_settings_tab.dart';

import '../../../../config/theme/theme.dart';

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
          title: const Text(
            'Editar perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.yellowMetraShop,
            indicatorWeight: 3,
            tabs: [
              Tab(
                text: 'Información',
                icon: Icon(Icons.person_outline),
              ),
              Tab(
                text: 'Imagen',
                icon: Icon(Icons.image_outlined),
              ),
              Tab(
                text: 'Contraseña',
                icon: Icon(Icons.lock_outline),
              ),
            ],
          ),
        ),
        body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is PasswordChangeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const TabBarView(
            children: [
              ProfileInformationTab(),
              ProfileImageTab(),
              ProfileSettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}