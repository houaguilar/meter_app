import 'package:flutter/material.dart';
import 'package:meter_app/presentation/assets/images.dart';
import 'package:url_launcher/url_launcher.dart';


class ProvidersList extends StatelessWidget {
  const ProvidersList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0.0),
      children: [
        ProviderCard(
          providerName: 'SIDEREXPRESS',
          providerDescription: 'Venta de materiales de construcción online, cotiza y compra desde tu celular',
          imageUrl: AppImages.expressImg,
          salesCount: 567,
          onWhatsAppPressed: () => _launchWhatsApp('51943529146'),
          onProductsPressed: _navigateToProducts,
          onQuotePressed: () => _navigateToQuote('51910297550', 'https://yndbqhfzxxoxsnxizoab.supabase.co/storage/v1/object/public/pdf/materiales.pdf?t=2024-11-12T23%3A20%3A58.916Z'),
        ),
        ProviderCard(
          providerName: 'EQUIPCONSTRUYE',
          providerDescription: 'Venta de materiales de construcción online, cotiza y compra desde tu celular',
          imageUrl: AppImages.equipImg,
          salesCount: 567,
          onWhatsAppPressed: () => _launchWhatsApp('51912188792'),
          onProductsPressed: _navigateToProducts,
          onQuotePressed: () => _navigateToQuote('51925912926', 'https://yndbqhfzxxoxsnxizoab.supabase.co/storage/v1/object/public/pdf/materiales.pdf?t=2024-11-12T23%3A20%3A58.916Z'),
        ),
      ],
    );
  }

  void _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone?text=Buenas');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir WhatsApp para $phone';
    }
  }

  static void _navigateToProducts() {
    // Navegación a pantalla de productos
  }

  void _navigateToQuote(String phone, String pdfUrl) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone?text= PDF: $pdfUrl');
    if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
    throw 'No se pudo abrir WhatsApp para $phone';
    }
  }
}

class ProviderCard extends StatelessWidget {
  final String providerName;
  final String providerDescription;
  final String imageUrl;
  final int salesCount;
  final VoidCallback onWhatsAppPressed;
  final VoidCallback onProductsPressed;
  final VoidCallback onQuotePressed;

  const ProviderCard({
    super.key,
    required this.providerName,
    required this.providerDescription,
    required this.imageUrl,
    required this.salesCount,
    required this.onWhatsAppPressed,
    required this.onProductsPressed,
    required this.onQuotePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Image.asset(
                  imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ventas \nrealizadas ($salesCount)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(5, (_) => const Icon(Icons.star, color: Colors.orange, size: 16)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    providerDescription,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Image.asset(AppImages.whatsappImg, height: 30, width: 30, fit: BoxFit.cover,),
                        iconSize: 24,
                        onPressed: onWhatsAppPressed,
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: onProductsPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Productos', style: TextStyle(fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onQuotePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Cotizar', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

