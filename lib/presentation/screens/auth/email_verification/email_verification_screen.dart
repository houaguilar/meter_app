import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/theme/theme.dart';
import '../../../../data/local/shared_preferences_helper.dart';
import '../../../../domain/usecases/use_cases.dart';
import '../../../../init_dependencies.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _listenForVerification();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _authSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  // Escucha el evento signedIn que dispara supabase_flutter cuando el usuario
  // toca el enlace del correo y la app se abre via deep link.
  // La navegación la maneja el router vía GoRouterRefreshStream al recibir
  // AuthSuccess — aquí solo cancelamos la suscripción para evitar duplicados.
  void _listenForVerification() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _authSubscription?.cancel();
      }
    });
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final resendOTPUseCase = serviceLocator<ResendOTP>();
      final result = await resendOTPUseCase(ResendOTPParams(email: widget.email));

      if (mounted) {
        result.fold(
          (failure) {
            setState(() => _isResending = false);
            _showError(failure.message);
          },
          (_) {
            setState(() => _isResending = false);
            _showSuccess('Enlace reenviado a ${widget.email}');
            _startResendCountdown();
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);
        _showError('Error al reenviar: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // Cancelar el registro: limpiar estado y volver al login
            serviceLocator<SharedPreferencesHelper>()
                .clearPendingVerificationEmail()
                .then((_) {
              if (context.mounted) context.go('/login');
            });
          },
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildInstructions(),
                const Spacer(),
                _buildResendButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.blueMetraShop.withOpacity(0.2),
                AppColors.blueMetraShop.withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.blueMetraShop),
        ),
        const SizedBox(height: 24),
        Text(
          'Revisa tu correo',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hemos enviado un enlace de verificación a',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blueMetraShop,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blueMetraShop.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blueMetraShop.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildStep(
            icon: Icons.email_outlined,
            text: 'Abre el correo que te enviamos',
          ),
          const SizedBox(height: 16),
          _buildStep(
            icon: Icons.touch_app_outlined,
            text: 'Toca el botón "Verificar mi correo"',
          ),
          const SizedBox(height: 16),
          _buildStep(
            icon: Icons.check_circle_outline,
            text: 'La app se abrirá automáticamente y podrás comenzar',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blueMetraShop, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton() {
    final canResend = _resendCountdown == 0 && !_isResending;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No recibiste el correo?',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        if (_isResending)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
            ),
          )
        else
          TextButton(
            onPressed: canResend ? _handleResend : null,
            child: Text(
              canResend ? 'Reenviar enlace' : 'Reenviar en ${_resendCountdown}s',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: canResend ? AppColors.blueMetraShop : AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}
