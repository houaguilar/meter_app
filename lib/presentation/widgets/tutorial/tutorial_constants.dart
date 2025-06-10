// lib/presentation/widgets/tutorial/tutorial_constants.dart
/// Constantes para el sistema de tutoriales
class TutorialConstants {
  // Duraciones de animación
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration slowAnimation = Duration(milliseconds: 800);

  // Mensajes por defecto
  static const String defaultInfoMessage = 'Recuerda que los datos que brindaremos son aproximados. Procura introducir datos exactos.';
  static const String defaultNextButton = 'Siguiente';
  static const String defaultSkipButton = 'Omitir tutorial';
  static const String defaultCompleteButton = 'Empezar';

  // IDs de módulos
  static const String wallModuleId = 'wall';
  static const String coatingModuleId = 'tarrajeo';
  static const String floorModuleId = 'piso';
  static const String slabModuleId = 'losa';
  static const String structuralModuleId = 'structural';

  // Assets por defecto (ajustar según tus assets)
  static const String defaultWallImage = 'assets/images/onboarding_tutorial.svg';
  static const String defaultCoatingImage = 'assets/images/coating_tutorial.svg';
  static const String defaultFloorImage = 'assets/images/floor_tutorial.svg';
  static const String defaultSlabImage = 'assets/images/slab_tutorial.svg';
  static const String defaultStructuralImage = 'assets/images/structural_tutorial.svg';
}