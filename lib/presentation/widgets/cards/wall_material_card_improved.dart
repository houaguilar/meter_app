// lib/presentation/widgets/cards/wall_material_card_improved.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/theme.dart';
import '../../../domain/entities/home/muro/wall_material.dart';

/// Tarjeta mejorada para materiales de muro con responsive design y mejores prácticas
/// 
/// Mantiene la funcionalidad original pero con mejoras en UX, accesibilidad
/// y responsive design para diferentes tamaños de pantalla.
class WallMaterialCardImproved extends StatefulWidget {
  final WallMaterial material;
  final VoidCallback onTap;
  final bool enabled;

  const WallMaterialCardImproved({
    super.key,
    required this.material,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<WallMaterialCardImproved> createState() => _WallMaterialCardImprovedState();
}

class _WallMaterialCardImprovedState extends State<WallMaterialCardImproved>
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
      onTapDown: widget.enabled ? (_) => _handlePress(true) : null,
      onTapUp: widget.enabled ? (_) => _handlePress(false) : null,
      onTapCancel: widget.enabled ? () => _handlePress(false) : null,
      onTap: widget.enabled ? _handleTap : null,
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
    final isDisabled = !widget.enabled || _isDisabledMaterial();

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
              SizedBox(height: isSmallScreen ? 4 : 6),
              _buildSize(isSmallScreen, isDisabled),
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

    return Hero(
      tag: 'material_${widget.material.id}',
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
            child: Image.asset(
              widget.material.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.neutral200,
                  child: Icon(
                    Icons.construction,
                    size: size * 0.6,
                    color: AppColors.neutral400,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen, bool isDisabled) {
    return Text(
      widget.material.name,
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

  Widget _buildSize(bool isSmallScreen, bool isDisabled) {
    return Text(
      widget.material.size,
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

  /// Determina si es una pantalla pequeña
  bool _isSmallScreen() {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Determina si el material está deshabilitado
  bool _isDisabledMaterial() {
    // IDs de materiales no disponibles (Tabicón y Bloquetas)
    const disabledIds = ['5', '6', '7', '8'];
    return disabledIds.contains(widget.material.id);
  }

  void _handlePress(bool isPressed) {
    if (!mounted || !widget.enabled) return;

    setState(() {
      _isPressed = isPressed;
    });

    if (isPressed) {
      _animationController.forward();
      // Feedback háptico ligero
      HapticFeedback.lightImpact();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (!widget.enabled) return;

    try {
      // Feedback háptico de selección
      HapticFeedback.selectionClick();

      // Ejecutar callback
      widget.onTap();
    } catch (e) {
      // Log error en modo debug
      assert(() {
        debugPrint('Error en WallMaterialCard onTap: $e');
        return true;
      }());

      // Mostrar error al usuario si es necesario
      if (mounted) {
        _showErrorSnackBar('Error al seleccionar material');
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

/// Extension para validar materiales
extension WallMaterialValidation on WallMaterial {
  /// Verifica si el material tiene datos válidos
  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        image.isNotEmpty &&
        size.isNotEmpty;
  }

  /// Verifica si el material está disponible para cálculos
  bool get isAvailable {
    // Solo ladrillos están disponibles (IDs 1-4)
    const availableIds = ['1', '2', '3', '4'];
    return availableIds.contains(id);
  }

  /// Obtiene el tipo de material basado en el ID
  MaterialType get materialType {
    switch (id) {
      case '1':
      case '2':
      case '3':
      case '4':
        return MaterialType.ladrillo;
      case '5':
        return MaterialType.tabicon;
      case '6':
      case '7':
      case '8':
        return MaterialType.bloqueta;
      default:
        return MaterialType.unknown;
    }
  }
}

/// Enum para tipos de material
enum MaterialType {
  ladrillo,
  bloqueta,
  tabicon,
  unknown;

  String get displayName {
    switch (this) {
      case MaterialType.ladrillo:
        return 'Ladrillo';
      case MaterialType.bloqueta:
        return 'Bloqueta';
      case MaterialType.tabicon:
        return 'Tabicón';
      case MaterialType.unknown:
        return 'Desconocido';
    }
  }

  bool get isAvailable {
    return this == MaterialType.ladrillo;
  }
}