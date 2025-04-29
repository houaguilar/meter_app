import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

import '../../../config/utils/loader.dart';
import '../../../config/constants/constants.dart';
import '../../../config/utils/show_snackbar.dart';
import '../../blocs/auth/auth_bloc.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      final profileBloc = context.read<ProfileBloc>();
      if (profileBloc.state is! ProfileLoaded) {
        profileBloc.add(LoadProfile());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryMetraShop,
        centerTitle: false,
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthInitial) {
                context.goNamed('metrashop');
              } else if (state is AuthFailure) {
                showSnackBar(context, state.message);
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileError) {
                  showSnackBar(context, state.message);
                }
              },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.only(right: 24, left: 24),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Loader();
              } else if (state is ProfileLoaded) {
                return SingleChildScrollView(
                  child: Column(
                  //  mainAxisSize: MainAxisSize.min, // Evita que el Column se expanda innecesariamente
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      _buildProfileContent(context, state.userProfile),
                      const SizedBox(height: 25),
                      _buildProfileOptions(context),
                      const SizedBox(height: 25),

                    ],
                  ),
                );
              }
              return const Center(child: Text('No se pudo cargar el perfil'));

            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: userProfile.profileImageUrl != null
                   //   ? NetworkImage(userProfile.profileImageUrl!)
                      ? null
                      : null,
                  child: userProfile.profileImageUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : const Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(userProfile.email),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                context.pushNamed('profile-settings');
              },
              child: const Icon(Icons.settings),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        const SizedBox(
          width: 300,
          child: LinearProgressIndicator(
            minHeight: 5,
            value: 0.5,
            //     value: userProfile.profileCompletion / 100,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text('Completa tu perfil - 2 de 4'),
        //   Text('Completa tu perfil - ${userProfile.profileCompletion} de 4'),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Mi perfil'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.store_mall_directory),
          title: const Text('Tiendas oficiales'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.shopping_basket),
          title: const Text('Registrarme como proveedor'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.pushNamed('register-location');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.add_alert),
          title: const Text('Notificaciones'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Información legal'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text('Libro de reclamaciones'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Cerrar sesión'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.read<AuthBloc>().add(AuthLogout());
          },
        ),
        // Más opciones aquí
      ],
    );
  }
}
