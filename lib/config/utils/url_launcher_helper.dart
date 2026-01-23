import 'package:url_launcher/url_launcher.dart';

/// Helper para abrir URLs externas de manera segura
class UrlLauncherHelper {
  /// Abre la política de privacidad
  static Future<bool> openPrivacyPolicy() async {
    const url = 'https://metrashopapp.com/privacy-policy.html';
    return await openUrl(url);
  }

  /// Abre los términos de servicio
  static Future<bool> openTermsOfService() async {
    const url = 'https://metrashopapp.com/terms-of-service.html';
    return await openUrl(url);
  }

  /// Abre una URL genérica
  static Future<bool> openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return false;
      }
    } catch (e) {
      print('Error opening URL: $e');
      return false;
    }
  }

  /// Abre el email de contacto
  static Future<bool> openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    return await openUrl(uri.toString());
  }

  /// Abre WhatsApp
  static Future<bool> openWhatsApp(String phone, [String? message]) async {
    final encodedMessage = message != null ? Uri.encodeComponent(message) : '';
    final url = 'https://wa.me/$phone?text=$encodedMessage';
    return await openUrl(url);
  }
}
