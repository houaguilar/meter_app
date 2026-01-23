// lib/presentation/providers/notifications/notification_settings_providers.dart
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/notifications/notification_repository.dart';
import '../../../domain/entities/notifications/notification_settings.dart';
import '../../../init_dependencies.dart';

part 'notification_settings_providers.g.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONSTANTES
// ═══════════════════════════════════════════════════════════════════════════

const String _kNotificationSettingsKey = 'notification_settings_v2';

// ═══════════════════════════════════════════════════════════════════════════
// ESTADOS
// ═══════════════════════════════════════════════════════════════════════════

/// Estado para el loading de las notificaciones
enum NotificationLoadingState {
  idle,
  loading,
  loaded,
  error,
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para el estado de carga
@riverpod
class NotificationLoadingStatus extends _$NotificationLoadingStatus {
  @override
  NotificationLoadingState build() => NotificationLoadingState.idle;

  void setLoading() => state = NotificationLoadingState.loading;
  void setLoaded() => state = NotificationLoadingState.loaded;
  void setError() => state = NotificationLoadingState.error;
  void setIdle() => state = NotificationLoadingState.idle;
}

/// Provider para mensajes de error
@riverpod
class NotificationErrorMessage extends _$NotificationErrorMessage {
  @override
  String? build() => null;

  void setError(String message) => state = message;
  void clear() => state = null;
}

/// Provider principal para las configuraciones de notificaciones
/// Mantiene el estado en memoria y sincroniza con SharedPreferences
@Riverpod(keepAlive: true)
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  late final NotificationRepository _notificationService;
  late final SharedPreferences _prefs;

  @override
  NotificationSettings build() {
    _notificationService = serviceLocator<NotificationRepository>();
    _prefs = serviceLocator<SharedPreferences>();

    // Cargar configuración guardada
    _loadSettings();

    return const NotificationSettings();
  }

  /// Carga las configuraciones desde SharedPreferences
  Future<void> _loadSettings() async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();

      final jsonString = _prefs.getString(_kNotificationSettingsKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = NotificationSettings.fromJson(json);
      }

      // Actualizar el estado del permiso del sistema
      final hasPermission = await _notificationService.hasPermission();
      state = state.copyWith(systemPermissionGranted: hasPermission);

      // Obtener el token FCM
      final token = await _notificationService.getToken();
      if (token != null) {
        state = state.copyWith(fcmToken: token);
      }

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error cargando configuración de notificaciones: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al cargar configuración');
    }
  }

  /// Guarda las configuraciones en SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final jsonString = jsonEncode(state.toJson());
      await _prefs.setString(_kNotificationSettingsKey, jsonString);
      debugPrint('✅ Configuración de notificaciones guardada');
    } catch (e) {
      debugPrint('❌ Error guardando configuración: $e');
      throw Exception('Error al guardar configuración');
    }
  }

  /// Actualiza las suscripciones de tópicos basado en el estado actual
  Future<void> _updateTopicSubscriptions() async {
    try {
      // General topic
      if (state.generalEnabled) {
        await _notificationService.subscribeToTopic('general');
      } else {
        await _notificationService.unsubscribeFromTopic('general');
      }

      // Updates topic
      if (state.updatesEnabled) {
        await _notificationService.subscribeToTopic('updates');
      } else {
        await _notificationService.unsubscribeFromTopic('updates');
      }

      // Projects topic
      if (state.projectsEnabled) {
        await _notificationService.subscribeToTopic('projects');
      } else {
        await _notificationService.unsubscribeFromTopic('projects');
      }

      // Articles topic
      if (state.articlesEnabled) {
        await _notificationService.subscribeToTopic('articles');
      } else {
        await _notificationService.unsubscribeFromTopic('articles');
      }

      // Location topic
      if (state.locationEnabled) {
        await _notificationService.subscribeToTopic('location');
      } else {
        await _notificationService.unsubscribeFromTopic('location');
      }

      debugPrint('✅ Suscripciones de tópicos actualizadas');
    } catch (e) {
      debugPrint('❌ Error actualizando suscripciones: $e');
      throw Exception('Error al actualizar suscripciones');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS PÚBLICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Solicita permisos del sistema para notificaciones
  Future<bool> requestPermission() async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      final granted = await _notificationService.requestPermission();
      state = state.copyWith(systemPermissionGranted: granted);

      if (granted) {
        // Si se otorgó el permiso, obtener el token
        final token = await _notificationService.getToken();
        if (token != null) {
          state = state.copyWith(fcmToken: token);
        }
      }

      await _saveSettings();
      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();

      return granted;
    } catch (e) {
      debugPrint('❌ Error solicitando permiso: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al solicitar permisos');
      return false;
    }
  }

  /// Verifica el estado actual del permiso del sistema
  Future<void> checkPermissionStatus() async {
    try {
      final hasPermission = await _notificationService.hasPermission();
      state = state.copyWith(systemPermissionGranted: hasPermission);
      await _saveSettings();
    } catch (e) {
      debugPrint('❌ Error verificando permisos: $e');
    }
  }

  /// Habilita/deshabilita notificaciones generales
  Future<void> toggleGeneral(bool enabled) async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      state = state.copyWith(generalEnabled: enabled);
      await _updateTopicSubscriptions();
      await _saveSettings();

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error actualizando notificaciones generales: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al actualizar configuración');
      // Revertir el cambio
      state = state.copyWith(generalEnabled: !enabled);
    }
  }

  /// Habilita/deshabilita notificaciones de actualizaciones
  Future<void> toggleUpdates(bool enabled) async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      state = state.copyWith(updatesEnabled: enabled);
      await _updateTopicSubscriptions();
      await _saveSettings();

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error actualizando notificaciones de updates: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al actualizar configuración');
      state = state.copyWith(updatesEnabled: !enabled);
    }
  }

  /// Habilita/deshabilita notificaciones de proyectos
  Future<void> toggleProjects(bool enabled) async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      state = state.copyWith(projectsEnabled: enabled);
      await _updateTopicSubscriptions();
      await _saveSettings();

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error actualizando notificaciones de proyectos: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al actualizar configuración');
      state = state.copyWith(projectsEnabled: !enabled);
    }
  }

  /// Habilita/deshabilita notificaciones de artículos
  Future<void> toggleArticles(bool enabled) async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      state = state.copyWith(articlesEnabled: enabled);
      await _updateTopicSubscriptions();
      await _saveSettings();

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error actualizando notificaciones de artículos: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al actualizar configuración');
      state = state.copyWith(articlesEnabled: !enabled);
    }
  }

  /// Habilita/deshabilita notificaciones de ubicación
  Future<void> toggleLocation(bool enabled) async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      state = state.copyWith(locationEnabled: enabled);
      await _updateTopicSubscriptions();
      await _saveSettings();

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error actualizando notificaciones de ubicación: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al actualizar configuración');
      state = state.copyWith(locationEnabled: !enabled);
    }
  }

  /// Habilita todas las notificaciones
  Future<void> enableAll() async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      state = state.copyWith(
        generalEnabled: true,
        updatesEnabled: true,
        projectsEnabled: true,
        articlesEnabled: true,
        locationEnabled: true,
      );

      await _updateTopicSubscriptions();
      await _saveSettings();

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error habilitando todas las notificaciones: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al habilitar notificaciones');
    }
  }

  /// Deshabilita todas las notificaciones
  Future<void> disableAll() async {
    try {
      ref.read(notificationLoadingStatusProvider.notifier).setLoading();
      ref.read(notificationErrorMessageProvider.notifier).clear();

      state = state.copyWith(
        generalEnabled: false,
        updatesEnabled: false,
        projectsEnabled: false,
        articlesEnabled: false,
        locationEnabled: false,
      );

      await _updateTopicSubscriptions();
      await _saveSettings();

      ref.read(notificationLoadingStatusProvider.notifier).setLoaded();
    } catch (e) {
      debugPrint('❌ Error deshabilitando todas las notificaciones: $e');
      ref.read(notificationLoadingStatusProvider.notifier).setError();
      ref
          .read(notificationErrorMessageProvider.notifier)
          .setError('Error al deshabilitar notificaciones');
    }
  }

  /// Recarga la configuración desde el almacenamiento
  Future<void> reload() async {
    await _loadSettings();
  }

  /// Resetea toda la configuración
  Future<void> reset() async {
    try {
      await _prefs.remove(_kNotificationSettingsKey);
      state = const NotificationSettings();
      await _updateTopicSubscriptions();
      debugPrint('✅ Configuración de notificaciones reseteada');
    } catch (e) {
      debugPrint('❌ Error reseteando configuración: $e');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que indica si alguna notificación está habilitada
@riverpod
bool hasAnyNotificationEnabled(HasAnyNotificationEnabledRef ref) {
  final settings = ref.watch(notificationSettingsNotifierProvider);
  return settings.hasAnyEnabled;
}

/// Provider que indica si el loading está activo
@riverpod
bool isNotificationLoading(IsNotificationLoadingRef ref) {
  final status = ref.watch(notificationLoadingStatusProvider);
  return status == NotificationLoadingState.loading;
}

/// Función auxiliar para debugPrint (para evitar import flutter)
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
