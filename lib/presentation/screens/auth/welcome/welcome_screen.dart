import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../data/local/shared_preferences_helper.dart';
import '../../../../init_dependencies.dart';
import 'package:meter_app/config/assets/app_images.dart';

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
        title: 'APRENDE CONSTRUYENDO',
        description: 'Encuentra cursos, videos y una comunidad de expertos',
        imagePath: AppImages.aprendeConstruyendoImg,
        color: AppColors.secondary,
      ),
      OnboardingPageData(
        title: 'CÁLCULO DE MATERIALES',
        description: 'Utiliza plantillas de cálculo y obten resultados precisos',
        imagePath: AppImages.calculoMaterialesImg,
        color: AppColors.accent,
      ),
      OnboardingPageData(
        title: 'CONECTA CON PROVEEDORES',
        description: 'Compara, cotiza y encuentra los mejores materiales cerca de ti',
        imagePath: AppImages.conectaProveedoresImg,
        color: AppColors.success,
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
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut), // Cambio de Curves.elasticOut
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
      curve: Curves.easeOut, // Cambio de Curves.easeOutBack
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
  // MANEJO DE PÁGINAS - CORREGIDO
  // ═══════════════════════════════════════════════════════════════════════════

  void _onPageChanged(int index) {
    if (_isAnimating) return;

    setState(() {
      _currentPageIndex = index;
    });

    _updateBackgroundColor(index);

    // Feedback háptico suave
    HapticFeedback.selectionClick();
  }

  void _updateBackgroundColor(int index) {
    // Crear nueva animación de color
    _backgroundColorAnimation = ColorTween(
      begin: _backgroundColorAnimation.value ?? _pages[_currentPageIndex].color,
      end: _pages[index].color,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundController.reset();
    _backgroundController.forward();
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

    // Actualizar el índice inmediatamente para las animaciones
    setState(() {
      _currentPageIndex = page;
    });

    // Actualizar color de fondo
    _updateBackgroundColor(page);

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
  // BUILD METHODS - CORREGIDOS CON MEJORES LAYOUTS
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
        // Header flexible
        Flexible(
          flex: 1,
          child: _buildHeader(),
        ),
        // PageView expandido - MÁS ESPACIO
        Expanded(
          flex: 8,
          child: _buildPageView(),
        ),
        // Indicadores con altura fija pero segura
        Container(
          height: 60,
          child: _buildPageIndicators(),
        ),
        // Acciones flexibles - MENOS ESPACIO
        Flexible(
          flex: 2,
          child: _buildActionSection(),
        ),
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
                height: 400,
                width: double.infinity,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: _buildImage(pageData.imagePath),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Título
            Text(
              pageData.title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Descripción
            Text(
              pageData.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.white.withOpacity(0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
  }

  Widget _buildImage(String imagePath) {
    // Auto-detectar si es SVG o PNG
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        allowDrawingOutsideViewBox: false,
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }


  Widget _buildPageIndicators() {
    return AnimatedBuilder(
      animation: _indicatorAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
      builder: (context, child) {
        // Asegurar que la opacidad esté en rango válido
        final opacity = _buttonSlideAnimation.value.clamp(0.0, 1.0);
        final translateY = 30 * (1 - _buttonSlideAnimation.value).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón principal
                  SizedBox(
                    width: double.infinity,
                    height: 50, // Reducido de 56 a 50
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

                  // Navegación adicional - Solo si hay espacio
                  if (_currentPageIndex > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12), // Reducido de 16 a 12
                      child: TextButton(
                        onPressed: _previousPage,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.white.withOpacity(0.7),
                              size: 16, // Reducido de 18 a 16
                            ),
                            const SizedBox(width: 6), // Reducido de 8 a 6
                            Text(
                              'Anterior',
                              style: GoogleFonts.poppins(
                                fontSize: 13, // Reducido de 14 a 13
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

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}