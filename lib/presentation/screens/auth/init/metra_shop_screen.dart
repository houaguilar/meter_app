import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/error_handler.dart';
import '../../../assets/images.dart';
import '../../../blocs/auth/auth_bloc.dart';

class MetraShopScreen extends StatefulWidget {
  const MetraShopScreen({super.key});

  @override
  State<MetraShopScreen> createState() => _MetraShopScreenState();
}

class _MetraShopScreenState extends State<MetraShopScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES DE ANIMACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  late AnimationController _logoAnimationController;
  late AnimationController _buttonsAnimationController;
  late AnimationController _backgroundAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _buttonsOpacityAnimation;
  late Animation<Offset> _buttonsSlideAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADO Y CONFIGURACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isInitialized = false;
  bool _hasNavigated = false;
  bool _isDisposed = false;

  // Configuración de timeouts y delays
  static const Duration _initializationTimeout = Duration(seconds: 10);
  static const Duration _navigationDelay = Duration(milliseconds: 500);
  static const Duration _animationDelay = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeAnimations();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Verificar autenticación cuando la app vuelve a primer plano
    if (state == AppLifecycleState.resumed && mounted && !_hasNavigated) {
      _checkAuthenticationState();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _initializeScreen() {
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _setupSystemUI();

    // Inicializar autenticación después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _initializeAuthentication();
      }
    });
  }

  void _setupAnimations() {
    // Controlador para animación del logo
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Controlador para animación de botones
    _buttonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controlador para animación de fondo
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animaciones del logo
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeOutBack,
    ));

    // Animaciones de botones
    _buttonsOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeIn,
    ));

    _buttonsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Animación de fondo
    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeIn,
    ));
  }

  void _setupSystemUI() {
    // Configurar la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Configurar orientación
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _initializeAuthentication() {
    _isInitialized = true;

    try {
      // Iniciar animación de fondo primero
      _backgroundAnimationController.forward();

      // Verificar estado de autenticación con timeout
      Future.delayed(_animationDelay, () {
        if (mounted && !_isDisposed) {
          _checkAuthenticationState();
        }
      });

      // Timeout de seguridad
      Future.delayed(_initializationTimeout, () {
        if (mounted && !_hasNavigated && !_isDisposed) {
          _handleInitializationTimeout();
        }
      });

    } catch (e) {
      _handleInitializationError(e);
    }
  }

  void _checkAuthenticationState() {
    try {
      final authBloc = context.read<AuthBloc>();
      authBloc.add(AuthIsUserLoggedIn());
    } catch (e) {
      _handleAuthenticationError('Error al verificar autenticación: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANEJO DE ERRORES Y TIMEOUTS
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleInitializationTimeout() {
    debugPrint('Timeout en inicialización - mostrando UI de autenticación');
    if (mounted) {
      _showAuthenticationUI();
    }
  }

  void _handleInitializationError(dynamic error) {
    debugPrint('Error en inicialización: $error');
    if (mounted) {
      _showAuthenticationUI();
    }
  }

  void _handleAuthenticationError(String message) {
    debugPrint('Error de autenticación: $message');
    if (mounted) {
      ErrorHandler.showErrorSnackBar(
        context,
        ErrorHandler.getErrorMessage(message),
        onRetry: _checkAuthenticationState,
      );
      _showAuthenticationUI();
    }
  }

  void _handleNetworkError() {
    debugPrint('Error de red detectado');
    if (mounted) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Sin conexión a internet. Algunas funciones pueden estar limitadas.',
        onRetry: _checkAuthenticationState,
      );
      _showAuthenticationUI();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _navigateToHome() {
    if (_hasNavigated || _isDisposed) return;

    _hasNavigated = true;
    Future.delayed(_navigationDelay, () {
      if (mounted && context.mounted) {
        context.goNamed('home');
      }
    });
  }

  void _navigateToWelcome() {
    if (_hasNavigated || _isDisposed) return;

    _hasNavigated = true;
    Future.delayed(_navigationDelay, () {
      if (mounted && context.mounted) {
        context.goNamed('welcome');
      }
    });
  }

  void _showAuthenticationUI() {
    if (_isDisposed) return;

    // Iniciar animaciones de UI
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _logoAnimationController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _buttonsAnimationController.forward();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCIONES DE USUARIO
  // ═══════════════════════════════════════════════════════════════════════════

  void _navigateToLogin() {
    if (!mounted) return;

    // Feedback háptico
    HapticFeedback.lightImpact();

    // Navegar con animación
    context.pushNamed('login');
  }

  void _navigateToRegister() {
    if (!mounted) return;

    // Feedback háptico
    HapticFeedback.lightImpact();

    // Navegar con animación
    context.pushNamed('register');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIMPIEZA
  // ═══════════════════════════════════════════════════════════════════════════

  void _disposeAnimations() {
    try {
      _logoAnimationController.dispose();
      _buttonsAnimationController.dispose();
      _backgroundAnimationController.dispose();
    } catch (e) {
      debugPrint('Error al liberar animaciones: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthStateChanges,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: _buildContent,
        ),
      ),
    );
  }

  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    if (_isDisposed || _hasNavigated) return;

    switch (state.runtimeType) {
      case AuthSuccess:
      // Usuario autenticado - ir directamente al home
        debugPrint('Usuario ya autenticado - navegando a home');
        _navigateToHome();
        break;

      case AuthInitial:
      // No hay sesión activa - mostrar UI de autenticación
        debugPrint('No hay sesión activa - mostrando autenticación');
        _showAuthenticationUI();
        break;

      case AuthFailure:
        final failureState = state as AuthFailure;
        if (failureState.message.toLowerCase().contains('network') ||
            failureState.message.toLowerCase().contains('connection')) {
          _handleNetworkError();
        } else {
          _handleAuthenticationError(failureState.message);
        }
        break;

      case AuthLoading:
      // Estado de carga - mantener UI actual
        break;

      default:
        _showAuthenticationUI();
        break;
    }
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    if (state is AuthLoading && !_hasNavigated) {
      return _buildLoadingState();
    }

    // Mostrar UI de autenticación por defecto
    return _buildAuthenticationUI();
  }

  Widget _buildLoadingState() {
    return AnimatedBuilder(
      animation: _backgroundOpacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(_backgroundOpacityAnimation.value),
                AppColors.primary.withOpacity(_backgroundOpacityAnimation.value * 0.8),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 3,
                ),
                SizedBox(height: 24),
                Text(
                  'Verificando autenticación...',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthenticationUI() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            Color(0xFF0A1520),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: _buildHeroSection(),
            ),
            Expanded(
              flex: 4,
              child: _buildActionSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.welcomeImg),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedLogo(),
          const SizedBox(height: 32),
          _buildWelcomeText(),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlideAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: FadeTransition(
              opacity: _logoOpacityAnimation,
              child: Column(
                children: [
                  // Logo con resplandor
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.architecture_rounded,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Texto del logo
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                      children: [
                        TextSpan(
                          text: 'METRA',
                          style: TextStyle(color: AppColors.white),
                        ),
                        TextSpan(
                          text: 'SHOP',
                          style: TextStyle(color: AppColors.secondary),
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

  Widget _buildWelcomeText() {
    return AnimatedBuilder(
      animation: _logoOpacityAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoOpacityAnimation,
          child: Column(
            children: [
              Text(
                'Tu plataforma de construcción',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Calcula materiales, encuentra proveedores y gestiona tus proyectos',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionSection() {
    return AnimatedBuilder(
      animation: _buttonsAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: _buttonsSlideAnimation,
          child: FadeTransition(
            opacity: _buttonsOpacityAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildSecurityInfo(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón de inicio de sesión
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Botón de registro
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _navigateToRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Crear cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tus datos están protegidos con encriptación de extremo a extremo',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}