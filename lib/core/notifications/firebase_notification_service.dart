import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:meter_app/core/notifications/notification_repository.dart';

/// Handler global para notificaciones en background
/// Debe ser una función top-level o estática
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

class FirebaseNotificationService implements NotificationRepository {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Callbacks para manejar mensajes
  Function(Map<String, dynamic>)? _onMessageReceivedHandler;
  Function(Map<String, dynamic>)? _onMessageOpenedHandler;

  // Subscriptions almacenadas para prevenir duplicados si initialize() se llama más de una vez
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;

  @override
  Future<void> initialize() async {
    try {

      // Handler de background deshabilitado hasta que se active el envío de
      // notificaciones en producción. Habilitarlo crea un segundo Flutter engine
      // que compite por GPU con el engine principal, pudiendo causar ANR.
      // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Solicitar permisos automáticamente en iOS
      await requestPermission();

      // Configurar manejo de notificaciones en foreground
      await _configureForegroundNotifications();

      // Configurar listeners
      _setupMessageListeners();

      // Obtener el token FCM
      final token = await getToken();

    } catch (e) {
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

      return isAuthorized;
    } catch (e) {
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
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
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
    } catch (e) {
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
    // Cancelar subscriptions previas para evitar duplicados
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();

    // Cuando la app está en foreground
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {

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
    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

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
  @override
  Future<Map<String, dynamic>?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) return null;

    return {
      'messageId': message.messageId ?? '',
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
    };
  }
}
