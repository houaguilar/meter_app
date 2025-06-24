import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

import '../../../config/theme/theme.dart';
import '../../../config/utils/show_snackbar.dart';
import '../../blocs/auth/auth_bloc.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  @override
  bool get wantKeepAlive => true;
  bool _isMounted = true;
  UserProfile? _cachedProfile;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initializeScreen() {
    WidgetsBinding.instance.addObserver(this);
    _loadProfileIfNeeded();
  }

  void _loadProfileIfNeeded() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      final profileBloc = context.read<ProfileBloc>();
      final profileState = profileBloc.state;

      if (profileState is! ProfileLoaded || _cachedProfile == null) {
        profileBloc.add(LoadProfile());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: _handleProfileStateChanges,
      builder: _buildProfileContent,
    );
  }

  void _handleProfileStateChanges(BuildContext context, ProfileState state) {
    if (!_isMounted) return;

    if (state is ProfileError) {
      _showErrorMessage(state.message);
    }
  }

  Widget _buildProfileContent(BuildContext context, ProfileState state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(state),
          SliverToBoxAdapter(
            child: _buildMainContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ProfileState state) {
    return SliverAppBar(
      expandedHeight: 350,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: state is ProfileLoaded
              ? _buildProfileHeader(state.userProfile)
              : _buildLoadingHeader(),
        ),
      ),
      actions: [
        if (state is ProfileLoaded)
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.white, size: 24),
            onPressed: () => context.pushNamed('profile-settings'),
            tooltip: 'Editar perfil',
          ),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile userProfile) {
    final completionPercentage = _calculateProfileCompletion(userProfile);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              height: constraints.maxHeight,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(flex: 1),

                  // Avatar con inicial del nombre
                  _buildProfileAvatar(userProfile),
                  const SizedBox(height: 16),

                  // Información del usuario
                  Flexible(
                    child: Text(
                      userProfile.name.isNotEmpty ? userProfile.name : 'Usuario MetraShop',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (userProfile.employment.isNotEmpty)
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          userProfile.employment,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Barra de completitud
                  _buildCompletionProgress(completionPercentage),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(UserProfile userProfile) {
    final firstLetter = userProfile.name.isNotEmpty
        ? userProfile.name[0].toUpperCase()
        : 'U';
    final avatarColor = _generateAvatarColor(userProfile.name);

    return Hero(
      tag: 'profile-avatar',
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              avatarColor,
              avatarColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _generateAvatarColor(String name) {
    if (name.isEmpty) return AppColors.secondary;

    final colors = [
      AppColors.secondary,
      AppColors.primary,
      const Color(0xFF8B5CF6), // Púrpura
      const Color(0xFFEF4444), // Rojo
      const Color(0xFF10B981), // Verde
      const Color(0xFFF59E0B), // Naranja
      const Color(0xFF3B82F6), // Azul claro
      const Color(0xFFEC4899), // Rosa
    ];

    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  Widget _buildCompletionProgress(double percentage) {
    final completedFields = (percentage / 100 * 6).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Completitud del perfil',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(percentage),
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            '$completedFields de 6 campos completados',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ProfileState state) {
    if (state is ProfileLoading) {
      return _buildLoadingState();
    }

    if (state is ProfileError) {
      return _buildErrorState(state.message);
    }

    if (state is ProfileLoaded) {
      return _buildProfileMenu(state.userProfile);
    }

    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el perfil',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _loadProfileIfNeeded,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Perfil no disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No se pudo cargar la información del perfil',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _loadProfileIfNeeded,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Cargar perfil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(UserProfile userProfile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAccountSection(),
          const SizedBox(height: 24),
          _buildBusinessSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mi cuenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        _buildActionCard([
          _ActionItem(
            icon: Icons.person_outline_rounded,
            title: 'Ver mi información',
            subtitle: 'Consulta tus datos personales',
            color: AppColors.secondary,
            onTap: () => context.pushNamed('profile-info'),
          ),
          _ActionItem(
            icon: Icons.edit_outlined,
            title: 'Editar perfil',
            subtitle: 'Modifica tu información personal',
            color: AppColors.accent,
            onTap: () => context.pushNamed('profile-settings'),
          ),
        ]),
      ],
    );
  }

  Widget _buildBusinessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        _buildActionCard([
          _ActionItem(
            icon: Icons.store_mall_directory_outlined,
            title: 'Tiendas oficiales',
            subtitle: 'Explora nuestras tiendas asociadas',
            color: AppColors.secondary,
            onTap: () => _showComingSoon('Tiendas oficiales'),
          ),
          _ActionItem(
            icon: Icons.add_business_outlined,
            title: 'Registrarme como proveedor',
            subtitle: 'Únete a nuestra red de proveedores',
            color: AppColors.accent,
            onTap: () => context.pushNamed('register-location'),
          ),
        ]),
      ],
    );
  }

  Widget _buildActionCard(List<_ActionItem> actions) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: actions.map((action) => _buildActionRow(action, actions.last == action)).toList(),
      ),
    );
  }

  Widget _buildActionRow(_ActionItem action, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
              bottom: BorderSide(
                color: AppColors.neutral200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  size: 24,
                  color: action.color,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        _buildActionCard([
          _ActionItem(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Gestiona tus preferencias de notificación',
            color: AppColors.secondary,
            onTap: () => context.pushNamed('notifications-settings'),
          ),
          _ActionItem(
            icon: Icons.security_outlined,
            title: 'Privacidad y seguridad',
            subtitle: 'Administra la seguridad de tu cuenta',
            color: AppColors.primary,
            onTap: () => _showComingSoon('Configuración de privacidad'),
          ),
        ]),

        const SizedBox(height: 16),

        // Botón de cerrar sesión separado
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 24,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Salir de tu cuenta actual',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateProfileCompletion(UserProfile userProfile) {
    int completedFields = 0;
    const totalFields = 6;

    if (userProfile.name.isNotEmpty) completedFields++;
    if (userProfile.phone.isNotEmpty) completedFields++;
    if (userProfile.employment.isNotEmpty) completedFields++;
    if (userProfile.city.isNotEmpty) completedFields++;
    if (userProfile.district.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 30) return AppColors.error;
    if (percentage <= 70) return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _loadProfileIfNeeded();
  }

  void _showErrorMessage(String message) {
    if (!_isMounted) return;
    showSnackBar(context, message);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión? Tendrás que volver a iniciar sesión para acceder a tu cuenta.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Limpiar cache antes de cerrar sesión
              _cachedProfile = null;
              context.read<AuthBloc>().add(AuthLogout());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje de "próximamente" para funcionalidades no implementadas
  void _showComingSoon(String feature) {
    if (!_isMounted || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('$feature estará disponible próximamente'),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}