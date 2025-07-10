// lib/config/utils/auth/auth_success_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart'; // Añadir esta dependencia en pubspec.yaml

import '../../theme/theme.dart';

class AuthSuccessUtils {
  AuthSuccessUtils._();

  /// Muestra mensaje de éxito de registro
  static void showRegistrationSuccess(BuildContext context, String userName) {
    _showSuccessMessage(
      context,
      title: '¡Bienvenido!',
      message: '¡Hola $userName! Tu cuenta ha sido creada exitosamente.',
      icon: Icons.celebration,
      duration: const Duration(seconds: 3),
    );
  }

  /// Muestra mensaje de éxito de login
  static void showLoginSuccess(BuildContext context, String userName) {
    _showSuccessMessage(
      context,
      title: '¡Hola de nuevo!',
      message: 'Bienvenido $userName',
      icon: Icons.waving_hand,
      duration: const Duration(seconds: 2),
    );
  }

  /// Muestra diálogo de bienvenida para nuevos usuarios
  static void showWelcomeDialog(BuildContext context, String userName) {
    if (!context.mounted) return;

    // Feedback háptico de celebración
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _WelcomeDialog(userName: userName);
      },
    );
  }

  /// Muestra celebración con confetti
  static void showCelebration(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// Muestra mensaje de éxito personalizado
  static void showCustomSuccess(
      BuildContext context, {
        required String title,
        required String message,
        IconData icon = Icons.check_circle,
        Duration duration = const Duration(seconds: 3),
      }) {
    _showSuccessMessage(
      context,
      title: title,
      message: message,
      icon: icon,
      duration: duration,
    );
  }

  /// Método privado para mostrar mensajes de éxito
  static void _showSuccessMessage(
      BuildContext context, {
        required String title,
        required String message,
        required IconData icon,
        required Duration duration,
      }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SuccessContent(
          title: title,
          message: message,
          icon: icon,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );

    // Vibración de éxito
    HapticFeedback.mediumImpact();
  }
}

// Widget para el contenido del SnackBar de éxito
class _SuccessContent extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;

  const _SuccessContent({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  State<_SuccessContent> createState() => _SuccessContentState();
}

class _SuccessContentState extends State<_SuccessContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Widget del diálogo de bienvenida
class _WelcomeDialog extends StatefulWidget {
  final String userName;

  const _WelcomeDialog({required this.userName});

  @override
  State<_WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<_WelcomeDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scaleController.forward();
    _confettiController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con confetti
                  Container(
                    height: 120,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.celebration,
                              size: 40,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        // Confetti effect aquí si tienes la librería
                      ],
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Hola ${widget.userName}!',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tu cuenta ha sido creada exitosamente. ¡Estamos emocionados de tenerte con nosotros!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Botón continuar
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Comenzar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

// Widget de celebración con confetti
class _CelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _CelebrationOverlay({required this.onComplete});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Aquí irían múltiples animaciones de confetti
            // Por simplicidad, mostramos algunas partículas básicas
            ...List.generate(20, (index) {
              return _ConfettiParticle(
                controller: _controller,
                startX: MediaQuery.of(context).size.width * (index / 20),
                color: _getRandomColor(index),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getRandomColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Widget de partícula de confetti
class _ConfettiParticle extends StatelessWidget {
  final AnimationController controller;
  final double startX;
  final Color color;

  const _ConfettiParticle({
    required this.controller,
    required this.startX,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        final y = -50 + (screenHeight + 100) * progress;
        final rotation = progress * 4 * 3.14159; // 2 rotaciones completas
        final scale = 1.0 - (progress * 0.5); // Se hace más pequeño al caer

        return Positioned(
          left: startX,
          top: y,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}