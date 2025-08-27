
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_config.dart';
import '../../../domain/entities/premium/premium_status.dart';
import '../../blocs/premium/premium_bloc.dart';
import 'mock_development_panel.dart';
import 'premium_status_indicator.dart';

class PremiumPaywallScreen extends StatelessWidget {
  const PremiumPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PremiumBloc, PremiumState>(
          listener: (context, state) {
            if (state is PurchaseSuccess) {
              _showSuccessDialog(context, state.newStatus);
            } else if (state is PurchaseFailure) {
              _showErrorSnackBar(context, state.message);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildFeaturesList(),
                const SizedBox(height: 32),
                _buildPricingCard(context),
                const SizedBox(height: 24),
                _buildActionButtons(context),
                const SizedBox(height: 16),
                _buildFooterLinks(context),
                const SizedBox(height: 24),

                // Panel de desarrollo solo en modo mock
                if (AppConfig.isDevelopment)
                  const MockDevelopmentPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const PremiumStatusIndicator(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star,
            size: 50,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Desbloquea Premium',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Accede a todas las funciones avanzadas y mejora tu experiencia',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.analytics,
        'title': 'Análisis Avanzados',
        'description': 'Estadísticas detalladas y reportes personalizados',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Sincronización Ilimitada',
        'description': 'Sincroniza todos tus datos en todos tus dispositivos',
      },
      {
        'icon': Icons.palette,
        'title': 'Temas Premium',
        'description': 'Personaliza la apariencia con temas exclusivos',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Soporte Prioritario',
        'description': 'Recibe ayuda prioritaria de nuestro equipo',
      },
      {
        'icon': Icons.backup,
        'title': 'Respaldos Automáticos',
        'description': 'Tus datos siempre seguros en la nube',
      },
      {
        'icon': Icons.offline_bolt,
        'title': 'Funciones Offline',
        'description': 'Trabaja sin conexión con funciones avanzadas',
      },
    ];

    return Column(
      children: features.map((feature) => _buildFeatureItem(
        icon: feature['icon'] as IconData,
        title: feature['title'] as String,
        description: feature['description'] as String,
      )).toList(),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Plan Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                AppConfig.isDevelopment ? '0.00' : '9.99',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '/mes',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (AppConfig.isDevelopment) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'MODO DESARROLLO',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text(
            '• Cancela cuando quieras\n• Sin compromisos\n• Activación inmediata',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        final isLoading = state is PremiumLoading ||
            state is PurchaseInProgress ||
            (state is PremiumLoaded && state.isPerformingAction);

        PremiumStatus? currentStatus;
        if (state is PremiumLoaded) {
          currentStatus = state.status;
        } else if (state is PurchaseInProgress) {
          currentStatus = state.currentStatus;
        } else if (state is PurchaseFailure) {
          currentStatus = state.currentStatus;
        }

        // Si ya es premium y activo, mostrar estado
        if (currentStatus?.isActive == true) {
          return _buildAlreadyPremiumCard(currentStatus!);
        }

        return Column(
          children: [
            // Botón principal de compra
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : () {
                  context.read<PremiumBloc>().add(PurchaseMonthlySubscription());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  AppConfig.isDevelopment
                      ? 'Simular Compra Premium'
                      : 'Suscribirse a Premium',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón de restaurar compras
            TextButton(
              onPressed: isLoading ? null : () {
                context.read<PremiumBloc>().add(RestorePurchases());
              },
              child: const Text(
                'Restaurar Compras',
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Botón de trial solo en modo desarrollo
            if (AppConfig.isDevelopment) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : () {
                    context.read<PremiumBloc>().add(GrantTrialPremium());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                    side: BorderSide(color: Colors.green.shade600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '🎁 Probar Premium Gratis (7 días)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAlreadyPremiumCard(PremiumStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 48,
          ),
          const SizedBox(height: 12),

          Text(
            '¡Ya eres Premium!',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          if (status.premiumUntil != null) ...[
            Text(
              'Tu suscripción ${status.source.isMock ? "mock " : ""}expira el:',
              style: TextStyle(
                color: Colors.green.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatExpirationDate(status.premiumUntil!),
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (status.timeRemainingFormatted.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                status.timeRemainingFormatted,
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],

          if (status.source.isMock) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Premium Mock - ${status.source.displayName}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => _launchUrl(AppConfig.termsOfServiceUrl),
              child: const Text(
                'Términos de Servicio',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
              width: 1,
              height: 12,
              color: Colors.grey.shade400,
            ),
            TextButton(
              onPressed: () => _launchUrl(AppConfig.privacyPolicyUrl),
              child: const Text(
                'Política de Privacidad',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),

        if (AppConfig.isDevelopment) ...[
          const SizedBox(height: 8),
          Text(
            'Modo Desarrollo: Las compras son simuladas',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  void _showSuccessDialog(BuildContext context, PremiumStatus status) {
    // Mostrar SnackBar en lugar de diálogo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¡Bienvenido a Premium!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu suscripción está activa${status.source.isMock ? " (Mock)" : ""}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // Cerrar paywall después de un momento
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ),
    );

    // Cerrar automáticamente el paywall después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        print('🔍 Success: Paywall cerrado automáticamente');
      }
    });
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  String _formatExpirationDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      print('Error abriendo URL: $e');
    }
  }

}