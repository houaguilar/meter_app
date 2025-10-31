import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_repository.dart';

/// Handler global para notificaciones en background
/// Debe ser una función top-level o estática
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

class FirebaseNotificationService implements NotificationRepository {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Callbacks para manejar mensajes
  Function(Map<String, dynamic>)? _onMessageReceivedHandler;
  Function(Map<String, dynamic>)? _onMessageOpenedHandler;

  @override
  Future<void> initialize() async {
    try {
      debugPrint('🔔 Initializing Firebase Notifications...');

      // Configurar el handler para mensajes en background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Solicitar permisos automáticamente en iOS
      await requestPermission();

      // Configurar manejo de notificaciones en foreground
      await _configureForegroundNotifications();

      // Configurar listeners
      _setupMessageListeners();

      // Obtener el token FCM
      final token = await getToken();
      debugPrint('✅ FCM Token: $token');

      debugPrint('✅ Firebase Notifications initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Notifications: $e');
      rethrow;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint('🔐 Notification permission status: ${settings.authorizationStatus}');
      return isAuthorized;
    } catch (e) {
      debugPrint('❌ Error requesting permission: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('❌ Error checking permission: $e');
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('📱 FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic $topic: $e');
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic $topic: $e');
      rethrow;
    }
  }

  @override
  void onMessageReceived(Function(Map<String, dynamic>) handler) {
    _onMessageReceivedHandler = handler;
  }

  @override
  void onMessageOpenedApp(Function(Map<String, dynamic>) handler) {
    _onMessageOpenedHandler = handler;
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('✅ FCM Token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting token: $e');
      rethrow;
    }
  }

  /// Configura cómo se muestran las notificaciones en foreground
  Future<void> _configureForegroundNotifications() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Mostrar alerta
      badge: true, // Actualizar badge
      sound: true, // Reproducir sonido
    );
  }

  /// Configura los listeners para diferentes estados de las notificaciones
  void _setupMessageListeners() {
    // Cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Foreground message received: ${message.messageId}');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      if (_onMessageReceivedHandler != null) {
        final data = {
          'messageId': message.messageId ?? '',
          'title': message.notification?.title ?? '',
          'body': message.notification?.body ?? '',
          'data': message.data,
        };
        _onMessageReceivedHandler!(data);
      }
    });

    // Cuando el usuario toca una notificación y abre la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 Notification tapped: ${message.messageId}');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      if (_onMessageOpenedHandler != null) {
        final data = {
          'messageId': message.messageId ?? '',
          'title': message.notification?.title ?? '',
          'body': message.notification?.body ?? '',
          'data': message.data,
        };
        _onMessageOpenedHandler!(data);
      }
    });
  }

  /// Obtiene el mensaje inicial si la app fue abierta desde una notificación
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }
}
