
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/init_dependencies.dart';
import 'package:meter_app/presentation/blocs/map/locations_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/metrados_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/metrados/result/result_bloc.dart';
import 'package:meter_app/presentation/blocs/projects/projects_bloc.dart';
import 'package:meter_app/presentation/providers/providers.dart';

import 'config/common/cubits/app_user/app_user_cubit.dart';
import 'config/config.dart';
import 'presentation/blocs/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  @override
  void initState() {
    super.initState();
    authBloc = serviceLocator<AuthBloc>();
    projectsBloc = serviceLocator<ProjectsBloc>();
    metradosBloc = serviceLocator<MetradosBloc>();
    resultBloc = serviceLocator<ResultBloc>();
    locationsBloc = serviceLocator<LocationsBloc>();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authBloc.add(AuthIsUserLoggedIn());
    projectsBloc.add(LoadProjectsEvent());
    locationsBloc.add(LoadLocations());
  }

  @override
  Widget build(BuildContext context) {

    final appRouter = AppRouter(authBloc).router;
    final isDarkMode = ref.watch(darkModeProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => authBloc,
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
        BlocProvider(create: (_) => locationsBloc),
      ],
      child: MaterialApp.router(
        title: 'METRASHOP',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme( isDarkmode: isDarkMode ).getTheme(),
      ),
    );
  }
}
