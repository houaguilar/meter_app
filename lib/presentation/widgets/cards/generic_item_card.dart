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

  /// Si la tarjeta está habilitada
  final bool enabled;

  /// Función para obtener el ID del item
  final String Function(T) getId;

  /// Función para obtener el nombre del item
  final String Function(T) getName;

  /// Función para obtener la imagen del item
  final String Function(T) getImage;

  /// Función para obtener información adicional (opcional)
  final String? Function(T)? getSubtitle;

  /// Función para determinar si el item está disponible
  final bool Function(T) isAvailable;

  /// Función para obtener el mensaje de no disponible
  final String Function(T)? getUnavailableMessage;

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
    required this.isAvailable,
    this.enabled = true,
    this.getSubtitle,
    this.getUnavailableMessage,
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
    final isItemAvailable = widget.isAvailable(widget.item);
    final isCardEnabled = widget.enabled && isItemAvailable;

    return GestureDetector(
      onTapDown: isCardEnabled ? (_) => _handlePress(true) : null,
      onTapUp: isCardEnabled ? (_) => _handlePress(false) : null,
      onTapCancel: isCardEnabled ? () => _handlePress(false) : null,
      onTap: isCardEnabled ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: _buildCard(isItemAvailable),
          );
        },
      ),
    );
  }

  Widget _buildCard(bool isItemAvailable) {
    final isSmallScreen = _isSmallScreen();
    final isDisabled = !widget.enabled || !isItemAvailable;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: _isPressed ? _elevationAnimation.value : 2.0,
        color: isDisabled
            ? AppColors.neutral100
            : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDisabled
                ? AppColors.neutral300
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImage(isSmallScreen, isDisabled),
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildTitle(isSmallScreen, isDisabled),
              if (widget.getSubtitle != null) ...[
                const SizedBox(height: 4),
                _buildSubtitle(isSmallScreen, isDisabled),
              ],
              if (isDisabled) ...[
                const SizedBox(height: 8),
                _buildDisabledBadge(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(bool isSmallScreen, bool isDisabled) {
    final size = isSmallScreen ? 50.0 : 65.0;
    final imagePath = widget.getImage(widget.item);

    return Hero(
      tag: '${widget.getId(widget.item)}_${widget.runtimeType}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDisabled ? null : [
            BoxShadow(
              color: AppColors.neutral300.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColorFiltered(
            colorFilter: isDisabled
                ? const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 1, 0,
            ])
                : const ColorFilter.matrix([
              1, 0, 0, 0, 0,
              0, 1, 0, 0, 0,
              0, 0, 1, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: _buildImageWidget(imagePath, size),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath, double size) {
    switch (widget.imageType) {
      case ImageType.svg:
        return SvgPicture.asset(
          imagePath,
          fit: BoxFit.contain,
          width: size,
          height: size,
          placeholderBuilder: (context) => _buildImagePlaceholder(size),
        );
      case ImageType.network:
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(size),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildImagePlaceholder(size);
          },
        );
      case ImageType.asset:
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
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

  Widget _buildTitle(bool isSmallScreen, bool isDisabled) {
    return Text(
      widget.getName(widget.item),
      style: TextStyle(
        fontSize: isSmallScreen ? 12 : 14,
        fontWeight: FontWeight.bold,
        color: isDisabled
            ? AppColors.textTertiary
            : AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(bool isSmallScreen, bool isDisabled) {
    final subtitle = widget.getSubtitle?.call(widget.item);
    if (subtitle == null || subtitle.isEmpty) return const SizedBox.shrink();

    return Text(
      subtitle,
      style: TextStyle(
        fontSize: isSmallScreen ? 9 : 11,
        color: isDisabled
            ? AppColors.textTertiary
            : AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDisabledBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        'Próximamente',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _isSmallScreen() {
    return MediaQuery.of(context).size.width < 600;
  }

  void _handlePress(bool isPressed) {
    if (!mounted || !widget.enabled) return;

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
    if (!widget.enabled) return;

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
      enabled: enabled,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      getSubtitle: (item) => item.size,
      isAvailable: (item) => _isWallMaterialAvailable(item.id),
      imageType: ImageType.asset,
      primaryColor: AppColors.success,
    );
  }

  bool _isWallMaterialAvailable(String id) {
    const availableIds = ['1', '2', '3', '4', 'custom'];
    return availableIds.contains(id);
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
      enabled: enabled,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      isAvailable: (item) => true, // Por ahora todas las losas están disponibles
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
      enabled: enabled,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      isAvailable: (item) => true, // Por ahora todos los pisos están disponibles
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
      enabled: enabled,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      isAvailable: (item) => true, // Por ahora todos los revestimientos están disponibles
      imageType: ImageType.svg,
      primaryColor: AppColors.yellowMetraShop,
    );
  }
}