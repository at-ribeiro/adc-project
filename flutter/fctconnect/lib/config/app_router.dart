import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/data/cache_factory_provider.dart';
import 'package:responsive_login_ui/views/edit_profile_page.dart';
import 'package:responsive_login_ui/views/event_view.dart';
import 'package:responsive_login_ui/views/loading_screen.dart';
import 'package:responsive_login_ui/views/login_view.dart';
import 'package:responsive_login_ui/views/my_home_page.dart';
import 'package:responsive_login_ui/views/my_profile.dart';
import 'package:responsive_login_ui/views/news_view.dart';
import 'package:responsive_login_ui/views/others_profile.dart';
import 'package:responsive_login_ui/views/post_page.dart';
import 'package:responsive_login_ui/views/report_view.dart';
import 'package:responsive_login_ui/views/reports_list_view.dart';
import 'package:responsive_login_ui/views/signUp_view.dart';
import 'package:responsive_login_ui/views/splash_secreen.dart';
import 'package:responsive_login_ui/widgets/nav_bar.dart';

import '../constants.dart';
import '../models/appbar_model.dart';
import '../models/drawer_model.dart';
import '../models/paths.dart';
import '../services/costum_search_delegate.dart';
import '../views/calendar_view.dart';
import '../views/event_creator.dart';
import '../views/event_page.dart';
import '../views/map_view.dart';
import '../views/reported_posts_view.dart';

class AppRouter {
  NavigationBarModel navigationBarModel = NavigationBarModel();
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
                path: Paths.homePage,
                builder: (BuildContext context, GoRouterState state) {
                  return const MyHomePage();
                },
              ),
              GoRoute(
                path: Paths.myProfile,
                builder: (BuildContext context, GoRouterState state) {
                  return const MyProfile();
                },
              ),
              GoRoute(
                path: Paths.otherProfile,
                builder: (BuildContext context, GoRouterState state) {
                  String? username = state.queryParameters['username']!;
                  return FutureBuilder<bool>(
                    future: isSessionUser(username),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
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
                path: Paths.noticias,
                builder: (BuildContext context, GoRouterState state) {
                  return const NewsView();
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
                path: Paths.report,
                builder: (BuildContext context, GoRouterState state) {
                  return ReportPage();
                },
              ),
            ],
            builder: (context, state, child) {
              return Scaffold(
                extendBody: true,
                bottomNavigationBar: navigationBarModel,
                body: child,
              );
            },
          ),
          GoRoute(
            path: Paths.mapas,
            builder: (BuildContext context, GoRouterState state) {
              return MapScreen();
            },
          ),
          GoRoute(
            path: Paths.editProfile,
            builder: (BuildContext context, GoRouterState state) {
              return EditProfile();
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
            path: Paths.event + "/:id",
            name: Paths.event,
            builder: (BuildContext context, GoRouterState state) {
              return EventPage(
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
        ],
        builder: (context, state, child) {
          return Scaffold(
            drawer: drawerModel,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
              elevation: 0,
              title: Text(
                _getTitleBasedOnRoute(state.location),
                style: TextStyle(color: kAccentColor0),
              ),
              actions: [
                _getButtonsBasedOnRoute(state.location, context),
              ],
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: kAccentColor0,
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
        path: Paths.splash,
        builder: (BuildContext context, GoRouterState state) {
          return Splash();
        },
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return FutureBuilder<dynamic>(
            future: CacheDefault.cacheFactory.get('isLoggedIn'),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                dynamic isLoggedInAsString = snapshot.data;

                if (isLoggedInAsString != null) {
                  bool isLoggedIn = isLoggedInAsString.toLowerCase() == 'true';
                  if (isLoggedIn) {
                    return Scaffold(
                      extendBody: true,
                      extendBodyBehindAppBar: true,
                      appBar: AppBar(
                        backgroundColor: kPrimaryColor,
                        elevation: 0,
                        title: Text(
                          _getTitleBasedOnRoute(state.location),
                          style: TextStyle(color: kAccentColor0),
                        ),
                        actions: [
                          _getButtonsBasedOnRoute(state.location, context),
                        ],
                        leading: Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: kAccentColor0,
                              ),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            );
                          },
                        ),
                      ),
                      bottomNavigationBar: navigationBarModel,
                      body: MyHomePage(),
                    );
                  } else {
                    return LoginView();
                  }
                } else {
                  return LoginView();
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
      ),
    ],
  );

  Future<bool> isSessionUser(String username) async {
    String? user = await CacheDefault.cacheFactory.get('Username');
    if (user == username) return true;
    return false;
  }

  String _getTitleBasedOnRoute(String location) {
    if (location == Paths.homePage || location == '/') {
      return 'Home';
    } else if (location == Paths.myProfile) {
      return 'Meu Perfil';
    } else if (location == Paths.noticias) {
      return 'Noticias';
    } else if (location == Paths.mapas) {
      return 'Mapa';
    } else if (location == Paths.events) {
      return 'Eventos';
    } else if (location == Paths.createEvent) {
      return 'Criar Evento';
    } else if (location == Paths.report) {
      return 'Reportar';
    } else if (location == Paths.calendar) {
      return 'Calendário';
    } else if (location == Paths.reportedPosts) {
      return 'Posts Reportados';
    }
    // add more conditions for other routes

    return ''; // fallback title
  }

  Widget _getButtonsBasedOnRoute(String location, BuildContext context) {
    if (location == Paths.homePage ||
        location == '/' ||
        location == Paths.myProfile ||
        location == Paths.noticias ||
        location == Paths.events) {
      return IconButton(
        onPressed: () {
          showSearch(
            context: context,
            delegate: CustomSearchDelegate("profile"),
          );
        },
        icon: Icon(Icons.search),
      );
    } else {
      return Container();
    }
    // add more conditions for other routes

    // return ''; // fallback title
  }
}
