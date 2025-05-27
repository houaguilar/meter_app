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
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Construye la app bar con título y acciones
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.white),
      elevation: 0,
      title: const Text(
        'Mi información',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.white),
          onPressed: _navigateToEdit,
          tooltip: 'Editar perfil',
        ),
      ],
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
    return switch (state.runtimeType) {
      ProfileLoading => _buildLoadingState(),
      ProfileLoaded => _buildLoadedState(state as ProfileLoaded),
      ProfileError => _buildErrorState(state as ProfileError),
      _ => _buildInitialState(),
    };
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return const Center(
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
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado con información cargada
  Widget _buildLoadedState(ProfileLoaded state) {
    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: _handlePullToRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: _buildProfileInfo(state.userProfile),
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(ProfileError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryLoadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado inicial
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Inicializando información...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeScreen,
            child: const Text('Cargar información'),
          ),
        ],
      ),
    );
  }

  /// Construye la información completa del perfil
  Widget _buildProfileInfo(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(userProfile),
        const SizedBox(height: 20),
        _buildPersonalInfoSection(userProfile),
        const SizedBox(height: 20),
        _buildContactInfoSection(userProfile),
        const SizedBox(height: 20),
        _buildLocationInfoSection(userProfile),
        const SizedBox(height: 80), // Espacio para el FAB
      ],
    );
  }

  /// Construye el header del perfil con foto y datos básicos
  Widget _buildProfileHeader(UserProfile userProfile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'profile-image-info',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _getProfileImage(userProfile),
                  child: _getProfileImage(userProfile) == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userProfile.name.isNotEmpty ? userProfile.name : 'Nombre no disponible',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userProfile.employment.isNotEmpty
                    ? userProfile.employment
                    : 'Profesión no especificada',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCompletionBadge(userProfile),
          ],
        ),
      ),
    );
  }

  /// Construye el badge de completitud del perfil
  Widget _buildCompletionBadge(UserProfile userProfile) {
    final completionPercentage = _calculateProfileCompletion(userProfile);
    final completedFields = (completionPercentage * 6 / 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getProgressColor(completionPercentage).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getProgressColor(completionPercentage).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCompletionIcon(completionPercentage),
            size: 16,
            color: _getProgressColor(completionPercentage),
          ),
          const SizedBox(width: 8),
          Text(
            'Perfil ${completionPercentage.toInt()}% completo ($completedFields/6)',
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

  /// Construye la sección de información personal
  Widget _buildPersonalInfoSection(UserProfile userProfile) {
    return _buildInfoSection(
      title: 'Información Personal',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
          'Nombre completo',
          userProfile.name.isNotEmpty ? userProfile.name : 'No especificado',
          Icons.person,
          canCopy: true,
        ),
        _buildInfoRow(
          'Ocupación',
          userProfile.employment.isNotEmpty ? userProfile.employment : 'No especificado',
          Icons.work_outline,
        ),
        _buildInfoRow(
          'Nacionalidad',
          userProfile.nationality.isNotEmpty ? userProfile.nationality : 'No especificado',
          Icons.flag_outlined,
        ),
      ],
    );
  }

  /// Construye la sección de información de contacto
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

  /// Construye la sección de información de ubicación
  Widget _buildLocationInfoSection(UserProfile userProfile) {
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

  /// Construye una sección de información con título e icono
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  /// Construye una fila de información con etiqueta y valor
  Widget _buildInfoRow(
      String label,
      String value,
      IconData icon, {
        bool canCopy = false,
        bool isEmail = false,
        bool isPhone = false,
        bool isMonospace = false,
      }) {
    final hasValue = value != 'No especificado' && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: hasValue ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: hasValue ? AppColors.primary : Colors.grey,
                    fontFamily: isMonospace ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy && hasValue) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.copy,
              tooltip: 'Copiar',
              onPressed: () => _copyToClipboard(value, label),
            ),
          ],
        ],
      ),
    );
  }

  /// Construye un botón de acción pequeño
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }

  /// Construye el botón flotante para editar
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToEdit,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
      icon: const Icon(Icons.edit),
      label: const Text(
        'Editar perfil',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Utility methods

  /// Obtiene la imagen de perfil de forma segura
  ImageProvider? _getProfileImage(UserProfile userProfile) {
    final imageUrl = userProfile.profileImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty && Uri.tryParse(imageUrl) != null) {
      return NetworkImage(imageUrl);
    }
    return null;
  }

  /// Calcula el porcentaje de completitud del perfil
  double _calculateProfileCompletion(UserProfile userProfile) {
    int completedFields = 0;
    const totalFields = 6;

    if (userProfile.name.isNotEmpty) completedFields++;
    if (userProfile.phone.isNotEmpty) completedFields++;
    if (userProfile.employment.isNotEmpty) completedFields++;
    if (userProfile.city.isNotEmpty) completedFields++;
    if (userProfile.district.isNotEmpty) completedFields++;
    if (userProfile.profileImageUrl?.isNotEmpty == true) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Obtiene el color de progreso según el porcentaje
  Color _getProgressColor(double percentage) {
    if (percentage <= 30) return Colors.red;
    if (percentage <= 70) return Colors.orange;
    return Colors.green;
  }

  /// Obtiene el icono de completitud según el porcentaje
  IconData _getCompletionIcon(double percentage) {
    if (percentage <= 30) return Icons.warning_amber;
    if (percentage <= 70) return Icons.info;
    return Icons.check_circle;
  }

  /// Copia texto al portapapeles
  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (_isMounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copiado al portapapeles'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Maneja el pull-to-refresh
  Future<void> _handlePullToRefresh() async {
    if (_isMounted && context.mounted) {
      context.read<ProfileBloc>().add(LoadProfile());
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Reintenta cargar el perfil
  void _retryLoadProfile() {
    if (_isMounted && context.mounted) {
      context.read<ProfileBloc>().add(LoadProfile());
    }
  }

  /// Navega a la pantalla de edición
  void _navigateToEdit() {
    if (_isMounted && context.mounted) {
      context.pushNamed('profile-settings');
    }
  }

  /// Muestra un mensaje de "próximamente"
  void _showComingSoon(String feature) {
    if (_isMounted && context.mounted) {
      showSnackBar(
        context,
        '$feature estará disponible próximamente',
      );
    }
  }

  /// Muestra un mensaje de error de forma segura
  void _showErrorMessage(String message) {
    if (_isMounted && context.mounted) {
      showSnackBar(context, message);
    }
  }
}