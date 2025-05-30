import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/error_handler.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../config/utils/validators.dart';
import '../../../assets/images.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../widgets/widgets.dart';

/// Pantalla de registro mejorada con validaciones robustas,
/// políticas de contraseña, términos y condiciones, y animaciones fluidas.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES Y LLAVES
  // ═══════════════════════════════════════════════════════════════════════════

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES DE ANIMACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _passwordStrengthController;

  late Animation<Offset> _headerSlideAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _passwordStrengthAnimation;

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADO
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _hasNavigated = false;
  bool _isFormValid = false;
  bool _acceptedTerms = false;

  PasswordStrength _passwordStrength = PasswordStrength.none;

  // Configuración de timeouts
  static const Duration _registerTimeout = Duration(seconds: 30);
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

    _passwordStrengthController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _passwordStrengthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _passwordStrengthController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupControllerListeners() {
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(() {
      _validateForm();
      _updatePasswordStrength();
    });
    _confirmPasswordController.addListener(_validateForm);
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
    final isValid = _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        Validators.validateEmail(_emailController.text.trim()) &&
        _passwordController.text == _confirmPasswordController.text &&
        _passwordStrength != PasswordStrength.none &&
        _acceptedTerms;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    final newStrength = _calculatePasswordStrength(password);

    if (_passwordStrength != newStrength) {
      setState(() {
        _passwordStrength = newStrength;
      });

      // Animar cambio de fuerza
      _passwordStrengthController.reset();
      _passwordStrengthController.forward();
    }
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;

    // Longitud
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Caracteres
    if (password.contains(RegExp(r'[A-Z]'))) score++; // Mayúsculas
    if (password.contains(RegExp(r'[a-z]'))) score++; // Minúsculas
    if (password.contains(RegExp(r'[0-9]'))) score++; // Números
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++; // Símbolos

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, introduce tu nombre completo';
    }

    final name = value.trim();
    if (name.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    if (name.length > 100) {
      return 'El nombre es demasiado largo';
    }

    if (!RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s\-'\.]+$").hasMatch(name)) {
      return 'El nombre contiene caracteres no válidos';
    }

    return null;
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
      return 'Por favor, introduce una contraseña';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (value.length > 128) {
      return 'La contraseña es demasiado larga';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe incluir al menos una letra mayúscula';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe incluir al menos una letra minúscula';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe incluir al menos un número';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirma tu contraseña';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  void _clearSensitiveData() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    _isPasswordVisible = false;
    _isConfirmPasswordVisible = false;
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
  // REGISTRO
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleRegister() async {
    if (!_isFormValid || _isLoading) return;

    // Unfocus para ocultar teclado
    FocusScope.of(context).unfocus();

    // Validar formulario
    if (!_formKey.currentState!.validate()) return;

    // Verificar términos y condiciones
    if (!_acceptedTerms) {
      _showErrorMessage('Debes aceptar los términos y condiciones');
      return;
    }

    // Feedback háptico
    HapticFeedback.lightImpact();

    // Sanitizar inputs
    final name = _sanitizeInput(_nameController.text);
    final email = _sanitizeInput(_emailController.text);
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorMessage('Por favor, completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Timeout de seguridad
      await Future.any([
        _performRegister(name, email, password),
        Future.delayed(_registerTimeout, () {
          throw Exception('Tiempo de espera agotado');
        }),
      ]);
    } catch (e) {
      if (mounted) {
        _handleRegisterError(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performRegister(String name, String email, String password) async {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthSignUp(
      name: name,
      email: email,
      password: password,
    ));
  }

  void _handleRegisterError(dynamic error) {
    String message = ErrorHandler.getErrorMessage(error.toString());

    // Limpiar contraseñas por seguridad
    _passwordController.clear();
    _confirmPasswordController.clear();

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

  void _navigateToLogin() {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    context.pushNamed('login');
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

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
    HapticFeedback.selectionClick();
  }

  void _toggleTermsAcceptance(bool? value) {
    setState(() {
      _acceptedTerms = value ?? false;
    });
    _validateForm();
    HapticFeedback.selectionClick();
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
            'Al crear una cuenta en METRASHOP, aceptas nuestros términos de servicio y política de privacidad.\n\n'
                '• Nos comprometemos a proteger tu información personal\n'
                '• Tu privacidad es importante para nosotros\n'
                '• Utilizamos tus datos solo para mejorar tu experiencia\n'
                '• Puedes eliminar tu cuenta en cualquier momento\n\n'
                'Para más información, visita nuestra página web.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIMPIEZA
  // ═══════════════════════════════════════════════════════════════════════════

  void _disposeResources() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _passwordStrengthController.dispose();
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
        _navigateToWelcome();
        break;
      case AuthFailure:
        final failureState = state as AuthFailure;
        _handleRegisterError(failureState.message);
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
          height: MediaQuery.of(context).size.height * 0.25,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.registerImg),
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
                          fontSize: 28,
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
                      const SizedBox(height: 4),
                      Text(
                        'Únete a nosotros',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
            minHeight: MediaQuery.of(context).size.height * 0.75,
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
                  const SizedBox(height: 24),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 12),
                  _buildPasswordStrengthIndicator(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 32),
                  _buildLoginPrompt(),
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
          'Crear Cuenta',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Completa la información para empezar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre completo',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          validator: _validateName,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Tu nombre y apellido',
            prefixIcon: Icon(
              Icons.person_outlined,
              color: _nameFocusNode.hasFocus
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
            _emailFocusNode.requestFocus();
          },
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
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
          validator: _validatePassword,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Mínimo 8 caracteres',
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
          onFieldSubmitted: (_) {
            _confirmPasswordFocusNode.requestFocus();
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _passwordStrengthAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Seguridad: ',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _passwordStrength.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _passwordStrength.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _passwordStrength.value,
            backgroundColor: AppColors.neutral200,
            color: _passwordStrength.color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      builder: (context, child) {
        return FadeTransition(
          opacity: _passwordStrengthAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmar contraseña',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: !_isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          validator: _validateConfirmPassword,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Repite tu contraseña',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: _confirmPasswordFocusNode.hasFocus
                  ? AppColors.secondary
                  : AppColors.textTertiary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: _toggleConfirmPasswordVisibility,
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
          onFieldSubmitted: (_) => _handleRegister(),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: _isLoading ? null : _toggleTermsAcceptance,
            activeColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Acepto los '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: _showTermsDialog,
                    child: Text(
                      'términos y condiciones',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' y la política de privacidad'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _handleRegister : null,
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
          'Crear Cuenta',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Ya tienes una cuenta? ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _navigateToLogin,
            child: Text(
              'Inicia sesión',
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

// ═══════════════════════════════════════════════════════════════════════════
// ENUMS Y CLASES AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

enum PasswordStrength {
  none,
  weak,
  medium,
  strong;

  String get displayName {
    switch (this) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Débil';
      case PasswordStrength.medium:
        return 'Media';
      case PasswordStrength.strong:
        return 'Fuerte';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.none:
        return AppColors.neutral400;
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return AppColors.warning;
      case PasswordStrength.strong:
        return AppColors.success;
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}