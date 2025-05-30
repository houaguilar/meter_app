import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../data/local/shared_preferences_helper.dart';
import '../../../../init_dependencies.dart';
import '../../../assets/images.dart';

/// Pantalla de bienvenida mejorada con onboarding interactivo,
/// animaciones fluidas y una mejor experiencia de usuario.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES Y ESTADO
  // ═══════════════════════════════════════════════════════════════════════════

  late PageController _pageController;
  late SharedPreferencesHelper _sharedPreferencesHelper;

  // Controladores de animación
  late AnimationController _mainAnimationController;
  late AnimationController _pageIndicatorController;
  late AnimationController _buttonAnimationController;
  late AnimationController _backgroundController;

  // Animaciones
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _indicatorAnimation;
  late Animation<double> _buttonSlideAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  // Estado
  int _currentPageIndex = 0;
  bool _hasNavigated = false;
  bool _isAnimating = false;

  // Configuración
  static const int _totalPages = 3;
  static const Duration _pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration _autoPlayDuration = Duration(seconds: 4);

  // Datos del onboarding
  late List<OnboardingPageData> _pages;

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

    if (state == AppLifecycleState.resumed) {
      _checkFirstTimeUser();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _initializeScreen() {
    WidgetsBinding.instance.addObserver(this);
    _sharedPreferencesHelper = serviceLocator<SharedPreferencesHelper>();
    _setupOnboardingData();
    _setupControllers();
    _setupAnimations();
    _setupSystemUI();

    // Verificar si es primera vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkFirstTimeUser();
        _startInitialAnimations();
      }
    });
  }

  void _setupOnboardingData() {
    _pages = [
      OnboardingPageData(
        title: 'Mediciones Precisas',
        description: 'Mide tu espacio y calcula la cantidad exacta de material que necesitas para tu proyecto.',
        imagePath: AppImages.muroImg,
        color: AppColors.secondary,
        features: [
          'Cálculos automatizados',
          'Múltiples tipos de construcción',
          'Resultados instantáneos',
        ],
      ),
      OnboardingPageData(
        title: 'Encuentra Materiales',
        description: 'Descubre los mejores materiales y conecta con proveedores confiables cerca de ti.',
        imagePath: AppImages.materialImg,
        color: AppColors.accent,
        features: [
          'Catálogo completo',
          'Proveedores verificados',
          'Comparación de precios',
        ],
      ),
      OnboardingPageData(
        title: 'Aprende y Crece',
        description: 'Accede a contenido educativo y mejora tus habilidades en construcción continuamente.',
        imagePath: AppImages.aprendizajeImg,
        color: AppColors.success,
        features: [
          'Tutoriales especializados',
          'Casos de éxito',
          'Comunidad activa',
        ],
      ),
    ];
  }

  void _setupControllers() {
    _pageController = PageController();

    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pageIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _setupAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageIndicatorController,
      curve: Curves.easeInOut,
    ));

    _buttonSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutBack,
    ));

    _backgroundColorAnimation = ColorTween(
      begin: AppColors.primary,
      end: _pages[0].color,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
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
    _mainAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _pageIndicatorController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _buttonAnimationController.forward();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LÓGICA DE NAVEGACIÓN Y PERSISTENCIA
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _checkFirstTimeUser() async {
    try {
      if (!_sharedPreferencesHelper.isFirstTimeUser()) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted && !_hasNavigated) {
          _navigateToHome();
        }
      }
    } catch (e) {
      debugPrint('Error verificando primera vez: $e');
      // En caso de error, mostrar la pantalla de bienvenida
    }
  }

  Future<void> _completeWelcome() async {
    if (_hasNavigated) return;

    try {
      // Feedback háptico
      HapticFeedback.lightImpact();

      // Guardar que ya no es primera vez
      await _sharedPreferencesHelper.setFirstTimeUser(false);

      // Animar salida
      await _animateExit();

      // Navegar al home
      _navigateToHome();

    } catch (e) {
      debugPrint('Error completando bienvenida: $e');
      // Navegar de todos modos
      _navigateToHome();
    }
  }

  Future<void> _animateExit() async {
    await Future.wait([
      _mainAnimationController.reverse(),
      _pageIndicatorController.reverse(),
      _buttonAnimationController.reverse(),
    ]);
  }

  void _navigateToHome() {
    if (_hasNavigated) return;

    _hasNavigated = true;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && context.mounted) {
        context.goNamed('home');
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANEJO DE PÁGINAS
  // ═══════════════════════════════════════════════════════════════════════════

  void _onPageChanged(int index) {
    if (_isAnimating) return;

    setState(() {
      _currentPageIndex = index;
    });

    // Animar cambio de color de fondo
    _backgroundColorAnimation = ColorTween(
      begin: _backgroundColorAnimation.value ?? _pages[0].color,
      end: _pages[index].color,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundController.reset();
    _backgroundController.forward();

    // Feedback háptico suave
    HapticFeedback.selectionClick();
  }

  void _nextPage() {
    if (_isAnimating || _currentPageIndex >= _totalPages - 1) return;

    _animateToPage(_currentPageIndex + 1);
  }

  void _previousPage() {
    if (_isAnimating || _currentPageIndex <= 0) return;

    _animateToPage(_currentPageIndex - 1);
  }

  void _animateToPage(int page) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    _pageController.animateToPage(
      page,
      duration: _pageTransitionDuration,
      curve: Curves.easeInOutCubic,
    ).then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  void _skipToEnd() {
    if (_isAnimating) return;

    HapticFeedback.lightImpact();
    _animateToPage(_totalPages - 1);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIMPIEZA
  // ═══════════════════════════════════════════════════════════════════════════

  void _disposeResources() {
    _pageController.dispose();
    _mainAnimationController.dispose();
    _pageIndicatorController.dispose();
    _buttonAnimationController.dispose();
    _backgroundController.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _backgroundColorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundColorAnimation.value ?? _pages[0].color,
                  (_backgroundColorAnimation.value ?? _pages[0].color).withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildPageView()),
        _buildPageIndicators(),
        _buildActionSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.architecture_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'METRASHOP',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              // Botón Skip
              if (_currentPageIndex < _totalPages - 1)
                TextButton(
                  onPressed: _skipToEnd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Omitir',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: _totalPages,
          itemBuilder: (context, index) {
            return _buildOnboardingPage(_pages[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPageData pageData, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen con efecto hero
          Hero(
            tag: 'onboarding_image_$index',
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.white.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  pageData.imagePath,
                  height: 120,
                  color: AppColors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Título
          Text(
            pageData.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Descripción
          Text(
            pageData.description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Características
          _buildFeaturesList(pageData.features),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(List<String> features) {
    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPageIndicators() {
    return AnimatedBuilder(
      animation: _indicatorAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalPages, (index) {
            final isActive = index == _currentPageIndex;
            return GestureDetector(
              onTap: () => _animateToPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ),
      builder: (context, child) {
        return FadeTransition(
          opacity: _indicatorAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildActionSection() {
    return AnimatedBuilder(
      animation: _buttonSlideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Botón principal
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _currentPageIndex == _totalPages - 1
                    ? _completeWelcome
                    : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: _pages[_currentPageIndex].color,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPageIndex == _totalPages - 1
                          ? 'Comenzar'
                          : 'Siguiente',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentPageIndex == _totalPages - 1
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Navegación adicional
            if (_currentPageIndex > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: _previousPage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.white.withOpacity(0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Anterior',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _buttonSlideAnimation.value)),
          child: Opacity(
            opacity: _buttonSlideAnimation.value,
            child: child,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;
  final Color color;
  final List<String> features;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
    required this.features,
  });
}