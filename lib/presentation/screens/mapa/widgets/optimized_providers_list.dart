// lib/presentation/screens/mapa/widgets/optimized_providers_list.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/theme.dart';
import '../../../assets/images.dart';

class OptimizedProvidersList extends StatelessWidget {
  const OptimizedProvidersList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _providers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return OptimizedProviderCard(provider: _providers[index]);
      },
    );
  }

  static final List<ProviderModel> _providers = [
    ProviderModel(
      name: 'SIDEREXPRESS',
      description: 'Venta de materiales de construcción online, cotiza y compra desde tu celular',
      imageUrl: AppImages.expressImg,
      salesCount: 567,
      rating: 4.8,
      phone: '51943529146',
      pdfUrl: 'https://yndbqhfzxxoxsnxizoab.supabase.co/storage/v1/object/public/pdf/materiales.pdf?t=2024-11-12T23%3A20%3A58.916Z',
    ),
    ProviderModel(
      name: 'EQUIPCONSTRUYE',
      description: 'Venta de materiales de construcción online, cotiza y compra desde tu celular',
      imageUrl: AppImages.equipImg,
      salesCount: 432,
      rating: 4.6,
      phone: '51912188792',
      pdfUrl: 'https://yndbqhfzxxoxsnxizoab.supabase.co/storage/v1/object/public/pdf/materiales.pdf?t=2024-11-12T23%3A20%3A58.916Z',
    ),
  ];
}

class OptimizedProviderCard extends StatelessWidget {
  final ProviderModel provider;

  const OptimizedProviderCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProviderImage(),
          const SizedBox(width: 16),
          Expanded(
            child: _buildProviderInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderImage() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              provider.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.neutral100,
                  child: Icon(
                    Icons.store,
                    color: AppColors.neutral400,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${provider.salesCount}+',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                provider.name,
                style: AppTypography.h6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildRatingBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          provider.description,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            provider.rating.toString(),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.message,
          label: 'WhatsApp',
          color: Colors.green,
          onPressed: () => _launchWhatsApp(provider.phone),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.shopping_cart,
          label: 'Productos',
          color: AppColors.primary,
          onPressed: () => _showProductsSheet(context),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.description,
          label: 'Cotizar',
          color: AppColors.secondary,
          onPressed: () => _launchQuote(provider.phone, provider.pdfUrl),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone?text=Hola, vi tu negocio en MetraShop');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  Future<void> _launchQuote(String phone, String pdfUrl) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone?text=Hola, me interesa cotizar materiales. Catálogo: $pdfUrl');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching quote WhatsApp: $e');
    }
  }

  void _showProductsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Catálogo de ${provider.name}',
              style: AppTypography.h5,
            ),
            const SizedBox(height: 16),
            const Text(
              'Próximamente podrás ver todos nuestros productos directamente en la app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _launchWhatsApp(provider.phone);
                },
                child: const Text('Contactar por WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modelo de datos para proveedores
class ProviderModel {
  final String name;
  final String description;
  final String imageUrl;
  final int salesCount;
  final double rating;
  final String phone;
  final String pdfUrl;

  ProviderModel({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.salesCount,
    required this.rating,
    required this.phone,
    required this.pdfUrl,
  });
}