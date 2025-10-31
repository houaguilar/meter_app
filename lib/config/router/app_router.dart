import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/screens/articles/article_detail_screen.dart';
import 'package:meter_app/presentation/screens/auth/login/login_screen.dart';
import 'package:meter_app/presentation/screens/auth/register/register_screen.dart';
import 'package:meter_app/presentation/screens/auth/welcome/welcome_screen.dart';
import 'package:meter_app/presentation/screens/home/acero/columna/datos/datos_steel_column_screen.dart';
import 'package:meter_app/presentation/screens/home/acero/columna/result/result_steel_column_screen.dart';
import 'package:meter_app/presentation/screens/home/acero/losa_maciza/datos/datos_steel_slab_screen.dart';
import 'package:meter_app/presentation/screens/home/acero/losa_maciza/result/result_steel_slab_screen.dart';
import 'package:meter_app/presentation/screens/home/acero/steel_main_screen.dart';
import 'package:meter_app/presentation/screens/home/acero/zapata/datos/datos_steel_footing_screen.dart';
import 'package:meter_app/presentation/screens/home/acero/zapata/result/result_steel_footing_screen.dart';
import 'package:meter_app/presentation/screens/home/muro/ladrillo/custom_brick_config_screen.dart';
import 'package:meter_app/presentation/screens/home/pisos/falso_piso/datos/datos_falso_piso_screen.dart';
import 'package:meter_app/presentation/screens/home/pisos/falso_piso/result/result_falso_piso_screen.dart';
import 'package:meter_app/presentation/screens/home/tarrajeo/datos/datos_tarrajeo_screen.dart';
import 'package:meter_app/presentation/screens/home/tarrajeo/derrame/datos/datos_tarrajeo_derrame_screen.dart';
import 'package:meter_app/presentation/screens/home/tarrajeo/derrame/result/result_tarrajeo_derrame_screen.dart';
import 'package:meter_app/presentation/screens/mapa/products/category_selector_screen.dart';
import 'package:meter_app/presentation/screens/mapa/products/brand_configurator_screen.dart';
import 'package:meter_app/presentation/screens/mapa/optimized_map_screen.dart';
import 'package:meter_app/presentation/screens/mapa/profile/provider_profile_screen.dart';
import 'package:meter_app/presentation/screens/perfil/notificaciones/notifications_settings_screen.dart';
import 'package:meter_app/presentation/screens/perfil/profile_settings/profile_settings_screen.dart';
import 'package:meter_app/presentation/screens/perfil/register_location/register_location_screen.dart';
import 'package:meter_app/presentation/screens/save/save_result_screen.dart';
import 'package:meter_app/presentation/screens/screens.dart';
import 'package:meter_app/presentation/views/views.dart';

import '../../data/local/shared_preferences_helper.dart';
import '../../init_dependencies.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/screens/auth/init/metra_shop_screen.dart';
import '../analytics/analytics_repository.dart';
import '../analytics/analytics_route_observer.dart';
import '../../presentation/screens/home/acero/viga/datos/datos_steel_beam_screen.dart';
import '../../presentation/screens/home/acero/viga/result/result_steel_beam_screen.dart';
import '../../presentation/screens/home/estructuras/data/datos_structural_elements_screen.dart';
import '../../presentation/screens/home/estructuras/result/result_structural_elements_screen.dart';
import '../../presentation/screens/home/estructuras/structural_element_screen.dart';
import '../../presentation/screens/home/losas/resultado/result_losas_screen.dart';
import '../../presentation/screens/home/muro/ladrillo/datos_ladrillo/datos_ladrillo_screen.dart';
import '../../presentation/screens/home/pisos/contrapiso/datos/datos_contrapiso_screen.dart';
import '../../presentation/screens/home/tarrajeo/result/result_tarrajeo_screen.dart';
import '../../presentation/screens/perfil/info/profile_info_screen.dart';
import '../../presentation/screens/projects/combined/combined_results_screen.dart';
import '../../presentation/screens/projects/metrados/metrados_screen.dart';
import '../../presentation/screens/projects/new_project/new_project_screen.dart';
import '../../presentation/screens/projects/result/result_screen.dart';


class AppRouter {
  final AuthBloc authBloc;
  final AnalyticsRepository analyticsRepository;

  // GlobalKeys as instance variables to prevent conflicts during hot reload
  final GlobalKey<NavigatorState> _rootNavigator = GlobalKey(debugLabel: 'root');
  final GlobalKey<NavigatorState> _shellNavigator = GlobalKey(debugLabel: 'shell');

  AppRouter(this.authBloc, this.analyticsRepository);

  GoRouter get router => GoRouter(
    initialLocation: '/metrashop',
    navigatorKey: _rootNavigator,
    observers: [
      AnalyticsRouteObserver(analyticsRepository),
    ],
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
                  builder: (context, state) => const OptimizedMapScreen(),
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
                    path: 'custom-brick-config',
                    name: 'custom-brick-config',
                    builder: (context, state) => const CustomBrickConfigScreen(),
                  ),
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
                                      path: 'map-screen-2',
                                      name: 'map-screen-2',
                                      builder: (context, state) => const OptimizedMapScreen(),
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
                              builder: (context, state) => const OptimizedMapScreen(),
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
                      path: 'tarrajeo-derrame',
                      name: 'tarrajeo-derrame',
                      builder: (context, state) => const DatosTarrajeoDerrameScreen(),
                      routes: [
                        GoRoute(
                          parentNavigatorKey: _rootNavigator,
                          path: 'tarrajeo-derrame-results',
                          name: 'tarrajeo-derrame-results',
                          builder: (context, state) => const ResultTarrajeoDerrameScreen(),
                          routes: [
                            GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'map-screen-tarrajeo-derrame',
                              name: 'map-screen-tarrajeo-derrame',
                              builder: (context, state) => const OptimizedMapScreen(),
                            ),
                            GoRoute(
                                parentNavigatorKey: _rootNavigator,
                                path: 'save-tarrajeo-derrame',
                                name: 'save-tarrajeo-derrame',
                                builder: (context, state) => const SaveResultScreen(),
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
                    builder: (context, state) => const DatosFalsoPisoScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'falso-pisos-results',
                        name: 'falso-pisos-results',
                        builder: (context, state) => const ResultFalsoPisoScreen(),
                        routes: [
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'falso-piso-map-screen',
                              name: 'falso-piso-map-screen',
                              builder: (context, state) => const OptimizedMapScreen(),
                          ),
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'falso-piso-save',
                              name: 'falso-piso-save',
                              builder: (context, state) => const SaveResultScreen(),
                              routes: [
                                GoRoute(
                                  parentNavigatorKey: _rootNavigator,
                                  path: 'new-project-falso-piso',
                                  name: 'new-project-falso-piso',
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
                    path: 'contrapiso',
                    name: 'contrapiso',
                    builder: (context, state) => const DatosContrapisoScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'contrapiso-result',
                        name: 'contrapiso-result',
                        builder: (context, state) => const ResultContrapisoScreen(),
                        routes: [
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'contrapiso-map-screen',
                              name: 'contrapiso-map-screen',
                              builder: (context, state) => const OptimizedMapScreen(),
                          ),
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'contrapiso-save',
                              name: 'contrapiso-save',
                              builder: (context, state) => const SaveResultScreen(),
                              routes: [
                                GoRoute(
                                  parentNavigatorKey: _rootNavigator,
                                  path: 'new-project-contrapiso',
                                  name: 'new-project-contrapiso',
                                  builder: (context, state) => const NewProjectScreen(),
                                ),
                              ]
                          ),
                        ],
                      ),
                    ]
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
                              builder: (context, state) => const OptimizedMapScreen(),
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
                          builder: (context, state) => const OptimizedMapScreen(),
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
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'steel',
                name: 'steel',
                builder: (context, state) => const SteelMainScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'steel-beam',
                    name: 'steel-beam',
                    builder: (context, state) => const DatosSteelBeamScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'steel-beam-results',
                        name: 'steel-beam-results',
                        builder: (context, state) => const ResultSteelBeamScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'map-screen-steel-beam',
                            name: 'map-screen-steel-beam',
                            builder: (context, state) => const OptimizedMapScreen(),
                          ),
                          GoRoute(
                              parentNavigatorKey: _rootNavigator,
                              path: 'save-steel-beam',
                              name: 'save-steel-beam',
                              builder: (context, state) => const SaveResultScreen(),
                          ),
                        ],
                      )
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'steel-column',
                    name: 'steel-column',
                    builder: (context, state) => const DatosSteelColumnScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'steel-column-results',
                        name: 'steel-column-results',
                        builder: (context, state) => const ResultSteelColumnScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'map-screen-steel-column',
                            name: 'map-screen-steel-column',
                            builder: (context, state) => const OptimizedMapScreen(),
                          ),
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'save-steel-column',
                            name: 'save-steel-column',
                            builder: (context, state) => const SaveResultScreen(),
                          ),
                        ],
                      )
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'steel-footing',
                    name: 'steel-footing',
                    builder: (context, state) => const DatosSteelFootingScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'steel-footing-results',
                        name: 'steel-footing-results',
                        builder: (context, state) => const ResultSteelFootingScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'map-screen-steel-footing',
                            name: 'map-screen-steel-footing',
                            builder: (context, state) => const OptimizedMapScreen(),
                          ),
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'save-steel-footing',
                            name: 'save-steel-footing',
                            builder: (context, state) => const SaveResultScreen(),
                          ),
                        ],
                      )
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'steel-slab',
                    name: 'steel-slab',
                    builder: (context, state) => const DatosSteelSlabScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigator,
                        path: 'steel-slab-results',
                        name: 'steel-slab-results',
                        builder: (context, state) => const ResultSteelSlabScreen(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'map-screen-steel-slab',
                            name: 'map-screen-steel-slab',
                            builder: (context, state) => const OptimizedMapScreen(),
                          ),
                          GoRoute(
                            parentNavigatorKey: _rootNavigator,
                            path: 'save-steel-slab',
                            name: 'save-steel-slab',
                            builder: (context, state) => const SaveResultScreen(),
                          ),
                        ],
                      )
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
                  // En tu GoRouter:
                  GoRoute(
                    path: 'combined-results/:projectId',
                    name: 'combined-results',
                    builder: (context, state) {
                      final projectId = int.parse(state.pathParameters['projectId']!);
                      final extra = state.extra as Map<String, dynamic>;
                      return CombinedResultsScreen(
                        projectId: projectId,
                        selectedMetradoIds: List<int>.from(extra['selectedMetrados']),
                        projectName: extra['projectName'],
                      );
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
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'notifications-settings',
                name: 'notifications-settings',
                builder: (context, state) => const NotificationsSettingsScreen(),
              ),
              // Rutas de marketplace/mapa
              GoRoute(
                parentNavigatorKey: _rootNavigator,
                path: 'provider-profile/:locationId',
                name: 'provider-profile',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return ProviderProfileScreen(
                    location: extra['location'],
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'configure-products',
                    name: 'configure-products',
                    builder: (context, state) {
                      final locationId = state.pathParameters['locationId']!;
                      return CategorySelectorScreen(locationId: locationId);
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigator,
                    path: 'brand-configurator/:categoryId',
                    name: 'brand-configurator',
                    builder: (context, state) {
                      final locationId = state.pathParameters['locationId']!;
                      final categoryId = state.pathParameters['categoryId']!;
                      return BrandConfiguratorScreen(
                        locationId: locationId,
                        categoryId: categoryId,
                      );
                    },
                  ),
                ],
              ),
            ]
          ),
        ],
      ),
    ],
  );
}
