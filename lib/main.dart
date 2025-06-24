
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/config/common/cubits/shimmer/loader_cubit.dart';
import 'package:meter_app/init_dependencies.dart';
import 'package:meter_app/presentation/blocs/home/inicio/article_bloc.dart';
import 'package:meter_app/presentation/blocs/home/inicio/measurement_bloc.dart';
import 'package:meter_app/presentation/blocs/map/locations_bloc.dart';
import 'package:meter_app/presentation/blocs/map/place/place_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/combined_results/combined_results_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/metrados_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/result/result_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/projects_bloc.dart';

import 'config/analytics/analytics_repository.dart';
import 'config/common/cubits/app_user/app_user_cubit.dart';
import 'config/config.dart';
import 'presentation/blocs/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // await Firebase.initializeApp();
  await initDependencies();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authBloc.add(AuthIsUserLoggedIn());
    projectsBloc.add(LoadProjectsEvent());
    locationsBloc.add(LoadLocations());
    profileBloc.add(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {

    final appRouter = AppRouter(
      authBloc
    //  serviceLocator<AnalyticsRepository>(),
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
          routerConfig: appRouter,
          theme: AppTheme.light,
        ),
      ),
    );
  }
}
