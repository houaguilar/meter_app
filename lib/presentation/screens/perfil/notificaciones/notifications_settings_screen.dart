import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/notifications/notification_repository.dart';
import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../init_dependencies.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen>
    with WidgetsBindingObserver {

  // Servicios
  late final NotificationRepository _notificationService;
  late final SharedPreferences _prefs;

  // Estado de las notificaciones
  bool _notificationsEnabled = false;
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _hasCheckedPermissions = false;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Verificar permisos cuando la app vuelve del foreground
    if (state == AppLifecycleState.resumed && _hasCheckedPermissions) {
      _checkNotificationPermissions();
    }
  }

  Future<void> _initializeServices() async {
    try {
      _notificationService = serviceLocator<NotificationRepository>();
      _prefs = serviceLocator<SharedPreferences>();
      await _initializeNotificationSettings();
    } catch (e) {
      debugPrint('Error initializing services: $e');
      _showErrorMessage('Error al inicializar los servicios');
    }
  }

  Future<void> _initializeNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar permisos
      await _checkNotificationPermissions();

      // Cargar estado guardado de las notificaciones
      await _loadNotificationPreference();

      // Obtener el token FCM
      if (!_permissionDenied) {
        _fcmToken = await _notificationService.getToken();
        debugPrint('📱 FCM Token loaded: $_fcmToken');
      }

    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      _showErrorMessage('Error al cargar la configuración de notificaciones');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasCheckedPermissions = true;
        });
      }
    }
  }

  Future<void> _checkNotificationPermissions() async {
    try {
      final hasPermission = await _notificationService.hasPermission();

      if (mounted) {
        setState(() {
          _permissionDenied = !hasPermission;
        });
      }
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      if (mounted) {
        setState(() {
          _permissionDenied = true;
        });
      }
    }
  }

  Future<void> _loadNotificationPreference() async {
    try {
      final enabled = _prefs.getBool('notifications_enabled') ?? false;

      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
        });
      }
    } catch (e) {
      debugPrint('Error loading notification preference: $e');
    }
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    try {
      await _prefs.setBool('notifications_enabled', enabled);

      // Suscribir/desuscribir a topics generales
      if (enabled) {
        await _notificationService.subscribeToTopic('general');
        await _notificationService.subscribeToTopic('updates');
      } else {
        await _notificationService.unsubscribeFromTopic('general');
        await _notificationService.unsubscribeFromTopic('updates');
      }

      debugPrint('Notification preference saved: $enabled');
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
      rethrow;
    }
  }

  Future<bool> _requestNotificationPermissions() async {
    try {
      return await _notificationService.requestPermission();
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.white),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text(
        'Notificaciones',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 32),
          _buildNotificationToggle(),
          const SizedBox(height: 24),
          if (_permissionDenied) _buildPermissionWarning(),
          if (_notificationsEnabled && !_permissionDenied) _buildSuccessInfo(),
          if (_fcmToken != null && !_permissionDenied) ...[
            const SizedBox(height: 24),
            _buildTokenInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Verificando configuración...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 40,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Notificaciones MetraShop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mantente informado sobre actualizaciones de tus proyectos, nuevos artículos y funcionalidades importantes.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _notificationsEnabled
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.neutral300.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  size: 28,
                  color: _notificationsEnabled
                      ? AppColors.success
                      : AppColors.neutral500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recibir notificaciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _notificationsEnabled
                            ? AppColors.textPrimary
                            : AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _notificationsEnabled
                          ? 'Las notificaciones están activadas'
                          : 'Las notificaciones están desactivadas',
                      style: TextStyle(
                        fontSize: 14,
                        color: _notificationsEnabled
                            ? AppColors.success
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: _onNotificationToggle,
                  activeColor: AppColors.success,
                  activeTrackColor: AppColors.success.withOpacity(0.3),
                  inactiveThumbColor: AppColors.neutral400,
                  inactiveTrackColor: AppColors.neutral200,
                ),
              ),
            ],
          ),

          if (_notificationsEnabled || _permissionDenied) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _permissionDenied
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _permissionDenied
                      ? AppColors.warning.withOpacity(0.3)
                      : AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _permissionDenied
                        ? Icons.warning_rounded
                        : Icons.info_outline_rounded,
                    size: 20,
                    color: _permissionDenied
                        ? AppColors.warning
                        : AppColors.info,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _permissionDenied
                          ? 'Para recibir notificaciones, necesitas activar los permisos en la configuración de tu dispositivo.'
                          : 'Recibirás notificaciones sobre actualizaciones importantes y contenido relevante.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _permissionDenied
                            ? AppColors.warning
                            : AppColors.info,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  size: 24,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Permisos requeridos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Para activar las notificaciones, necesitas conceder permisos en la configuración de tu dispositivo. Esto es necesario para enviarte información importante sobre tus proyectos.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.error,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAppSettings,
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Abrir configuración'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 24,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Listo para recibir notificaciones!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Te mantendremos informado sobre las actualizaciones más importantes.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.success.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.key_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Token FCM',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _fcmToken ?? ''));
                  _showSuccessMessage('Token copiado al portapapeles');
                },
                tooltip: 'Copiar token',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _fcmToken ?? '',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Métodos de interacción
  Future<void> _onNotificationToggle(bool value) async {
    if (value && _permissionDenied) {
      // Si intenta activar pero no tiene permisos, solicitar permisos
      await _requestAndHandlePermissions();
      return;
    }

    // Feedback háptico
    HapticFeedback.lightImpact();

    try {
      // Mostrar loading durante el proceso
      setState(() {
        _isLoading = true;
      });

      if (value) {
        // Solicitar permisos si es la primera vez
        final hasPermission = await _requestNotificationPermissions();

        if (!hasPermission) {
          setState(() {
            _permissionDenied = true;
            _isLoading = false;
          });
          _showErrorMessage('Se requieren permisos para activar las notificaciones');
          return;
        }

        // Obtener token después de conceder permisos
        _fcmToken = await _notificationService.getToken();
      }

      // Guardar preferencia
      await _saveNotificationPreference(value);

      // Actualizar estado
      setState(() {
        _notificationsEnabled = value;
        _permissionDenied = false;
        _isLoading = false;
      });

      // Mostrar mensaje de confirmación
      _showSuccessMessage(
          value
              ? 'Notificaciones activadas correctamente'
              : 'Notificaciones desactivadas'
      );

    } catch (e) {
      debugPrint('Error toggling notifications: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error al actualizar la configuración');
    }
  }

  Future<void> _requestAndHandlePermissions() async {
    try {
      final hasPermission = await _requestNotificationPermissions();

      if (hasPermission) {
        setState(() {
          _permissionDenied = false;
        });
        // Intentar activar las notificaciones nuevamente
        await _onNotificationToggle(true);
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      _showErrorMessage('Error al solicitar permisos');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permisos de notificación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Para recibir notificaciones importantes sobre tus proyectos y actualizaciones de MetraShop, necesitas activar los permisos en la configuración de tu dispositivo.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Ahora no',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ir a configuración'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    try {
      // Aquí usarías permission_handler que ya tienes en pubspec.yaml
      // await openAppSettings();
      _showSuccessMessage('Abriendo configuración de la aplicación...');
    } catch (e) {
      _showErrorMessage('No se pudo abrir la configuración');
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    showSnackBar(context, message);
  }
}
