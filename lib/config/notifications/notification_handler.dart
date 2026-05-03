import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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


    // Mostrar un SnackBar cuando la notificación llega en foreground
    _showForegroundNotification(context, title, body, data: data);
  }

  /// Maneja cuando el usuario toca una notificación
  static void handleNotificationTap(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final data = notification['data'] as Map<String, dynamic>? ?? {};


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
    final projectName = data['projectName'] as String?;
    final articleTitle = data['articleTitle'] as String?;
    final videoId = data['videoId'] as String?;


    if (!context.mounted) {
      return;
    }

    // Navegar según el tipo de notificación
    switch (type) {
      case 'project':
        if (id != null && projectName != null) {
          context.push('/projects/$id/$projectName');
        } else {
          // Si no hay ID específico, ir a la lista de proyectos
          context.push('/projects');
        }
        break;

      case 'article':
        if (id != null && articleTitle != null) {
          // Navegar al detalle del artículo
          final title = Uri.encodeComponent(articleTitle);
          final video = videoId ?? '';
          context.push('/home/detail/$id/$title/$video');
        } else {
          // Si no hay ID específico, ir a la lista de artículos
          context.push('/articles');
        }
        break;

      case 'update':
        // Navegar a la pantalla de inicio donde se muestran las actualizaciones
        context.go('/home');
        break;

      case 'location':
        // Navegar al mapa
        context.push('/home/home-to-provider');
        break;

      default:
        // Si hay una ruta personalizada, usarla
        if (route != null) {
          try {
            context.push(route);
          } catch (e) {
          }
        } else {
        }
    }
  }

  /// Muestra una notificación en foreground usando un SnackBar
  static void _showForegroundNotification(
    BuildContext context,
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) {
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
        action: data != null && data.isNotEmpty
            ? SnackBarAction(
                label: 'Ver',
                textColor: Colors.white,
                onPressed: () {
                  // Navegar a la pantalla correspondiente
                  _processNotificationData(context, data);
                },
              )
            : null,
      ),
    );
  }
}
