/// Repositorio abstracto para manejo de notificaciones push
abstract class NotificationRepository {
  /// Inicializa el servicio de notificaciones
  Future<void> initialize();

  /// Solicita permisos de notificaciones al usuario
  /// Retorna true si se concedieron los permisos
  Future<bool> requestPermission();

  /// Verifica si se han concedido los permisos de notificaciones
  Future<bool> hasPermission();

  /// Obtiene el token FCM del dispositivo
  Future<String?> getToken();

  /// Suscribe al usuario a un topic
  Future<void> subscribeToTopic(String topic);

  /// Desuscribe al usuario de un topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Configura el listener para notificaciones en foreground
  void onMessageReceived(Function(Map<String, dynamic>) handler);

  /// Configura el listener para cuando el usuario toca una notificación
  void onMessageOpenedApp(Function(Map<String, dynamic>) handler);

  /// Obtiene el mensaje inicial si la app se abrió desde una notificación
  /// mientras estaba terminada
  Future<Map<String, dynamic>?> getInitialMessage();

  /// Elimina el token FCM (útil para logout)
  Future<void> deleteToken();
}
