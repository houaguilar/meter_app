import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/error_handler.dart';
import '../../../../config/utils/validators.dart';
import '../../../../domain/entities/projects/project.dart';
import '../../../blocs/projects/projects_bloc.dart';

/// Pantalla para crear un nuevo proyecto
class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen>
    with SingleTickerProviderStateMixin {

  // Controllers y formulario
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  // Estado de validación
  bool _hasError = false;
  String? _errorMessage;
  bool _isSubmitting = false;
  int? _createdProjectId; // Para almacenar el ID del proyecto creado

  // Animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFormValidation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  /// Inicializa las animaciones
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    // Iniciar animación
    _animationController.forward();

    // Enfocar automáticamente después de la animación
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  /// Configura la validación del formulario
  void _setupFormValidation() {
    _nameController.addListener(_onTextChanged);
  }

  /// Maneja cambios en el texto
  void _onTextChanged() {
    if (_hasError && _nameController.text.trim().isNotEmpty) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }
  }

  /// Valida y guarda el proyecto
  Future<void> _saveProject() async {
    if (_isSubmitting) return;

    // Ocultar teclado
    FocusScope.of(context).unfocus();

    // Validar formulario
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final project = Project(name: _nameController.text.trim());
      context.read<ProjectsBloc>().add(SaveProject(project: project));
    } catch (e) {
      _handleError('Error inesperado: ${e.toString()}');
    }
  }

  /// Valida el formulario
  bool _validateForm() {
    final name = _nameController.text.trim();

    if (!Validators.validateText(name)) {
      _setError('El nombre del proyecto es obligatorio');
      return false;
    }

    if (name.length < 2) {
      _setError('El nombre debe tener al menos 2 caracteres');
      return false;
    }

    if (name.length > 100) {
      _setError('El nombre es demasiado largo (máximo 100 caracteres)');
      return false;
    }

    // Validación mejorada de caracteres - permitir ñ y acentos
    if (_containsInvalidCharacters(name)) {
      _setError('El nombre contiene caracteres no válidos');
      return false;
    }

    return true;
  }

  /// Verifica caracteres inválidos - MEJORADO para permitir ñ y acentos
  bool _containsInvalidCharacters(String text) {
    // Solo prohibir caracteres que realmente son problemáticos para nombres de archivo
    final invalidChars = RegExp(r'[<>"\\\/:*?|]');
    return invalidChars.hasMatch(text);
  }

  /// Establece un error
  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isSubmitting = false;
    });

    // Vibración háptica para indicar error
    HapticFeedback.lightImpact();

    // Enfocar el campo para corrección
    _focusNode.requestFocus();
  }

  /// Maneja errores generales
  void _handleError(String message) {
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ErrorHandler.showErrorSnackBar(
      context,
      message,
      onRetry: _saveProject,
    );
  }

  /// Maneja el éxito
  void _handleSuccess(Project? project) {
    if (!mounted) return;

    // Vibración de éxito
    HapticFeedback.mediumImpact();

    // Mostrar mensaje de éxito
    ErrorHandler.showSuccessSnackBar(
      context,
      'Proyecto creado exitosamente',
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      // MEJORADO: GestureDetector para ocultar teclado al tocar fuera
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocListener<ProjectsBloc, ProjectsState>(
          listener: _handleBlocListener,
          child: SafeArea(
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  /// Construye la AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Nuevo Proyecto',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => context.pop(),
        tooltip: 'Volver',
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  /// Construye el cuerpo principal
  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildCharacterTips(), // NUEVO: Consejos sobre caracteres permitidos
                    const Expanded(
                      child: SizedBox(height: 32),
                    ),
                    _buildActionButtons(),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el header explicativo
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Crear nuevo proyecto',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Los proyectos te ayudan a organizar tus metrados.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el formulario
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Información del proyecto',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildNameField(),
      ],
    );
  }

  /// Construye el campo de nombre
  Widget _buildNameField() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nombre del proyecto',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            focusNode: _focusNode,
            enabled: !_isSubmitting,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 100,
            // MEJORADO: Permitir caracteres latinos incluyendo ñ
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ0-9\s\-_.,()]+'),
              ),
            ],
            decoration: InputDecoration(
              hintText: 'Ej: Casa de la familia García - Año 2024',
              prefixIcon: Icon(
                Icons.folder_outlined,
                color: _hasError
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
              errorText: _hasError ? _errorMessage : null,
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _isSubmitting
                    ? null
                    : () {
                  _nameController.clear();
                  _focusNode.requestFocus();
                },
                tooltip: 'Limpiar',
              )
                  : null,
              counterStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            style: AppTypography.bodyLarge,
            onFieldSubmitted: (_) => _saveProject(),
            // MEJORADO: Cerrar teclado al tocar fuera
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
          if (!_hasError) ...[
            const SizedBox(height: 8),
            Text(
              'Usa un nombre descriptivo y fácil de recordar',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// NUEVO: Consejos sobre caracteres permitidos
  Widget _buildCharacterTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Caracteres permitidos',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildCharacterChip('Letras: A-Z, a-z'),
              _buildCharacterChip('Acentos: á, é, í, ó, ú'),
              _buildCharacterChip('Eñe: ñ, Ñ'),
              _buildCharacterChip('Números: 0-9'),
              _buildCharacterChip('Espacios y guiones'),
              _buildCharacterChip('Puntos y comas'),
              _buildCharacterChip('Paréntesis: ( )'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'No se permiten: < > " \\ / : * ? |',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.accent,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _saveProject,
          icon: _isSubmitting
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.white,
              ),
            ),
          )
              : const Icon(Icons.save_outlined),
          label: Text(_isSubmitting ? 'Guardando...' : 'Crear Proyecto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: _isSubmitting ? 0 : 2,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
          label: const Text('Cancelar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// Maneja los eventos del BLoC
  void _handleBlocListener(BuildContext context, ProjectsState state) {
    if (state is ProjectAdded) {
      // MEJORADO: Pasar información del proyecto creado
      _handleSuccess(state.project);
    } else if (state is ProjectNameAlreadyExists) {
      _setError(state.message);
    } else if (state is ProjectFailure) {
      _handleError(state.message);
    }

    // Asegurar que el estado de carga se resetee
    if (state is! ProjectLoading && _isSubmitting) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

/// Extensión para validaciones adicionales específicas del proyecto
extension ProjectNameValidation on String {
  /// Valida que el nombre del proyecto sea apropiado
  bool get isValidProjectName {
    if (trim().isEmpty) return false;
    if (trim().length < 2) return false;
    if (trim().length > 100) return false;

    // No debe contener solo espacios o caracteres especiales
    if (trim().replaceAll(RegExp(r'[^a-zA-ZáéíóúüñÁÉÍÓÚÜÑ0-9\s]'), '').isEmpty) {
      return false;
    }

    return true;
  }

  /// Sanitiza el nombre del proyecto - MEJORADO para conservar ñ y acentos
  String get sanitizedProjectName {
    return trim()
        .replaceAll(RegExp(r'[<>"\\\/:*?|]'), '') // Solo remover caracteres realmente problemáticos
        .replaceAll(RegExp(r'\s+'), ' '); // Normalizar espacios múltiples
  }
}

/// Widget personalizado para mostrar consejos sobre nombres de proyecto
class ProjectNameTips extends StatelessWidget {
  const ProjectNameTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Consejos para el nombre',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Usa nombres descriptivos: "Casa García" en lugar de "Proyecto 1"',
            'Incluye la ubicación si es relevante: "Oficina Centro Lima"',
            'Puedes usar acentos y ñ: "Edificio Señor Hernández"',
            'Evita caracteres especiales como / \\ : * ? " < > |',
            'Mantén el nombre corto pero informativo',
          ].map((tip) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
        ],
      ),
    );
  }
}