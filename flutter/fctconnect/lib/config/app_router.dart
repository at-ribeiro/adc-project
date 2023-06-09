
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/data/cache_factory_provider.dart';
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
import 'package:responsive_login_ui/widgets/nav_bar.dart';

import '../models/paths.dart';
import '../views/event_page.dart';
import '../views/map_view.dart';

class AppRouter {
  NavigationBarModel navigationBarModel = NavigationBarModel();

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        routes: [
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return const MyHomePage();
            },
          ),
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
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == false) {
                      return OtherProfile(name: username);
                    } else  {
                      return MyProfile();
                    }
                  } else {
                    return CircularProgressIndicator(); // Show loading indicator while waiting for future to complete
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
            path: Paths.post +"/:id/:user",
            name: Paths.post,
            builder: (BuildContext context, GoRouterState state) {
              return PostPage(
                postID: state.pathParameters['id']!,
               postUser: state.pathParameters['user']!,
              );
            },
          ),
           GoRoute(
            path: Paths.events +"/:id",
            name: Paths.events,
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
            path: Paths.report,
            builder: (BuildContext context, GoRouterState state) {
              return ReportPage();
            },
          ),
           GoRoute(
            path: Paths.listReports,
            builder: (BuildContext context, GoRouterState state) {
              return ListReportsPage();
            },
          ),
          // Add other GoRoutes here for which you want the navigation bar to appear
        ],
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: navigationBarModel.build(context),
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
            path: Paths.mapas,
            builder: (BuildContext context, GoRouterState state) {
              return MapScreen();
            },
          ),
         
    ],
  );

  Future<bool> isSessionUser(String username) async {
    String? user = await CacheDefault.cacheFactory.get('Username');
    if (user == username) return true;
    return false;
  }
}
