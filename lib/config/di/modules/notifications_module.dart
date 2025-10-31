import 'package:get_it/get_it.dart';
import 'package:meter_app/config/notifications/firebase_notification_service.dart';
import 'package:meter_app/config/notifications/notification_repository.dart';

/// Módulo para gestión de notificaciones push (Firebase Cloud Messaging)
void registerNotificationsModule(GetIt sl) {
  // Notification Service
  sl.registerLazySingleton<NotificationRepository>(
    () => FirebaseNotificationService(),
  );
}
