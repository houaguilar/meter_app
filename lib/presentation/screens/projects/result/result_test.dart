import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/error_handler.dart';
import '../../../../domain/services/shared/UnifiedMaterialsCalculator.dart';
import '../../../assets/icons.dart';
import '../../../blocs/projects/metrados/result/result_bloc.dart';
import '../../../widgets/app_bar/app_bar_projects_widget.dart';
import 'components/result_screen_components.dart';

class ResultScreens extends StatefulWidget {
  final String metradoId;

  const ResultScreens({
    super.key,
    required this.metradoId,
  });

  @override
  State<ResultScreens> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreens>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  /// Carga los resultados del metrado
  void _loadResults() {
    if (!mounted) return;

    try {
      context.read<ResultBloc>().add(
        LoadResultsEvent(metradoId: widget.metradoId),
      );
    } catch (e) {
      _handleError('Error al cargar resultados: $e');
    }
  }

  /// Maneja errores de forma segura
  void _handleError(String message) {
    if (!mounted) return;

    ErrorHandler.showErrorSnackBar(
      context,
      message,
      onRetry: _loadResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: const AppBarProjectsWidget(
        titleAppBar: 'Resultados Guardados',
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ResultBloc, ResultState>(
          listener: _handleBlocListener,
          builder: _buildContent,
        ),
      ),
    );
  }

  /// Maneja los eventos del BLoC
  void _handleBlocListener(BuildContext context, ResultState state) {
    if (state is ResultFailure) {
      _handleError(state.message);
    }
  }

  /// Construye el contenido basado en el estado
  Widget _buildContent(BuildContext context, ResultState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _getWidgetForState(state),
    );
  }

  /// Retorna el widget apropiado para cada estado
  Widget _getWidgetForState(ResultState state) {
    switch (state.runtimeType) {
      case ResultLoading:
        return const LoadingIndicator(
          message: 'Cargando resultados guardados...',
        );

      case ResultSuccess:
        final successState = state as ResultSuccess;
        return _buildSuccessContent(successState.results);

      case ResultFailure:
        final failureState = state as ResultFailure;
        return ErrorDisplay(
          message: failureState.message,
          onRetry: _loadResults,
        );

      default:
        return const EmptyResultsMessage();
    }
  }

  /// Construye el contenido cuando hay resultados exitosos
  Widget _buildSuccessContent(List<dynamic> results) {
    if (results.isEmpty) {
      return const EmptyResultsMessage();
    }

    try {
      // Usar la calculadora unificada para procesar los resultados
      final calculationResult = UnifiedMaterialsCalculator.calculateMaterials(results);

      if (calculationResult.hasError) {
        return ErrorDisplay(
          message: calculationResult.errorMessage!,
          onRetry: _loadResults,
        );
      }

      return _buildResultContent(calculationResult);
    } catch (e) {
      return ErrorDisplay(
        message: 'Error al procesar resultados: $e',
        onRetry: _loadResults,
      );
    }
  }

  /// Construye el contenido principal de resultados
  Widget _buildResultContent(CalculationResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Icono de éxito
          SvgPicture.asset(
            AppIcons.checkmarkCircleIcon,
            height: 48,
          ),
          const SizedBox(height: 16),

          // Tipo de resultado
          ResultTypeHeader(type: result.type),

          // Detalles del metrado
          MetradoDetailsCard(result: result),

          // Lista de materiales
          MaterialsListCard(result: result),

          // Botones de acción
          ActionButtons(
            result: result,
            metradoId: widget.metradoId,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Extensión para validación de entrada
extension ResultScreenValidation on _ResultScreenState {

  /// Valida el ID del metrado
  bool _isValidMetradoId(String metradoId) {
    return metradoId.isNotEmpty && metradoId.trim().length > 0;
  }

  /// Valida los resultados recibidos
  bool _areValidResults(List<dynamic> results) {
    if (results.isEmpty) return false;

    // Verificar que todos los elementos sean del mismo tipo
    final firstType = results.first.runtimeType;
    return results.every((result) => result.runtimeType == firstType);
  }
}

/// Widget de error específico para ResultScreen
class ResultScreenError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const ResultScreenError({
    super.key,
    required this.message,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error en Resultados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onGoBack != null) ...[
                  OutlinedButton.icon(
                    onPressed: onGoBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mixin para logging de ResultScreen
mixin ResultScreenLogging {

  /// Registra eventos importantes
  void logEvent(String event, [Map<String, dynamic>? data]) {
    assert(() {
      debugPrint('🏗️ ResultScreen: $event');
      if (data != null) {
        debugPrint('   Data: $data');
      }
      return true;
    }());
  }

  /// Registra errores
  void logError(String error, [StackTrace? stackTrace]) {
    assert(() {
      debugPrint('❌ ResultScreen Error: $error');
      if (stackTrace != null) {
        debugPrint('   Stack: $stackTrace');
      }
      return true;
    }());
  }
}

/// Constantes específicas de ResultScreen
class ResultScreenConstants {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
  static const int maxRetries = 3;

  // Mensajes de error estándar
  static const String errorLoadingResults = 'Error al cargar los resultados';
  static const String errorEmptyResults = 'No hay resultados disponibles';
  static const String errorInvalidData = 'Los datos recibidos no son válidos';
  static const String errorCalculation = 'Error en el cálculo de materiales';

  // Títulos de secciones
  static const String titleMetradoData = 'Datos del Metrado';
  static const String titleMaterialsList = 'Lista de Materiales';
  static const String titleActions = 'Acciones';
}

/// Configuración específica para ResultScreen
class ResultScreenConfig {
  static const bool enablePdfGeneration = true;
  static const bool enableSharing = true;
  static const bool enableProviderSearch = false; // Funcionalidad en desarrollo
  static const bool enableAutoSave = false;

  static const List<String> supportedCalculationTypes = [
    'ladrillo',
    'piso',
    'losaAligerada',
    'tarrajeo',
    'columna',
    'viga',
  ];
}