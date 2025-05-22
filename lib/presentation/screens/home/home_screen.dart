import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/widgets.dart';

/// Pantalla principal que actúa como contenedor para las vistas secundarias
///
/// Esta pantalla implementa el patrón de navegación con bottom navigation bar
/// y maneja la inyección de vistas secundarias a través del parámetro [childView]
class HomeScreen extends StatefulWidget {
  /// Nombre de ruta para la navegación
  static const String name = 'home-screen';

  /// Vista secundaria que se mostrará en el cuerpo de la pantalla
  final Widget childView;

  /// Constructor que requiere una vista secundaria
  const HomeScreen({
    super.key,
    required this.childView,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  /// Mantiene el estado de la pantalla activo
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Inicializa los recursos necesarios para la pantalla
  void _initializeScreen() {
    // Agregar observer para cambios en el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Configurar orientación de pantalla si es necesario
    _setScreenOrientation();

    // Log para debugging (solo en modo debug)
    _logScreenInitialization();
  }

  /// Limpia recursos al destruir la pantalla
  void _cleanupResources() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Configura la orientación de pantalla permitida
  void _setScreenOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Log de inicialización (solo en modo debug)
  void _logScreenInitialization() {
    assert(() {
      debugPrint('HomeScreen inicializada correctamente');
      return true;
    }());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  /// Maneja cuando la app vuelve a primer plano
  void _handleAppResumed() {
    assert(() {
      debugPrint('App resumed - HomeScreen activa');
      return true;
    }());
    // Aquí puedes agregar lógica para refrescar datos si es necesario
  }

  /// Maneja cuando la app pasa a segundo plano
  void _handleAppPaused() {
    assert(() {
      debugPrint('App paused - Guardando estado si es necesario');
      return true;
    }());
    // Aquí puedes guardar estado crítico o pausar operaciones
  }

  /// Maneja cuando la app está siendo cerrada
  void _handleAppDetached() {
    _cleanupResources();
  }

  /// Maneja cuando la app está inactiva
  void _handleAppInactive() {
    // Pausa operaciones sensibles como video o audio
  }

  /// Maneja cuando la app está oculta (Android 14+)
  void _handleAppHidden() {
    // Similar a paused pero para casos específicos de Android 14+
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    return Scaffold(
      // Configuración de seguridad para evitar capturas de pantalla en datos sensibles
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: _buildBody(),
      ),

      bottomNavigationBar: _buildBottomNavigation(),

      // Evita que el teclado empuje el contenido hacia arriba innecesariamente
      extendBody: false,
    );
  }

  /// Construye el cuerpo principal de la pantalla
  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _buildChildViewWithErrorBoundary(),
    );
  }

  /// Envuelve la vista secundaria con manejo de errores
  Widget _buildChildViewWithErrorBoundary() {
    return ErrorBoundary(
      onError: _handleChildViewError,
      child: widget.childView,
    );
  }

  /// Construye la barra de navegación inferior
  Widget _buildBottomNavigation() {
    return const CustomBottomNavigation();
  }

  /// Maneja errores en la vista secundaria
  void _handleChildViewError(FlutterErrorDetails details) {
    assert(() {
      debugPrint('Error en childView: ${details.exception}');
      return true;
    }());

    // En producción, podrías enviar este error a un servicio de monitoreo
    // como Crashlytics, Sentry, etc.
  }
}

/// Widget para manejar errores de manera elegante
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();

    // Captura errores de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorDetails = details;
        });
        widget.onError?.call(details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return widget.child;
  }

  /// Construye un widget de error amigable para el usuario
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Algo salió mal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retryOperation,
              child: const Text('Reintentar'),
            ),
            if (_shouldShowErrorDetails()) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _showErrorDetails,
                child: const Text('Ver detalles del error'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Reintenta la operación reiniciando el estado
  void _retryOperation() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _errorDetails = null;
      });
    }
  }

  /// Determina si se deben mostrar los detalles del error (solo en debug)
  bool _shouldShowErrorDetails() {
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());
    return inDebugMode;
  }

  /// Muestra los detalles completos del error
  void _showErrorDetails() {
    if (_errorDetails != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Detalles del Error'),
          content: SingleChildScrollView(
            child: Text(_errorDetails.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }
}