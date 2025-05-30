import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/analytics/analytics_repository.dart';
import 'package:meter_app/config/analytics/analytics_route_observer.dart';
import 'package:meter_app/presentation/screens/articles/article_detail_screen.dart';
import 'package:meter_app/presentation/screens/auth/login/login_screen.dart';
import 'package:meter_app/presentation/screens/auth/register/register_screen.dart';
import 'package:meter_app/presentation/screens/auth/welcome/welcome_screen.dart';
import 'package:meter_app/presentation/screens/home/muro/ladrillo/datos_ladrillo/datos.dart';
import 'package:meter_app/presentation/screens/home/tarrajeo/datos/datos_tarrajeo_screen.dart';
import 'package:meter_app/presentation/screens/mapa/map_screen.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_settings_screen.dart';
import 'package:meter_app/presentation/screens/perfil/register_location/register_location_screen.dart';
import 'package:meter_app/presentation/screens/save/save_result_screen.dart';
import 'package:meter_app/presentation/screens/screens.dart';
import 'package:meter_app/presentation/views/views.dart';

import '../../data/local/shared_preferences_helper.dart';
import '../../init_dependencies.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/screens/auth/init/metra_shop_screen.dart';
import '../../presentation/screens/home/estructuras/data/datos_structural_elements_screen.dart';
import '../../presentation/screens/home/estructuras/result/result_structural_elements_screen.dart';
import '../../presentation/screens/home/estructuras/structural_element_screen.dart';
import '../../presentation/screens/home/losas/resultado/resultado_losas.dart';
import '../../presentation/screens/home/pisos/datos/datos_p.dart';
import '../../presentation/screens/home/tarrajeo/result/result_tarrajeo_screen.dart';
import '../../presentation/screens/perfil/info/profile_info_screen.dart';
import '../../presentation/screens/projects/metrados/metrados_screen.dart';
import '../../presentation/screens/projects/new_project/new_project_screen.dart';
import '../../presentation/screens/projects/result/result_screen.dart';


final GlobalKey<NavigatorState> _rootNavigator = GlobalKey(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigator = GlobalKey(debugLabel: 'shell');

class AppRouter {
  final AuthBloc authBloc;
 // final AnalyticsRepository analyticsRepository;

  AppRouter(this.authBloc);

  GoRouter get router => GoRouter(
    initialLocation: '/metrashop',
    navigatorKey: _rootNavigator,
   /* observers: [
      AnalyticsRouteObserver(analyticsRepository),
    ],*/
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthSuccess;
      final currentLocation = state.matchedLocation;
      final isLoggingIn = currentLocation == '/metrashop' ||
          currentLocation == '/login' ||
          currentLocation == '/register';
      final isLoading = authState is AuthLoading;

      final sharedPrefs = serviceLocator<SharedPreferencesHelper>();
      final isFirstTime = sharedPrefs.isFirstTimeUser();

      if (isLoading) {
        return null;
      }

      if (!isAuthenticated && !isLoggingIn) {
        return '/metrashop';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/welcome';
      }

      if (currentLocation == '/welcome' && !isFirstTime) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/metrashop',
        name: 'metrashop',
        builder: (context, state) => const MetraShopScreen(),
      ),
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

      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
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
                  path: 'home-to-provider',
                  name: 'home-to-provider',
                  builder: (context, state) => const MapScreen()
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'detail/:id/:title/:videoId',
                name: 'home-to-detail',
                builder: (context, state) {
                  final String id = state.pathParameters['id']!;
                  final String title = state.pathParameters['title']!;
                  final String video = state.pathParameters['videoId']!;
                  return ArticleDetailScreen(articleId: id, articleName: title, articleVideo: video,);
                },
              ),

              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'muro',
                name: 'muro',
                builder: (context, state) => const WallScreen(),
                routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'ladrillo1',
                            name: 'ladrillo1',
                            builder: (context, state) => const DatosLadrilloScreens(),
                            routes: [
                              GoRoute(
                                parentNavigatorKey: _rootNavigator,
                                path: 'ladrillo-results',
                                name: 'ladrillo_results',
                                builder: (context, state) => const ResultLadrilloScreen(),
                                routes: [
                                  GoRoute(
                                      parentNavigatorKey: _rootNavigator,
                                      path: 'map-screen-2',
                                      name: 'map-screen-2',
                                      builder: (context, state) => const MapScreen()
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
                ],
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'tarrajeo',
                name: 'tarrajeo',
                builder: (context, state) => const TarrajeoScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'tarrajeo-muro',
                    name: 'tarrajeo-muro',
                    builder: (context, state) => const DatosTarrajeoScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'tarrajeo_results',
                        name: 'tarrajeo_results',
                        builder: (context, state) => const ResultTarrajeoScreen(),
                        routes: [
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'map-screen-tarrajeo',
                              name: 'map-screen-tarrajeo',
                              builder: (context, state) => const MapScreen()
                          ),
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'save-tarrajeo',
                              name: 'save-tarrajeo',
                              builder: (context, state) => const SaveResultScreen(),
                              routes: [
                                GoRoute(
                                  parentNavigatorKey: _rootNavigator,
                                  path: 'new-project-tarrajeo',
                                  name: 'new-project-tarrajeo',
                                  builder: (context, state) => const NewProjectScreen(),
                                ),
                              ]
                          ),
                        ],
                      ),
                    ]
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'tarrajeo-cielorraso',
                    name: 'tarrajeo-cielorraso',
                    builder: (context, state) => const DatosTarrajeoScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'tarrajeo-solaqueo',
                    name: 'tarrajeo-solaqueo',
                    builder: (context, state) => const DatosTarrajeoScreen(),
                  ),
                ],
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
                    builder: (context, state) => const DatosPisosScreens(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'contrapiso',
                    name: 'contrapiso',
                    builder: (context, state) => const DatosPisosScreens(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'pisos_results',
                    name: 'pisos_results',
                    builder: (context, state) => const ResultPisosScreen(),
                    routes: [
                      GoRoute(
                          parentNavigatorKey: _rootNavigator,
                          path: 'map-screen-piso',
                          name: 'map-screen-piso',
                          builder: (context, state) => const MapScreen()
                      ),
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
                        path: 'losas-aligeradas-results',
                        name: 'losas-aligeradas-results',
                        builder: (context, state) => const ResultLosasScreen(),
                        routes: [
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'map-screen-losas',
                              name: 'map-screen-losas',
                              builder: (context, state) => const MapScreen()
                          ),
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'save-losas',
                              name: 'save-losas',
                              builder: (context, state) => const SaveResultScreen(),
                              routes: [
                                GoRoute(
                                  parentNavigatorKey: _rootNavigator,
                                  path: 'new-project-losas',
                                  name: 'new-project-losas',
                                  builder: (context, state) => const NewProjectScreen(),
                                ),
                              ]
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'structural-elements',
                name: 'structural-elements',
                builder: (context, state) => const StructuralElementScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'structural-element-datos',
                    name: 'structural-element-datos',
                    builder: (context, state) => const DatosStructuralElementsScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'structural-element-results',
                    name: 'structural-element-results',
                    builder: (context, state) => const ResultStructuralElementsScreen(),
                    routes: [
                      GoRoute(
                          parentNavigatorKey: _rootNavigator,
                          path: 'map-screen-structural',
                          name: 'map-screen-structural',
                          builder: (context, state) => const MapScreen()
                      ),
                      GoRoute(
                          parentNavigatorKey: _rootNavigator,
                          path: 'save-structural-element',
                          name: 'save-structural-element',
                          builder: (context, state) => const SaveResultScreen(),
                          routes: [
                            GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'new-project-structural',
                              name: 'new-project-structural',
                              builder: (context, state) => const NewProjectScreen(),
                            ),
                          ]
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
                      return ResultScreen(metradoId: metradoId);
                    },
                  ),
                ],
              ),
            ]
          ),
          GoRoute(
            path: '/articles',
            name: 'articles',
            builder: (context, state) => const ArticlesScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'detail/:id/:title/:videoId',
                name: 'detail',
                builder: (context, state) {
                  final String id = state.pathParameters['id']!;
                  final String title = state.pathParameters['title']!;
                  final String video = state.pathParameters['videoId']!;
                  return ArticleDetailScreen(articleId: id, articleName: title, articleVideo: video,);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/perfil',
            name: 'perfil',
            builder: (context, state) => const PerfilScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'profile-info',
                name: 'profile-info',
                builder: (context, state) => const ProfileInfoScreen(),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'resultados',
                name: 'resultados',
                builder: (context, state) => const MapScreen(),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'register-location',
                name: 'register-location',
                builder: (context, state) => const RegisterLocationScreen(),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'profile-settings',
                name: 'profile-settings',
                builder: (context, state) => const ProfileSettingsScreen(),
              ),
            ]
          ),
        ],
      ),
    ],
  );
}
