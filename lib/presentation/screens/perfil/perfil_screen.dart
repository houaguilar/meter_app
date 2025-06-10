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

  /// Mantiene el estado activo para optimizar rendimiento
  @override
  bool get wantKeepAlive => true;

  /// Indica si la pantalla está montada para evitar errores de setState
  bool _isMounted = true;

  /// Cache del perfil del usuario para mejorar rendimiento
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

  /// Inicializa la pantalla y sus dependencias
  void _initializeScreen() {
    WidgetsBinding.instance.addObserver(this);
    _loadProfileIfNeeded();
  }

  /// Carga el perfil solo si es necesario
  void _loadProfileIfNeeded() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      final profileBloc = context.read<ProfileBloc>();
      final profileState = profileBloc.state;

      // Solo cargar si no tenemos datos o si hay error
      if (profileState is! ProfileLoaded) {
        profileBloc.add(LoadProfile());
      } else {
        _cachedProfile = profileState.userProfile;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _isMounted) {
      // Refrescar datos cuando la app vuelve a primer plano
      _refreshProfileIfNeeded();
    }
  }

  /// Refresca el perfil si es necesario
  void _refreshProfileIfNeeded() {
    final profileBloc = context.read<ProfileBloc>();
    if (profileBloc.state is ProfileError) {
      profileBloc.add(LoadProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido para AutomaticKeepAliveClientMixin

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Usa el color primario de tu tema automáticamente
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  /// Construye la app bar con el título
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryMetraShop,
      centerTitle: false,
      elevation: 0,
      title: const Text(
        'Mi perfil',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  /// Construye el cuerpo principal de la pantalla
  Widget _buildBody() {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: _handleAuthStateChanges,
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: _handleProfileStateChanges,
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: _buildProfileContent,
      ),
    );
  }

  /// Maneja los cambios de estado de autenticación
  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    if (!_isMounted) return;

    switch (state.runtimeType) {
      case AuthInitial:
        _navigateToAuth();
        break;
      case AuthFailure:
        final failureState = state as AuthFailure;
        _showErrorMessage(failureState.message);
        break;
    }
  }

  /// Maneja los cambios de estado del perfil
  void _handleProfileStateChanges(BuildContext context, ProfileState state) {
    if (!_isMounted) return;

    switch (state.runtimeType) {
      case ProfileLoaded:
        final loadedState = state as ProfileLoaded;
        _cachedProfile = loadedState.userProfile;
        break;
      case ProfileError:
        final errorState = state as ProfileError;
        _showErrorMessage(errorState.message);
        break;
      case ProfileSuccess:
        _showSuccessMessage('Perfil actualizado correctamente');
        break;
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando perfil...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryMetraShop,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado con perfil cargado
  Widget _buildLoadedState(ProfileLoaded state) {
    return RefreshIndicator(
      color: AppColors.blueMetraShop,
      onRefresh: _handlePullToRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildProfileMenu(state.userProfile),
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
              color: AppColors.errorGeneralColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMetraShop,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.greyTextColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryLoadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueMetraShop,
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
            'Inicializando perfil...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryMetraShop,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProfileIfNeeded,
            child: const Text('Cargar perfil'),
          ),
        ],
      ),
    );
  }

  /// Construye el menú principal del perfil
  Widget _buildProfileMenu(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        _buildProfileHeader(userProfile),
        const SizedBox(height: 25),
        _buildProfileOptions(),
        const SizedBox(height: 25),
        _buildSecuritySection(),
        const SizedBox(height: 25),
      ],
    );
  }

  /// Construye el header del perfil con información básica
  Widget _buildProfileHeader(UserProfile userProfile) {
    final completionPercentage = _calculateProfileCompletion(userProfile);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildProfileAvatar(userProfile),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildUserInfo(userProfile),
                ),
                _buildEditButton(),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildCompletionProgress(completionPercentage),
          ],
        ),
      ),
    );
  }

  /// Construye el avatar del perfil
  Widget _buildProfileAvatar(UserProfile userProfile) {
    return Hero(
      tag: 'profile-image',
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: _getProfileImage(userProfile),
        child: _getProfileImage(userProfile) == null
            ? const Icon(Icons.person, size: 40, color: Colors.grey)
            : null,
      ),
    );
  }

  /// Obtiene la imagen de perfil de forma segura
  ImageProvider? _getProfileImage(UserProfile userProfile) {
    final imageUrl = userProfile.profileImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty && Uri.tryParse(imageUrl) != null) {
      return NetworkImage(imageUrl);
    }
    return null;
  }

  /// Construye la información básica del usuario
  Widget _buildUserInfo(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userProfile.name.isNotEmpty ? userProfile.name : 'Nombre no disponible',
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
        if (userProfile.phone.isNotEmpty) ...[
          const SizedBox(height: 4.0),
          Text(
            userProfile.phone,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Construye el botón de edición
  Widget _buildEditButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: _navigateToProfileInfo,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.blueMetraShop.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.visibility,
            color: AppColors.primaryMetraShop,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Construye la barra de progreso de completitud del perfil
  Widget _buildCompletionProgress(double completionPercentage) {
    final completedFields = (completionPercentage * 6 / 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Completitud del perfil',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$completedFields de 6 campos',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: completionPercentage / 100,
          backgroundColor: Colors.grey.shade200,
          color: _getProgressColor(completionPercentage),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
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

  /// Obtiene el color de la barra de progreso según el porcentaje
  Color _getProgressColor(double percentage) {
    if (percentage <= 30) return Colors.red;
    if (percentage <= 70) return Colors.orange;
    return Colors.green;
  }

  /// Construye las opciones principales del perfil
  Widget _buildProfileOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Mi cuenta'),
          _buildOptionTile(
            icon: Icons.person_outline,
            title: 'Ver mi información',
            subtitle: 'Consulta tus datos personales',
            onTap: _navigateToProfileInfo,
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.edit_outlined,
            title: 'Editar perfil',
            subtitle: 'Modifica tu información personal',
            onTap: _navigateToProfileSettings,
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.store_mall_directory_outlined,
            title: 'Tiendas oficiales',
            subtitle: 'Explora nuestras tiendas asociadas',
            onTap: _navigateToOfficialStores,
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.add_business_outlined,
            title: 'Registrarme como proveedor',
            subtitle: 'Únete a nuestra red de proveedores',
            onTap: _navigateToProviderRegistration,
          ),
        ],
      ),
    );
  }

  /// Construye la sección de seguridad y configuración
  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Configuración'),
          _buildOptionTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Gestiona tus preferencias de notificación',
            onTap: _navigateToNotifications,
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Ayuda y soporte',
            subtitle: 'Obtén ayuda cuando la necesites',
            onTap: _navigateToHelp,
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.info_outline,
            title: 'Información legal',
            subtitle: 'Términos y condiciones, privacidad',
            onTap: _navigateToLegalInfo,
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.feedback_outlined,
            title: 'Libro de reclamaciones',
            subtitle: 'Presenta tus sugerencias o reclamos',
            onTap: _navigateToComplaints,
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta de forma segura',
            onTap: _confirmLogout,
            textColor: Colors.red,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Construye el header de una sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMetraShop,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de opción del menú
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primaryMetraShop).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? AppColors.primaryMetraShop,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // Navigation methods

  void _navigateToAuth() {
    if (_isMounted && context.mounted) {
      context.goNamed('metrashop');
    }
  }

  void _navigateToProfileInfo() {
    if (_isMounted && context.mounted) {
      context.pushNamed('profile-info');
    }
  }

  void _navigateToProfileSettings() {
    if (_isMounted && context.mounted) {
      context.pushNamed('profile-settings');
    }
  }

  void _navigateToOfficialStores() {
    // TODO: Implementar navegación a tiendas oficiales
    _showComingSoon('Tiendas oficiales');
  }

  void _navigateToProviderRegistration() {
    if (_isMounted && context.mounted) {
      context.pushNamed('register-location');
    }
  }

  void _navigateToNotifications() {
    // TODO: Implementar navegación a notificaciones
    _showComingSoon('Notificaciones');
  }

  void _navigateToHelp() {
    // TODO: Implementar navegación a ayuda
    _showComingSoon('Ayuda y soporte');
  }

  void _navigateToLegalInfo() {
    // TODO: Implementar navegación a información legal
    _showComingSoon('Información legal');
  }

  void _navigateToComplaints() {
    // TODO: Implementar navegación a libro de reclamaciones
    _showComingSoon('Libro de reclamaciones');
  }

  // Utility methods

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

  /// Confirma el cierre de sesión con un diálogo de seguridad
  Future<void> _confirmLogout() async {
    if (!_isMounted || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('¿Cerrar sesión?'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión? Tendrás que volver a iniciar sesión para acceder a tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && _isMounted && context.mounted) {
      // Limpiar cache antes de cerrar sesión
      _cachedProfile = null;
      context.read<AuthBloc>().add(AuthLogout());
    }
  }

  /// Muestra un mensaje de "próximamente" para funcionalidades no implementadas
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

  /// Muestra un mensaje de éxito de forma segura
  void _showSuccessMessage(String message) {
    if (_isMounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}