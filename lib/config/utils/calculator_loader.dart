import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meter_app/config/constants/constants.dart';

/// Un loader de pantalla completa con un icono SVG que puede mostrarse por encima de cualquier contenido
class CalculationLoader extends StatefulWidget {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  final String svgAssetPath;
  final String message;
  final String? description;
  final Color color;
  final bool showProgressBar;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  const CalculationLoader._({
    Key? key,
    required this.svgAssetPath,
    required this.message,
    this.description,
    required this.color,
    this.showProgressBar = true,
    this.onCancel,
    this.showCancelButton = false,
  }) : super(key: key);

  /// Muestra el loader en la pantalla
  static void show(
      BuildContext context, {
        required String svgAssetPath,
        String message = 'Calculando...',
        String? description,
        Color color = AppColors.blueMetraShop,
        bool showProgressBar = true,
        VoidCallback? onCancel,
        bool showCancelButton = false,
      }) {
    // No hacer nada si ya está visible
    if (_isVisible) return;

    _isVisible = true;

    // Crear el loader
    _overlayEntry = OverlayEntry(
      builder: (context) => CalculationLoader._(
        svgAssetPath: svgAssetPath,
        message: message,
        description: description,
        color: color,
        showProgressBar: showProgressBar,
        onCancel: onCancel ?? () {
          hide();
        },
        showCancelButton: showCancelButton,
      ),
    );

    // Mostrar el loader
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Ocultar el loader
  static void hide() {
    if (!_isVisible) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }

  /// Muestra el loader por un tiempo determinado
  static Future<void> showFor(
      BuildContext context,
      Duration duration, {
        required String svgAssetPath,
        String message = 'Calculando...',
        String? description,
        Color color = AppColors.blueMetraShop,
        bool showProgressBar = true,
      }) async {
    show(
      context,
      svgAssetPath: svgAssetPath,
      message: message,
      description: description,
      color: color,
      showProgressBar: showProgressBar,
    );

    await Future.delayed(duration);

    hide();
  }

  @override
  State<CalculationLoader> createState() => _CalculationLoaderState();
}

class _CalculationLoaderState extends State<CalculationLoader> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar la animación de pulso
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Inicializar la animación de progreso
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Añadir listener para ciclar la animación de progreso
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _progressController.reset();
        _progressController.forward();
      }
    });

    // Iniciar animaciones
    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono animado
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            widget.svgAssetPath,
                            color: Colors.white,
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Mensaje
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Descripción (si existe)
                if (widget.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 20),

                // Barra de progreso animada
                if (widget.showProgressBar)
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 150,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Botón de cancelar
                if (widget.showCancelButton) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}