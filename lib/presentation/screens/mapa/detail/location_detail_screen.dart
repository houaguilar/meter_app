import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../domain/entities/map/location.dart';
import '../../../../domain/entities/map/product.dart';
import '../../../../domain/entities/map/verification_status.dart';
import '../../../blocs/map/products_bloc.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../cart/cart_screen.dart';

/// Extension para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

/// Pantalla de detalle de ubicación con layout vertical continuo
class LocationDetailScreen extends StatefulWidget {
  final LocationMap location;

  const LocationDetailScreen({
    super.key,
    required this.location,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  List<Product> _products = [];
  bool _loadingProducts = false;
  bool _showTitle = false;

  // Posición del FAB arrastrable
  Offset _fabPosition = const Offset(20, 24);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
    _loadProducts();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Mostrar título cuando se haya scrolleado más de 200px
    setState(() {
      _showTitle = offset > 200;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final locationId = widget.location.id;
    if (locationId == null) {
      setState(() => _loadingProducts = false);
      return;
    }

    setState(() => _loadingProducts = true);
    context.read<ProductsBloc>().add(LoadLocationProducts(locationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsLoaded) {
            setState(() {
              _products = state.products;
              _loadingProducts = false;
            });
          } else if (state is ProductsError) {
            setState(() => _loadingProducts = false);
            showSnackBar(context, 'Error al cargar productos: ${state.message}');
          }
        },
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildModernSliverAppBar(),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          if (_isProvider) _buildQuickStats(),
                          if (_isProvider) const SizedBox(height: 24),
                          _buildLocationInfo(),
                          if (_isProvider) ...[
                            const SizedBox(height: 32),
                            _buildProductsSection(),
                          ] else ...[
                            const SizedBox(height: 32),
                            _buildBasicLocationContent(),
                          ],
                          const SizedBox(height: 100), // Espacio para FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // FAB del carrito
            if (_isProvider) _buildCartFAB(),
          ],
        ),
      ),
    );
  }

  bool get _isProvider {
    return widget.location.verificationStatus.isApproved &&
        widget.location.isActive;
  }

  Widget _buildModernSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Text(
          widget.location.title ?? 'Sin nombre',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      actions: [
        // Botón de información
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: _showInfoBottomSheet,
            tooltip: 'Información',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildLocationImage(),
            _buildModernGradientOverlay(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildModernTitleSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationImage() {
    final imageUrl = widget.location.imageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultImage(),
      );
    }

    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.store_mall_directory_rounded,
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildModernGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTitleSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.warning,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'MetraShop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.location.title ?? 'Sin nombre',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.location.address ?? 'Dirección no disponible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    if (!_isProvider) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.star_rounded,
              iconColor: AppColors.warning,
              label: 'Rating',
              value: widget.location.formattedRating,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.neutral200,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.rate_review_rounded,
              iconColor: AppColors.secondary,
              label: 'Reseñas',
              value: '${widget.location.reviewsCount}',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.neutral200,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.shopping_bag_rounded,
              iconColor: AppColors.accent,
              label: 'Pedidos',
              value: '${widget.location.ordersCount}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Acerca de',
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.location.description ?? 'Sin descripción disponible',
            style: AppTypography.bodyLarge.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    if (_loadingProducts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cargando productos...',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.neutral200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.15),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay productos',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Este proveedor aún no ha agregado productos a su catálogo',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Agrupar productos por categoría
    final groupedProducts = <String, List<Product>>{};
    for (final product in _products) {
      final categoryId = product.categoryId ?? 'otros';
      groupedProducts.putIfAbsent(categoryId, () => []).add(product);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedProducts.entries.map((entry) {
        final categoryId = entry.key;
        final categoryProducts = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(categoryId, categoryProducts.length),
            const SizedBox(height: 16),
            _buildProductCarousel(categoryProducts),
            const SizedBox(height: 32),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryHeader(String categoryId, int productCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.warning],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.category_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryId.toUpperCase(),
                  style: AppTypography.h5.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '$productCount ${productCount == 1 ? 'producto' : 'productos'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCarousel(List<Product> products) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: EdgeInsets.only(right: index < products.length - 1 ? 16 : 0),
            child: _buildProductCard(product),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final bool isAvailable = product.stockAvailable;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable
              ? AppColors.secondary.withOpacity(0.2)
              : AppColors.neutral300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAvailable
                ? AppColors.secondary.withOpacity(0.12)
                : Colors.black.withOpacity(0.04),
            blurRadius: isAvailable ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isAvailable ? () => _showModernProductDetail(product) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto
                Center(
                  child: Hero(
                    tag: 'product_${product.id}',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isAvailable
                              ? [
                                  AppColors.secondary,
                                  AppColors.secondary.withOpacity(0.8),
                                ]
                              : [
                                  AppColors.neutral400,
                                  AppColors.neutral300,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isAvailable
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre del producto
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.attributes?['brand'] ?? product.name ?? 'Sin nombre',
                        style: AppTypography.h6.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isAvailable
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'Agotado',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                // Precio
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withOpacity(0.25),
                              AppColors.accent.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          product.priceWithUnit,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (isAvailable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicLocationContent() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.warning,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ubicación Registrada',
            style: AppTypography.h2.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Esta ubicación está en proceso de verificación o no está configurada como proveedor activo.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartFAB() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final itemCount = state is CartLoaded ? state.totalItems : 0;
        final screenSize = MediaQuery.of(context).size;

        return Positioned(
          bottom: _fabPosition.dy,
          right: _fabPosition.dx,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Actualizar posición del FAB (invertido porque right/bottom son desde el borde)
                _fabPosition = Offset(
                  (_fabPosition.dx - details.delta.dx).clamp(16.0, screenSize.width - 180),
                  (_fabPosition.dy - details.delta.dy).clamp(16.0, screenSize.height - 200),
                );
              });
            },
            child: FloatingActionButton.extended(
              heroTag: 'cart_fab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CartScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.accent,
              elevation: 8,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: Text(
                'Carrito',
                style: AppTypography.buttonMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Contact methods
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

  void _showModernProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModernProductDetailModal(
        product: product,
        location: widget.location,
      ),
    );
  }

  void _showInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InfoBottomSheet(location: widget.location),
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final days = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];
    final todayIndex = now.weekday - 1;
    return days[todayIndex] == day.toLowerCase();
  }
}

/// Bottom Sheet de información del negocio
class _InfoBottomSheet extends StatelessWidget {
  final LocationMap location;

  const _InfoBottomSheet({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.2,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.warning,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.info_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Información',
                          style: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Botones de contacto
                  _buildContactSection(context),
                  const SizedBox(height: 32),
                  // Horarios
                  if (location.businessHours != null &&
                      location.businessHours!.isNotEmpty)
                    _buildBusinessHoursSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final phone = location.phone;
    final whatsapp = location.whatsapp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contacto',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        if (whatsapp != null || phone != null) ...[
          if (whatsapp != null) ...[
            _buildContactButton(
              context: context,
              icon: Icons.chat_bubble_rounded,
              label: 'WhatsApp',
              subtitle: 'Enviar mensaje ahora',
              gradient: const LinearGradient(
                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              ),
              onTap: () => _launchWhatsApp(context, whatsapp),
            ),
            if (phone != null) const SizedBox(height: 12),
          ],
          if (phone != null) ...[
            _buildContactButton(
              context: context,
              icon: Icons.phone_rounded,
              label: 'Llamar',
              subtitle: 'Realizar llamada directa',
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withOpacity(0.8),
                ],
              ),
              onTap: () => _makePhoneCall(context, phone),
            ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neutral300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay información de contacto disponible',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.isNotEmpty
                    ? gradient.colors.first.withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.h6.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessHoursSection(BuildContext context) {
    final businessHours = location.businessHours;
    if (businessHours == null || businessHours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios de Atención',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neutral200,
            ),
          ),
          child: Column(
            children: businessHours.entries.map((entry) {
              final day = entry.key;
              final hours = entry.value;
              final isToday = _isToday(day);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: isToday
                      ? LinearGradient(
                          colors: [
                            AppColors.accent.withOpacity(0.15),
                            AppColors.accent.withOpacity(0.08),
                          ],
                        )
                      : null,
                  color: isToday ? null : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isToday
                        ? AppColors.accent.withOpacity(0.4)
                        : AppColors.neutral200,
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (isToday) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        day.capitalize(),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w600,
                          color:
                              isToday ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hours.closed
                            ? AppColors.error.withOpacity(0.15)
                            : AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hours.closed
                              ? AppColors.error.withOpacity(0.3)
                              : AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        hours.closed ? 'Cerrado' : '${hours.open} - ${hours.close}',
                        style: AppTypography.bodySmall.copyWith(
                          color: hours.closed ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final days = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];
    final todayIndex = now.weekday - 1;
    return days[todayIndex] == day.toLowerCase();
  }

  Future<void> _launchWhatsApp(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        showSnackBar(context, 'No se pudo abrir WhatsApp');
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackBar(context, 'No se pudo realizar la llamada');
      }
    }
  }
}

/// Modal moderno de detalle de producto con selector de cantidad
class _ModernProductDetailModal extends StatefulWidget {
  final Product product;
  final LocationMap location;

  const _ModernProductDetailModal({
    required this.product,
    required this.location,
  });

  @override
  State<_ModernProductDetailModal> createState() =>
      _ModernProductDetailModalState();
}

class _ModernProductDetailModalState extends State<_ModernProductDetailModal>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late TextEditingController _quantityController;
  late FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _quantityFocusNode = FocusNode();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _quantityController.text = '$_quantity';
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _quantityController.text = '$_quantity';
      });
    }
  }

  void _updateQuantityFromText(String value) {
    final newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity > 0) {
      setState(() {
        _quantity = newQuantity;
      });
    } else if (value.isEmpty) {
      // No actualizar cantidad si está vacío, esperar a que termine de escribir
    } else {
      // Si el valor no es válido, restaurar el valor anterior
      _quantityController.text = '$_quantity';
      _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length),
      );
    }
  }

  double get _totalPrice {
    return (widget.product.price ?? 0.0) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.15,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero image
                      Center(
                        child: Hero(
                          tag: 'product_${widget.product.id}',
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.secondary,
                                  AppColors.secondary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Título y categoría
                      Text(
                        widget.product.attributes?['brand'] ??
                            widget.product.name ??
                            'Sin nombre',
                        style: AppTypography.h2.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.product.categoryId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.product.categoryId!.toUpperCase(),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      // Precio por unidad
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withOpacity(0.2),
                              AppColors.accent.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.warning,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.price_change_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Precio por ${widget.product.unit?.displayName ?? 'unidad'}',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.product.formattedPrice,
                                    style: AppTypography.h3.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Descripción
                      if (widget.product.description != null &&
                          widget.product.description!.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          'Descripción',
                          style: AppTypography.h5.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.neutral200,
                            ),
                          ),
                          child: Text(
                            widget.product.description!,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      // Selector de cantidad
                      Text(
                        'Cantidad',
                        style: AppTypography.h5.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Botón decrementar
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _decrementQuantity,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: _quantity > 1
                                        ? LinearGradient(
                                            colors: [
                                              AppColors.secondary,
                                              AppColors.secondary
                                                  .withOpacity(0.9),
                                            ],
                                          )
                                        : null,
                                    color: _quantity > 1
                                        ? null
                                        : AppColors.neutral200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    color: _quantity > 1
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            // Campo editable de cantidad
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _quantityFocusNode.requestFocus();
                                  _quantityController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _quantityController.text.length,
                                  );
                                },
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _quantityController,
                                      focusNode: _quantityFocusNode,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.h2.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      onChanged: _updateQuantityFromText,
                                      onSubmitted: (value) {
                                        _updateQuantityFromText(value);
                                        _quantityFocusNode.unfocus();
                                        // Si el campo está vacío al finalizar, establecer 1
                                        if (value.isEmpty) {
                                          setState(() {
                                            _quantity = 1;
                                            _quantityController.text = '1';
                                          });
                                        }
                                      },
                                    ),
                                    Text(
                                      widget.product.unit?.displayName ??
                                          'unidad(es)',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Botón incrementar
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _incrementQuantity,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.secondary,
                                        AppColors.secondary.withOpacity(0.9),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.secondary.withOpacity(0.4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Total
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total a pagar',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.product.currency.symbol} ${_totalPrice.toStringAsFixed(2)}',
                                  style: AppTypography.h3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_quantity × ${widget.product.formattedPrice}',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón agregar al carrito
                      if (widget.product.stockAvailable)
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<CartBloc>().add(AddToCart(
                                    product: widget.product,
                                    locationId: widget.location.id ?? '',
                                    locationName: widget.location.title,
                                    quantity: _quantity,
                                  ));
                              Navigator.pop(context);
                              showSnackBar(
                                context,
                                '$_quantity × ${widget.product.attributes?['brand'] ?? widget.product.name} agregado al carrito',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              shadowColor: AppColors.accent.withOpacity(0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 26,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'Agregar al Carrito',
                                  style: AppTypography.h5.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
