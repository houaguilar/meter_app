
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/core/common/cubits/shimmer/loader_cubit.dart';
import 'package:meter_app/core/notifications/notification_handler.dart';
import 'package:meter_app/core/notifications/notification_repository.dart';
import 'package:meter_app/firebase_options.dart';
import 'package:meter_app/init_dependencies.dart';
import 'package:meter_app/features/inicio/presentation/blocs/article_bloc.dart';
import 'package:meter_app/features/inicio/presentation/blocs/measurement_bloc.dart';
import 'package:meter_app/features/mapa/presentation/blocs/locations_bloc.dart';
import 'package:meter_app/features/mapa/presentation/blocs/place/place_bloc.dart';
import 'package:meter_app/features/premium/presentation/blocs/premium_bloc.dart';
import 'package:meter_app/features/perfil/presentation/blocs/profile_bloc.dart';
import 'package:meter_app/features/projects/presentation/blocs/metrados/combined_results/combined_results_bloc.dart';
import 'package:meter_app/features/projects/presentation/blocs/metrados/metrados_bloc.dart';
import 'package:meter_app/features/projects/presentation/blocs/metrados/result/result_bloc.dart';
import 'package:meter_app/features/projects/presentation/blocs/projects_bloc.dart';

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:meter_app/core/analytics/analytics_repository.dart';
import 'package:meter_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:meter_app/core/config.dart';
import 'package:meter_app/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:meter_app/features/cart/presentation/blocs/cart_bloc.dart';
import 'package:meter_app/features/feedback/presentation/blocs/feedback_bloc.dart';
import 'package:meter_app/features/mapa/presentation/blocs/products_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Determinar ambiente: --dart-define=ENV=prod o ENV=dev (default: dev)
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  final envFile = environment == 'prod' ? '.env.prod' : '.env.dev';

  // Cargar variables de entorno segun el ambiente
  await dotenv.load(fileName: envFile);


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
  late final FeedbackBloc feedbackBloc;
  late final NotificationRepository notificationService;
  late final GoRouter _appRouter;
  StreamSubscription<supabase.AuthState>? _authStateSubscription;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    authBloc = serviceLocator<AuthBloc>();

    // Router creado una sola vez: evita perder el estado de navegación en rebuilds
    _appRouter = AppRouter(
      authBloc,
      serviceLocator<AnalyticsRepository>(),
      rootNavigatorKey: _rootNavigatorKey,
    ).router;

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
    feedbackBloc = serviceLocator<FeedbackBloc>();
    notificationService = serviceLocator<NotificationRepository>();

    // Configurar handlers de notificaciones
    _setupNotificationHandlers();

    // Escuchar el evento de recuperación de contraseña vía magic link
    _authStateSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == supabase.AuthChangeEvent.passwordRecovery) {
        final context = _getRootContext();
        if (context != null) {
          GoRouter.of(context).go('/new-password');
        }
      } else if (data.event == supabase.AuthChangeEvent.signedIn) {
        // Solo actúa si el AuthBloc no tiene sesión activa (ej: app abierta desde cero
        // por magic link y EmailVerificationScreen no está montada).
        // Evita llamadas redundantes cuando el login normal ya actualizó el estado.
        if (authBloc.state is! AuthSuccess) {
          authBloc.add(AuthIsUserLoggedIn());
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationHandlers() {
    // Handler para notificaciones recibidas en foreground
    notificationService.onMessageReceived((notification) {
      // Usar el context del root navigator
      final context = _getRootContext();
      if (context != null) {
        NotificationHandler.handleForegroundNotification(context, notification);
      }
    });

    // Handler para cuando el usuario toca una notificación
    notificationService.onMessageOpenedApp((notification) {
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

        final context = _getRootContext();
        if (context != null) {
          NotificationHandler.handleNotificationTap(context, initialMessage);
        }
      }
    } catch (e) {
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guardia para que los eventos de arranque se disparen una sola vez.
    // Los re-disparos por cambios de auth ya están cubiertos por
    // _authStateSubscription y el BlocListener<AuthBloc> en build().
    if (_initialized) return;
    _initialized = true;

    authBloc.add(AuthIsUserLoggedIn());
    // Perfil se carga en el BlocListener<AuthBloc> de build() cuando AuthSuccess se emite.
    // Projects se carga en ProjectsScreen.initState() al navegar — no cargar aquí (falla sin auth).
    // Locations se carga bajo demanda en la pantalla del mapa con LoadNearbyLocations.

    // Manejar notificación inicial (si la app se abrió desde una notificación)
    _handleInitialMessage();
  }

  @override
  Widget build(BuildContext context) {
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
        BlocProvider(
          create: (_) => feedbackBloc,
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
