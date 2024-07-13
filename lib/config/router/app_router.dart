import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/screens/auth/login/login_screen.dart';
import 'package:meter_app/presentation/screens/auth/register/register_screen.dart';
import 'package:meter_app/presentation/screens/home/muro/ladrillo/tutorial/tutorial_ladrillo_screen.dart';
import 'package:meter_app/presentation/screens/mapa/map_screen.dart';
import 'package:meter_app/presentation/screens/perfil/register_location_screen.dart';
import 'package:meter_app/presentation/screens/projects/result/results_screen.dart';
import 'package:meter_app/presentation/screens/save/save_result_screen.dart';
import 'package:meter_app/presentation/screens/screens.dart';
import 'package:meter_app/presentation/views/views.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/screens/projects/metrados/metrados_screen.dart';
import '../../presentation/screens/projects/new_project/new_project_screen.dart';


final GlobalKey<NavigatorState> _rootNavigator = GlobalKey(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigator = GlobalKey(debugLabel: 'shell');

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  GoRouter get router => GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigator,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthSuccess;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigator,
        builder: (context, state, child) {
          return HomeScreen(childView: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeView(),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'muro',
                name: 'muro',
                builder: (context, state) => const MuroScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'ladrillo',
                    name: 'ladrillo',
                    builder: (context, state) => const LadrilloScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'tutorial-ladrillo',
                        name: 'tutorial-ladrillo',
                        builder: (context, state) => const TutorialLadrilloScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'ladrillo1',
                            name: 'ladrillo1',
                            builder: (context, state) => const DatosLadrilloScreen(),
                            routes: [
                              GoRoute(
                                parentNavigatorKey: _rootNavigator,
                                path: 'ladrillo-results',
                                name: 'ladrillo_results',
                                builder: (context, state) => const ResultLadrilloScreen(),
                                routes: [
                                  GoRoute(
                                    parentNavigatorKey: _rootNavigator,
                                    path: 'ladrillo-pdf',
                                    name: 'ladrillo-pdf',
                                    builder: (context, state) => const PreviewScreen(),
                                  ),
                                  GoRoute(
                                    parentNavigatorKey: _rootNavigator,
                                    path: 'save-ladrillo',
                                    name: 'save-ladrillo',
                                    builder: (context, state) => const SaveResultScreen(),
                                    routes: [
                                      GoRoute(
                                        parentNavigatorKey: _rootNavigator,
                                        path: 'new-project-ladrillo',
                                        name: 'new-project-ladrillo',
                                        builder: (context, state) => const NewProjectScreen(),
                                      ),
                                    ]
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]
                      ),

                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'bloqueta',
                    name: 'bloqueta',
                    builder: (context, state) => const BloquetaScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'bloqueta1',
                        name: 'bloqueta1',
                        builder: (context, state) => const DatosBloquetaScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'bloqueta-results',
                            name: 'bloqueta_results',
                            builder: (context, state) => const ResultLadrilloScreen(),
                            routes: [
                              GoRoute(
                                parentNavigatorKey: _rootNavigator,
                                path: 'save-bloqueta',
                                name: 'save-bloqueta',
                                builder: (context, state) => const SaveResultScreen(),
                                routes: [
                                  GoRoute(
                                    parentNavigatorKey: _rootNavigator,
                                    path: 'new-project-bloqueta',
                                    name: 'new-project-bloqueta',
                                    builder: (context, state) => const NewProjectScreen(),
                                  ),
                                ]
                              ),
                              GoRoute(
                                parentNavigatorKey: _rootNavigator,
                                path: 'bloqueta-pdf',
                                name: 'bloqueta-pdf',
                                builder: (context, state) => const PreviewScreen(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                      parentNavigatorKey: _rootNavigator,
                      path: 'map-screen',
                      name: 'map-screen',
                      builder: (context, state) => const MapScreen()
                  )
                ],
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'columna',
                name: 'columna',
                builder: (context, state) => const ColumnaScreen(),
                routes: const [],
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'pisos',
                name: 'pisos',
                builder: (context, state) => const PisosScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'falso-piso',
                    name: 'falso-piso',
                    builder: (context, state) => const DatosPisosScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'contrapiso',
                    name: 'contrapiso',
                    builder: (context, state) => const DatosPisosScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'pisos_results',
                    name: 'pisos_results',
                    builder: (context, state) => const ResultPisosScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'save-piso',
                        name: 'save-piso',
                        builder: (context, state) => const SaveResultScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'new-project-piso',
                            name: 'new-project-piso',
                            builder: (context, state) => const NewProjectScreen(),
                          ),
                        ]
                      ),
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'pisos-pdf',
                        name: 'pisos-pdf',
                        builder: (context, state) => const PreviewPisosScreen(),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'losas',
                name: 'losas',
                builder: (context, state) => const LosasScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'losas-aligeradas',
                    name: 'losas-aligeradas',
                    builder: (context, state) => const DatosLosasAligeradasScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'losas-macizas',
                        name: 'losas-macizas',
                        builder: (context, state) => const DatosLosasMacizasScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'losas-vigas',
                            name: 'losas-vigas',
                            builder: (context, state) => const DatosVigasScreen(),
                            routes: [
                              GoRoute(
                                parentNavigatorKey: _rootNavigator,
                                path: 'losas-escaleras',
                                name: 'losas-escaleras',
                                builder: (context, state) => const DatosEscalerasScreen(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'new-project',
                name: 'new-project',
                builder: (context, state) => const NewProjectScreen(),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'projects/:projectId/:projectName',
                name: 'metrados',
                builder: (context, state) {
                  final int projectId = int.parse(state.pathParameters['projectId']!);
                  final projectName = state.pathParameters['projectName']!;
                  return MetradosScreen(projectId: projectId, projectName: projectName,);
                  },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'results/:metradoId',
                    name: 'results',
                    builder: (context, state) {
                      final String metradoId = state.pathParameters['metradoId']!;
                      return ResultsScreen(metradoId: metradoId);
                    },
                  ),
                ],
              ),
            ]
          ),
          GoRoute(
            path: '/mapa',
            name: 'mapa',
            builder: (context, state) => const MapaScreen(),
          ),
          GoRoute(
            path: '/perfil',
            name: 'perfil',
            builder: (context, state) => const PerfilScreen(),
            routes: [
              GoRoute(
                path: 'resultados',
                name: 'resultados',
                builder: (context, state) => const MapScreen(),
              ),
              GoRoute(
                path: 'register-location',
                name: 'register-location',
                builder: (context, state) => const RegisterLocationScreen(),
              ),
            ]
          ),
        ],
      ),
    ],
  );
}
