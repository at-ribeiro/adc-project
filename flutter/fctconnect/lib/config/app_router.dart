import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/views/loading_screen.dart';
import 'package:responsive_login_ui/views/login_view.dart';
import 'package:responsive_login_ui/views/my_home_page.dart';
import 'package:responsive_login_ui/views/my_profile.dart';
import 'package:responsive_login_ui/views/signUp_view.dart';

import '../models/paths.dart';

class AppRouter {
// final loginCubit;

// AppRouter(this.loginCubit);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginView();
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
      // GoRoute(path: '/loading', builder: (BuildContext context, GoRouterState state){ return const LoadingScreen();},
      // ),
    ],
// redirect: (BuildContext context,GoRouterState state) {

//   //check if is loggedin
//   // final bool loggingIn = state.subloc == '/login';

//   final bool loggedIn = false;

//   if(!loggedIn){
//     return loggingIn ? null : '/login';
//   }
//   if(loggingIn){
//     return '/';
//   }
//   return null;

// },
  );
}
