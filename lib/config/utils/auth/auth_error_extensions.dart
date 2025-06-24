// lib/config/utils/auth_error_extensions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_error_handler.dart';

/// Extensiones para el AuthErrorHandler con implementaciones específicas
extension AuthErrorHandlerExtensions on AuthErrorHandler {

  /// Implementa las acciones de navegación específicas para la app
  static void setupNavigationActions(BuildContext context) {
    // Configurar las acciones estáticas con el contexto actual
    _currentContext = context;
  }

  static BuildContext? _currentContext;

  /// Navega a la pantalla de registro
  static void navigateToRegister() {
    if (_currentContext?.mounted == true) {
      _currentContext!.pushNamed('register');
    }
  }

  /// Navega a la pantalla de login
  static void navigateToLogin() {
    if (_currentContext?.mounted == true) {
      _currentContext!.pop(); // Si está en register, volver a login
    }
  }

  /// Muestra diálogo de recuperación de contraseña
  static void showForgotPasswordDialog() {
    if (_currentContext?.mounted != true) return;

    showDialog<void>(
      context: _currentContext!,
      builder: (BuildContext context) {
        final emailController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: Colors.blue),
              SizedBox(width: 12),
              Text('Recuperar Contraseña'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Introduce tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí implementarías la lógica de recuperación de contraseña
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Si el correo existe, recibirás un enlace de recuperación'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  /// Contacta con el soporte técnico
  static void contactSupport() {
    _showSupportDialog();
  }

  /// Realiza logout del usuario
  static void logout() {
    if (_currentContext?.mounted != true) return;

    showDialog<void>(
      context: _currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.orange),
              SizedBox(width: 12),
              Text('Cerrar Sesión'),
            ],
          ),
          content: Text(
              'Para cambiar tu contraseña necesitas iniciar sesión nuevamente por seguridad.\n\n'
                  '¿Quieres cerrar sesión ahora?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí implementarías la lógica de logout
                // Por ejemplo: context.read<AuthBloc>().add(AuthLogout());
                _currentContext!.goNamed('metrashop');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra diálogo de soporte técnico
  static void _showSupportDialog() {
    if (_currentContext?.mounted != true) return;

    showDialog<void>(
      context: _currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.support_agent, color: Colors.green),
              SizedBox(width: 12),
              Text('Soporte Técnico'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puedes contactarnos a través de:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),

              // WhatsApp
              _buildSupportOption(
                icon: Icons.phone,
                title: 'WhatsApp',
                subtitle: '+51 999 999 999',
                onTap: () => _launchWhatsApp(),
              ),

              SizedBox(height: 12),

              // Email
              _buildSupportOption(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'soporte@metrashop.com',
                onTap: () => _launchEmail(),
              ),

              SizedBox(height: 12),

              // Horarios
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Horario de atención:\nLunes a Viernes: 8:00 AM - 6:00 PM\nSábados: 9:00 AM - 1:00 PM',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  /// Construye una opción de soporte
  static Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// Abre WhatsApp
  static void _launchWhatsApp() async {
    const phoneNumber = '51999999999'; // Número de ejemplo
    const message = 'Hola, necesito ayuda con mi cuenta de METRASHOP';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      if (_currentContext?.mounted == true) {
        ScaffoldMessenger.of(_currentContext!).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir WhatsApp. Contacta al +51 999 999 999'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Abre cliente de email
  static void _launchEmail() async {
    const email = 'soporte@metrashop.com';
    const subject = 'Solicitud de Soporte - METRASHOP';
    const body = 'Hola,\n\nNecesito ayuda con mi cuenta de METRASHOP.\n\nDescripción del problema:\n\n\nGracias.';

    final url = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'No se pudo abrir el cliente de correo';
      }
    } catch (e) {
      if (_currentContext?.mounted == true) {
        ScaffoldMessenger.of(_currentContext!).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el correo. Escribe a: soporte@metrashop.com'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}