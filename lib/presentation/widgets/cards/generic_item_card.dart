// lib/presentation/widgets/cards/generic_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/theme.dart';

/// Tarjeta genérica reutilizable para cualquier tipo de item (Muro, Losa, Piso, etc.)
///
/// Proporciona una interfaz consistente con animaciones, responsive design
/// y manejo de estados (disponible/no disponible) para todos los módulos.
class GenericItemCard<T> extends StatefulWidget {
  /// Datos del item
  final T item;

  /// Callback cuando se toca la tarjeta
  final VoidCallback onTap;

  /// Función para obtener el ID del item
  final String Function(T) getId;

  /// Función para obtener el nombre del item
  final String Function(T) getName;

  /// Función para obtener la imagen del item
  final String Function(T) getImage;

  final String? Function(T)? getSubtitle;

  /// Color primario del módulo
  final Color? primaryColor;

  /// Tipo de imagen (SVG o PNG)
  final ImageType imageType;

  const GenericItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.getId,
    required this.getName,
    required this.getImage,
    this.getSubtitle,
    this.primaryColor,
    this.imageType = ImageType.svg,
  });

  @override
  State<GenericItemCard<T>> createState() => _GenericItemCardState<T>();
}

class _GenericItemCardState<T> extends State<GenericItemCard<T>>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapDown: (_) => _handlePress(true),
      onTapUp: (_) => _handlePress(false),
      onTapCancel: () => _handlePress(false),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: _buildCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    final isSmallScreen = _isSmallScreen();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: _isPressed ? _elevationAnimation.value : 4.0,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isPressed
                ? (AppColors.blueMetraShop).withOpacity(0.3)
                : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white,
                AppColors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImage(isSmallScreen),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitle(isSmallScreen),
                    if (widget.getSubtitle != null) ...[
                      const SizedBox(height: 6),
                      _buildSubtitle(isSmallScreen),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(bool isSmallScreen) {
    final size = isSmallScreen ? 100.0 : 140.0;
    final imagePath = widget.getImage(widget.item);
    final primaryColor = widget.primaryColor ?? AppColors.blueMetraShop;

    return Hero(
      tag: '${widget.getId(widget.item)}_${widget.runtimeType}',
      child: Container(
        width: size + 20,
        height: size + 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.08),
              primaryColor.withOpacity(0.15),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.white.withOpacity(0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImageWidget(imagePath, size),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath, double size) {
    // Auto-detectar el tipo de imagen si es SVG, si no detectar automáticamente
    final isSvg = imagePath.toLowerCase().endsWith('.svg');
    final isNetwork = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(size),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImagePlaceholder(size);
        },
      );
    } else if (isSvg) {
      return SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
        width: size,
        height: size,
        placeholderBuilder: (context) => _buildImagePlaceholder(size),
      );
    } else {
      // PNG, JPG, etc.
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(size),
      );
    }
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.neutral200,
      child: Icon(
        Icons.image,
        size: size * 0.6,
        color: AppColors.neutral400,
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return Text(
      widget.getName(widget.item),
      style: TextStyle(
        fontSize: isSmallScreen ? 15 : 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(bool isSmallScreen) {
    final subtitle = widget.getSubtitle?.call(widget.item);
    if (subtitle == null || subtitle.isEmpty) return const SizedBox.shrink();

    return Text(
      subtitle,
      style: TextStyle(
        fontSize: isSmallScreen ? 11 : 13,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }

  bool _isSmallScreen() {
    return MediaQuery.of(context).size.width < 600;
  }

  void _handlePress(bool isPressed) {

    setState(() {
      _isPressed = isPressed;
    });

    if (isPressed) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTap() {
    try {
      HapticFeedback.selectionClick();
      widget.onTap();
    } catch (e) {
      assert(() {
        debugPrint('Error en GenericItemCard onTap: $e');
        return true;
      }());

      if (mounted) {
        _showErrorSnackBar('Error al seleccionar item');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Enum para tipos de imagen soportados
enum ImageType {
  svg,
  asset,
  network,
}

/// Factory methods para crear tarjetas específicas con configuración predefinida

/// Factory para WallMaterial
class WallMaterialCard extends StatelessWidget {
  final dynamic wallMaterial; // WallMaterial
  final VoidCallback onTap;
  final bool enabled;

  const WallMaterialCard({
    super.key,
    required this.wallMaterial,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemCard(
      item: wallMaterial,
      onTap: onTap,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      imageType: ImageType.asset,
      getSubtitle: (item) => item.size,
      primaryColor: AppColors.success,
    );
  }
}

/// Factory para Slab
class SlabCard extends StatelessWidget {
  final dynamic slab; // Slab
  final VoidCallback onTap;
  final bool enabled;

  const SlabCard({
    super.key,
    required this.slab,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemCard(
      item: slab,
      onTap: onTap,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      imageType: ImageType.svg,
      primaryColor: AppColors.secondary,
    );
  }
}

/// Factory para Floor
class FloorCard extends StatelessWidget {
  final dynamic floor; // Floor
  final VoidCallback onTap;
  final bool enabled;

  const FloorCard({
    super.key,
    required this.floor,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemCard(
      item: floor,
      onTap: onTap,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      imageType: ImageType.svg,
      primaryColor: AppColors.blueMetraShop,
    );
  }
}

/// Factory para Coating
class CoatingCard extends StatelessWidget {
  final dynamic coating; // Coating
  final VoidCallback onTap;
  final bool enabled;

  const CoatingCard({
    super.key,
    required this.coating,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemCard(
      item: coating,
      onTap: onTap,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      imageType: ImageType.svg,
      primaryColor: AppColors.yellowMetraShop,
    );
  }
}

class SteelCard extends StatelessWidget {
  final dynamic steel; // Coating
  final VoidCallback onTap;
  final bool enabled;

  const SteelCard({
    super.key,
    required this.steel,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemCard(
      item: steel,
      onTap: onTap,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      imageType: ImageType.svg,
      primaryColor: AppColors.yellowMetraShop,
    );
  }
}