import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/data/cache_factory_provider.dart';
import 'package:responsive_login_ui/models/Token.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/views/edit_profile_page.dart';
import 'package:responsive_login_ui/views/edit_profile_password.dart';
import 'package:responsive_login_ui/views/event_view.dart';
import 'package:responsive_login_ui/views/forgot_pwd.dart';
import 'package:responsive_login_ui/views/forgot_pwd_code.dart';
import 'package:responsive_login_ui/views/login_view.dart';
import 'package:responsive_login_ui/views/my_home_page.dart';
import 'package:responsive_login_ui/views/my_profile.dart';
import 'package:responsive_login_ui/views/news_page.dart';
import 'package:responsive_login_ui/views/news_view.dart';
import 'package:responsive_login_ui/views/notification_screen.dart';
import 'package:responsive_login_ui/views/nucleo_page.dart';
import 'package:responsive_login_ui/views/nucleos_view.dart';
import 'package:responsive_login_ui/views/others_profile.dart';
import 'package:responsive_login_ui/views/pomodoro/pomodoro_page.dart';
import 'package:responsive_login_ui/views/post_creator.dart';
import 'package:responsive_login_ui/views/post_page.dart';
import 'package:responsive_login_ui/views/report_view.dart';
import 'package:responsive_login_ui/views/reports_list_view.dart';
import 'package:responsive_login_ui/views/routes_view.dart';
import 'package:responsive_login_ui/views/signUp_view.dart';
import 'package:responsive_login_ui/views/splash_secreen.dart';
import 'package:responsive_login_ui/views/welcome_screen.dart';
// import 'package:responsive_login_ui/views/welcome_screen.dart';
import 'package:responsive_login_ui/widgets/nav_bar.dart';
import 'package:responsive_login_ui/views/salas_view.dart';
import 'package:responsive_login_ui/views/buildings_view.dart';
import 'package:responsive_login_ui/views/sala_page.dart';

import '../constants.dart';
import '../models/drawer_model.dart';
import '../models/paths.dart';
import '../services/costum_search_delegate.dart';
import '../views/calendar_view.dart';
import '../views/edit_profile_options.dart';
import '../views/event_creator.dart';
import '../views/event_page.dart';
import '../views/evente_registration_page.dart';
import '../views/map_view.dart';
import '../views/nucleo_creator.dart';
import '../views/reported_posts_view.dart';
import '../views/route_creator.dart';
import '../views/routes_map.dart';
import '../views/sala_creator.dart';
import '../views/sala_page.dart';

import '../views/verify_account_view.dart';

class AppRouter {
  DrawerModel drawerModel = DrawerModel();

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        routes: [
          ShellRoute(
            navigatorKey: GlobalKey<NavigatorState>(),
            routes: [
              GoRoute(
                path: Paths.myProfile,
                builder: (BuildContext context, GoRouterState state) {
                  return const MyProfile();
                },
              ),
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return MyHomePage();
                },
              ),
              GoRoute(
                path: Paths.noticias,
                builder: (BuildContext context, GoRouterState state) {
                  return NewsView();
                },
              ),
              GoRoute(
                path: "/:noticias/:year/:month/:title",
                builder: (BuildContext context, GoRouterState state) {
                  return NewsDetailPage(
                    newsUrl: "/" +
                        state.pathParameters['noticias']! +
                        "/" +
                        state.pathParameters['year']! +
                        "/" +
                        state.pathParameters['month']! +
                        "/" +
                        state.pathParameters['title']!,
                  );
                },
              ),
            ],
            builder: (context, state, child) {
              return Scaffold(
                extendBody: true,
                bottomNavigationBar: NavigationBarModel(
                  location: state.location,
                ),
                body: child,
              );
            },
          ),
          GoRoute(
            path: Paths.createPost,
            builder: (BuildContext context, GoRouterState state) {
              return PostCreator();
            },
          ),
          GoRoute(
            path: Paths.mapas,
            builder: (BuildContext context, GoRouterState state) {
              return MapScreen();
            },
          ),
          GoRoute(
            path: Paths.calendar,
            builder: (BuildContext context, GoRouterState state) {
              return const CalendarView();
            },
          ),
          GoRoute(
            path: Paths.reportedPosts,
            builder: (BuildContext context, GoRouterState state) {
              return const ReportedPostsPage();
            },
          ),
          GoRoute(
            path: Paths.listReports,
            builder: (BuildContext context, GoRouterState state) {
              return ListReportsPage();
            },
          ),
          GoRoute(
            path: Paths.routes,
            builder: (BuildContext context, GoRouterState state) {
              return RouteView();
            },
          ),
          GoRoute(
            path: '/event/:id',
            builder: (BuildContext context, GoRouterState state) {
              return EventPage(
                eventId: state.pathParameters['id']!,
              );
            },
          ),
          GoRoute(
            path: '/event/qrcode/:id',
            builder: (BuildContext context, GoRouterState state) {
              return ConfirmationPage(
                eventId: state.pathParameters['id']!,
              );
            },
          ),
          GoRoute(
            path: Paths.events,
            builder: (BuildContext context, GoRouterState state) {
              return EventView();
            },
          ),
          GoRoute(
            path: Paths.createEvent,
            builder: (BuildContext context, GoRouterState state) {
              return EventCreator();
            },
          ),
          GoRoute(
            path: Paths.createRoute,
            builder: (BuildContext context, GoRouterState state) {
              return RouteCreator();
            },
          ),
          GoRoute(
            path: Paths.buildings,
            builder: (BuildContext context, GoRouterState state) {
              return BuildingView();
            },
          ),
          GoRoute(
            path: "${Paths.buildings}/:building",
            builder: (BuildContext context, GoRouterState state) {
              return SalaView(
                building: state.pathParameters["building"]!,
              );
            },
          ),
          GoRoute(
            path: "${Paths.buildings}/:building/:salaId",
            builder: (BuildContext context, GoRouterState state) {
              return SalaPage(
                salaId: state.pathParameters["salaId"]!,
              );
            },
          ),
          GoRoute(
            path: Paths.createSala,
            builder: (BuildContext context, GoRouterState state) {
              return SalaCreator();
            },
          ),
          GoRoute(
            path: Paths.editProfile,
            builder: (BuildContext context, GoRouterState state) {
              return EditProfile();
            },
          ),
          GoRoute(
            path: '/routes/:user/:id',
            builder: (BuildContext context, GoRouterState state) {
              return RouteMapScreen(
                routeUser: state.pathParameters['user']!,
                routeID: state.pathParameters['id']!,
              );
            },
          ),
          GoRoute(
            path: Paths.optionsProfile,
            builder: (BuildContext context, GoRouterState state) {
              return EditProfileOptions();
            },
          ),
          GoRoute(
            path: Paths.changePassword,
            builder: (BuildContext context, GoRouterState state) {
              return EditProfilePassword();
            },
          ),
          GoRoute(
            path: Paths.report,
            builder: (BuildContext context, GoRouterState state) {
              return ReportPage();
            },
          ),
          GoRoute(
            path: '${Paths.otherProfile}/:username',
            builder: (BuildContext context, GoRouterState state) {
              String? username = state.pathParameters['username'];
              return FutureBuilder<bool>(
                future: isSessionUser(username!),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == false) {
                      return OtherProfile(name: username);
                    } else {
                      return MyProfile();
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              );
            },
          ),
          GoRoute(
            path: Paths.post + "/:id/:user",
            name: Paths.post,
            builder: (BuildContext context, GoRouterState state) {
              return PostPage(
                postID: state.pathParameters['id']!,
                postUser: state.pathParameters['user']!,
              );
            },
          ),
          GoRoute(
            path: Paths.nucleos,
            builder: (BuildContext context, GoRouterState state) {
              return NucleosView();
            },
          ),
          GoRoute(
            path: Paths.criarNucleo,
            builder: (BuildContext context, GoRouterState state) {
              return NuceloCreator();
            },
          ),
          GoRoute(
            path: Paths.nucleos + "/:id",
            builder: (BuildContext context, GoRouterState state) {
              return NucleoPage(
                nucleoId: state.pathParameters['id']!,
              );
            },
          ),
          GoRoute(
            path: Paths.pomodoro,
            builder: (BuildContext context, GoRouterState state) {
              return PomodoroTimer();
            },
          ),
          GoRoute(
            path: Paths.notification + '/:messageBody',
            builder: (BuildContext context, GoRouterState state) {
              return NotificationScreen();
            },
          ),
        ],
        builder: (context, state, child) {
          return Scaffold(
            drawer: drawerModel,
            appBar: AppBar(
              elevation: 0,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _getTitleBasedOnRoute(state.location),
                ),
              ),
              actions: [
                _getButtonsBasedOnRoute(state.location, context),
              ],
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(
                      Icons.menu,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
            body: child,
          );
        },
      ),
      GoRoute(
        path: Paths.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginView();
        },
      ),
      GoRoute(
        path: Paths.signUp,
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpView();
        },
      ),
      GoRoute(
        path: Paths.forgotPwd,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordView();
        },
      ),
      GoRoute(
        path: "${Paths.verifyAccount}/:username",
        builder: (BuildContext context, GoRouterState state) {
          return VerifyAccountView(
            username: state.pathParameters['username']!,
          );
        },
      ),
      GoRoute(
        path: "${Paths.forgotPwdCode}/:query",
        builder: (BuildContext context, GoRouterState state) {
          return ForgotPwdCodeView(
            query: state.pathParameters['query']!,
          );
        },
      ),
      GoRoute(
        path: Paths.welcome,
        builder: (BuildContext context, GoRouterState state) {
          return WelcomeScreen();
        },
      ),
      GoRoute(
        path: Paths.splash,
        builder: (BuildContext context, GoRouterState state) {
          return Splash();
        },
      ),
    ],
  );

  Future<bool> isSessionUser(String username) async {
    String? user = await CacheDefault.cacheFactory.get('Username');
    if (user == username) return true;
    return false;
  }

  Future<bool> hasRoleTo() async {
    String? role = await CacheDefault.cacheFactory.get('Role');
    if (role == "AE" || role == "SECRETARIA" || role == "SA") return true;
    return false;
  }

  String _getTitleBasedOnRoute(String location) {
    CacheDefault.cacheFactory.set('LastLocation', location);
    if (location == Paths.homePage || location == '/') {
      return 'Home';
    } else if (location == Paths.myProfile) {
      return 'Meu Perfil';
    } else if (location == Paths.noticias || location.contains('noticias')) {
      return 'Notícias';
    } else if (location == Paths.mapas) {
      return 'Mapa';
    } else if (location == Paths.routes) {
      return 'Percursos';
    } else if (location == Paths.events) {
      return 'Eventos';
    } else if (location == Paths.createEvent) {
      return 'Criar Evento';
    } else if (location == Paths.createRoute) {
      return 'Criar Percurso';
    } else if (location == Paths.buildings) {
      return 'Edifícios';
    } else if (location == Paths.createSala) {
      return 'Criar Sala';
    } else if (location == Paths.report) {
      return 'Reportar';
    } else if (location == Paths.calendar) {
      return 'Calendário';
    } else if (location == Paths.reportedPosts) {
      return 'Posts Reportados';
    } else if (location == Paths.editProfile) {
      return 'Editar Perfil';
    } else if (location == Paths.listReports) {
      return 'Lista de Anomalias';
    } else if (location.contains(Paths.otherProfile)) {
      return 'Perfil';
    } else if (location.contains(Paths.event)) {
      return 'Evento';
    } else if (location.contains(Paths.buildings)) {
      return 'Edifício';
    } else if (location.contains(Paths.buildings)) {
      return 'Sala';
    } else if (location.contains(Paths.post)) {
    } else if (location == Paths.post) {
      return 'Comentários';
    } else if (location == Paths.nucleos) {
      return 'Núcleos';
    } else if (location == Paths.criarNucleo) {
      return 'Criar Núcleo';
    } else if (location == Paths.pomodoro) {
      return 'Pomodoro';
    } else if (location != Paths.nucleos && location.contains(Paths.nucleos)) {
      return 'Núcleo';
    } else if (location.contains(Paths.changePassword)) {
      return 'Mudar Password';
    } else if (location.contains(Paths.optionsProfile)) {
      return 'Opções de Perfil';
    } else if (location.contains(Paths.notification)) {
      return 'Notificação';
    } else if (location.contains(Paths.post) && location != Paths.post) {
      return 'Criar Post';
    }
    // add more conditions for other routes

    return ''; // fallback title
  }

  Widget _getButtonsBasedOnRoute(String location, BuildContext context) {
    if (location == Paths.homePage ||
        location == '/' ||
        location == Paths.noticias) {
      return IconButton(
        onPressed: () {
          showSearch(
            context: context,
            delegate: CustomSearchDelegate("profile"),
          );
        },
        icon: Icon(Icons.search),
      );
    } else if (location == Paths.myProfile) {
      return IconButton(
          onPressed: () {
            context.go(Paths.optionsProfile);
          },
          icon: Icon(Icons.settings));
    } else if (location == Paths.editProfile) {
      return IconButton(
          onPressed: () {
            context.go(Paths.optionsProfile);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location == Paths.changePassword) {
      return IconButton(
          onPressed: () {
            context.go(Paths.optionsProfile);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location == Paths.events) {
      return FutureBuilder<bool>(
        future: hasRoleTo(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == true) {
            return IconButton(
              onPressed: () {
                context.go(Paths.createEvent);
              },
              icon: Icon(Icons.add),
            );
          } else {
            return Container();
          }
        },
      );
    } else if (location == Paths.routes) {
      return IconButton(
          onPressed: () {
            context.go(Paths.createRoute);
          },
          icon: Icon(Icons.add));
    } else if (location == Paths.createSala) {
      return IconButton(
          onPressed: () {
            context.go(Paths.buildings);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location == Paths.createRoute) {
      return IconButton(
          onPressed: () {
            context.go(Paths.routes);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location == Paths.createEvent) {
      return IconButton(
          onPressed: () {
            context.go(Paths.events);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location.contains(Paths.buildings + "/")) {
      return IconButton(
          onPressed: () {
            context.go(Paths.buildings);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location.contains(Paths.otherProfile) ||
        location.contains(Paths.post)) {
      return IconButton(
          onPressed: () {
            context.go(Paths.homePage);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location.contains(Paths.nucleos) && location != Paths.nucleos) {
      return IconButton(
          onPressed: () {
            context.go(Paths.nucleos);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location.contains('noticias')) {
      return IconButton(
          onPressed: () {
            context.go(Paths.noticias);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location.contains(Paths.optionsProfile)) {
      return IconButton(
          onPressed: () {
            context.go(Paths.myProfile);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location.contains(Paths.notification)) {
      return IconButton(
          onPressed: () {
            context.go(Paths.homePage);
          },
          icon: Icon(Icons.arrow_back));
    } else if (location.contains(Paths.event)) {
      return IconButton(
          onPressed: () {
            context.go(Paths.events);
          },
          icon: Icon(Icons.home));
    }
    return Container();
  }
}
