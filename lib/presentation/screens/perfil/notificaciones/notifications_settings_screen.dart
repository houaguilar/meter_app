// lib/presentation/screens/perfil/notificaciones/notifications_settings_screen_v2.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../domain/entities/notifications/notification_settings.dart';
import '../../../providers/notifications/notification_settings_providers.dart';

/// Versión mejorada de NotificationsSettingsScreen usando Riverpod
/// con notificaciones granulares y manejo robusto de errores
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Cargar configuración inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationSettingsNotifierProvider.notifier).reload();
    });
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
    if (state == AppLifecycleState.resumed) {
      ref
          .read(notificationSettingsNotifierProvider.notifier)
          .checkPermissionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar errores
    ref.listen<String?>(notificationErrorMessageProvider, (previous, next) {
      if (next != null) {
        showSnackBar(context, next);
        // Limpiar el error después de mostrarlo
        Future.delayed(const Duration(seconds: 3), () {
          ref.read(notificationErrorMessageProvider.notifier).clear();
        });
      }
    });

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
      actions: [
        // Botón para resetear configuración (solo en modo debug)
        if (const bool.fromEnvironment('dart.vm.product') == false)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              await ref
                  .read(notificationSettingsNotifierProvider.notifier)
                  .reset();
              if (mounted) {
                _showSuccessMessage('Configuración reseteada');
              }
            },
            tooltip: 'Resetear configuración',
          ),
      ],
    );
  }

  Widget _buildBody() {
    final isLoading = ref.watch(isNotificationLoadingProvider);
    final settings = ref.watch(notificationSettingsNotifierProvider);

    if (isLoading) {
      return _buildLoadingState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 32),

          // Sección de permisos del sistema
          if (!settings.systemPermissionGranted) _buildPermissionWarning(),
          if (settings.systemPermissionGranted) ...[
            _buildSystemPermissionGranted(),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 16),

          // Título de categorías
          const Text(
            'Categorías de notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona qué tipo de notificaciones deseas recibir',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Opciones granulares
          _buildNotificationOption(
            title: 'Notificaciones generales',
            description: 'Información general sobre la aplicación',
            icon: Icons.notifications_active_rounded,
            enabled: settings.generalEnabled,
            onChanged: settings.systemPermissionGranted
                ? (value) => ref
                    .read(notificationSettingsNotifierProvider.notifier)
                    .toggleGeneral(value)
                : null,
          ),
          const SizedBox(height: 12),
          _buildNotificationOption(
            title: 'Actualizaciones',
            description: 'Nuevas funcionalidades y mejoras de la app',
            icon: Icons.system_update_rounded,
            enabled: settings.updatesEnabled,
            onChanged: settings.systemPermissionGranted
                ? (value) => ref
                    .read(notificationSettingsNotifierProvider.notifier)
                    .toggleUpdates(value)
                : null,
          ),
          const SizedBox(height: 12),
          _buildNotificationOption(
            title: 'Proyectos',
            description: 'Cambios y actualizaciones en tus proyectos',
            icon: Icons.folder_open_rounded,
            enabled: settings.projectsEnabled,
            onChanged: settings.systemPermissionGranted
                ? (value) => ref
                    .read(notificationSettingsNotifierProvider.notifier)
                    .toggleProjects(value)
                : null,
          ),
          const SizedBox(height: 12),

          // Botones de acción rápida
          if (settings.systemPermissionGranted) ...[
            const SizedBox(height: 24),
            _buildQuickActions(settings),
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
            'Cargando configuración...',
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
            'Personaliza las notificaciones que deseas recibir. Mantente informado sobre lo que más te importa.',
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
            'Para recibir notificaciones, necesitas conceder permisos en la configuración del sistema. Esto te permitirá estar al tanto de información importante.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.error,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.shield_rounded),
                  label: const Text('Solicitar permisos'),
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
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openAppSettings,
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Configuración'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPermissionGranted() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
              size: 20,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Permisos otorgados correctamente',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String description,
    required IconData icon,
    required bool enabled,
    required void Function(bool)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.neutral300,
          width: 1,
        ),
        boxShadow: [
          if (enabled)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChanged != null ? () => onChanged(!enabled) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: enabled ? AppColors.primary : AppColors.neutral500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: enabled
                              ? AppColors.textSecondary
                              : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: enabled,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(NotificationSettings settings) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();
              await ref
                  .read(notificationSettingsNotifierProvider.notifier)
                  .enableAll();
              if (mounted) {
                _showSuccessMessage('Todas las notificaciones activadas');
              }
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Activar todas'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();
              await ref
                  .read(notificationSettingsNotifierProvider.notifier)
                  .disableAll();
              if (mounted) {
                _showSuccessMessage('Todas las notificaciones desactivadas');
              }
            },
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Desactivar todas'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.neutral300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS DE INTERACCIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _requestPermission() async {
    HapticFeedback.lightImpact();

    final granted = await ref
        .read(notificationSettingsNotifierProvider.notifier)
        .requestPermission();

    if (mounted) {
      if (granted) {
        _showSuccessMessage('Permisos otorgados correctamente');
      } else {
        _showPermissionDialog();
      }
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
          'Para recibir notificaciones importantes, necesitas activar los permisos en la configuración de tu dispositivo.',
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
      final opened = await openAppSettings();
      if (opened && mounted) {
        _showSuccessMessage('Abriendo configuración...');
      } else if (mounted) {
        showSnackBar(context, 'No se pudo abrir la configuración');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al abrir la configuración');
      }
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
}
