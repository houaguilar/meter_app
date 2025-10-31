import 'package:flutter/material.dart';

/// Handler para procesar notificaciones y navegar según el tipo
class NotificationHandler {
  /// Maneja cuando se recibe una notificación en foreground
  static void handleForegroundNotification(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final data = notification['data'] as Map<String, dynamic>? ?? {};

    debugPrint('📨 Foreground notification:');
    debugPrint('Title: $title');
    debugPrint('Body: $body');
    debugPrint('Data: $data');

    // Mostrar un SnackBar o diálogo cuando la notificación llega en foreground
    _showForegroundNotification(context, title, body);

    // Procesar según el tipo de notificación
    _processNotificationData(context, data);
  }

  /// Maneja cuando el usuario toca una notificación
  static void handleNotificationTap(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final data = notification['data'] as Map<String, dynamic>? ?? {};

    debugPrint('📲 Notification tapped:');
    debugPrint('Title: $title');
    debugPrint('Body: $body');
    debugPrint('Data: $data');

    // Navegar según el tipo de notificación
    _processNotificationData(context, data);
  }

  /// Procesa los datos de la notificación y navega si es necesario
  static void _processNotificationData(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    if (data.isEmpty) return;

    final type = data['type'] as String?;
    final route = data['route'] as String?;
    final id = data['id'] as String?;

    debugPrint('Processing notification - Type: $type, Route: $route, ID: $id');

    // Navegar según el tipo de notificación
    switch (type) {
      case 'project':
        if (id != null) {
          // Navigator.of(context).pushNamed('/project/$id');
          debugPrint('Navigate to project: $id');
        }
        break;

      case 'article':
        if (id != null) {
          // Navigator.of(context).pushNamed('/article/$id');
          debugPrint('Navigate to article: $id');
        }
        break;

      case 'update':
        // Navigator.of(context).pushNamed('/updates');
        debugPrint('Navigate to updates');
        break;

      case 'location':
        if (id != null) {
          // Navigator.of(context).pushNamed('/location/$id');
          debugPrint('Navigate to location: $id');
        }
        break;

      default:
        if (route != null) {
          // Navigator.of(context).pushNamed(route);
          debugPrint('Navigate to custom route: $route');
        }
    }
  }

  /// Muestra una notificación en foreground usando un SnackBar
  static void _showForegroundNotification(
    BuildContext context,
    String title,
    String body,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(body),
            ],
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Aquí podrías navegar a la pantalla correspondiente
            debugPrint('SnackBar action tapped');
          },
        ),
      ),
    );
  }
}
