// lib/presentation/screens/map/location_detail_hardcoded_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/utils/show_snackbar.dart';

class LocationDetailHardcodedScreen extends StatefulWidget {
  final String locationId;

  const LocationDetailHardcodedScreen({
    super.key,
    required this.locationId,
  });

  @override
  State<LocationDetailHardcodedScreen> createState() => _LocationDetailHardcodedScreenState();
}

class _LocationDetailHardcodedScreenState extends State<LocationDetailHardcodedScreen>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Datos hardcodeados
  final Map<String, dynamic> _locationData = {
    'id': '1',
    'title': 'Ferretería El Constructor',
    'description': 'Ferretería especializada en materiales de construcción y herramientas profesionales. Más de 20 años de experiencia en el sector.',
    'address': 'Av. Los Constructores 456, San Juan de Lurigancho, Lima',
    'imageUrl': 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800',
    'isProvider': true,
    'providerType': 'ferreteria',
    'businessHours': {
      'lunes': '8:00-18:00',
      'martes': '8:00-18:00',
      'miercoles': '8:00-18:00',
      'jueves': '8:00-18:00',
      'viernes': '8:00-18:00',
      'sabado': '8:00-16:00',
      'domingo': 'cerrado',
    },
    'contactInfo': {
      'phone': '+51987654321',
      'whatsapp': '+51987654321',
      'email': 'contacto@elconstructor.com',
    },
    'servicesOffered': ['delivery', 'credito', 'instalacion'],
    'products': [
      {
        'id': '1',
        'name': 'Arena gruesa',
        'category': 'Agregados',
        'unitType': 'm³',
        'priceMin': 45.0,
        'priceMax': 55.0,
        'availability': true,
        'description': 'Arena gruesa de calidad para construcción de cimientos y mezclas de concreto',
      },
      {
        'id': '2',
        'name': 'Cemento Sol',
        'category': 'Cemento',
        'unitType': 'bolsa',
        'priceMin': 25.0,
        'priceMax': 28.0,
        'availability': true,
        'description': 'Cemento Portland Tipo I, ideal para todo tipo de construcción',
      },
      {
        'id': '3',
        'name': 'Ladrillo King Kong',
        'category': 'Ladrillos',
        'unitType': 'unidad',
        'priceMin': 0.8,
        'priceMax': 1.2,
        'availability': true,
        'description': 'Ladrillo de arcilla con 18 huecos, medidas estándar',
      },
      {
        'id': '4',
        'name': 'Piedra chancada',
        'category': 'Agregados',
        'unitType': 'm³',
        'priceMin': 50.0,
        'priceMax': 60.0,
        'availability': true,
        'description': 'Piedra chancada de 1/2 pulgada para concreto estructural',
      },
      {
        'id': '5',
        'name': 'Fierro corrugado 12mm',
        'category': 'Acero',
        'unitType': 'varilla',
        'priceMin': 35.0,
        'priceMax': 45.0,
        'availability': false,
        'description': 'Fierro de construcción corrugado de 12mm - Temporalmente agotado',
      },
      {
        'id': '6',
        'name': 'Martillo de uña',
        'category': 'Herramientas',
        'unitType': 'unidad',
        'priceMin': 25.0,
        'priceMax': 45.0,
        'availability': true,
        'description': 'Martillo profesional con mango de fibra de vidrio',
      },
      {
        'id': '7',
        'name': 'Taladro percutor',
        'category': 'Herramientas',
        'unitType': 'unidad',
        'priceMin': 180.0,
        'priceMax': 250.0,
        'availability': true,
        'description': 'Taladro percutor 13mm con maletín y accesorios',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildLocationInfo(),
                  if (_locationData['isProvider']) ...[
                    _buildTabSection(),
                  ] else ...[
                    _buildBasicLocationContent(),
                  ],
                  SizedBox(height: context.spacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: context.colors.primary,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(context.spacing.sm),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(context.spacing.sm),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () => _shareLocation(),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _locationData['imageUrl'],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: context.colors.surface,
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.blue,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildDefaultImage(),
            ),
            // Gradiente mejorado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: context.spacing.md,
              left: context.spacing.md,
              right: context.spacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationData['title'],
                    style: context.typography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      SizedBox(width: context.spacing.xs),
                      Expanded(
                        child: Text(
                          _locationData['address'],
                          style: context.typography.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildDefaultImage() {
    return Container(
      color: context.colors.primary,
      child: Icon(
        Icons.store_rounded,
        size: 80,
        color: context.colors.blue,
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: EdgeInsets.all(context.spacing.md),
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.spacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: context.colors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                'Información General',
                style: context.typography.h5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Text(
            _locationData['description'],
            style: context.typography.bodyLarge.copyWith(
              height: 1.6,
              color: context.colors.textSecondary,
            ),
          ),
          if (_locationData['isProvider']) ...[
            SizedBox(height: context.spacing.md),
            _buildProviderTypeChip(_locationData['providerType']),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderTypeChip(String providerType) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.blue,
            context.colors.blue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getProviderIcon(providerType),
            size: 18,
            color: Colors.white,
          ),
          SizedBox(width: context.spacing.sm),
          Text(
            _getProviderTypeName(providerType),
            style: context.typography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: context.colors.blue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: context.colors.textSecondary,
            labelStyle: context.typography.buttonMedium,
            unselectedLabelStyle: context.typography.buttonMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
            indicatorPadding: EdgeInsets.all(context.spacing.xs),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Productos'),
              Tab(text: 'Contacto'),
            ],
          ),
        ),
        SizedBox(height: context.spacing.md),
        SizedBox(
          height: 450,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductsTab(),
              _buildContactTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    final products = _locationData['products'] as List;

    if (products.isEmpty) {
      return Container(
        margin: EdgeInsets.all(context.spacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.spacing.lg),
              decoration: BoxDecoration(
                color: context.colors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: context.spacing.md),
            Text(
              'No hay productos disponibles',
              style: context.typography.h6.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar productos por categoría
    final groupedProducts = <String, List<Map<String, dynamic>>>{};
    for (final product in products) {
      final category = product['category'] ?? 'Otros';
      groupedProducts.putIfAbsent(category, () => []).add(product);
    }

    return ListView.builder(
      padding: EdgeInsets.all(context.spacing.md),
      itemCount: groupedProducts.length,
      itemBuilder: (context, index) {
        final category = groupedProducts.keys.elementAt(index);
        final categoryProducts = groupedProducts[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) SizedBox(height: context.spacing.lg),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category.toUpperCase(),
                style: context.typography.h3.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: context.spacing.sm),
            ...categoryProducts.map((product) => _buildProductCard(product)),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final bool isAvailable = product['availability'] ?? true;

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.textSecondary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isAvailable ? () => _showProductDetail(product) : null,
          child: Padding(
            padding: EdgeInsets.all(context.spacing.md),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAvailable
                          ? [context.colors.blue, context.colors.blue.withOpacity(0.8)]
                          : [context.colors.textSecondary, context.colors.textSecondary.withOpacity(0.6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getProductIcon(product['category'] ?? ''),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: context.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product['name'],
                              style: context.typography.h6.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isAvailable
                                    ? context.colors.textPrimary
                                    : context.colors.textSecondary,
                              ),
                            ),
                          ),
                          if (!isAvailable)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.spacing.sm,
                                vertical: context.spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Agotado',
                                style: context.typography.h6.copyWith(
                                  color: context.colors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: context.spacing.xs),
                      Text(
                        'S/ ${product['priceMin'].toStringAsFixed(2)} - S/ ${product['priceMax'].toStringAsFixed(2)}',
                        style: context.typography.h6.copyWith(
                          color: context.colors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Por ${product['unitType']}',
                        style: context.typography.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      if (product['description'] != null) ...[
                        SizedBox(height: context.spacing.xs),
                        Text(
                          product['description'],
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.spacing.md),
      child: Column(
        children: [
          _buildContactButtons(),
          SizedBox(height: context.spacing.lg),
          _buildBusinessHours(),
          SizedBox(height: context.spacing.lg),
          _buildServicesOffered(),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    final contactInfo = _locationData['contactInfo'];

    return Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.spacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.phone_rounded,
                  color: context.colors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                'Contacto',
                style: context.typography.h5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              if (contactInfo['whatsapp'] != null) ...[
                Expanded(
                  child: _buildContactButton(
                    icon: Icons.chat_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _launchWhatsApp(contactInfo['whatsapp']),
                  ),
                ),
                SizedBox(width: context.spacing.sm),
              ],
              if (contactInfo['phone'] != null) ...[
                Expanded(
                  child: _buildContactButton(
                    icon: Icons.phone_rounded,
                    label: 'Llamar',
                    color: context.colors.blue,
                    onTap: () => _makePhoneCall(contactInfo['phone']),
                  ),
                ),
              ],
            ],
          ),
          if (contactInfo['email'] != null) ...[
            SizedBox(height: context.spacing.sm),
            _buildContactButton(
              icon: Icons.email_rounded,
              label: 'Enviar Email',
              color: context.colors.textSecondary,
              onTap: () => _sendEmail(contactInfo['email']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.spacing.md,
            horizontal: context.spacing.lg,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(width: context.spacing.sm),
              Text(
                label,
                style: context.typography.buttonMedium.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessHours() {
    final businessHours = _locationData['businessHours'] as Map<String, dynamic>;

    return Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.spacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: context.colors.yellow,
                  size: 24,
                ),
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                'Horarios de Atención',
                style: context.typography.h5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          ...businessHours.entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: context.spacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getDayName(entry.key),
                  style: context.typography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.sm,
                    vertical: context.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: entry.value == 'cerrado'
                        ? context.colors.error.withOpacity(0.1)
                        : context.colors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.value == 'cerrado' ? 'Cerrado' : entry.value,
                    style: context.typography.bodyMedium.copyWith(
                      color: entry.value == 'cerrado'
                          ? context.colors.error
                          : context.colors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildServicesOffered() {
    final services = _locationData['servicesOffered'] as List<String>;

    if (services.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.spacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: context.colors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                'Servicios Adicionales',
                style: context.typography.h5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Wrap(
            spacing: context.spacing.sm,
            runSpacing: context.spacing.sm,
            children: services.map((service) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.yellow,
                    context.colors.yellow.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.yellow.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getServiceIcon(service),
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: context.spacing.xs),
                  Text(
                    _getServiceName(service),
                    style: context.typography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicLocationContent() {
    return Container(
      margin: EdgeInsets.all(context.spacing.md),
      padding: EdgeInsets.all(context.spacing.xl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacing.lg),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 64,
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Text(
            'Ubicación Registrada',
            style: context.typography.h4.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            'Esta es una ubicación básica sin información de proveedor.',
            style: context.typography.bodyLarge.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Métodos de utilidad
  IconData _getProviderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ferreteria':
        return Icons.hardware_rounded;
      case 'cemento':
        return Icons.construction_rounded;
      case 'materiales':
        return Icons.inventory_rounded;
      default:
        return Icons.store_rounded;
    }
  }

  String _getProviderTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'ferreteria':
        return 'Ferretería';
      case 'cemento':
        return 'Cemento y Agregados';
      case 'materiales':
        return 'Materiales de Construcción';
      default:
        return type;
    }
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'agregados':
        return Icons.grain_rounded;
      case 'cemento':
        return Icons.local_shipping_rounded;
      case 'ladrillos':
        return Icons.view_module_rounded;
      case 'herramientas':
        return Icons.build_rounded;
      case 'acero':
        return Icons.construction_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'delivery':
        return Icons.local_shipping_rounded;
      case 'credito':
        return Icons.credit_card_rounded;
      case 'instalacion':
        return Icons.build_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _getServiceName(String service) {
    switch (service.toLowerCase()) {
      case 'delivery':
        return 'Delivery';
      case 'credito':
        return 'Crédito';
      case 'instalacion':
        return 'Instalación';
      default:
        return service;
    }
  }

  String _getDayName(String day) {
    switch (day.toLowerCase()) {
      case 'lunes':
        return 'Lunes';
      case 'martes':
        return 'Martes';
      case 'miercoles':
        return 'Miércoles';
      case 'jueves':
        return 'Jueves';
      case 'viernes':
        return 'Viernes';
      case 'sabado':
        return 'Sábado';
      case 'domingo':
        return 'Domingo';
      default:
        return day;
    }
  }

  // Métodos de contacto
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showSnackBar(context, 'No se pudo abrir WhatsApp');
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showSnackBar(context, 'No se pudo realizar la llamada');
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showSnackBar(context, 'No se pudo abrir el cliente de email');
      }
    }
  }

  void _shareLocation() {
    showSnackBar(context, 'Funcionalidad de compartir en desarrollo');
  }

  void _showProductDetail(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductDetailModal(product),
    );
  }

  Widget _buildProductDetailModal(Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(top: context.screenHeight * 0.1),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: context.spacing.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.spacing.lg,
                0,
                context.spacing.lg,
                context.spacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colors.blue,
                              context.colors.blue.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getProductIcon(product['category'] ?? ''),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: context.spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: context.typography.h4.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.primary,
                              ),
                            ),
                            Text(
                              product['category'] ?? '',
                              style: context.typography.bodyMedium.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing.lg),

                  // Precio
                  Container(
                    padding: EdgeInsets.all(context.spacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.price_change_rounded,
                          color: context.colors.blue,
                        ),
                        SizedBox(width: context.spacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Precio',
                              style: context.typography.h3.copyWith(
                                color: context.colors.blue,
                              ),
                            ),
                            Text(
                              'S/ ${product['priceMin'].toStringAsFixed(2)} - S/ ${product['priceMax'].toStringAsFixed(2)}',
                              style: context.typography.h5.copyWith(
                                color: context.colors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Por ${product['unitType']}',
                              style: context.typography.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (product['description'] != null) ...[
                    SizedBox(height: context.spacing.lg),
                    Text(
                      'Descripción',
                      style: context.typography.h6.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm),
                    Text(
                      product['description'],
                      style: context.typography.bodyLarge.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],

                  SizedBox(height: context.spacing.lg),

                  // Disponibilidad
                  Container(
                    padding: EdgeInsets.all(context.spacing.md),
                    decoration: BoxDecoration(
                      color: (product['availability'] ?? true)
                          ? context.colors.success.withOpacity(0.1)
                          : context.colors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (product['availability'] ?? true)
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: (product['availability'] ?? true)
                              ? context.colors.success
                              : context.colors.error,
                        ),
                        SizedBox(width: context.spacing.sm),
                        Text(
                          (product['availability'] ?? true)
                              ? 'Disponible'
                              : 'No disponible',
                          style: context.typography.bodyLarge.copyWith(
                            color: (product['availability'] ?? true)
                                ? context.colors.success
                                : context.colors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}