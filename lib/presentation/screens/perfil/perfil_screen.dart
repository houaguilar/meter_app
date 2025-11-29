import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

import '../../../config/app_config.dart';
import '../../../config/theme/theme.dart';
import '../../../config/utils/show_snackbar.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/entities/map/verification_status.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/map/locations_bloc.dart';
import '../../blocs/premium/premium_bloc.dart';
import '../../widgets/premium/premium_feature_widget.dart';
import '../../widgets/premium/premium_paywall_screen.dart';
import '../../widgets/premium/premium_status_indicator.dart';
import '../mapa/profile/provider_profile_screen.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final premiumBloc = context.read<PremiumBloc>();
      print('🔍 PerfilScreen: Forzando carga inicial de premium status');
      premiumBloc.add(LoadPremiumStatus());
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Verificar si necesitamos recargar el perfil cuando la app vuelve al foreground
      final profileBloc = context.read<ProfileBloc>();
      final currentState = profileBloc.state;

      // Si hay algún problema con el estado, forzar recarga
      if (currentState is ProfileError || currentState is ProfileInitial) {
        profileBloc.add(LoadProfile(forceReload: true));
      }
    }
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

      // Modificación: Solo cargar si realmente no hay perfil cargado
      // Remover la verificación de _cachedProfile que puede causar inconsistencias
      if (profileState is ProfileInitial || profileState is ProfileError) {
        profileBloc.add(LoadProfile());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        // Listener existente del ProfileBloc
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              _showErrorMessage(state.message);
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthInitial) {
              // Logout exitoso - navegar a la pantalla de inicio
              context.goNamed('metrashop');
            } else if (state is AuthFailure) {
              // Error en logout - mostrar mensaje
              _showErrorMessage('Error al cerrar sesión: ${state.message}');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _buildBody(),
      ),
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
    } else if (state is ProfileLoaded) {
      // Actualizar cache cuando el perfil se carga exitosamente
      _cachedProfile = state.userProfile;
    } else if (state is ProfileSuccess) {
      // Cuando se actualiza exitosamente, mostrar mensaje y mantener el perfil cargado
      showSnackBar(context, 'Perfil actualizado correctamente');
    }
  }

  Widget _buildPremiumDebugInfo() {
    if (!AppConfig.isDevelopment) return const SizedBox.shrink();

    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, premiumState) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔍 DEBUG PREMIUM STATE:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'State Type: ${premiumState.runtimeType}',
                style: TextStyle(fontSize: 10, color: Colors.red.shade600),
              ),
              if (premiumState is PremiumLoaded) ...[
                Text(
                  'Is Premium: ${premiumState.status.isPremium}',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade600),
                ),
                Text(
                  'Source: ${premiumState.status.source}',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade600),
                ),
                Text(
                  'Until: ${premiumState.status.premiumUntil}',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade600),
                ),
                Text(
                  'Is Active: ${premiumState.status.isActive}',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade600),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PremiumBloc>().add(LoadPremiumStatus());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text('Refresh', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumPaywallScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text('Paywall', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
          SliverToBoxAdapter(
            child: _buildPremiumDebugInfo(),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
//      systemOverlayStyle: SystemUiOverlayStyle.light,
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
        const PremiumStatusIndicator(padding: EdgeInsets.symmetric(horizontal: 8)),

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
               //   _buildProfileAvatar(userProfile),
                  _buildPremiumProfileAvatar(userProfile),
                  const SizedBox(height: 16),

                  // Información del usuario
                  Flexible(
                    /*child: Text(
                      userProfile.name.isNotEmpty ? userProfile.name : 'Usuario MetraShop',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),*/
                    child: _buildUserNameWithPremium(userProfile),
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
             //     _buildCompletionProgress(completionPercentage),
                  _buildPremiumProgressCard(completionPercentage),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumProgressCard(double completionPercentage) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, premiumState) {
        final isPremium = premiumState is PremiumLoaded && premiumState.status.isActive;

        if (isPremium) {
          // Usuario premium - mostrar beneficios
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.diamond, color: Colors.amber.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuario Premium',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      if (premiumState is PremiumLoaded && premiumState.status.daysRemaining != null)
                        Text(
                          'Expira en ${premiumState.status.daysRemaining} días',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumPaywallScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Text(
                    'Gestionar',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Usuario gratuito - mostrar progreso y CTA premium
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Completitud del perfil',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${completionPercentage.round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress bar
                LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 12),

                // CTA Premium
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumPaywallScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.blue.shade400],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Activar Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
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

  Widget _buildPremiumProfileAvatar(UserProfile userProfile) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, premiumState) {
        final isPremium = premiumState is PremiumLoaded && premiumState.status.isActive;

        return Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isPremium
                    ? LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [AppColors.accent, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPremium
                        ? Colors.amber.withOpacity(0.3)
                        : AppColors.accent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userProfile.name.isNotEmpty
                      ? userProfile.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // Badge premium
            if (isPremium)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserNameWithPremium(UserProfile userProfile) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, premiumState) {
        final isPremium = premiumState is PremiumLoaded && premiumState.status.isActive;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                userProfile.name.isNotEmpty
                    ? userProfile.name
                    : 'Usuario Anónimo',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (isPremium) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
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
          _buildPremiumSection(),
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

  Widget _buildPremiumSection() {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, premiumState) {
        final isPremium = premiumState is PremiumLoaded && premiumState.status.isActive;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.diamond : Icons.star_outline,
                  color: isPremium ? Colors.amber.shade600 : Colors.purple.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isPremium ? 'Premium' : 'Mejora tu experiencia',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isPremium)
              _buildPremiumActiveCard(premiumState as PremiumLoaded)
            else
              _buildPremiumUpgradeCard(),
          ],
        );
      },
    );
  }

  Widget _buildBusinessSection() {
    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, locationsState) {
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

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textSecondary.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  PremiumFeatureWidget(
                    featureName: 'Análisis Avanzados desde Perfil',
                    fallback: _ActionItem(
                      icon: Icons.analytics_outlined,
                      title: 'Análisis básicos',
                      subtitle: 'Estadísticas limitadas • Actualiza a Premium',
                      color: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumPaywallScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                    ),
                    child: _ActionItem(
                      icon: Icons.analytics_rounded,
                      title: 'Análisis avanzados',
                      subtitle: 'Estadísticas detalladas y reportes premium',
                      color: Colors.purple,
                      onTap: () {
                        // Navegar a análisis premium
                        showSnackBar(context, 'Abriendo análisis premium...');
                      },
                    ),
                  ),

                  // Divisor
                  const Divider(height: 1, color: AppColors.border),

                  // Sección de Proveedor
                  _buildProviderSection(locationsState),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProviderSection(LocationsState locationsState) {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is! ProfileLoaded) {
      return const SizedBox.shrink();
    }

    final userId = profileState.userProfile.id;

    // Cargar ubicaciones del usuario si no están cargadas
    if (locationsState is! UserLocationsLoaded &&
        locationsState is! UserLocationsLoading) {
      // Disparar evento para cargar ubicaciones del usuario
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LocationsBloc>().add(LoadLocationsByUser(userId));
      });
      return const SizedBox.shrink();
    }

    if (locationsState is UserLocationsLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (locationsState is UserLocationsLoaded) {
      final userLocations = locationsState.userLocations;

      if (userLocations.isEmpty) {
        // Usuario NO es proveedor - Mostrar botón para registrarse
        return _buildActionCard([
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
        ]);
      } else {
        // Usuario YA es proveedor - Mostrar estado y botones
        final providerLocation = userLocations.first;
        return _buildProviderStatusCard(providerLocation);
      }
    }

    // Estado por defecto
    return _buildActionCard([
      _ActionItem(
        icon: Icons.add_business_outlined,
        title: 'Registrarme como proveedor',
        subtitle: 'Únete a nuestra red de proveedores',
        color: AppColors.accent,
        onTap: () => context.pushNamed('register-location'),
      ),
    ]);
  }

  Widget _buildProviderStatusCard(LocationMap location) {
    final status = location.verificationStatus;
    final statusColor = _getProviderStatusColor(status);
    final statusIcon = _getProviderStatusIcon(status);
    final statusText = _getProviderStatusText(status);

    return Column(
      children: [
        // Card de estado de verificación
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mi Negocio',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          location.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Información adicional según el estado
              if (status.isPending && location.scheduledDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verificación: ${_formatDate(location.scheduledDate!)} ${location.scheduledTime ?? ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Botones según el estado
              const SizedBox(height: 12),
              _buildProviderActions(location),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderActions(LocationMap location) {
    final status = location.verificationStatus;

    if (status.isApproved) {
      // Si está aprobado, mostrar botón para configurar negocio
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToProviderProfile(location),
          icon: const Icon(Icons.settings, size: 20),
          label: const Text('Configurar Mi Negocio'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else {
      // Si está pendiente o rechazado, mostrar botón para ver detalles
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _navigateToProviderProfile(location),
          icon: const Icon(Icons.info_outline, size: 20),
          label: const Text('Ver Detalles'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }
  }

  Color _getProviderStatusColor(VerificationStatus status) {
    if (status.isPending) return AppColors.warning;
    if (status.isApproved) return AppColors.success;
    if (status.isRejected) return AppColors.error;
    return AppColors.textSecondary;
  }

  IconData _getProviderStatusIcon(VerificationStatus status) {
    if (status.isPending) return Icons.hourglass_empty;
    if (status.isApproved) return Icons.check_circle;
    if (status.isRejected) return Icons.cancel;
    return Icons.info;
  }

  String _getProviderStatusText(VerificationStatus status) {
    if (status.isPending) return 'Verificación Pendiente';
    if (status.isApproved) return 'Negocio Verificado - Configura tus productos';
    if (status.isRejected) return 'Solicitud Rechazada';
    return 'Estado desconocido';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToProviderProfile(LocationMap location) {
    // Importar ProviderProfileScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderProfileScreen(location: location),
      ),
    );
  }

  // AGREGAR estos métodos para los cards premium:

  Widget _buildPremiumActiveCard(PremiumLoaded premiumState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.diamond, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Eres Premium!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (premiumState.status.timeRemainingFormatted.isNotEmpty)
                      Text(
                        premiumState.status.timeRemainingFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumPaywallScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: const Text('Gestionar'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Funciones premium activas:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('Análisis avanzados', Icons.analytics),
              _buildFeatureChip('Sincronización ilimitada', Icons.cloud_sync),
              _buildFeatureChip('Soporte prioritario', Icons.support_agent),
              _buildFeatureChip('Respaldos automáticos', Icons.backup),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Desbloquea Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'Accede a funciones avanzadas y mejora tu productividad',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBenefitRow('Análisis detallados'),
                    _buildBenefitRow('Sin límites de sincronización'),
                    _buildBenefitRow('Temas personalizados'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConfig.isDevelopment ? 'Gratis' : '\$9.99',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!AppConfig.isDevelopment)
                      const Text(
                        '/mes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumPaywallScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ver Planes Premium',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 14, color: Colors.purple.shade600),
          const SizedBox(width: 6),
          Text(
            benefit,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
      /*child: Column(
        children: actions.map((action) => _buildActionRow(action, actions.last == action)).toList(),
      ),*/
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          return Column(
            children: [
              action,
              if (index < actions.length - 1)
                Divider(height: 1, color: AppColors.border),
            ],
          );
        }).toList(),
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
    if (userProfile.email.isNotEmpty) completedFields++;
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
            onPressed: () => context.pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return ElevatedButton(
                onPressed: authState is AuthLoading ? null : () {
                  context.pop(); // Cerrar diálogo
                  // Limpiar cache antes de cerrar sesión
                  _cachedProfile = null;
                  // Disparar evento de logout
                  context.read<AuthBloc>().add(AuthLogout());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: authState is AuthLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
                    : const Text('Cerrar sesión'),
              );
            },
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

// Clase helper para items del menú
class _ActionItem extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}