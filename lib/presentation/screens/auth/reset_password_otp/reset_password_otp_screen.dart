import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/usecases/use_cases.dart';
import '../../../../init_dependencies.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String email;

  const ResetPasswordOTPScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });

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

  Future<void> _handleVerifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('Por favor, introduce un código de 6 dígitos');
      return;
    }

    // Validar que sean solo dígitos
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showError('El código debe contener solo números');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Pequeño delay para mostrar el indicador de carga
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isVerifying = false;
      });

      // Navegar directamente a la pantalla de nueva contraseña
      // La verificación del OTP se hará cuando se actualice la contraseña
      context.pushNamed(
        'new-password',
        queryParameters: {
          'email': widget.email,
          'token': otp,
        },
      );
    }
  }

  Future<void> _handleResendOTP() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final resendOTPUseCase = serviceLocator<ResendOTP>();
      final result = await resendOTPUseCase(
        ResendOTPParams(email: widget.email),
      );

      if (mounted) {
        result.fold(
          (failure) {
            setState(() {
              _isResending = false;
            });
            _showError(failure.message);
          },
          (_) {
            setState(() {
              _isResending = false;
            });
            _showSuccess('Código reenviado exitosamente');
            _startResendCountdown();
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _showError('Error al reenviar código: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
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
            const Icon(
              Icons.check_circle,
              color: AppColors.white,
              size: 20,
            ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header
                _buildHeader(),

                const SizedBox(height: 40),

                // OTP Input
                _buildOTPInput(),

                const SizedBox(height: 32),

                // Verify Button
                _buildVerifyButton(),

                const SizedBox(height: 24),

                // Resend Button
                _buildResendButton(),
              ],
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
                AppColors.secondary.withValues(alpha: 0.2),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 64,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Verifica tu código',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hemos enviado un código de 6 dígitos a',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          height: 60,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.neutral300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }

              // Auto-verify when all digits are entered
              if (index == 5 && value.length == 1) {
                final allFilled = _otpControllers.every((c) => c.text.length == 1);
                if (allFilled) {
                  _handleVerifyOTP();
                }
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _handleVerifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                'Verificar código',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResendButton() {
    final canResend = _resendCountdown == 0 && !_isResending;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No recibiste el código?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        if (_isResending)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          )
        else
          TextButton(
            onPressed: canResend ? _handleResendOTP : null,
            child: Text(
              canResend
                  ? 'Reenviar'
                  : 'Reenviar en ${_resendCountdown}s',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: canResend ? AppColors.secondary : AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}
