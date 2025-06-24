import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/auth/auth_error_handler.dart';
import '../../../../config/utils/auth/auth_success_utils.dart';
import '../../../../config/utils/error_handler.dart';
import '../../../../config/utils/validators.dart';
import '../../../assets/images.dart';
import '../../../blocs/auth/auth_bloc.dart';

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
      // Limpiar campos sensibles cuando la app se pausa
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
    _setupSystemUI();

    // Iniciar animaciones después del primer frame
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
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeAnimationController.forward();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDACIÓN Y SEGURIDAD
  // ═══════════════════════════════════════════════════════════════════════════

  void _validateForm() {
    final isValid = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        Validators.validateEmail(_emailController.text.trim());

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
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

    // Lista de caracteres peligrosos a remover
    final dangerousChars = ['<', '>', '"', "'", '`', '{', '}'];

    // Remover caracteres peligrosos uno por uno
    for (String char in dangerousChars) {
      cleaned = cleaned.replaceAll(char, '');
    }

    // Remover scripts básicos
    cleaned = cleaned.replaceAll('<script>', '');
    cleaned = cleaned.replaceAll('</script>', '');

    // Normalizar espacios múltiples
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

    // Unfocus para ocultar teclado
    FocusScope.of(context).unfocus();

    // Validar formulario
    if (!_formKey.currentState!.validate()) return;

    // Feedback háptico
    HapticFeedback.lightImpact();

    // Sanitizar inputs
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
      // Timeout de seguridad
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
        AuthErrorHandler.handleGoogleSignInError(context, e.toString());

        // Animar error
        _scaleAnimationController.forward().then((_) {
          _scaleAnimationController.reverse();
        });
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

  void _handleLoginError(dynamic error) {
    String message = ErrorHandler.getErrorMessage(error.toString());

    // Limpiar contraseña por seguridad
    _passwordController.clear();

    _showErrorMessage(message);

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
      ErrorHandler.showErrorSnackBar(context, message);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
    HapticFeedback.selectionClick();
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
        // Mostrar mensaje de éxito antes de navegar
        AuthSuccessUtils.showLoginSuccess(context, successState.user.name);
        _navigateToWelcome();
        break;
      case AuthFailure:
        final failureState = state as AuthFailure;
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
                  _buildFormSection(),
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
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'METRASHOP',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bienvenido de nuevo',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
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

  Widget _buildFormSection() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormHeader(),
                  const SizedBox(height: 32),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildForgotPasswordButton(),
                  const SizedBox(height: 32),
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialLoginButtons(),
                  const SizedBox(height: 32),
                  _buildRegisterPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Iniciar Sesión',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa a tu cuenta para continuar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo electrónico',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
          validator: _validateEmail,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'ejemplo@correo.com',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: _emailFocusNode.hasFocus
                  ? AppColors.secondary
                  : AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onFieldSubmitted: (_) {
            _passwordFocusNode.requestFocus();
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          validator: _validatePassword,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Tu contraseña',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: _passwordFocusNode.hasFocus
                  ? AppColors.secondary
                  : AppColors.textTertiary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : () {
          // TODO: Implementar recuperación de contraseña
          _showErrorMessage('Función próximamente disponible');
        },
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.neutral300,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : Text(
          'Iniciar Sesión',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O continúa con',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        icon: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        )
            : const Icon(
          Icons.g_mobiledata_rounded,
          size: 24,
          color: AppColors.secondary,
        ),
        label: Text(
          'Continuar con Google',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿No tienes una cuenta? ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _navigateToRegister,
            child: Text(
              'Regístrate',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}