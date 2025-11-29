
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/common/cubits/shimmer/loader_cubit.dart';
import 'package:meter_app/config/notifications/notification_handler.dart';
import 'package:meter_app/config/notifications/notification_repository.dart';
import 'package:meter_app/firebase_options.dart';
import 'package:meter_app/init_dependencies.dart';
import 'package:meter_app/presentation/blocs/home/inicio/article_bloc.dart';
import 'package:meter_app/presentation/blocs/home/inicio/measurement_bloc.dart';
import 'package:meter_app/presentation/blocs/map/locations_bloc.dart';
import 'package:meter_app/presentation/blocs/map/place/place_bloc.dart';
import 'package:meter_app/presentation/blocs/premium/premium_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/combined_results/combined_results_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/metrados_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/result/result_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/projects_bloc.dart';

import 'config/analytics/analytics_repository.dart';
import 'config/common/cubits/app_user/app_user_cubit.dart';
import 'config/config.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/map/products_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar dependencias
  await initDependencies();

  // Inicializar servicio de notificaciones
  final notificationService = serviceLocator<NotificationRepository>();
  await notificationService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // GlobalKey para el navigator
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  late final AuthBloc authBloc;
  late final ProjectsBloc projectsBloc;
  late final MetradosBloc metradosBloc;
  late final ResultBloc resultBloc;
  late final LocationsBloc locationsBloc;
  late final ArticleBloc articleBloc;
  late final MeasurementBloc measurementBloc;
  late final ProfileBloc profileBloc;
  late final PlaceBloc placeBloc;
  late final CombinedResultsBloc combinedResultsBloc;
  late final ProductsBloc productsBloc;
  late final CartBloc cartBloc;
  late final NotificationRepository notificationService;
  late GoRouter _appRouter;

  @override
  void initState() {
    super.initState();
    authBloc = serviceLocator<AuthBloc>();
    articleBloc = serviceLocator<ArticleBloc>();
    measurementBloc = serviceLocator<MeasurementBloc>();
    projectsBloc = serviceLocator<ProjectsBloc>();
    metradosBloc = serviceLocator<MetradosBloc>();
    resultBloc = serviceLocator<ResultBloc>();
    locationsBloc = serviceLocator<LocationsBloc>();
    profileBloc = serviceLocator<ProfileBloc>();
    placeBloc = serviceLocator<PlaceBloc>();
    combinedResultsBloc = serviceLocator<CombinedResultsBloc>();
    productsBloc = serviceLocator<ProductsBloc>();
    cartBloc = serviceLocator<CartBloc>();
    notificationService = serviceLocator<NotificationRepository>();

    // Configurar handlers de notificaciones
    _setupNotificationHandlers();
  }

  void _setupNotificationHandlers() {
    // Handler para notificaciones recibidas en foreground
    notificationService.onMessageReceived((notification) {
      debugPrint('🔔 Notification received in foreground');
      // Usar el context del root navigator
      final context = _getRootContext();
      if (context != null) {
        NotificationHandler.handleForegroundNotification(context, notification);
      }
    });

    // Handler para cuando el usuario toca una notificación
    notificationService.onMessageOpenedApp((notification) {
      debugPrint('📲 User tapped on notification');
      // Navegar a la pantalla correspondiente
      final context = _getRootContext();
      if (context != null) {
        NotificationHandler.handleNotificationTap(context, notification);
      }
    });
  }

  /// Obtiene el context del root navigator
  BuildContext? _getRootContext() {
    return _rootNavigatorKey.currentContext;
  }

  /// Maneja la notificación inicial cuando la app se abre desde una notificación
  Future<void> _handleInitialMessage() async {
    try {
      // Esperar un frame para que el widget esté completamente montado
      await Future.delayed(const Duration(milliseconds: 500));

      final initialMessage = await notificationService.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('📱 App opened from notification');
        debugPrint('Initial message: $initialMessage');

        final context = _getRootContext();
        if (context != null) {
          NotificationHandler.handleNotificationTap(context, initialMessage);
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling initial message: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authBloc.add(AuthIsUserLoggedIn());
    projectsBloc.add(LoadProjectsEvent());
    locationsBloc.add(LoadLocations());
    profileBloc.add(LoadProfile());

    // Manejar notificación inicial (si la app se abrió desde una notificación)
    _handleInitialMessage();
  }

  @override
  Widget build(BuildContext context) {

    _appRouter = AppRouter(
      authBloc,
      serviceLocator<AnalyticsRepository>(),
      rootNavigatorKey: _rootNavigatorKey,
    ).router;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<LoaderCubit>(),
        ),
        BlocProvider(
          create: (_) => authBloc,
        ),
        BlocProvider(
          create: (_) => profileBloc,
        ),
        BlocProvider(
          create: (_) => articleBloc,
        ),
        BlocProvider(
          create: (_) => measurementBloc,
        ),
        BlocProvider(
          create: (_) => projectsBloc,
        ),
        BlocProvider(
            create: (_) => metradosBloc,
        ),
        BlocProvider(
            create: (_) => resultBloc,
        ),
        BlocProvider(
            create: (_) => locationsBloc,
        ),
        BlocProvider(
            create: (_) => placeBloc,
        ),
        BlocProvider(
          create: (_) => combinedResultsBloc,
        ),
        BlocProvider(
          create: (context) => serviceLocator<PremiumBloc>()
            ..add(LoadPremiumStatus()),
        ),
        BlocProvider(
          create: (_) => productsBloc,
        ),
        BlocProvider(
          create: (_) => cartBloc,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Nuevo: Escuchar cambios de autenticación para limpiar perfil
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              final profileBloc = context.read<ProfileBloc>();

              if (state is AuthInitial) {
                // Usuario cerró sesión - limpiar perfil
                profileBloc.clearProfile();
              } else if (state is AuthSuccess) {
                // Usuario inició sesión - cargar nuevo perfil
                profileBloc.add(LoadProfile(forceReload: true));
              }
            },
          ),
        ],
        child: MaterialApp.router(
          title: 'METRASHOP',
          debugShowCheckedModeBanner: false,
          routerConfig: _appRouter,
          theme: AppTheme.light,
        ),
      ),
    );
  }
}
