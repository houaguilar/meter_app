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
          'Mi perfil',
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
              } else if (state is ProfileSuccess) {
                showSnackBar(context, 'Perfil actualizado correctamente');
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Loader();
            } else if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.userProfile);
            }
            return const Center(child: Text('No se pudo cargar el perfil'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile userProfile) {
    // Calculate profile completion percentage
    int completedFields = 0;
    final totalFields = 6; // Count fields that should be filled (excluding id, email)
    if (userProfile.name.isNotEmpty) completedFields++;
    if (userProfile.phone.isNotEmpty) completedFields++;
    if (userProfile.employment.isNotEmpty) completedFields++;
    if (userProfile.city.isNotEmpty) completedFields++;
    if (userProfile.district.isNotEmpty) completedFields++;
    if (userProfile.profileImageUrl != null && userProfile.profileImageUrl!.isNotEmpty) completedFields++;

    final completionPercentage = (completedFields / totalFields) * 100;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(LoadProfile());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            // Profile header card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Hero(
                                tag: 'profile-image',
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: userProfile.profileImageUrl?.isNotEmpty == true
                                      ? NetworkImage(userProfile.profileImageUrl!)
                                      : null,
                                  child: userProfile.profileImageUrl?.isNotEmpty != true
                                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userProfile.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      userProfile.email,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (userProfile.phone.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          userProfile.phone,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              context.pushNamed('profile-settings');
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.settings,
                                color: AppColors.primaryMetraShop,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Completa tu perfil',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$completedFields de $totalFields',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        LinearProgressIndicator(
                          value: completedFields / totalFields,
                          backgroundColor: Colors.grey.shade200,
                          color: _getProgressColor(completionPercentage),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            _buildProfileOptions(context),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 30) return Colors.red;
    if (percentage <= 70) return Colors.orange;
    return Colors.green;
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.person,
            title: 'Mi perfil',
            onTap: () => context.pushNamed('profile-settings'),
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.store_mall_directory,
            title: 'Tiendas oficiales',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.shopping_basket,
            title: 'Registrarme como proveedor',
            onTap: () => context.pushNamed('register-location'),
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.add_alert,
            title: 'Notificaciones',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.info,
            title: 'Información legal',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.book,
            title: 'Libro de reclamaciones',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.exit_to_app,
            title: 'Cerrar sesión',
            onTap: () => _confirmLogout(context),
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primaryMetraShop),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogout());
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}