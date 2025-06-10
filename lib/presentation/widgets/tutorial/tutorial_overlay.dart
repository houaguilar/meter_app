import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/theme.dart';
import '../../../data/local/shared_preferences_helper.dart';
import '../../../domain/entities/tutorial/tutorial_step.dart';
import '../../../init_dependencies.dart';
import '../../blocs/tutorial/tutorial_bloc.dart';

/// Overlay de tutorial unificado y reutilizable para todos los flujos
class TutorialOverlay extends StatelessWidget {
  final TutorialConfig config;
  final VoidCallback onSkip;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.config,
    required this.onSkip,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocProvider(
            create: (_) => TutorialBloc(totalSteps: config.steps.length),
            child: BlocListener<TutorialBloc, TutorialState>(
              listener: (context, state) {
                if (state is TutorialCompleted) {
                  _handleTutorialComplete(context);
                }
              },
              child: BlocBuilder<TutorialBloc, TutorialState>(
                builder: (context, state) {
                  int currentStepIndex = 0;

                  if (state is TutorialStep) {
                    currentStepIndex = state.stepIndex;
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOutCubic,
                        )),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: TutorialStepWidget(
                      key: ValueKey(currentStepIndex),
                      step: config.steps[currentStepIndex],
                      stepIndex: currentStepIndex,
                      totalSteps: config.steps.length,
                      config: config,
                      onSkip: onSkip,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTutorialComplete(BuildContext context) {
    HapticFeedback.mediumImpact();
    if (onComplete != null) {
      onComplete!();
    } else {
      onSkip();
    }
  }
}

/// Widget individual para cada paso del tutorial
class TutorialStepWidget extends StatefulWidget {
  final TutorialStepData step;
  final int stepIndex;
  final int totalSteps;
  final TutorialConfig config;
  final VoidCallback onSkip;

  const TutorialStepWidget({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.config,
    required this.onSkip,
  });

  @override
  State<TutorialStepWidget> createState() => _TutorialStepWidgetState();
}

class _TutorialStepWidgetState extends State<TutorialStepWidget>
    with TickerProviderStateMixin {

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = widget.stepIndex == widget.totalSteps - 1;
    final canGoBack = widget.stepIndex > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Stack(
            children: [
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header con progreso
                    _buildHeader(canGoBack),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Imagen con animación
                            _buildAnimatedImage(),

                            const SizedBox(height: 32),

                            // Información del paso
                            _buildStepInfo(),

                            const SizedBox(height: 24),

                            // Info box
                            if (widget.config.showInfoBox)
                              _buildInfoSection(),

                            const SizedBox(height: 32),

                            // Botones de navegación
                            _buildNavigationButtons(isLastStep),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de cerrar
              Positioned(
                top: 16,
                right: 16,
                child: _buildCloseButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool canGoBack) {
    return Row(
      children: [
        // Botón de retroceso
        if (canGoBack)
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<TutorialBloc>().add(TutorialPrevious());
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.white,
              size: 24,
            ),
          )
        else
          const SizedBox(width: 48),

        Expanded(
          child: Column(
            children: [
              // Indicador de progreso
              _buildProgressIndicator(),

              const SizedBox(height: 12),

              // Información del paso
              Text(
                'Paso ${widget.stepIndex + 1} de ${widget.totalSteps}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 48), // Espaciado para balance
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final progress = (widget.stepIndex + 1) / widget.totalSteps;
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Transform.rotate(
            angle: (1 - value) * 0.1,
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral900.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                widget.step.imagePath,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepInfo() {
    return Column(
      children: [
        // Título con animación
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Text(
                  widget.step.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Descripción con animación retrasada
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 15 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Text(
                  widget.step.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.config.infoMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.9),
                        height: 1.4,
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

  Widget _buildNavigationButtons(bool isLastStep) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                // Botón principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (isLastStep) {
                        widget.onSkip();
                      } else {
                        context.read<TutorialBloc>().add(TutorialNext());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.accent.withOpacity(0.4),
                    ),
                    child: Text(
                      isLastStep ? widget.config.completeButtonText : widget.config.nextButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón de omitir
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onSkip();
                  },
                  child: Text(
                    widget.config.skipButtonText,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloseButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          widget.onSkip();
        },
        icon: const Icon(
          Icons.close,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }
}

// lib/data/models/tutorial/tutorial_config.dart
/// Configuración para diferentes tipos de tutorial
class TutorialConfig {
  final String moduleId;
  final String title;
  final List<TutorialStepData> steps;
  final String infoMessage;
  final bool showInfoBox;
  final String nextButtonText;
  final String skipButtonText;
  final String completeButtonText;

  const TutorialConfig({
    required this.moduleId,
    required this.title,
    required this.steps,
    required this.infoMessage,
    this.showInfoBox = true,
    this.nextButtonText = 'Siguiente',
    this.skipButtonText = 'Omitir tutorial',
    this.completeButtonText = 'Empezar',
  });
}

// lib/presentation/widgets/tutorial/tutorial_factory.dart
/// Factory para crear configuraciones de tutorial específicas
class TutorialFactory {
  /// Tutorial para el módulo de muros/ladrillos
  static TutorialConfig createWallTutorial() {
    return TutorialConfig(
      moduleId: 'wall_tutorial',
      title: 'Tutorial de Muros',
      infoMessage: 'Recuerda que los datos que brindaremos son aproximados. Procura introducir datos exactos.',
      steps: [
        TutorialStepData(
          title: "¿Qué debes hacer?",
          description: "Ingresa la descripción para el proyecto.\nSi ya tienes el área completa ingrésala, de no ser así, coloca las medidas, nosotros te ayudaremos.",
          imagePath: "assets/images/onboarding_tutorial.svg",
        ),
        TutorialStepData(
          title: "Configuración",
          description: "Elige el tipo de asentado que utilizarás para tu proyecto. Si no lo sabes, aquí te brindaremos las opciones.",
          imagePath: "assets/images/piso_tutorial.svg",
        ),
        TutorialStepData(
          title: "Secciones",
          description: "Podrás añadir diferentes secciones al proyecto para tener cada espacio metrado.",
          imagePath: "assets/images/column_tutorial.svg",
        ),
      ],
      completeButtonText: 'Empezar a calcular',
    );
  }

  /// Tutorial para el módulo de tarrajeo
  static TutorialConfig createCoatingTutorial() {
    return TutorialConfig(
      moduleId: 'coating_tutorial',
      title: 'Tutorial de Tarrajeo',
      infoMessage: 'Los cálculos de tarrajeo incluyen factores de desperdicio. Revisa bien las proporciones.',
      steps: [
        TutorialStepData(
          title: "Medición de Superficies",
          description: "Ingresa las medidas de las superficies que vas a tarrajear. Puedes usar área directa o medidas individuales.",
          imagePath: "assets/images/coating_measurement.svg",
        ),
        TutorialStepData(
          title: "Espesor y Proporción",
          description: "Selecciona el espesor del tarrajeo y la proporción de mortero según el tipo de acabado deseado.",
          imagePath: "assets/images/coating_thickness.svg",
        ),
        TutorialStepData(
          title: "Factores de Desperdicio",
          description: "Configura los factores de desperdicio para obtener cálculos más precisos en tu proyecto.",
          imagePath: "assets/images/coating_waste.svg",
        ),
      ],
      completeButtonText: 'Comenzar tarrajeo',
    );
  }

  /// Tutorial para el módulo de pisos
  static TutorialConfig createFloorTutorial() {
    return TutorialConfig(
      moduleId: 'floor_tutorial',
      title: 'Tutorial de Pisos',
      infoMessage: 'Para pisos considera el tipo de superficie y las juntas de dilatación.',
      steps: [
        TutorialStepData(
          title: "Área de Piso",
          description: "Calcula el área total del piso a construir. Puedes dividir en secciones si tienes formas irregulares.",
          imagePath: "assets/images/floor_area.svg",
        ),
        TutorialStepData(
          title: "Tipo de Piso",
          description: "Selecciona el tipo de piso que vas a construir: falso piso, contrapiso o acabado final.",
          imagePath: "assets/images/floor_type.svg",
        ),
        TutorialStepData(
          title: "Configuración Técnica",
          description: "Ajusta el espesor, proporción de materiales y factores según el tipo de piso seleccionado.",
          imagePath: "assets/images/floor_config.svg",
        ),
      ],
      completeButtonText: 'Calcular piso',
    );
  }

  /// Tutorial para el módulo de losas
  static TutorialConfig createSlabTutorial() {
    return TutorialConfig(
      moduleId: 'slab_tutorial',
      title: 'Tutorial de Losas',
      infoMessage: 'Las losas requieren cálculos estructurales precisos. Verifica las especificaciones técnicas.',
      steps: [
        TutorialStepData(
          title: "Dimensiones de Losa",
          description: "Ingresa las dimensiones exactas de la losa: largo, ancho y altura según el diseño estructural.",
          imagePath: "assets/images/slab_dimensions.svg",
        ),
        TutorialStepData(
          title: "Tipo de Losa",
          description: "Selecciona el tipo de losa: aligerada, maciza o prefabricada según tu proyecto.",
          imagePath: "assets/images/slab_type.svg",
        ),
        TutorialStepData(
          title: "Materiales Estructurales",
          description: "Configura los materiales: concreto, acero de refuerzo y elementos auxiliares necesarios.",
          imagePath: "assets/images/slab_materials.svg",
        ),
      ],
      completeButtonText: 'Calcular losa',
    );
  }

  /// Tutorial para elementos estructurales
  static TutorialConfig createStructuralTutorial() {
    return TutorialConfig(
      moduleId: 'structural_tutorial',
      title: 'Tutorial de Elementos Estructurales',
      infoMessage: 'Los elementos estructurales requieren precisión y cumplimiento de normativas.',
      steps: [
        TutorialStepData(
          title: "Tipo de Elemento",
          description: "Selecciona el elemento estructural: columnas, vigas, zapatas o muros de contención.",
          imagePath: "assets/images/structural_element.svg",
        ),
        TutorialStepData(
          title: "Dimensiones Estructurales",
          description: "Ingresa las dimensiones según los planos estructurales y especificaciones del ingeniero.",
          imagePath: "assets/images/structural_dimensions.svg",
        ),
        TutorialStepData(
          title: "Refuerzo y Materiales",
          description: "Configura el acero de refuerzo, calidad del concreto y otros materiales estructurales.",
          imagePath: "assets/images/structural_reinforcement.svg",
        ),
      ],
      completeButtonText: 'Calcular elementos',
    );
  }

  /// Obtiene el tutorial basado en el ID del módulo
  static TutorialConfig? getTutorialByModule(String moduleId) {
    switch (moduleId) {
      case 'wall':
      case 'ladrillo':
      case 'muro':
        return createWallTutorial();
      case 'tarrajeo':
      case 'coating':
        return createCoatingTutorial();
      case 'piso':
      case 'floor':
        return createFloorTutorial();
      case 'losa':
      case 'slab':
        return createSlabTutorial();
      case 'structural':
      case 'elementos':
        return createStructuralTutorial();
      default:
        return null;
    }
  }
}

// lib/presentation/widgets/tutorial/tutorial_manager.dart

/// Manager para controlar el estado y la lógica de los tutoriales
class TutorialManager {
  static const String _tutorialPrefix = 'tutorial_shown_';

  /// Verifica si un tutorial ya fue mostrado
  static bool isTutorialShown(SharedPreferencesHelper prefs, String moduleId) {
    return prefs.sharedPreferences.getBool(_tutorialPrefix + moduleId) ?? false;
  }

  /// Marca un tutorial como mostrado
  static Future<void> markTutorialAsShown(SharedPreferencesHelper prefs, String moduleId) async {
    await prefs.sharedPreferences.setBool(_tutorialPrefix + moduleId, true);
  }

  /// Resetea el estado de un tutorial (útil para testing)
  static Future<void> resetTutorial(SharedPreferencesHelper prefs, String moduleId) async {
    await prefs.sharedPreferences.setBool(_tutorialPrefix + moduleId, false);
  }

  /// Resetea todos los tutoriales
  static Future<void> resetAllTutorials(SharedPreferencesHelper prefs) async {
    final tutorials = ['wall', 'tarrajeo', 'piso', 'losa', 'structural'];
    for (final tutorial in tutorials) {
      await resetTutorial(prefs, tutorial);
    }
  }

  /// Muestra un tutorial si no ha sido mostrado antes
  static Future<void> showTutorialIfNeeded(
      BuildContext context,
      SharedPreferencesHelper prefs,
      String moduleId,
      ) async {
    if (!isTutorialShown(prefs, moduleId)) {
      final config = TutorialFactory.getTutorialByModule(moduleId);
      if (config != null) {
        await showTutorial(context, config, () async {
          await markTutorialAsShown(prefs, moduleId);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  /// Muestra un tutorial específico
  static Future<void> showTutorial(
      BuildContext context,
      TutorialConfig config,
      VoidCallback onComplete,
      ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TutorialOverlay(
        config: config,
        onSkip: onComplete,
        onComplete: onComplete,
      ),
    );
  }
}


// lib/presentation/widgets/tutorial/tutorial_mixin.dart
/// Mixin para facilitar el uso de tutoriales en las pantallas
mixin TutorialMixin<T extends StatefulWidget> on State<T> {
  late SharedPreferencesHelper _sharedPrefs;

  /// Inicializa el tutorial manager
  void initializeTutorial() {
    _sharedPrefs = serviceLocator<SharedPreferencesHelper>();
  }

  /// Muestra el tutorial para un módulo específico
  Future<void> showModuleTutorial(String moduleId) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialManager.showTutorialIfNeeded(
        context,
        _sharedPrefs,
        moduleId,
      );
    });
  }

  /// Fuerza la muestra de un tutorial (ignora si ya fue mostrado)
  Future<void> forceTutorial(String moduleId) async {
    final config = TutorialFactory.getTutorialByModule(moduleId);
    if (config != null) {
      await TutorialManager.showTutorial(
        context,
        config,
            () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );
    }
  }

  /// Resetea un tutorial específico
  Future<void> resetTutorial(String moduleId) async {
    await TutorialManager.resetTutorial(_sharedPrefs, moduleId);
  }
}