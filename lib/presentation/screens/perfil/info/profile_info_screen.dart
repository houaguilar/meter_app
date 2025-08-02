import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  /// Indica si la pantalla está montada para evitar errores de setState
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  /// Inicializa la pantalla cargando el perfil si es necesario
  void _initializeScreen() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is! ProfileLoaded) {
      context.read<ProfileBloc>().add(LoadProfile());
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

  /// Construye el cuerpo principal de la pantalla
  Widget _buildBody() {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: _handleProfileStateChanges,
      builder: _buildProfileContent,
    );
  }

  /// Maneja los cambios de estado del perfil
  void _handleProfileStateChanges(BuildContext context, ProfileState state) {
    if (!_isMounted) return;

    if (state is ProfileError) {
      _showErrorMessage(state.message);
    }
  }

  /// Construye el contenido basado en el estado del perfil
  Widget _buildProfileContent(BuildContext context, ProfileState state) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: _buildProfileBody(state),
        ),
      ],
    );
  }

  /// Construye la SliverAppBar moderna con gradiente
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Elementos decorativos
              Positioned(
                top: 60,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.2),
                  ),
                ),
              ),
              // Título centrado
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: AppColors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Mi Información',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Gestiona tus datos personales',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: _navigateToEdit,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
            tooltip: 'Editar información',
          ),
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  /// Construye el cuerpo del perfil según el estado
  Widget _buildProfileBody(ProfileState state) {
    if (state is ProfileLoading) {
      return _buildLoadingState();
    } else if (state is ProfileLoaded) {
      return _buildProfileInfo(state.userProfile);
    } else if (state is ProfileError) {
      return _buildErrorState(state);
    } else {
      return _buildInitialState();
    }
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando información...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la información completa del perfil
  Widget _buildProfileInfo(UserProfile userProfile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(userProfile),
          const SizedBox(height: 24),
          _buildCompletionCard(userProfile),
          const SizedBox(height: 24),
          _buildPersonalInfoSection(userProfile),
          const SizedBox(height: 20),
          _buildContactInfoSection(userProfile),
          const SizedBox(height: 20),
          _buildLocationSection(userProfile),
          const SizedBox(height: 100), // Espacio para el FAB
        ],
      ),
    );
  }

  /// Tarjeta de bienvenida personalizada
  Widget _buildWelcomeCard(UserProfile userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola ${userProfile.name.isNotEmpty ? userProfile.name.split(' ').first : 'Usuario'}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Aquí puedes ver toda tu información personal',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tarjeta de completitud del perfil
  Widget _buildCompletionCard(UserProfile userProfile) {
    final completionPercentage = _calculateProfileCompletion(userProfile);
    final completedFields = (completionPercentage * 5 / 100).round(); // Sin imagen

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCompletionIcon(completionPercentage),
                color: _getProgressColor(completionPercentage),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Completitud del Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$completedFields de 5 campos completados',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(completionPercentage),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${completionPercentage.toInt()}% completo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getProgressColor(completionPercentage),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de información personal
  Widget _buildPersonalInfoSection(UserProfile userProfile) {
    return _buildInfoSection(
      title: 'Información Personal',
      icon: Icons.person_outline_rounded,
      children: [
        _buildInfoRow(
          'Nombre completo',
          userProfile.name.isNotEmpty ? userProfile.name : 'No especificado',
          Icons.badge_outlined,
          canCopy: userProfile.name.isNotEmpty,
        ),
        _buildInfoRow(
          'Ocupación',
          userProfile.employment.isNotEmpty ? userProfile.employment : 'No especificado',
          Icons.work_outline_rounded,
        ),
        _buildInfoRow(
          'Nacionalidad',
          userProfile.nationality.isNotEmpty ? userProfile.nationality : 'No especificado',
          Icons.flag_outlined,
        ),
      ],
    );
  }

  /// Sección de información de contacto
  Widget _buildContactInfoSection(UserProfile userProfile) {
    return _buildInfoSection(
      title: 'Información de Contacto',
      icon: Icons.contact_phone_outlined,
      children: [
        _buildInfoRow(
          'Correo electrónico',
          userProfile.email,
          Icons.email_outlined,
          canCopy: true,
          isEmail: true,
        ),
        _buildInfoRow(
          'Teléfono',
          userProfile.phone.isNotEmpty ? userProfile.phone : 'No especificado',
          Icons.phone_outlined,
          canCopy: userProfile.phone.isNotEmpty,
          isPhone: true,
        ),
      ],
    );
  }

  /// Sección de ubicación
  Widget _buildLocationSection(UserProfile userProfile) {
    return _buildInfoSection(
      title: 'Ubicación',
      icon: Icons.location_on_outlined,
      children: [
        _buildInfoRow(
          'Ciudad',
          userProfile.city.isNotEmpty ? userProfile.city : 'No especificado',
          Icons.location_city_outlined,
        ),
        _buildInfoRow(
          'Provincia',
          userProfile.province.isNotEmpty ? userProfile.province : 'No especificado',
          Icons.map_outlined,
        ),
        _buildInfoRow(
          'Distrito',
          userProfile.district.isNotEmpty ? userProfile.district : 'No especificado',
          Icons.place_outlined,
        ),
      ],
    );
  }

  /// Widget de sección de información
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// Widget de fila de información
  Widget _buildInfoRow(
      String label,
      String value,
      IconData icon, {
        bool canCopy = false,
        bool isEmail = false,
        bool isPhone = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: value == 'No especificado'
                        ? AppColors.textSecondary
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy && value != 'No especificado')
            IconButton(
              onPressed: () => _copyToClipboard(value),
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
              tooltip: 'Copiar',
            ),
        ],
      ),
    );
  }

  /// Estado de error mejorado
  Widget _buildErrorState(ProfileError state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar la información',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _retryLoadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado inicial mejorado
  Widget _buildInitialState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 48,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Inicializando información...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _initializeScreen,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Cargar información'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES
  // ══════════════════════════════════════════════════════════════════════════════

  /// Calcula el porcentaje de completitud del perfil (sin imagen)
  double _calculateProfileCompletion(UserProfile profile) {
    int completedFields = 0;
    const int totalFields = 5; // Sin incluir la imagen

    if (profile.name.isNotEmpty) completedFields++;
    if (profile.phone.isNotEmpty) completedFields++;
    if (profile.employment.isNotEmpty) completedFields++;
    if (profile.city.isNotEmpty) completedFields++;
    if (profile.district.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Obtiene el color del progreso según el porcentaje
  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.accent;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }

  /// Obtiene el icono del progreso según el porcentaje
  IconData _getCompletionIcon(double percentage) {
    if (percentage >= 80) return Icons.check_circle_rounded;
    if (percentage >= 60) return Icons.thumb_up_rounded;
    if (percentage >= 40) return Icons.info_rounded;
    return Icons.warning_rounded;
  }

  /// Navega a la pantalla de edición
  void _navigateToEdit() {
    context.pushNamed('profile-settings');
  }

  /// Reintenta cargar el perfil
  void _retryLoadProfile() {
    context.read<ProfileBloc>().add(LoadProfile());
  }

  /// Copia texto al portapapeles
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessMessage('Copiado al portapapeles');
  }

  /// Muestra mensaje de error
  void _showErrorMessage(String message) {
    if (!_isMounted) return;
    showSnackBar(context, message);
  }

  /// Muestra mensaje de éxito
  void _showSuccessMessage(String message) {
    if (!_isMounted) return;
    showSnackBar(context, message);
  }
}