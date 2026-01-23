import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/auth/auth_error_handler.dart';
import '../../../../config/utils/auth/auth_success_utils.dart';
import '../../../../config/utils/validators.dart';
import '../../../../domain/usecases/use_cases.dart';
import '../../../../init_dependencies.dart';
import 'package:meter_app/config/assets/app_images.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../widgets/enhanced_auth_text_field.dart';
import '../widgets/enhanced_register_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES Y LLAVES
  // ═══════════════════════════════════════════════════════════════════════════

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES DE ANIMACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;

  late Animation<Offset> _headerSlideAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADO
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _hasNavigated = false;
  bool _isFormValid = false;

  // NUEVAS VARIABLES PARA MEJORAS UX
  ValidationResult? _emailValidation;
  bool _showValidationHints = false;
  int _loginAttempts = 0;
  DateTime? _lastAttemptTime;

  // Configuración de timeouts
  static const Duration _loginTimeout = Duration(seconds: 30);
  static const Duration _navigationDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _clearSensitiveData();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _initializeScreen() {
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _setupControllerListeners();
    _setupRealTimeValidation(); // NUEVO
    _setupSystemUI();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startInitialAnimations();
      }
    });
  }

  void _setupAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupControllerListeners() {
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  // NUEVO: Validación en tiempo real
  void _setupRealTimeValidation() {
    _emailController.addListener(() {
      if (_emailController.text.isNotEmpty) {
        setState(() {
          _emailValidation = Validators.validateEmailAdvanced(_emailController.text);
          _showValidationHints = true;
        });
      }
    });

    // Auto-focus inteligente
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus &&
          _emailController.text.isNotEmpty &&
          _emailValidation?.isValid == true &&
          _passwordController.text.isEmpty) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _startInitialAnimations() {
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _validateForm() {
    final isValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        (_emailValidation?.isValid != false);

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  bool _canSubmitForm() {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        (_emailValidation?.isValid != false);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, introduce tu correo electrónico';
    }

    final email = value.trim();
    if (!Validators.validateEmail(email)) {
      return 'Por favor, introduce un correo electrónico válido';
    }

    if (email.length > 254) {
      return 'El correo electrónico es demasiado largo';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, introduce tu contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    if (value.length > 128) {
      return 'La contraseña es demasiado larga';
    }

    return null;
  }

  void _clearSensitiveData() {
    _passwordController.clear();
    _isPasswordVisible = false;
  }

  String _sanitizeInput(String input) {
    if (input.isEmpty) return input;

    String cleaned = input.trim();
    final dangerousChars = ['<', '>', '"', "'", '`', '{', '}'];

    for (String char in dangerousChars) {
      cleaned = cleaned.replaceAll(char, '');
    }

    cleaned = cleaned.replaceAll('<script>', '');
    cleaned = cleaned.replaceAll('</script>', '');

    while (cleaned.contains('  ')) {
      cleaned = cleaned.replaceAll('  ', ' ');
    }

    return cleaned.trim();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTENTICACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleLogin() async {
    if (!_isFormValid || _isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();

    final email = _sanitizeInput(_emailController.text);
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorMessage('Por favor, completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.any([
        _performLogin(email, password),
        Future.delayed(_loginTimeout, () {
          throw Exception('Tiempo de espera agotado');
        }),
      ]);
    } catch (e) {
      if (mounted) {
        _handleLoginError(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performLogin(String email, String password) async {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthLogin(
      email: email,
      password: password,
    ));
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.any([
        _performGoogleLogin(),
        Future.delayed(_loginTimeout, () {
          throw Exception('Tiempo de espera agotado para Google Sign-In');
        }),
      ]);
    } catch (e) {
      if (mounted) {
        final errorString = e.toString().toLowerCase();

        // Si el usuario canceló, no mostrar error ni incrementar intentos
        final isCancellation = errorString.contains('sign_in_canceled') ||
            errorString.contains('cancelled') ||
            errorString.contains('canceled');

        if (!isCancellation) {
          AuthErrorHandler.handleGoogleSignInError(context, e.toString());

          _scaleAnimationController.forward().then((_) {
            _scaleAnimationController.reverse();
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performGoogleLogin() async {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthLoginWithGoogle());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANEJO DE ERRORES MEJORADO
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleLoginError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Manejo inteligente según el tipo de error
    if (errorString.contains('wrong-password') ||
        errorString.contains('invalid-credential') ||
        errorString.contains('incorrect password')) {
      _passwordController.clear();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _passwordFocusNode.requestFocus();
        }
      });

    } else if (errorString.contains('user-not-found') ||
        errorString.contains('user not found')) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _emailFocusNode.requestFocus();
        }
      });

    } else if (errorString.contains('invalid-email')) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _emailFocusNode.requestFocus();
        }
      });

    } else if (errorString.contains('too-many-requests') ||
        errorString.contains('too many attempts')) {
      _passwordController.clear();

    } else if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      // Para errores de red, no limpiar nada

    } else {
      _passwordController.clear();
    }

    // Usar AuthErrorHandler mejorado en lugar del genérico
    AuthErrorHandler.handleLoginError(context, error.toString());

    // Feedback háptico específico
    if (errorString.contains('wrong-password') ||
        errorString.contains('user-not-found')) {
      HapticFeedback.mediumImpact();
    } else if (errorString.contains('too-many-requests')) {
      HapticFeedback.heavyImpact();
    } else if (errorString.contains('network')) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    // Animar error
    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _navigateToWelcome() {
    if (_hasNavigated) return;

    _hasNavigated = true;
    _clearSensitiveData();

    Future.delayed(_navigationDelay, () {
      if (mounted && context.mounted) {
        context.goNamed('welcome');
      }
    });
  }

  void _navigateToRegister() {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    context.pushNamed('register');
  }

  void _navigateBack() {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    context.pop();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // NUEVO: Diálogo mejorado de recuperar contraseña
  void _showForgotPasswordDialog() {
    HapticFeedback.lightImpact();

    // Guardar referencia al contexto del Scaffold principal
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final emailController = TextEditingController(
          text: _emailValidation?.isValid == true ? _emailController.text : '',
        );

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Recuperar contraseña'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Introduce tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final dialogContext = context;

                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, introduce un email válido'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Cerrar el diálogo ANTES de hacer la operación async
                Navigator.of(dialogContext).pop();

                // Mostrar indicador de carga en el Scaffold principal
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Enviando correo de recuperación...'),
                      ],
                    ),
                    backgroundColor: AppColors.blueMetraShop,
                    duration: const Duration(seconds: 3),
                  ),
                );

                try {
                  // Enviar email de recuperación usando Supabase
                  final resetPasswordUseCase = serviceLocator<ResetPasswordForEmail>();
                  final result = await resetPasswordUseCase(
                    ResetPasswordParams(email: email),
                  );

                  if (mounted) {
                    result.fold(
                      // Error
                      (failure) {
                        ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text(failure.message ?? 'Error al enviar código'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      // Éxito
                      (_) {
                        ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Código de verificación enviado a tu email.'),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Navegar a la pantalla de OTP
                        Future.delayed(const Duration(milliseconds: 800), () {
                          if (mounted) {
                            scaffoldContext.pushNamed(
                              'reset-password-otp',
                              queryParameters: {'email': email},
                            );
                          }
                        });
                      },
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.white, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Si existe una cuenta con ese email, recibirás un correo de recuperación.'),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Enviar enlace'),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIMPIEZA
  // ═══════════════════════════════════════════════════════════════════════════

  void _disposeResources() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthStateChanges,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.white,
            size: 18,
          ),
        ),
        onPressed: _navigateBack,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    switch (state.runtimeType) {
      case AuthSuccess:
        final successState = state as AuthSuccess;

        // Resetear intentos en caso de éxito
        _loginAttempts = 0;

        AuthSuccessUtils.showLoginSuccess(context, successState.user.name);
        _navigateToWelcome();
        break;

      case AuthFailure:
        final failureState = state as AuthFailure;

        // Incrementar contador de intentos
        setState(() {
          _loginAttempts++;
          _lastAttemptTime = DateTime.now();
        });

        _handleLoginError(failureState.message);
        break;
    }
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: double.infinity,
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildEnhancedFormSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary,
          Color(0xFF0A1520),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.loginImg),
              fit: BoxFit.cover,
              opacity: 0.8,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
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

  // NUEVO: Formulario completamente mejorado
  Widget _buildEnhancedFormSection() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Iniciar Sesión',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenido de vuelta. Ingresa tus credenciales para continuar.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Indicador de intentos
              _buildLoginAttemptsIndicator(),

              // Campo de email mejorado
              _buildEnhancedEmailField(),

              const SizedBox(height: 20),

              // Campo de contraseña mejorado
              _buildEnhancedPasswordField(),

              const SizedBox(height: 32),

              // Botón de login mejorado
              _buildEnhancedLoginButton(),

              const SizedBox(height: 24),

              // Divider
              _buildDivider(),

              const SizedBox(height: 24),

              // Botón de Google
              _buildGoogleLoginButton(),

              const SizedBox(height: 24),

              // Link para registro
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  // NUEVO: Indicador de intentos de login
  Widget _buildLoginAttemptsIndicator() {
    if (_loginAttempts == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _loginAttempts >= 3
            ? AppColors.error.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _loginAttempts >= 3
              ? AppColors.error.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _loginAttempts >= 3 ? Icons.warning : Icons.info_outline,
            size: 16,
            color: _loginAttempts >= 3 ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _loginAttempts >= 3
                  ? 'Múltiples intentos fallidos. ¿Olvidaste tu contraseña?'
                  : 'Intento ${_loginAttempts} de inicio de sesión',
              style: TextStyle(
                fontSize: 12,
                color: _loginAttempts >= 3 ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
          if (_loginAttempts >= 3)
            TextButton(
              onPressed: _showForgotPasswordDialog,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Recuperar',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // NUEVO: Campos mejorados
  Widget _buildEnhancedEmailField() {
    return EnhancedAuthTextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      label: 'Correo electrónico',
      hint: 'ejemplo@correo.com',
      prefixIcon: Icons.email_outlined,
      isEmail: true,
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      showValidationInRealTime: _showValidationHints,
      onChanged: (value) => _validateForm(),
    );
  }

  Widget _buildEnhancedPasswordField() {
    return Column(
      children: [
        EnhancedAuthTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          label: 'Contraseña',
          hint: 'Introduce tu contraseña',
          prefixIcon: Icons.lock_outlined,
          isPassword: true,
          enabled: !_isLoading,
          textInputAction: TextInputAction.done,
          showValidationInRealTime: false,
          handleLogin: (_) => _handleLogin(),
        ),

        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : _showForgotPasswordDialog,
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                color: _isLoading ? AppColors.textSecondary : AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedLoginButton() {
    final canLogin = _canSubmitForm();

    return EnhancedRegisterButton(
      onPressed: canLogin ? _handleLogin : null,
      isLoading: _isLoading,
      isEnabled: canLogin,
      text: 'Iniciar sesión',
      loadingText: 'Iniciando sesión...',
      icon: Icons.login,
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        icon: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'G',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        label: Text(
          'Continuar con Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isLoading ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _isLoading
                ? AppColors.textSecondary.withOpacity(0.3)
                : AppColors.textSecondary.withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : _navigateToRegister,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: '¿No tienes una cuenta? '),
              TextSpan(
                text: 'Regístrate',
                style: TextStyle(
                  color: _isLoading ? AppColors.textSecondary : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}